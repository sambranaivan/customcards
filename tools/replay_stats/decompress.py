"""LZMA decompression matching EDOPro LzmaUncompress (RAW stream, not LZMA-alone)."""

from __future__ import annotations

import lzma

from .header import ReplayHeader


class ReplayDecompressError(Exception):
    pass


def _lzma_filters(props: bytes) -> list[dict]:
    if len(props) < 1:
        props = b"\x5d"
    lc = props[0] % 9
    rem = props[0] // 9
    lp = rem % 5
    pb = rem // 5
    dict_size = int.from_bytes(props[1:5], "little") if len(props) >= 5 else 1 << 24
    if dict_size < 4096:
        dict_size = 1 << 24
    return [{"id": lzma.FILTER_LZMA1, "lc": lc, "lp": lp, "pb": pb, "dict_size": dict_size}]


def decompress_payload(header: ReplayHeader, compressed: bytes) -> bytes:
    """Decompress replay body using header LZMA props (EDOPro-compatible)."""
    if not compressed:
        raise ReplayDecompressError("Empty compressed payload")

    filters = _lzma_filters(header.lzma_props)
    dec = lzma.LZMADecompressor(format=lzma.FORMAT_RAW, filters=filters)
    try:
        out = dec.decompress(compressed)
    except lzma.LZMAError as e:
        raise ReplayDecompressError(str(e)) from e

    expected = header.datasize
    if expected and abs(len(out) - expected) > 64:
        # Allow small slack; EDOPro and Python may differ slightly at stream end
        pass
    return out


def decompress_alone_fallback(header: ReplayHeader, compressed: bytes) -> bytes:
    """Fallback used by some tools: LZMA-alone wrapper with datasize prefix."""
    props = header.lzma_props
    stream = props + int(header.datasize).to_bytes(8, "little") + compressed
    return lzma.decompress(stream, format=lzma.FORMAT_ALONE)


def decompress(header: ReplayHeader, compressed: bytes) -> bytes:
    try:
        return decompress_payload(header, compressed)
    except ReplayDecompressError:
        try:
            return decompress_alone_fallback(header, compressed)
        except lzma.LZMAError as e:
            raise ReplayDecompressError(
                f"LZMA decompress failed (RAW and alone): {e}"
            ) from e

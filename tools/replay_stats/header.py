"""Parse EDOPro ExtendedReplayHeader from .yrp / .yrpX files."""

from __future__ import annotations

import struct
from dataclasses import dataclass
from pathlib import Path

from .constants import (
    REPLAY_EXTENDED_HEADER,
    REPLAY_YRP1,
    REPLAY_YRPX,
)


@dataclass(frozen=True)
class ReplayHeader:
    replay_id: int
    version: int
    flag: int
    timestamp: int
    datasize: int
    hash_value: int
    props: bytes  # 8 bytes in file; first 5 used for LZMA
    header_version: int = 0
    seed: tuple[int, int, int, int] = (0, 0, 0, 0)

    @property
    def magic(self) -> str:
        return struct.pack("<I", self.replay_id).decode("ascii", errors="replace")

    @property
    def is_yrpx(self) -> bool:
        return self.replay_id == REPLAY_YRPX

    @property
    def is_yrp1(self) -> bool:
        return self.replay_id == REPLAY_YRP1

    @property
    def has_extended_header(self) -> bool:
        return bool(self.flag & REPLAY_EXTENDED_HEADER)

    @property
    def header_size(self) -> int:
        return 72 if self.has_extended_header else 32

    @property
    def lzma_props(self) -> bytes:
        return self.props[:5]


def parse_header(data: bytes) -> ReplayHeader:
    if len(data) < 32:
        raise ValueError("File too small for replay header")

    replay_id, version, flag, timestamp, datasize, hash_value = struct.unpack_from("<6I", data, 0)
    props = data[24:32]

    if replay_id not in (REPLAY_YRP1, REPLAY_YRPX):
        magic = struct.pack("<I", replay_id)
        raise ValueError(f"Invalid replay id {magic!r} (0x{replay_id:08x})")

    header_version = 0
    seed = (0, 0, 0, 0)
    if flag & REPLAY_EXTENDED_HEADER:
        if len(data) < 72:
            raise ValueError("File too small for extended replay header")
        header_version = struct.unpack_from("<Q", data, 32)[0]
        seed = struct.unpack_from("<4Q", data, 40)

    return ReplayHeader(
        replay_id=replay_id,
        version=version,
        flag=flag,
        timestamp=timestamp,
        datasize=datasize,
        hash_value=hash_value,
        props=props,
        header_version=header_version,
        seed=seed,
    )


def read_replay_file(path: Path | str) -> tuple[ReplayHeader, bytes]:
    path = Path(path)
    raw = path.read_bytes()
    header = parse_header(raw)
    payload = raw[header.header_size :]
    return header, payload

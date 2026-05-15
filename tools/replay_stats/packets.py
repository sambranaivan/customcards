"""Parse decompressed replay body: player names, duel params, packet stream."""

from __future__ import annotations

import struct
from dataclasses import dataclass, field

from .constants import (
    OLD_REPLAY_MODE,
    REPLAY_64BIT_DUELFLAG,
    REPLAY_NEWREPLAY,
    REPLAY_SINGLE_MODE,
    REPLAY_TAG,
    REPLAY_YRP1,
)
from .header import ReplayHeader


@dataclass
class Packet:
    index: int
    message: int
    data: bytes

    @property
    def name(self) -> str:
        from .constants import MSG_NAMES

        return MSG_NAMES.get(self.message, f"MSG_{self.message}")


@dataclass
class ReplayDeck:
    main: list[int] = field(default_factory=list)
    extra: list[int] = field(default_factory=list)


@dataclass
class DuelParams:
    start_lp: int = 0
    start_hand: int = 0
    draw_count: int = 0
    duel_flags: int = 0


@dataclass
class ParsedReplayBody:
    players: list[str]
    home_count: int
    opposing_count: int
    params: DuelParams
    packets: list[Packet]
    embedded_yrp1_buffer: bytes | None = None
  # first OLD_REPLAY_MODE payload


def _decode_name(buf: bytes) -> str:
    if len(buf) < 40:
        return ""
    chars = struct.unpack_from("<20H", buf, 0)
    out: list[str] = []
    for c in chars:
        if c == 0:
            break
        out.append(chr(c))
    return "".join(out)


def _read_u32(data: bytes, offset: int) -> tuple[int, int]:
    return struct.unpack_from("<I", data, offset)[0], offset + 4


def parse_names(data: bytes, offset: int, flag: int) -> tuple[list[str], int, int, int]:
    players: list[str] = []
    if flag & REPLAY_SINGLE_MODE:
        players.append(_decode_name(data[offset : offset + 40]))
        offset += 40
        players.append(_decode_name(data[offset : offset + 40]))
        offset += 40
        return players, 1, 1, offset

    def read_side() -> tuple[int, int]:
        nonlocal offset
        if flag & REPLAY_NEWREPLAY:
            count, offset = _read_u32(data, offset)
        elif flag & REPLAY_TAG:
            count = 2
        else:
            count = 1
        for _ in range(count):
            players.append(_decode_name(data[offset : offset + 40]))
            offset += 40
        return count, offset

    home_count, offset = read_side()
    opposing_count, offset = read_side()
    return players, home_count, opposing_count, offset


def parse_params(
    data: bytes, offset: int, flag: int, replay_id: int
) -> tuple[DuelParams, int]:
    params = DuelParams()
    if replay_id == REPLAY_YRP1:
        params.start_lp, offset = _read_u32(data, offset)
        params.start_hand, offset = _read_u32(data, offset)
        params.draw_count, offset = _read_u32(data, offset)

    if flag & REPLAY_64BIT_DUELFLAG:
        params.duel_flags = struct.unpack_from("<Q", data, offset)[0]
        offset += 8
    else:
        params.duel_flags, offset = _read_u32(data, offset)

    if (flag & REPLAY_SINGLE_MODE) and replay_id == REPLAY_YRP1:
        slen = struct.unpack_from("<H", data, offset)[0]
        offset += 2 + slen

    return params, offset


def iter_packets(data: bytes, offset: int) -> list[Packet]:
    packets: list[Packet] = []
    idx = 0
    while offset + 5 <= len(data):
        msg = data[offset]
        offset += 1
        if msg == 0:
            break
        pkt_len, offset = _read_u32(data, offset)
        if pkt_len > 100_000 or offset + pkt_len > len(data):
            break
        payload = data[offset : offset + pkt_len]
        offset += pkt_len
        packets.append(Packet(index=idx, message=msg, data=payload))
        idx += 1
    return packets


def parse_yrp1_responses(data: bytes, offset: int) -> list[Packet]:
    """Legacy yrp1: decks then [len u8][response bytes]..."""
    packets: list[Packet] = []
    idx = 0
    # Skip decks: handled by caller if needed
    while offset < len(data):
        if offset >= len(data):
            break
        length = data[offset]
        offset += 1
        if length == 0:
            break
        if offset + length > len(data):
            break
        payload = data[offset : offset + length]
        offset += length
        packets.append(Packet(index=idx, message=0, data=payload))
        idx += 1
    return packets


def parse_body(header: ReplayHeader, decompressed: bytes) -> ParsedReplayBody:
    flag = header.flag
    offset = 0
    players, home_count, opposing_count, offset = parse_names(decompressed, offset, flag)
    params, offset = parse_params(decompressed, offset, flag, header.replay_id)

    embedded: bytes | None = None
    if header.is_yrp1:
        packets = []
        # yrp1 deck section then responses
        player_count = (2 if flag & REPLAY_TAG else 2) if not (flag & REPLAY_SINGLE_MODE) else 0
        if not (flag & REPLAY_SINGLE_MODE):
            for _ in range(player_count):
                main, offset = _read_u32(decompressed, offset)
                offset += main * 4
                extra, offset = _read_u32(decompressed, offset)
                offset += extra * 4
        packets = parse_yrp1_responses(decompressed, offset)
    else:
        packets = iter_packets(decompressed, offset)
        for p in packets:
            if p.message == OLD_REPLAY_MODE and embedded is None:
                embedded = p.data

    return ParsedReplayBody(
        players=players,
        home_count=home_count,
        opposing_count=opposing_count,
        params=params,
        packets=packets,
        embedded_yrp1_buffer=embedded,
    )

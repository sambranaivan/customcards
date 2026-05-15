"""Extract deck lists from OLD_REPLAY_MODE (231) embedded yrp1 buffer."""

from __future__ import annotations

import struct

from .constants import (
    REPLAY_64BIT_DUELFLAG,
    REPLAY_HAND_TEST,
    REPLAY_NEWREPLAY,
    REPLAY_SINGLE_MODE,
    REPLAY_TAG,
    REPLAY_YRP1,
)
from .packets import ReplayDeck, parse_names, parse_params


def _read_u32(data: bytes, offset: int) -> tuple[int, int]:
    return struct.unpack_from("<I", data, offset)[0], offset + 4


def parse_embedded_yrp1(buffer: bytes) -> tuple[list[str], list[ReplayDeck], int]:
    """Parse nested yrp1 buffer inside yrpX OLD_REPLAY_MODE packet."""
    if len(buffer) < 32:
        return [], [], 0

    replay_id = struct.unpack_from("<I", buffer, 0)[0]
    if replay_id != REPLAY_YRP1:
        return [], [], 0

    flag = struct.unpack_from("<I", buffer, 8)[0]
    header_size = 72 if (flag & 0x200) else 32
    offset = header_size

    players, home_count, opposing_count, offset = parse_names(buffer, offset, flag)
    params, offset = parse_params(buffer, offset, flag, REPLAY_YRP1)

    decks: list[ReplayDeck] = []
    if flag & REPLAY_SINGLE_MODE and not (flag & REPLAY_HAND_TEST):
        return players, decks, params.duel_flags

    total_players = home_count + opposing_count
    for _ in range(total_players):
        deck = ReplayDeck()
        main, offset = _read_u32(buffer, offset)
        if main and offset + main * 4 <= len(buffer):
            deck.main = list(struct.unpack_from(f"<{main}I", buffer, offset))
            offset += main * 4
        extra, offset = _read_u32(buffer, offset)
        if extra and offset + extra * 4 <= len(buffer):
            deck.extra = list(struct.unpack_from(f"<{extra}I", buffer, offset))
            offset += extra * 4
        decks.append(deck)

    return players, decks, params.duel_flags

"""Lightweight duel summary: winner, play-by-play, final LP and field."""

from __future__ import annotations

import struct
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

from .cdb_lookup import CardLookup
from .constants import (
    MSG_ATTACK,
    MSG_BATTLE,
    MSG_CHAIN_NEGATED,
    MSG_CHAINING,
    MSG_DAMAGE,
    MSG_DRAW,
    MSG_FLIPSUMMONED,
    MSG_HINT,
    MSG_LPUPDATE,
    MSG_MOVE,
    MSG_NEW_PHASE,
    MSG_NEW_TURN,
    MSG_PAY_LPCOST,
    MSG_POS_CHANGE,
    MSG_RECOVER,
    MSG_SET,
    MSG_SPSUMMONED,
    MSG_SUMMONED,
    MSG_WIN,
    HINT_CARD,
    PHASE_BATTLE,
    PHASE_BATTLE_START,
    PHASE_DRAW,
    PHASE_END,
    PHASE_MAIN1,
    PHASE_MAIN2,
    PHASE_STANDBY,
)
from .decompress import ReplayDecompressError, decompress
from .header import read_replay_file
from .packets import ParsedReplayBody, parse_body

LOCATION_HAND = 0x02
LOCATION_MZONE = 0x04
LOCATION_SZONE = 0x08
LOCATION_GRAVE = 0x10
LOCATION_REMOVED = 0x20
LOCATION_DECK = 0x01
LOCATION_EXTRA = 0x40

# Order matters for multi-bit values (pick the latest phase in the turn).
_PHASE_LABEL_ORDER: tuple[tuple[int, str], ...] = (
    (PHASE_END, "End Phase"),
    (PHASE_MAIN2, "Main Phase 2"),
    (PHASE_BATTLE, "Battle Phase"),
    (PHASE_BATTLE_START, "Battle Phase"),
    (PHASE_MAIN1, "Main Phase 1"),
    (PHASE_STANDBY, "Standby Phase"),
    (PHASE_DRAW, "Draw Phase"),
)


def _read_phase(data: bytes) -> int:
    """MSG_NEW_PHASE carries the phase as uint16 little-endian (ocgapi bitflags)."""
    if len(data) >= 2:
        return struct.unpack_from("<H", data, 0)[0]
    if data:
        return data[0]
    return 0


def _phase_label(phase: int) -> str | None:
    for mask, name in _PHASE_LABEL_ORDER:
        if phase & mask:
            return name
    return None

# EDOPro victory types — config/strings.conf (!victory 0xN)
WIN_REASONS = {
    0: "won (opponent surrendered)",
    1: "won (opponent reached 0 LP)",
    2: "won (opponent decked out)",
    3: "won (opponent lost on time)",
    4: "won (opponent disconnected)",
}


@dataclass
class CardOnField:
    code: int
    name: str
    zone: str
    position: str = "unknown"


@dataclass
class DuelState:
    lp: list[int] = field(default_factory=lambda: [8000, 8000])
    field: dict[tuple[int, int, int], CardOnField] = field(default_factory=dict)
    current_turn: int = 0
    current_phase: int = 0
    active_player: int = 0


def _zone_label(loc: int, seq: int) -> str:
    # EDOPro uses location 0 for hand/private cards in MSG_MOVE (not LOCATION_HAND).
    if loc == 0:
        return "Hand"
    if loc == LOCATION_MZONE:
        return f"Monster Zone {seq + 1}"
    if loc == LOCATION_SZONE:
        return f"Spell/Trap Zone {seq + 1}"
    if loc == LOCATION_HAND:
        return "Hand"
    if loc == LOCATION_GRAVE:
        return "Graveyard"
    if loc == LOCATION_REMOVED:
        return "Banished"
    if loc == LOCATION_DECK:
        return "Deck"
    if loc == LOCATION_EXTRA:
        return "Extra Deck"
    return f"Location 0x{loc:x}"


def _pos_label(pos: int) -> str:
    if pos in (1, 0x1):
        return "Attack Position"
    if pos in (2, 4, 0x2, 0x4):
        return "Defense Position"
    if pos in (8, 0x8):
        return "Face-down"
    return ""


def _display_names(raw: list[str]) -> list[str]:
    """Unique labels for each side (replays may repeat the same AI name)."""
    cleaned = [n.strip() if n else "" for n in raw]
    if len(cleaned) >= 2 and cleaned[0] and cleaned[0] == cleaned[1]:
        return ["Player 1", "Player 2"]
    out: list[str] = []
    for i, n in enumerate(cleaned[:2] if cleaned else []):
        out.append(n if n else f"Player {i + 1}")
    while len(out) < 2:
        out.append(f"Player {len(out) + 1}")
    return out


def _player_label(player: int, names: list[str]) -> str:
    if player < len(names):
        return names[player]
    return f"Player {player + 1}"


def _read_loc_info(data: bytes, offset: int) -> tuple[int, int, int, int]:
    """EDOPro CoreUtils::loc_info — controller, location, sequence (u32), position (u32)."""
    if offset + 10 > len(data):
        return 0, 0, 0, 0
    controller = data[offset]
    location = data[offset + 1]
    sequence = struct.unpack_from("<I", data, offset + 2)[0]
    position = struct.unpack_from("<I", data, offset + 6)[0]
    return controller, location, sequence, position


def _read_move_locs(data: bytes) -> tuple[tuple[int, int, int, int], tuple[int, int, int, int]]:
    """MSG_MOVE: code(4) + previous loc_info(10) + current loc_info(10) + reason(4)."""
    return _read_loc_info(data, 4), _read_loc_info(data, 14)


def _parse_move(state: DuelState, data: bytes, lookup: CardLookup) -> str | None:
    if len(data) < 24:  # full MSG_MOVE is 28 bytes
        return None
    code = struct.unpack_from("<I", data, 0)[0]
    (fp, floc, fseq, fpos), (tp, tloc, tseq, tpos) = _read_move_locs(data)
    name = lookup.name(code)
    from_z = _zone_label(floc, fseq)
    to_z = _zone_label(tloc, tseq)
    pos_txt = _pos_label(tpos) or _pos_label(fpos)

    key_from = (fp, floc, fseq)
    key_to = (tp, tloc, tseq)
    if floc in (LOCATION_MZONE, LOCATION_SZONE) and key_from in state.field:
        del state.field[key_from]
    if tloc in (LOCATION_MZONE, LOCATION_SZONE):
        state.field[key_to] = CardOnField(
            code=code, name=name, zone=to_z, position=pos_txt or "?"
        )
    elif tloc in (0, LOCATION_GRAVE, LOCATION_REMOVED, LOCATION_HAND, LOCATION_DECK):
        if key_to in state.field:
            del state.field[key_to]

    if floc in (0, LOCATION_HAND) and tloc == LOCATION_MZONE:
        return f"Normal Summoned {name} ({pos_txt}) to {to_z}"
    if floc in (LOCATION_MZONE, LOCATION_SZONE) and tloc in (LOCATION_GRAVE, LOCATION_REMOVED):
        return f"Sent {name} from {from_z} to {to_z}"
    if floc in (LOCATION_MZONE, LOCATION_SZONE) and tloc in (LOCATION_MZONE, LOCATION_SZONE):
        return f"Moved {name} from {from_z} to {to_z}"
    if tloc == LOCATION_SZONE and floc in (0, LOCATION_HAND):
        return f"Set {name} in {to_z}"
    return f"Moved {name} from {from_z} to {to_z}"


def _field_snapshot(state: DuelState) -> dict[str, list[dict[str, str]]]:
    out: dict[str, list[dict[str, str]]] = {"0": [], "1": []}
    for (pl, loc, seq), card in sorted(state.field.items()):
        if loc not in (LOCATION_MZONE, LOCATION_SZONE):
            continue
        key = str(pl)
        out.setdefault(key, []).append(
            {
                "zone": card.zone,
                "card": card.name,
                "position": card.position,
            }
        )
    return out


def summarize_duel(
    body: ParsedReplayBody,
    lookup: CardLookup,
    *,
    source: str = "",
) -> dict[str, Any]:
    names = _display_names(body.players or [])
    start = body.params.start_lp or 8000
    state = DuelState(lp=[start, start])
    plays: list[str] = []
    winner_text: str | None = None
    win_reason: int | None = None

    for pkt in body.packets:
        m, d = pkt.message, pkt.data
        pl_label = lambda p: _player_label(p, names)

        if m == MSG_NEW_TURN and d:
            state.current_turn += 1
            state.active_player = d[0]
            plays.append(
                f"Turn {state.current_turn} — {pl_label(d[0])} begins their turn."
            )
        elif m == MSG_NEW_PHASE and d:
            phase = _read_phase(d)
            state.current_phase = phase
            label = _phase_label(phase)
            if label:
                plays.append(
                    f"Turn {state.current_turn} — {label} ({pl_label(state.active_player)})."
                )
        elif m == MSG_DRAW and len(d) >= 2:
            plays.append(
                f"Turn {state.current_turn} — {pl_label(d[0])} draws {d[1]} card(s)."
            )
        elif m == MSG_SUMMONED and len(d) >= 4:
            code = struct.unpack_from("<I", d, 0)[0]
            plays.append(
                f"Turn {state.current_turn} — {pl_label(state.active_player)} "
                f"successfully Summoned {lookup.name(code)}."
            )
        elif m == MSG_SPSUMMONED and len(d) >= 4:
            code = struct.unpack_from("<I", d, 0)[0]
            plays.append(
                f"Turn {state.current_turn} — {pl_label(state.active_player)} "
                f"Special Summoned {lookup.name(code)}."
            )
        elif m == MSG_FLIPSUMMONED and len(d) >= 4:
            code = struct.unpack_from("<I", d, 0)[0]
            plays.append(
                f"Turn {state.current_turn} — {pl_label(state.active_player)} "
                f"Flip Summoned {lookup.name(code)}."
            )
        elif m == MSG_MOVE:
            desc = _parse_move(state, d, lookup)
            if desc:
                plays.append(
                    f"Turn {state.current_turn} — {pl_label(state.active_player)}: {desc}."
                )
        elif m == MSG_SET and len(d) >= 4:
            code = struct.unpack_from("<I", d, 0)[0]
            plays.append(
                f"Turn {state.current_turn} — {pl_label(state.active_player)} "
                f"Set {lookup.name(code)}."
            )
        elif m == MSG_POS_CHANGE and len(d) >= 8:
            code = struct.unpack_from("<I", d, 0)[0]
            plays.append(
                f"Turn {state.current_turn} — {lookup.name(code)} changed battle position."
            )
        elif m == MSG_ATTACK and d:
            plays.append(
                f"Turn {state.current_turn} — {pl_label(d[0])} declares an attack."
            )
        elif m == MSG_DAMAGE and len(d) >= 5:
            pl = d[0]
            amt = struct.unpack_from("<i", d, 1)[0]
            state.lp[pl] = max(0, state.lp[pl] - amt)
            plays.append(
                f"Turn {state.current_turn} — {pl_label(pl)} takes {amt} damage "
                f"(LP: {state.lp[pl]})."
            )
        elif m == MSG_RECOVER and len(d) >= 5:
            pl = d[0]
            amt = struct.unpack_from("<i", d, 1)[0]
            state.lp[pl] += amt
            plays.append(
                f"Turn {state.current_turn} — {pl_label(pl)} recovers {amt} LP "
                f"(LP: {state.lp[pl]})."
            )
        elif m == MSG_PAY_LPCOST and len(d) >= 5:
            pl = d[0]
            amt = struct.unpack_from("<i", d, 1)[0]
            state.lp[pl] = max(0, state.lp[pl] - amt)
            plays.append(
                f"Turn {state.current_turn} — {pl_label(pl)} pays {amt} LP "
                f"(LP: {state.lp[pl]})."
            )
        elif m == MSG_LPUPDATE and len(d) >= 5:
            pl = d[0]
            state.lp[pl] = struct.unpack_from("<i", d, 1)[0]
        elif m == MSG_CHAINING and len(d) >= 4:
            code = struct.unpack_from("<I", d, 0)[0]
            plays.append(
                f"Turn {state.current_turn} — Chain: {pl_label(state.active_player)} "
                f"activates {lookup.name(code)}."
            )
        elif m == MSG_CHAIN_NEGATED:
            plays.append(f"Turn {state.current_turn} — A chain link was negated.")
        elif m == MSG_HINT and len(d) >= 5 and d[0] == HINT_CARD:
            code = struct.unpack_from("<I", d, 1)[0]
            # Skip routine hints to avoid noise
            pass
        elif m == MSG_WIN and len(d) >= 2:
            win_reason = d[1]
            winner_pl = d[0]
            reason = WIN_REASONS.get(win_reason, f"won (reason code {win_reason})")
            winner_text = f"{pl_label(winner_pl)} {reason}."

    if winner_text is None and win_reason is None:
        for pkt in reversed(body.packets):
            if pkt.message == MSG_WIN and len(pkt.data) >= 2:
                winner_pl = pkt.data[0]
                reason = WIN_REASONS.get(pkt.data[1], "won the duel")
                winner_text = f"{pl_label(winner_pl)} {reason}."
                break

    return {
        "source": source,
        "status": "ok",
        "winner": winner_text or "Winner could not be determined.",
        "players": names,
        "plays": plays,
        "final": {
            "life_points": [
                {"side": 0, "name": names[0], "lp": state.lp[0]},
                {"side": 1, "name": names[1], "lp": state.lp[1]},
            ],
            "field": [
                {"side": 0, "name": names[0], "cards": _field_snapshot(state)["0"]},
                {"side": 1, "name": names[1], "cards": _field_snapshot(state)["1"]},
            ],
        },
    }


def analyze_replay(
    path: Path | str,
    *,
    cdb_path: Path | str | None = None,
    **_: Any,
) -> dict[str, Any]:
    """Parse replay and return a compact duel summary (no heavy event dump)."""
    path = Path(path)
    try:
        with CardLookup(cdb_path) as lookup:
            header, compressed = read_replay_file(path)
            body = parse_body(header, decompress(header, compressed))
            return summarize_duel(body, lookup, source=str(path.resolve()))
    except (ReplayDecompressError, ValueError, struct.error) as e:
        return {
            "source": str(path),
            "status": "error",
            "error": str(e),
        }

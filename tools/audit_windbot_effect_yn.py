#!/usr/bin/env python3
"""Cross-check deck cards with TRIGGER effects vs WindBot executor activate patterns."""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCRIPT_DIR = ROOT / "script" / "unofficial"
DECKS = {
    "Bronze": ROOT / "WindBot" / "Decks" / "AI_SaintSeiyaBronzeOnly.ydk",
    "BlackSaints": ROOT / "WindBot" / "Decks" / "AI_SaintSeiyaBlackSaints.ydk",
}
EXECUTORS = {
    "Bronze": ROOT
    / "WindBot"
    / "Executors"
    / "SaintSeiyaBronzeOnlyExecutor"
    / "SaintSeiyaBronzeOnlyExecutor.cs",
    "BlackSaints": ROOT
    / "WindBot"
    / "Executors"
    / "SaintSeiyaBlackSaintsExecutor"
    / "SaintSeiyaBlackSaintsExecutor.cs",
}

SUMMON_CODES = {"EVENT_SUMMON_SUCCESS", "EVENT_SPSUMMON_SUCCESS"}
FIELD_CODES = {"EVENT_TO_GRAVE", "EVENT_BATTLE_DESTROYED", "EVENT_LEAVE_FIELD"}


def load_deck_ids(path: Path) -> list[int]:
    ids: list[int] = []
    in_main = False
    for line in path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if line == "#main":
            in_main = True
            continue
        if line.startswith("#") or not line:
            if line.startswith("#extra"):
                in_main = False
            continue
        if in_main and line.isdigit():
            ids.append(int(line))
    return sorted(set(ids))


def parse_lua_triggers(card_id: int) -> list[dict]:
    path = SCRIPT_DIR / f"c{card_id}.lua"
    if not path.exists():
        return []
    text = path.read_text(encoding="utf-8", errors="replace")
    blocks = re.split(r"local e\d+\w*=Effect\.CreateEffect", text)
    out: list[dict] = []
    for block in blocks[1:]:
        m_desc = re.search(r"SetDescription\(aux\.Stringid\(id,(\d+)\)\)", block)
        if not m_desc:
            continue
        si = int(m_desc.group(1))
        is_trigger = "TRIGGER_O" in block or "TRIGGER_F" in block
        if not is_trigger:
            continue
        codes = set(re.findall(r"SetCode\((EVENT_[A-Z0-9_]+)\)", block))
        rng = re.search(r"SetRange\(([^)]+)\)", block)
        location = rng.group(1) if rng else "?"
        kind = "summon" if codes & SUMMON_CODES else "field" if codes & FIELD_CODES else "other"
        out.append(
            {
                "string_index": si,
                "codes": sorted(codes),
                "location": location,
                "kind": kind,
            }
        )
    return out


def executor_covers(card_id: int, string_index: int, kind: str, exe_text: str) -> str:
    cid = str(card_id)
    if cid not in exe_text:
        return "no_card_ref"
    if kind == "summon":
        if f"IsOnSummonOptionalTriggerDesc" in exe_text and (
            f"{cid}, {string_index}" in exe_text
            or f"{cid},{string_index}" in exe_text
        ):
            return "summon_helper"
        if f"MatchesCardEffectDescOrTrigger" in exe_text:
            return "or_trigger_only"
        return "check_manual"
    if kind == "field":
        if "IsFieldSpellOptionalTriggerDesc" in exe_text or "IsMonsterZoneOptionalTriggerDesc" in exe_text:
            return "field_helper_maybe"
        if f"MatchesCardEffectDescOrTrigger" in exe_text:
            return "or_trigger_only"
        return "check_manual"
    return "check_manual"


def main() -> int:
    any_risk = False
    for deck_name, deck_path in DECKS.items():
        exe_path = EXECUTORS[deck_name]
        exe_text = exe_path.read_text(encoding="utf-8", errors="replace")
        print(f"\n=== {deck_name} ({deck_path.name}) ===\n")
        for cid in load_deck_ids(deck_path):
            triggers = parse_lua_triggers(cid)
            if not triggers:
                continue
            name_m = re.search(
                rf"-- ID: {cid}\s*\n[^\n]*\n[^\n]*\n[^\n]*\n[^\n]*\n[^\n]*\n--\s*([^\n]+)",
                (SCRIPT_DIR / f"c{cid}.lua").read_text(encoding="utf-8", errors="replace")
                if (SCRIPT_DIR / f"c{cid}.lua").exists()
                else "",
            )
            label = name_m.group(1).strip() if name_m else f"c{cid}"
            for tr in triggers:
                cov = executor_covers(cid, tr["string_index"], tr["kind"], exe_text)
                risk = cov in ("or_trigger_only", "check_manual", "no_card_ref")
                if risk:
                    any_risk = True
                flag = "RISK" if risk else "ok"
                print(
                    f"  [{flag}] {cid} {label} | str{tr['string_index']+1} (Stringid {tr['string_index']}) "
                    f"| {tr['kind']} | {','.join(tr['codes']) or 'no_code'} | {cov}"
                )
    return 1 if any_risk else 0


if __name__ == "__main__":
    sys.exit(main())

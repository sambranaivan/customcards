"""
Rewrite `-- Archetypes:` blocks in script/unofficial/c922100*.lua from
`expansions/saint-seiya.cdb` datas.setcode (LSB-first 16-bit segments).

Skips files whose archetype block contains '(no archetype' (hand-maintained).
"""
from __future__ import annotations

import re
import sqlite3
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CDB = ROOT / "expansions" / "saint-seiya.cdb"
SCRIPTS = ROOT / "script" / "unofficial"

# Header labels (match common existing Lua style; insert_saint_172_302 ARCH_TO_SET keys where applicable)
SEGMENT_TO_LINE: dict[int, str] = {
    0x1D7: "saint",
    0x1D8: "cloth",
    0x1D9: "Bronze Saint",
    0x1DA: "Silver Saint",
    0x1DB: "Gold Saint",
    0x1DC: "Gold Cloth",
    0x1DD: "Envoy of the Pope",
    0x1DE: "Pope's Mandate",
    0x1DF: "Ghost Saint",
    0x1E0: "Steel Saint",
    0x1E1: "Black Saint",
    0x1E2: "Fragment of Sagittarius",
    0x1E3: "God Warrior",
    0x1E4: "Poseidon",
    0x1E5: "Marine General",
    0x1E6: "Pillar",
    0x1E7: "Hades",
    0x1E8: "Specter",
    0x1E9: "Renegade Saint",
    0x1EA: "Meta",
    0x1EB: "Silver Cloth",
    0x1EC: "Bronze Cloth",
}


def segments_from_setcode(setcode: int) -> list[int]:
    out: list[int] = []
    s = setcode
    while s:
        out.append(s & 0xFFFF)
        s >>= 16
    return out


def archetypes_block_lines(setcode: int) -> list[str]:
    segs = segments_from_setcode(setcode)
    lines: list[str] = ["-- Archetypes:"]
    if not segs:
        lines.append("-- (setcode 0 — not in a named ProjectIgnis archetype series)")
        return lines
    for seg in segs:
        label = SEGMENT_TO_LINE.get(seg)
        if label is None:
            lines.append(f"-- - (unknown setcode 0x{seg:04x})")
        else:
            lines.append(f"-- - {label}")
    return lines


def replace_archetypes(script: str, new_block_lines: list[str]) -> str:
    new_block = "\n".join(new_block_lines)
    pattern = re.compile(
        r"(^--\s*Archetypes\s*:\s*\n)(?:^--[^\n]*\n)*?(?=^--\s*Effect\s*\(EN\)\s*:\s*$)",
        flags=re.MULTILINE,
    )
    m = pattern.search(script)
    if not m:
        raise ValueError("could not find Archetypes / Effect (EN) region")
    return script[: m.start()] + new_block + "\n" + script[m.end() :]


def main() -> None:
    sys.stdout.reconfigure(encoding="utf-8")
    conn = sqlite3.connect(str(CDB))
    cur = conn.cursor()
    rows = dict(
        cur.execute(
            "SELECT id, setcode FROM datas WHERE id BETWEEN 922100000 AND 922100302"
        ).fetchall()
    )
    conn.close()

    updated = 0
    skipped = 0
    for cid in range(922100000, 922100303):
        path = SCRIPTS / f"c{cid}.lua"
        if not path.is_file():
            continue
        text = path.read_text(encoding="utf-8", errors="replace")
        if "(no archetype" in text:
            skipped += 1
            continue
        if "-- Archetypes:" not in text:
            skipped += 1
            continue
        sc = rows.get(cid, 0)
        try:
            new_text = replace_archetypes(text, archetypes_block_lines(sc))
        except ValueError:
            skipped += 1
            continue
        if new_text != text:
            path.write_text(new_text, encoding="utf-8", newline="\n")
            updated += 1

    print(f"updated: {updated}, skipped: {skipped}")


if __name__ == "__main__":
    main()

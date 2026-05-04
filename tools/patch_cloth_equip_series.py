"""Normalize Cloth Equip Spell Lua: DB-facing archetypes = Cloth only (+ Gold/Silver Cloth tier)."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCRIPTS = ROOT / "script" / "unofficial"

ARCH_RE = re.compile(
    r"-- Archetypes:\n(?:.*\n)*?-- Effect \(EN\):",
    re.MULTILINE,
)
LISTED_RE = re.compile(r"^s\.listed_series=\{[^}]*\}\s*$", re.MULTILINE)


def _sub_silver_cloth_filter(txt: str) -> str:
    txt = txt.replace(
        "c:IsSetCard(SET_CLOTH) and c:IsSetCard(SET_SILVER_SAINT)",
        "c:IsSetCard(SET_SILVER_CLOTH)",
    )
    return txt.replace(
        "c:IsSetCard(SET_SILVER_SAINT) and c:IsSetCard(SET_CLOTH)",
        "c:IsSetCard(SET_SILVER_CLOTH)",
    )


def patch_one(p: Path, arch_block: str, listed_line: str) -> bool:
    raw = p.read_text(encoding="utf-8", errors="replace")
    new = ARCH_RE.sub(arch_block, raw, count=1)
    new = LISTED_RE.sub(listed_line, new, count=1)
    new = _sub_silver_cloth_filter(new)
    if new != raw:
        p.write_text(new, encoding="utf-8", newline="\n")
        return True
    return False


def main() -> None:
    n = 0
    for p in sorted(SCRIPTS.glob("c922100*.lua")):
        lines = p.read_text(encoding="utf-8", errors="replace").splitlines()
        first = lines[0] if lines else ""

        if first.startswith("--Bronze Cloth"):
            arch = "-- Archetypes:\n-- - cloth\n-- - Bronze Cloth\n--\n-- Effect (EN):"
            listed = "s.listed_series={SET_SAINT,SET_CLOTH,SET_BRONZE_CLOTH}"
            if patch_one(p, arch, listed):
                n += 1

        elif first.startswith("--Silver Cloth"):
            arch = "-- Archetypes:\n-- - cloth\n-- - Silver Cloth\n--\n-- Effect (EN):"
            listed = "s.listed_series={SET_CLOTH,SET_SILVER_CLOTH,SET_SAINT}"
            if patch_one(p, arch, listed):
                n += 1

        elif first.startswith("--Gold Cloth"):
            arch = "-- Archetypes:\n-- - cloth\n-- - Gold Cloth\n--\n-- Effect (EN):"
            listed = "s.listed_series={SET_CLOTH,SET_GOLD_CLOTH,SET_GOLD_SAINT,SET_SAINT}"
            if patch_one(p, arch, listed):
                n += 1

    # Non-Cloth-title scripts that filter Silver Cloth equips by old dual setcode
    for p in sorted(SCRIPTS.glob("c922100*.lua")):
        raw = p.read_text(encoding="utf-8", errors="replace")
        new = _sub_silver_cloth_filter(raw)
        if new != raw:
            p.write_text(new, encoding="utf-8", newline="\n")
            n += 1

    print(f"patch_cloth_equip_series: touched {n} file pass(es)")


if __name__ == "__main__":
    main()

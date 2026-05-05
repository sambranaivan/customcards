"""Add ACTIVATE SetDescription(aux.Stringid(id,1)) and shift other Stringid indices +1."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FILES = [ROOT / "script" / "unofficial" / f"c9221000{i}.lua" for i in range(41, 51)]


def patch_content(txt: str) -> str:
    if "e0:SetDescription(aux.Stringid(id,1))" in txt:
        return txt
    # Bump Stringid indices from high to low (never touch id,0) — must run BEFORE inserting id,1
    for n in (3, 2, 1):
        txt = txt.replace(f"aux.Stringid(id,{n})", f"__BUMP_{n}__")
    for n in (3, 2, 1):
        txt = txt.replace(f"__BUMP_{n}__", f"aux.Stringid(id,{n + 1})")
    txt = re.sub(
        r"(e0:SetCode\(EVENT_FREE_CHAIN\))\r?\n(\tc:RegisterEffect\(e0\))",
        r"\1\n\te0:SetDescription(aux.Stringid(id,1))\n\2",
        txt,
        count=1,
    )
    return txt


def main() -> None:
    for path in FILES:
        raw = path.read_text(encoding="utf-8")
        new = patch_content(raw)
        if new != raw:
            path.write_text(new, encoding="utf-8", newline="\n")
            print("updated", path.name)


if __name__ == "__main__":
    main()

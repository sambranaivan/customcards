"""Add ACTIVATE condition: require face-up Saint on your field + free S/T zone."""
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FILES = [ROOT / "script" / "unofficial" / f"c9221000{i}.lua" for i in range(41, 51)]

BEFORE_EQLIM = (
    "function s.actcon(e,tp,eg,ep,ev,re,r,rp)\n"
    "\treturn Duel.GetLocationCount(tp,LOCATION_SZONE)>0\n"
    "\t\tand Duel.IsExistingMatchingCard(function(tc)\n"
    "\t\t\treturn tc:IsFaceup() and tc:IsSetCard(SET_SAINT) and tc:IsControler(tp)\n"
    "\t\tend,tp,LOCATION_MZONE,0,1,nil)\n"
    "end\n\n"
    "function s.eqlimit(e,c)"
)

DESC_LINE = "\te0:SetDescription(aux.Stringid(id,1))"
DESC_WITH_COND = DESC_LINE + "\n\te0:SetCondition(s.actcon)"


def patch(txt: str) -> str:
    if "function s.actcon" in txt:
        return txt
    if DESC_WITH_COND not in txt:
        txt = txt.replace(DESC_LINE, DESC_WITH_COND, 1)
    txt = txt.replace("function s.eqlimit(e,c)", BEFORE_EQLIM, 1)
    return txt


def main() -> None:
    for path in FILES:
        raw = path.read_text(encoding="utf-8")
        new = patch(raw)
        if new != raw:
            path.write_text(new, encoding="utf-8", newline="\n")
            print("updated", path.name)


if __name__ == "__main__":
    main()

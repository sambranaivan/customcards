import re
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable


ROOT = Path(__file__).resolve().parents[1]
SCRIPTS_DIR = ROOT / "script" / "unofficial"


@dataclass(frozen=True)
class CardComment:
    id: int
    name: str
    type_line: str
    level: int | None
    attribute: str | None
    race: str | None
    atk: int | None
    defe: int | None
    archetypes: list[str]
    effect_en: str


def _norm(text: str) -> str:
    return text.replace("\r\n", "\n").replace("\r", "\n")


def _extract_block(text: str) -> str | None:
    text = _norm(text)
    m = re.search(r"--\[\=\=\[\s*\n([\s\S]*?)\n--\]\=\=\]", text)
    return m.group(1) if m else None


def _extract_effect_en(block: str) -> str:
    m = re.search(r"^--\s*Effect\s*\(EN\):\s*$", block, flags=re.MULTILINE)
    if not m:
        raise ValueError("missing Effect (EN) header")
    lines: list[str] = []
    for line in block[m.end() :].splitlines():
        if line == "":
            continue
        if line.strip().startswith("--") is False:
            break
        content = line.lstrip()[2:]
        if content.startswith(" "):
            content = content[1:]
        lines.append(content.rstrip())
    eff = "\n".join(lines).strip()
    if not eff:
        raise ValueError("empty Effect (EN)")
    return eff


def _extract_list(block: str, header: str) -> list[str]:
    m = re.search(rf"^--\s*{re.escape(header)}\s*:\s*$", block, flags=re.MULTILINE)
    if not m:
        return []
    out: list[str] = []
    for line in block[m.end() :].splitlines():
        if re.match(r"^--\s*Effect\s*\(EN\):\s*$", line):
            break
        mm = re.match(r"^--\s*-\s*(.+?)\s*$", line)
        if mm:
            out.append(mm.group(1))
    return out


def _extract_kv(block: str, key: str) -> str | None:
    m = re.search(rf"^--\s*{re.escape(key)}\s*:\s*(.+?)\s*$", block, flags=re.MULTILINE)
    return m.group(1).strip() if m else None


def _parse_atk_def(line: str | None) -> tuple[int | None, int | None]:
    if not line:
        return None, None
    m = re.match(r"(\d+)\s*/\s*(\d+)", line)
    if not m:
        return None, None
    return int(m.group(1)), int(m.group(2))


def parse_card_comment(script_path: Path) -> CardComment:
    raw = script_path.read_text(encoding="utf-8", errors="replace")
    block = _extract_block(raw)
    if not block:
        raise ValueError("missing [==[ comment block ]==]")

    cid_s = _extract_kv(block, "ID")
    if not cid_s or not cid_s.isdigit():
        raise ValueError("missing/invalid ID")
    cid = int(cid_s)

    type_line = _extract_kv(block, "Type") or ""
    name = raw.splitlines()[0].lstrip("-").strip() if raw.splitlines() else script_path.stem

    level = _extract_kv(block, "Level")
    attribute = _extract_kv(block, "Attribute")
    race = _extract_kv(block, "Race")
    atk_def = _extract_kv(block, "ATK/DEF")
    atk, defe = _parse_atk_def(atk_def)

    archetypes = _extract_list(block, "Archetypes")
    effect_en = _extract_effect_en(block)

    return CardComment(
        id=cid,
        name=name,
        type_line=type_line,
        level=int(level) if level and level.isdigit() else None,
        attribute=attribute,
        race=race,
        atk=atk,
        defe=defe,
        archetypes=archetypes,
        effect_en=effect_en,
    )


def iter_cards(start: int, end: int) -> Iterable[CardComment]:
    for cid in range(start, end + 1):
        path = SCRIPTS_DIR / f"c{cid}.lua"
        if not path.exists():
            raise FileNotFoundError(str(path))
        yield parse_card_comment(path)


def main() -> None:
    start, end = 922100172, 922100302
    cards = list(iter_cards(start, end))

    unique_arch = sorted({a for c in cards for a in c.archetypes})
    types = sorted({c.type_line for c in cards})

    missing_arch = [c.id for c in cards if not c.archetypes]
    missing_effect = [c.id for c in cards if not c.effect_en.strip()]

    print(f"cards: {len(cards)}  range: {min(c.id for c in cards)}..{max(c.id for c in cards)}")
    print(f"unique_archetypes({len(unique_arch)}): {', '.join(unique_arch)}")
    print(f"unique_type_lines({len(types)}): {types}")
    if missing_arch:
        print(f"missing_archetypes: {missing_arch[:20]}{' ...' if len(missing_arch)>20 else ''}")
    if missing_effect:
        print(f"missing_effect_en: {missing_effect[:20]}{' ...' if len(missing_effect)>20 else ''}")

    # Quick sanity samples
    for sample_id in (922100172, 922100180, 922100210, 922100244, 922100302):
        c = next(x for x in cards if x.id == sample_id)
        print("\n---")
        print(f"{c.id} {c.name}")
        print(f"type: {c.type_line}")
        print(f"arch: {c.archetypes}")
        if c.level is not None:
            print(f"lvl/attr/race/atk/def: {c.level}/{c.attribute}/{c.race}/{c.atk}/{c.defe}")
        print("effect_en_first_line:", c.effect_en.splitlines()[0])


if __name__ == "__main__":
    main()


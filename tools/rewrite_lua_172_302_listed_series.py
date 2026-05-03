import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SCRIPTS_DIR = ROOT / "script" / "unofficial"


ARCH_TO_CONST = {
    "saint": "SET_SAINT",
    "saint-seiya": "SET_SAINT",
    "God Warrior": "SET_GOD_WARRIOR",
    "Poseidon": "SET_POSEIDON",
    "Marine General": "SET_MARINE_GENERAL",
    "Pillar": "SET_PILLAR",
    "Hades": "SET_HADES",
    "Specter": "SET_SPECTER",
    "Renegade Saint": "SET_RENEGADE_SAINT",
    "Meta": "SET_META",
}


def norm(text: str) -> str:
    return text.replace("\r\n", "\n").replace("\r", "\n")


def extract_block(text: str) -> str:
    m = re.search(r"--\[\=\=\[\s*\n([\s\S]*?)\n--\]\=\=\]", norm(text))
    if not m:
        raise ValueError("missing [==[ block ]==]")
    return m.group(1)


def list_archetypes(block: str) -> list[str]:
    m = re.search(r"^--\s*Archetypes\s*:\s*$", block, flags=re.MULTILINE)
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


def listed_series_from_archetypes(archetypes: list[str]) -> list[str]:
    series: list[str] = []
    for a in archetypes:
        const = ARCH_TO_CONST.get(a)
        if not const:
            raise KeyError(f"unknown archetype: {a}")
        if const not in series:
            series.append(const)
    if not series:
        series = ["SET_SAINT"]
    return series


def rewrite_one(path: Path) -> None:
    original = path.read_text(encoding="utf-8", errors="replace")
    text = norm(original)

    block = extract_block(text)
    archetypes = list_archetypes(block)
    series = listed_series_from_archetypes(archetypes)

    # Keep everything up to (and including) the second name line after the comment block, if present.
    # Then replace the script body from 'local s,id=GetID()' onwards.
    m = re.search(r"^local s,id=GetID\(\)\s*$", text, flags=re.MULTILINE)
    if not m:
        raise ValueError(f"{path.name}: missing GetID() line")

    prefix = text[: m.start()].rstrip("\n") + "\n"
    body = (
        "local s,id=GetID()\n"
        "function s.initial_effect(c)\n"
        "end\n"
        f"s.listed_series={{{', '.join(series)}}}\n"
    )
    new_text = prefix + body

    # Preserve original newline style (assume CRLF on Windows)
    new_text = new_text.replace("\n", "\r\n")
    path.write_text(new_text, encoding="utf-8", newline="")


def main() -> None:
    start, end = 922100172, 922100302
    rewritten = 0
    for cid in range(start, end + 1):
        path = SCRIPTS_DIR / f"c{cid}.lua"
        rewrite_one(path)
        rewritten += 1
    print(f"rewritten: {rewritten}")


if __name__ == "__main__":
    main()


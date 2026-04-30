import re
import sqlite3
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SCRIPTS_DIR = ROOT / "script" / "unofficial"
DB_PATH = ROOT / "expansions" / "cards-unofficial.cdb"


def extract_effect_en(text: str) -> str | None:
    # Normalize newlines so regex anchors behave on Windows CRLF files
    text = text.replace("\r\n", "\n").replace("\r", "\n")
    m = re.search(r"^--\s*Effect\s*\(EN\):\s*$", text, flags=re.MULTILINE)
    if not m:
        return None
    start = m.end()
    # read subsequent comment lines until end of comment block
    lines = []
    for line in text[start:].splitlines():
        if line == "":
            continue
        if line.strip().startswith("--]==]"):
            break
        if not line.lstrip().startswith("--"):
            # stop at first non-comment after effect header inside block
            break
        # strip leading comment markers
        content = line.lstrip()[2:]
        if content.startswith(" "):
            content = content[1:]
        lines.append(content.rstrip())
    # trim leading/trailing blanks
    while lines and not lines[0].strip():
        lines.pop(0)
    while lines and not lines[-1].strip():
        lines.pop()
    # collapse multiple empty lines to single empty line
    cleaned = []
    prev_blank = False
    for ln in lines:
        blank = not ln.strip()
        if blank and prev_blank:
            continue
        cleaned.append(ln)
        prev_blank = blank
    eff = "\n".join(cleaned).strip()
    return eff or None


def main() -> None:
    start = 922100000
    end = 922100171
    ids = list(range(start, end + 1))

    conn = sqlite3.connect(str(DB_PATH))
    c = conn.cursor()

    updated = 0
    skipped_missing_file = 0
    skipped_no_effect = 0

    for cid in ids:
        script_path = SCRIPTS_DIR / f"c{cid}.lua"
        if not script_path.exists():
            skipped_missing_file += 1
            continue
        text = script_path.read_text(encoding="utf-8", errors="replace")
        eff = extract_effect_en(text)
        if not eff:
            skipped_no_effect += 1
            continue
        c.execute("UPDATE texts SET desc=? WHERE id=?", (eff, cid))
        if c.rowcount:
            updated += 1

    conn.commit()
    conn.close()

    print(f"updated_desc: {updated}")
    print(f"skipped_missing_file: {skipped_missing_file}")
    print(f"skipped_no_effect: {skipped_no_effect}")


if __name__ == "__main__":
    main()


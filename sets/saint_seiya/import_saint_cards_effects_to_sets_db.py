import re
import sqlite3
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, Optional


DB_PATH = Path(r"c:\ProjectIgnis\sets\sets.sqlite3")

# Keep Saint Seiya cards in a predictable custom range.
ID_FLOOR = 922_100_000


@dataclass(frozen=True)
class ParsedCard:
    name_en: str
    raw_card_type: str
    section_tags: list[str]
    attribute: Optional[str]
    race: Optional[str]
    level: Optional[int]
    rank: Optional[int]
    link: Optional[int]
    atk: Optional[int]
    defe: Optional[int]
    effect_text_en: str


_re_h2 = re.compile(r"^##\s+(?P<title>.+?)\s*$")
_re_h3 = re.compile(r"^###\s+(?P<title>.+?)\s*$")
_re_bullet = re.compile(r"^- \*\*(?P<k>[^*]+?)\*\*:\s*(?P<v>.+?)\s*$")
_re_code_open = re.compile(r"^```text\s*$")
_re_code_close = re.compile(r"^```\s*$")


def _section_tags_from_h2(title: str) -> list[str]:
    t = title.lower()
    tags: list[str] = ["saint-seiya"]
    if "saints" in t:
        tags.append("saint")
    if "cloth" in t:
        tags.append("cloth")
    if "bronze" in t:
        tags.append("Bronze Saint")
    if "silver" in t:
        tags.append("Silver Saint")
    if "gold" in t:
        tags.append("Gold Saint")
    return tags


def _normalize_card_type(raw: str) -> str:
    r = raw.lower()
    if "trap" in r:
        return "Trap"
    if "spell" in r:
        return "Spell"
    if "monster" in r:
        return "Monster"
    # Default: treat unknown as Spell to avoid forcing monster stats.
    return "Spell"


def _parse_atk_def(v: str) -> tuple[Optional[int], Optional[int]]:
    # Format: "1700 / 1200" or sometimes just "2500" (Link Monster ATK-only)
    if "/" in v:
        left, right = [p.strip() for p in v.split("/", 1)]
        return (int(left), int(right))
    return (int(v.strip()), None)


def parse_cards_from_md(lines: Iterable[str]) -> list[ParsedCard]:
    cards: list[ParsedCard] = []

    current_h2_tags: list[str] = ["saint-seiya"]
    i = 0
    lines_list = list(lines)
    n = len(lines_list)

    while i < n:
        line = lines_list[i].rstrip("\n")

        m2 = _re_h2.match(line)
        if m2:
            current_h2_tags = _section_tags_from_h2(m2.group("title"))
            i += 1
            continue

        m3 = _re_h3.match(line)
        if not m3:
            i += 1
            continue

        name = m3.group("title").strip()
        raw_card_type: Optional[str] = None
        attribute: Optional[str] = None
        race: Optional[str] = None
        level: Optional[int] = None
        rank: Optional[int] = None
        link: Optional[int] = None
        atk: Optional[int] = None
        defe: Optional[int] = None
        effect_lines: list[str] = []

        i += 1
        # Read bullets until code block starts (or next heading)
        while i < n:
            l = lines_list[i].rstrip("\n")

            if _re_h3.match(l) or _re_h2.match(l) or l.startswith("# "):
                break

            mb = _re_bullet.match(l)
            if mb:
                k = mb.group("k").strip().lower()
                v = mb.group("v").strip()
                if k == "card type":
                    raw_card_type = v
                elif k == "attribute":
                    attribute = v
                elif k == "type":
                    race = v
                elif k == "level":
                    level = int(v)
                elif k == "rank":
                    rank = int(v)
                elif k == "link rating":
                    link = int(v)
                elif k == "atk/def":
                    atk, defe = _parse_atk_def(v)
                elif k == "atk":
                    atk = int(v)
                # ignore other keys for now
                i += 1
                continue

            if _re_code_open.match(l):
                i += 1
                while i < n:
                    cl = lines_list[i].rstrip("\n")
                    if _re_code_close.match(cl):
                        i += 1
                        break
                    effect_lines.append(cl)
                    i += 1
                break

            i += 1

        effect_text = "\n".join(effect_lines).strip()
        if not raw_card_type or not effect_text:
            # Skip incomplete blocks; better to import nothing than half.
            continue

        cards.append(
            ParsedCard(
                name_en=name,
                raw_card_type=raw_card_type,
                section_tags=current_h2_tags,
                attribute=attribute,
                race=race,
                level=level,
                rank=rank,
                link=link,
                atk=atk,
                defe=defe,
                effect_text_en=effect_text,
            )
        )

    return cards


def _next_card_id(conn: sqlite3.Connection) -> int:
    row = conn.execute("SELECT MAX(card_id) FROM cards").fetchone()
    max_in_db = row[0] if row else None
    if max_in_db is None:
        return ID_FLOOR
    return max(int(max_in_db) + 1, ID_FLOOR)


def _card_exists_by_name(conn: sqlite3.Connection, name_en: str) -> bool:
    row = conn.execute("SELECT 1 FROM cards WHERE name_en = ? LIMIT 1", (name_en,)).fetchone()
    return row is not None


def insert_cards(cards: list[ParsedCard], *, source_path: Path) -> tuple[int, int]:
    conn = sqlite3.connect(DB_PATH)
    conn.execute("PRAGMA foreign_keys=ON")

    inserted = 0
    skipped = 0
    next_id = _next_card_id(conn)

    for c in cards:
        if _card_exists_by_name(conn, c.name_en):
            skipped += 1
            continue

        card_type = _normalize_card_type(c.raw_card_type)
        archetypes_json = (
            "[" + ",".join(f"\"{t}\"" for t in sorted(set(c.section_tags))) + "]"
            if c.section_tags
            else None
        )

        conn.execute(
            """
            INSERT INTO cards (
              card_id,
              name_en,
              card_type,
              level, rank, link,
              attribute, race,
              atk, def,
              is_psct, effect_text_en,
              archetypes_json,
              updated_ts, updated_reason, updated_source_ref, updated_notes
            ) VALUES (
              ?,
              ?,
              ?,
              ?, ?, ?,
              ?, ?,
              ?, ?,
              1, ?,
              ?,
              strftime('%Y-%m-%dT%H:%M:%fZ','now'),
              'initial',
              ?,
              ?
            )
            """,
            (
                next_id,
                c.name_en,
                card_type,
                c.level,
                c.rank,
                c.link,
                c.attribute,
                c.race,
                c.atk,
                c.defe,
                c.effect_text_en,
                archetypes_json,
                str(source_path),
                f"Imported from {source_path.name} ({c.raw_card_type}).",
            ),
        )
        inserted += 1
        next_id += 1

    conn.commit()
    conn.close()
    return inserted, skipped


def main() -> None:
    md_path = (
        Path(sys.argv[1])
        if len(sys.argv) > 1
        else Path(r"c:\ProjectIgnis\sets\saint_seiya\saint_cards_effects.md")
    )
    cards = parse_cards_from_md(md_path.read_text(encoding="utf-8").splitlines())
    inserted, skipped = insert_cards(cards, source_path=md_path)
    print(f"parsed={len(cards)} inserted={inserted} skipped={skipped} db={DB_PATH} md={md_path}")


if __name__ == "__main__":
    main()


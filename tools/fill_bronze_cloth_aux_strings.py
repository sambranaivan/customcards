"""Populate texts.str1+ for Bronze Cloth: Stringid 0=hand search, 1=Activate equip, rest=effects."""
import sqlite3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CDB = ROOT / "expansions" / "saint-seiya.cdb"

ACT = 'Activate: Equip to 1 appropriate "Saint" monster'

# Per card: (str1..str5) — empty trailing OK. Matches Lua after ACTIVATE uses Stringid(id,1).
STRINGS: dict[int, tuple[str, str, str, str, str]] = {
    922100041: (
        'Add 1 Level 4 "Saint" from your Deck (discard this card)',
        ACT,
        "Inflict 500 damage to your opponent",
        "Re-equip during your next Standby Phase",
        "",
    ),
    922100042: (
        'Add 1 Level 4 "Saint" from your Deck (discard this card)',
        ACT,
        "Destroy 1 card your opponent controls",
        "Re-equip during your next Standby Phase",
        "",
    ),
    922100043: (
        'Add 1 Level 4 "Saint" from your Deck (discard this card)',
        ACT,
        "Negate the effects of 1 face-up card your opponent controls until the end of this turn",
        "Re-equip during your next Standby Phase",
        "",
    ),
    922100044: (
        'Add 1 Level 4 "Saint" from your Deck (discard this card)',
        ACT,
        "Re-equip during your next Standby Phase",
        "",
        "",
    ),
    922100045: (
        'Add 1 Level 4 "Saint" from your Deck (discard this card)',
        ACT,
        "Inflict 1000 damage to your opponent",
        "Destroy this equipped card instead (Ikki is not destroyed); you can destroy 1 card on the field",
        "Re-equip during your next Standby Phase",
    ),
    922100046: (
        'Add 1 Level 4 "Saint" from your Deck (discard this card)',
        ACT,
        "Re-equip during your next Standby Phase",
        "",
        "",
    ),
    922100047: (
        'Add 1 Level 4 "Saint" from your Deck (discard this card)',
        ACT,
        "That opponent's monster loses 1000 ATK/DEF",
        "Re-equip during your next Standby Phase",
        "",
    ),
    922100048: (
        'Add 1 Level 4 "Saint" from your Deck (discard this card)',
        ACT,
        "Your opponent discards 1 random card",
        "Destroy that opponent's monster",
        "Re-equip during your next Standby Phase",
    ),
    922100049: (
        'Add 1 Level 4 "Saint" from your Deck (discard this card)',
        ACT,
        'Add 1 "Saint" from your GY to your hand, then discard 1 card',
        "Re-equip during your next Standby Phase",
        "",
    ),
    922100050: (
        'Add 1 Level 4 "Saint" from your Deck (discard this card)',
        ACT,
        'Shuffle 1 "Cloth" from your GY into the Deck',
        "Draw 1 card, then discard 1 card",
        "Re-equip during your next Standby Phase",
    ),
}


def main() -> None:
    conn = sqlite3.connect(str(CDB))
    cur = conn.cursor()
    for cid, row in STRINGS.items():
        cur.execute(
            """
            UPDATE texts SET str1=?, str2=?, str3=?, str4=?, str5=?,
            str6='', str7='', str8='', str9='', str10='', str11='', str12='', str13='', str14='', str15='', str16=''
            WHERE id=?
            """,
            (*row, cid),
        )
    conn.commit()
    conn.close()
    print(f"Updated texts str1–str5 for {len(STRINGS)} Bronze Cloth cards.")


if __name__ == "__main__":
    main()

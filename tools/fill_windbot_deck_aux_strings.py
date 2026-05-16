"""Populate texts.str* for WindBot Black Saints + Bronze Only decks (aux.Stringid in lua)."""
from __future__ import annotations

import sqlite3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DB = ROOT / "expansions" / "saint-seiya.cdb"

EQ = (
    'Pay 500 LP; equip 1 "Cloth" Equip Spell from your GY to this card '
    '(you cannot Special Summon from the Extra Deck except "Saint" monsters this turn)'
)
MAT = (
    'If sent to the GY as material for a "Saint" monster: equip or attach '
    '1 face-up "Cloth" Equip Spell you control'
)

# card_id -> str1..strN (Stringid 0 = str1, …)
STRINGS: dict[int, tuple[str, ...]] = {
    # --- Bronze Only ---
    922100000: (
        'Add 1 "Cloth" Equip Spell or 1 "Saint" monster from your Deck to your hand',
        "Special Summon (from your hand)",
        EQ,
        MAT,
    ),
    922100001: (
        '(Quick Effect): Discard; "Cloth" cards you control cannot be destroyed by card effects this turn',
        EQ,
        MAT,
    ),
    922100002: (
        "Before damage calculation: change the attack target to Defense Position and negate its effects",
        EQ,
        MAT,
    ),
    922100003: (
        EQ,
        MAT,
    ),
    922100004: (
        'Discard 1 "Saint" card; Special Summon this card',
        EQ,
        MAT,
    ),
    922100005: (
        'Special Summon (from your hand)',
        'Add 1 "Cloth" card from your GY to your hand, then discard 1 card',
        MAT,
    ),
    922100006: (
        'Discard 1 "Cloth" card; inflict 800 damage, and if you do, this card can attack directly this turn',
        'Send 1 "Cloth" card from your Deck to the GY',
        MAT,
    ),
    922100007: (
        'Add 1 Level 5 or higher "Saint" monster from your Deck to your hand',
        'Add 1 "Cloth" card from your GY to your hand, then banish this card',
        MAT,
    ),
    922100008: (
        'Special Summon this card from your hand',
        'Target 1 "Saint" monster in your GY; add it to your hand',
        MAT,
    ),
    922100009: (
        "Draw 1 card, then discard 1 card",
        'Shuffle 1 "Cloth" card from your GY into the Deck, then draw 1 card',
        MAT,
    ),
    922100010: (
        'Target up to 2 "Cloth" Equip Spells in your GY; add them to your hand',
        'Discard this card; add 1 "Athena\'s Sanctuary" from your Deck to your hand',
    ),
    922100011: (
        '(Quick Effect): Discard; equip 1 "Cloth" Equip Spell from your Deck or GY to 1 "Saint" you control',
        'Banish this card; add up to 2 "Cloth" cards with different names from your GY to your hand',
    ),
    922100086: (
        'Banish this card from your GY instead?',
    ),
    # --- Black Saints (Ikki leader) ---
    922100148: (
        "Special Summon (from your hand)",
        'Send 1 face-up "Fragment of Sagittarius" Equip Spell to the GY; Special Summon this card',
        'Add 1 "Fragment of Sagittarius" card from your Deck to your hand',
        '(Quick Effect): Send 1 face-up "Fragment of Sagittarius" Equip Spell to the GY, then destroy 1 face-up card on the field',
    ),
    922100149: (
        'Send 1 "Fragment of Sagittarius" card from your Deck to the GY',
        'Special Summon 1 Level 4 or lower "Black Saint" from your hand or GY',
    ),
    922100150: (
        'Special Summon (from your hand)',
        'Equip 1 "Fragment of Sagittarius" Equip Spell from your hand or GY to this card',
    ),
    922100151: (
        'Equip 1 "Fragment of Sagittarius" Equip Spell from your Deck to this card',
        'Send 1 Equip Card equipped to this card to the GY; this card cannot be destroyed this turn',
        'Add 1 "Fragment of Sagittarius" card from your GY to your hand',
    ),
    922100152: (
        "Target 1 face-up monster your opponent controls; change it to Defense Position",
        'Send 1 "Fragment of Sagittarius" Equip Spell you control to the GY; negate 1 opponent monster\'s effects',
        'Equip 1 "Fragment of Sagittarius" Equip Spell from your GY to the Summoned monster',
    ),
    922100153: (
        'Equip 1 "Fragment of Sagittarius" Equip Spell from your hand or GY to this card',
        'Draw 1 card',
    ),
    922100154: (
        'Send 1 "Fragment of Sagittarius" card from your Deck to the GY',
        'Send 1 face-up "Fragment of Sagittarius" Equip Spell to the GY; Special Summon 1 "Dark Phoenix" from your Deck',
    ),
    922100163: (
        'Send 1 "Fragment of Sagittarius" card from your Deck to the GY?',
        'Target 1 "Black Saint" monster; equip 1 "Fragment of Sagittarius" Equip Spell from your GY',
        'Add 1 "Black Saint" monster from your Deck to your hand',
    ),
    922100165: (
        'Destroy 1 card your opponent controls?',
    ),
    922100166: (
        'Send 1 "Fragment of Sagittarius" card from your hand or field to the GY; Special Summon 1 "Black Saint" from your GY',
    ),
    922100168: (
        'Add 1 "Death Queen Island" from your Deck to your hand',
        '(Quick Effect): When targeted by a card effect; Special Summon "Black Saint - Ikki, Leader of Death Queen Island"',
        'When targeted for an attack: negate the attack, change battle position, then Special Summon Ikki',
    ),
    922100169: (
        'Special Summon (from your hand)',
        'Send 1 "Fragment of Sagittarius" card from your Deck to the GY',
        '(Quick Effect): Send 1 "Fragment of Sagittarius" Equip Spell to the GY; negate that monster effect',
        'Special Summon "Black Saint - Ikki, Leader of Death Queen Island" from your hand or GY',
        'Equip 1 "Fragment of Sagittarius" Equip Spell from your GY to that monster?',
    ),
    922100170: (
        'Send 1 "Fragment of Sagittarius" card from your Deck to the GY?',
    ),
    922100171: (
        'Add 1 "Esmeralda, Light of Death Queen Island" or "Guilty, Master of Hell" from your Deck to your hand?',
        'Draw 1 card, then discard 1 card',
    ),
}


def main() -> None:
    conn = sqlite3.connect(DB)
    for cid, row in STRINGS.items():
        sets = ", ".join(f"str{i + 1}=?" for i in range(len(row)))
        conn.execute(f"UPDATE texts SET {sets} WHERE id=?", (*row, cid))
    conn.commit()
    conn.close()
    print(f"Updated str fields for {len(STRINGS)} cards in {DB}")


if __name__ == "__main__":
    main()

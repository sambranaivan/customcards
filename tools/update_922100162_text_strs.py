"""Idempotent: set English str1-str3 for 922100162 (matches c922100162.lua Stringid 0-2)."""
import sqlite3

DB = r"c:\ProjectIgnis\expansions\saint-seiya.cdb"
CID = 922100162

STR1 = (
    'Fusion Summon with 7+ different "Fragment of Sagittarius" names '
    "on your field and/or GY"
)
STR2 = 'Equip up to 2 "Fragment of Sagittarius" Equip Spells from your GY'
STR3 = (
    "Send 1 equipped card to the GY; negate the activation, "
    "and if you do, destroy it"
)


def main() -> None:
    conn = sqlite3.connect(DB)
    conn.execute(
        "UPDATE texts SET str1=?, str2=?, str3=? WHERE id=?",
        (STR1, STR2, STR3, CID),
    )
    conn.commit()
    conn.close()


if __name__ == "__main__":
    main()

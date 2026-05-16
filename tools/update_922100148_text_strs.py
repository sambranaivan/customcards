"""Idempotent: set English str1-str4 for 922100148 (matches c922100148.lua Stringid 0-3)."""
import sqlite3

DB = r"c:\ProjectIgnis\expansions\saint-seiya.cdb"
CID = 922100148

# str1 = aux.Stringid(id,0) hand Special Summon
STR1 = 'Special Summon (from your hand)'
# str2 = aux.Stringid(id,1) GY Special Summon
STR2 = (
    'Send 1 face-up "Fragment of Sagittarius" Equip Spell to the GY; '
    "Special Summon this card"
)
# str3 = aux.Stringid(id,2) on-summon Deck search
STR3 = 'Add 1 "Fragment of Sagittarius" card from your Deck to your hand'
# str4 = aux.Stringid(id,3) Quick destroy
STR4 = (
    '(Quick Effect): Send 1 face-up "Fragment of Sagittarius" Equip Spell to the GY, '
    "then destroy 1 face-up card on the field"
)


def main() -> None:
    conn = sqlite3.connect(DB)
    cur = conn.execute("SELECT id FROM texts WHERE id=?", (CID,))
    if cur.fetchone() is None:
        raise SystemExit(f"Card {CID} not found in {DB}")
    conn.execute(
        "UPDATE texts SET str1=?, str2=?, str3=?, str4=? WHERE id=?",
        (STR1, STR2, STR3, STR4, CID),
    )
    conn.commit()
    conn.close()
    print(f"Updated texts.str1-str4 for {CID} in {DB}")


if __name__ == "__main__":
    main()

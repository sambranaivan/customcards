import sqlite3

OLD_DISCARD = (
    'You can discard this card; add 1 Level 4 "Saint" monster from your Deck to your hand.\n'
)
OLD_REEQUIP = (
    "If this face-up Equip Card in its owner's Spell & Trap Zone is sent to the GY: "
    'You can target 1 "Saint" monster you control; during your next Standby Phase, '
    "equip this card to that target, but banish it when it leaves the field.\n"
)
NEW_GY = (
    'When this card is sent from the field to the GY: You can add 1 "Bronze Saint" monster '
    'or 1 "Bronze Cloth" Equip Spell from your Deck to your hand.\n'
)
# Partial already-inserted version (with \r\n) that may exist from first run
NEW_GY_OLD = (
    'When this card is sent from the field to the GY: You can add 1 "Bronze Saint" monster '
    'or 1 "Bronze Cloth" Equip Spell from your Deck to your hand.\r\n'
)
NEW_STR1 = 'Add 1 "Bronze Saint" monster or "Bronze Cloth" from your Deck to your hand?'

CLOTH_IDS = list(range(922100041, 922100051))  # 041..050


def main() -> None:
    conn = sqlite3.connect("expansions/saint-seiya.cdb")
    cur = conn.cursor()

    for cid in CLOTH_IDS:
        cur.execute("SELECT name, desc, str1 FROM texts WHERE id=?", (cid,))
        row = cur.fetchone()
        if not row:
            print(f"MISSING: {cid}")
            continue
        name, desc, str1 = row

        # Update desc: remove old lines, insert new GY effect line
        new_desc = desc
        if OLD_DISCARD in new_desc:
            new_desc = new_desc.replace(OLD_DISCARD, "")
        else:
            print(f"WARNING {cid}: discard line not found in desc")
        if OLD_REEQUIP in new_desc:
            new_desc = new_desc.replace(OLD_REEQUIP, "")
        else:
            print(f"WARNING {cid}: re-equip line not found in desc")

        # Strip the partial \r\n version from the first run if present
        if NEW_GY_OLD in new_desc:
            new_desc = new_desc.replace(NEW_GY_OLD, "")

        # Insert new GY search line right before the HOPT closing line
        hopt_marker = 'You can only use 1 '
        if hopt_marker in new_desc and NEW_GY not in new_desc:
            idx = new_desc.index(hopt_marker)
            new_desc = new_desc[:idx] + NEW_GY + new_desc[idx:]

        # Update str1 (aux.Stringid(id,0))
        cur.execute(
            "UPDATE texts SET desc=?, str1=? WHERE id=?",
            (new_desc, NEW_STR1, cid),
        )
        print(f"Updated {cid}: {name}")

    conn.commit()
    conn.close()
    print("\nDone.")


if __name__ == "__main__":
    main()

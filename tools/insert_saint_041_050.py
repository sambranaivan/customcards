import sqlite3


def main() -> None:
    conn = sqlite3.connect("expansions/cards-unofficial.cdb")
    c = conn.cursor()

    SET_CLOTH = 0x1D8
    SET_BRONZE_SAINT = 0x1D9

    # These are "Cloth" cards, also tagged as Bronze Saint in comments.
    setcode = SET_CLOTH | (SET_BRONZE_SAINT << 16)

    cards = [
        (922100041, "Bronze Cloth - Pegasus"),
        (922100042, "Bronze Cloth - Dragon"),
        (922100043, "Bronze Cloth - Cygnus"),
        (922100044, "Bronze Cloth - Andromeda"),
        (922100045, "Bronze Cloth - Phoenix"),
        (922100046, "Bronze Cloth - Unicorn"),
        (922100047, "Bronze Cloth - Hydra"),
        (922100048, "Bronze Cloth - Bear"),
        (922100049, "Bronze Cloth - Lionet"),
        (922100050, "Bronze Cloth - Wolf"),
    ]

    for cid, name in cards:
        # Equip Spell: type = 262146
        c.execute(
            "INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)",
            (cid, 4, 0, setcode, 262146, 0, 0, 0, 0, 0, 0),
        )
        c.execute(
            "INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
            (cid, name, "Custom card (scripted).", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""),
        )

    conn.commit()
    conn.close()
    print(f"Inserted/updated {len(cards)} cards (041-050).")


if __name__ == "__main__":
    main()


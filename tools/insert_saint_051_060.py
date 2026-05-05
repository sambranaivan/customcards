import sqlite3


def main() -> None:
    conn = sqlite3.connect("expansions/cards-unofficial.cdb")
    c = conn.cursor()

    SET_CLOTH = 0x1D8
    SET_SILVER_CLOTH = 0x1EB
    setcode = SET_CLOTH | (SET_SILVER_CLOTH << 16)

    cards = [
        (922100051, "Silver Cloth - Eagle"),
        (922100052, "Silver Cloth - Ophiuchus"),
        (922100053, "Silver Cloth - Perseus"),
        (922100054, "Silver Cloth - Lyra"),
        (922100055, "Silver Cloth - Lacerta"),
        (922100056, "Silver Cloth - Hound"),
        (922100057, "Silver Cloth - Whale"),
        (922100058, "Silver Cloth - Centaurus"),
        (922100059, "Silver Cloth - Crow"),
        (922100060, "Silver Cloth - Cerberus"),
    ]

    for cid, name in cards:
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
    print(f"Inserted/updated {len(cards)} cards (051-060).")


if __name__ == "__main__":
    main()


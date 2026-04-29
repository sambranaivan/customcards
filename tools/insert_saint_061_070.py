import sqlite3


def main() -> None:
    conn = sqlite3.connect("expansions/cards-unofficial.cdb")
    c = conn.cursor()

    SET_CLOTH = 0x1D8
    SET_SILVER_SAINT = 0x1DA
    SET_GOLD_SAINT = 0x1DB
    SET_GOLD_CLOTH = 0x1DC

    setcode_silver = SET_CLOTH | (SET_SILVER_SAINT << 16)
    # Gold cloths are both Cloth + Gold Cloth archetype; also tag as Gold Saint in comments.
    setcode_gold = SET_CLOTH | (SET_GOLD_CLOTH << 16) | (SET_GOLD_SAINT << 32)

    silver = [
        (922100061, "Silver Cloth - Auriga"),
        (922100062, "Silver Cloth - Canis Major"),
        (922100063, "Silver Cloth - Musca"),
        (922100064, "Silver Cloth - Heracles"),
        (922100065, "Silver Cloth - Sagitta"),
        (922100066, "Silver Cloth - Cepheus"),
    ]
    gold = [
        (922100067, "Gold Cloth - Sagittarius"),
        (922100068, "Gold Cloth - Aries"),
        (922100069, "Gold Cloth - Taurus"),
        (922100070, "Gold Cloth - Cancer"),
    ]

    for cid, name in silver:
        c.execute(
            "INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)",
            (cid, 4, 0, setcode_silver, 262146, 0, 0, 0, 0, 0, 0),
        )
        c.execute(
            "INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
            (cid, name, "Custom card (scripted).", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""),
        )

    for cid, name in gold:
        c.execute(
            "INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)",
            (cid, 4, 0, setcode_gold, 262146, 0, 0, 0, 0, 0, 0),
        )
        c.execute(
            "INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
            (cid, name, "Custom card (scripted).", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""),
        )

    conn.commit()
    conn.close()
    print("Inserted/updated 10 cards (061-070).")


if __name__ == "__main__":
    main()


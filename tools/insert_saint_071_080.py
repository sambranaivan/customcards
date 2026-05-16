import sqlite3


def main() -> None:
    conn = sqlite3.connect("expansions/cards-unofficial.cdb")
    c = conn.cursor()

    SET_CLOTH = 0x1D8
    SET_GOLD_CLOTH = 0x1DC

    setcode_gold_cloth = SET_CLOTH | (SET_GOLD_CLOTH << 16)

    equip_cards = [
        (922100071, "Gold Cloth - Libra"),
        (922100072, "Gold Cloth - Scorpio"),
        (922100073, "Gold Cloth - Capricorn"),
        (922100074, "Gold Cloth - Pisces"),
        (922100075, "Gold Cloth - Gemini"),
        (922100076, "Gold Cloth - Leo"),
        (922100077, "Gold Cloth - Virgo"),
        (922100078, "Gold Cloth - Aquarius"),
    ]
    field_cards = [
        (922100079, "Athena's Sanctuary"),
        (922100080, "Athena's Sanctuary - Reforged"),
    ]

    TYPE_EQUIP = 262146
    TYPE_FIELD = 524290

    for cid, name in equip_cards:
        c.execute(
            "INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)",
            (cid, 4, 0, setcode_gold_cloth, TYPE_EQUIP, 0, 0, 0, 0, 0, 0),
        )
        c.execute(
            "INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
            (cid, name, "Custom card (scripted).", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""),
        )

    for cid, name in field_cards:
        c.execute(
            "INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)",
            (cid, 4, 0, 0, TYPE_FIELD, 0, 0, 0, 0, 0, 0),
        )
        c.execute(
            "INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
            (cid, name, "Custom card (scripted).", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""),
        )

    conn.commit()
    conn.close()
    print("Inserted/updated 10 cards (071-080).")


if __name__ == "__main__":
    main()


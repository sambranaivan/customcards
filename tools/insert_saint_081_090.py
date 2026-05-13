import sqlite3


def main() -> None:
    conn = sqlite3.connect("expansions/cards-unofficial.cdb")
    c = conn.cursor()

    TYPE_SPELL = 0x2
    TYPE_TRAP = 0x4
    TYPE_QUICKPLAY = 0x10000
    TYPE_CONTINUOUS = 0x20000
    TYPE_COUNTER = 0x100000

    entries = [
        (922100081, "Inherited Cosmos", TYPE_SPELL),
        (922100082, "Athena's Vanguard", TYPE_TRAP | TYPE_COUNTER),
        (922100083, "The Galactic Tournament", TYPE_SPELL | TYPE_CONTINUOUS),
        (922100084, "Sanctuary Assassination Order", TYPE_SPELL),
        (922100085, "Golden Inheritance", TYPE_SPELL),
        (922100086, "Athena's Shield", TYPE_SPELL | TYPE_QUICKPLAY),
        (922100087, "Master's Legacy", TYPE_SPELL),
        (922100088, "Athena's Call", TYPE_SPELL),
        (922100089, "Training at the Sanctuary", TYPE_SPELL),
        (922100090, "Meditation at Star Hill", TYPE_SPELL),
    ]

    for cid, name, typ in entries:
        c.execute(
            "INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)",
            (cid, 4, 0, 0, typ, 0, 0, 0, 0, 0, 0),
        )
        c.execute(
            "INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
            (cid, name, "Custom card (scripted).", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""),
        )

    conn.commit()
    conn.close()
    print("Inserted/updated 10 cards (081-090).")


if __name__ == "__main__":
    main()


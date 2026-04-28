import sqlite3


def main() -> None:
    conn = sqlite3.connect("expansions/cards-unofficial.cdb")
    c = conn.cursor()

    SET_SAINT = 0x1D7
    SET_GOLD_SAINT = 0x1DB
    setcode_gold = SET_SAINT | (SET_GOLD_SAINT << 16)

    cards = [
        (
            922100036,
            "Gold Saint - Milo of Scorpio",
            2400,
            2000,
            4,
            4,  # FIRE
            1,
            8388641,
            (
                '3 Level 4 "Saint" monsters\r\n'
                'Once per turn: You can detach 1 material from this card, then target 1 face-up monster on the field; place '
                '1 "Scarlet Needle Counter" on it. Monsters with 3 or more "Scarlet Needle Counters" are sent to the GY.\r\n'
                'Once per turn: You can target 1 "Cloth" card in your GY; attach it to this card as material.\r\n'
                'You can only use each effect of "Gold Saint - Milo of Scorpio" once per turn.'
            ),
        ),
        (
            922100037,
            "Gold Saint - Shura of Capricorn",
            2500,
            2100,
            4,
            1,  # EARTH
            1,
            8388641,
            (
                '3 Level 4 "Saint" monsters\r\n'
                'Once per turn: You can detach 1 material from this card, then target 1 card on the field; send it to the GY.\r\n'
                'Once per turn: You can target 1 "Cloth" card in your GY; attach it to this card as material.\r\n'
                'You can only use each effect of "Gold Saint - Shura of Capricorn" once per turn.'
            ),
        ),
        (
            922100038,
            "Gold Saint - Aphrodite of Pisces",
            2200,
            2600,
            4,
            2,  # WATER
            1,
            8388641,
            (
                '3 Level 4 "Saint" monsters\r\n'
                'Once per turn: You can detach 1 material from this card; your opponent cannot declare attacks during their next '
                'Battle Phase.\r\n'
                'Once per turn: You can target 1 "Cloth" card in your GY; attach it to this card as material.\r\n'
                'You can only use each effect of "Gold Saint - Aphrodite of Pisces" once per turn.'
            ),
        ),
        (
            922100039,
            "Gold Saint - Aiolos of Sagittarius",
            2900,
            2300,
            8,
            16,
            1,
            8388641,
            (
                '2 Level 8 "Saint" monsters\r\n'
                'Once per turn: You can detach 1 material from this card; this card gains ATK equal to the combined original ATK '
                'of all "Bronze Saint" monsters in your GY, until the End Phase.\r\n'
                'Once per turn: You can target 1 "Cloth" card in your GY; attach it to this card as material.\r\n'
                'You can only use each effect of "Gold Saint - Aiolos of Sagittarius" once per turn.'
            ),
        ),
        (
            922100040,
            "Gold Saint - Camus of Aquarius",
            2700,
            2600,
            8,
            2,
            1,
            8388641,
            (
                '2 Level 8 "Saint" monsters\r\n'
                'Once per turn: You can detach 1 material from this card, then target 2 cards your opponent controls; while this '
                'card is face-up on the field, those cards cannot be activated, cannot change their battle positions, and cannot '
                'attack.\r\n'
                'Once per turn: You can target 1 "Cloth" card in your GY; attach it to this card as material.\r\n'
                'You can only use each effect of "Gold Saint - Camus of Aquarius" once per turn.'
            ),
        ),
    ]

    for cid, name, atk, defe, rank, attribute, race, type_value, desc in cards:
        c.execute(
            "INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)",
            (cid, 4, 0, setcode_gold, type_value, atk, defe, rank, race, attribute, 0),
        )
        c.execute(
            "INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
            (cid, name, desc, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""),
        )

    conn.commit()
    conn.close()
    print(f"Inserted/updated {len(cards)} cards (036-040).")


if __name__ == "__main__":
    main()


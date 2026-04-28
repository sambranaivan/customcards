import sqlite3


def main() -> None:
    conn = sqlite3.connect("expansions/cards-unofficial.cdb")
    c = conn.cursor()

    SET_SAINT = 0x1D7
    SET_GOLD_SAINT = 0x1DB
    setcode_gold = SET_SAINT | (SET_GOLD_SAINT << 16)

    cards = [
        (
            922100031,
            "Gold Saint - Shaka of Virgo",
            2800,
            2800,
            8,
            16,  # LIGHT
            1,  # Warrior
            8388641,  # Xyz/Effect
            setcode_gold,
            (
                '2 Level 8 "Saint" monsters\r\n'
                'While this card has a "Gold Cloth" card as material, your opponent cannot activate card effects in the GY, '
                'also they cannot banish cards.\r\n'
                'Once per turn: You can detach 1 material from this card; negate the effects of all face-up cards currently '
                'on the field until the end of this turn.\r\n'
                'Once per turn: You can target 1 "Cloth" card in your GY; attach it to this card as material.\r\n'
                'You can only use each effect of "Gold Saint - Shaka of Virgo" once per turn.'
            ),
        ),
        (
            922100032,
            "Gold Saint - Saga of Gemini",
            3000,
            2500,
            8,
            16,
            1,
            8388641,
            setcode_gold,
            (
                '2 Level 8 "Saint" monsters\r\n'
                '(Quick Effect): You can detach 2 materials from this card; destroy all cards in 1 column, and if you do, '
                'inflict 1000 damage to your opponent.\r\n'
                'Once per turn: You can target 1 "Cloth" card in your GY; attach it to this card as material.\r\n'
                'You can only use each effect of "Gold Saint - Saga of Gemini" once per turn.'
            ),
        ),
        (
            922100033,
            "Gold Saint - Dohko of Libra - Master of the Five Ancient Peaks",
            2400,
            2400,
            4,
            1,  # EARTH
            1,
            8388641,
            setcode_gold,
            (
                '3 Level 4 "Saint" monsters\r\n'
                'This card gains these effects based on the number of materials attached to it.\r\n'
                '● 1+: Cannot be destroyed by battle.\r\n'
                '● 2+: Once per turn: You can detach 1 material from this card; destroy 1 Spell/Trap on the field.\r\n'
                '● 3+: (Quick Effect): You can detach 1 material from this card; "Saint" monsters you control gain 1000 ATK '
                'and cannot be targeted by your opponent\'s card effects, until the end of this turn.\r\n'
                'Once per turn: You can target 1 "Cloth" card in your GY; attach it to this card as material.\r\n'
                'You can only use each effect of "Gold Saint - Dohko of Libra - Master of the Five Ancient Peaks" once per turn.'
            ),
        ),
        (
            922100034,
            "Gold Saint - Aldebaran of Taurus",
            2500,
            2800,
            4,
            1,
            1,
            8388641,
            setcode_gold,
            (
                '3 Level 4 "Saint" monsters\r\n'
                'Once per turn, when an opponent\'s monster declares an attack: You can detach 1 material from this card; '
                'negate that attack, and if you do, destroy that monster, then inflict 1000 damage to your opponent.\r\n'
                'Once per turn: You can target 1 "Cloth" card in your GY; attach it to this card as material.\r\n'
                'You can only use each effect of "Gold Saint - Aldebaran of Taurus" once per turn.'
            ),
        ),
        (
            922100035,
            "Gold Saint - Deathmask of Cancer",
            2300,
            2200,
            4,
            32,  # DARK
            1,
            8388641,
            setcode_gold,
            (
                '3 Level 4 "Saint" monsters\r\n'
                'Once per turn: You can detach 1 material from this card, then target up to 2 monsters in your opponent\'s GY; '
                'banish them, and if you do, this card gains 300 ATK for each card banished by this effect.\r\n'
                'Once per turn: You can target 1 "Cloth" card in your GY; attach it to this card as material.\r\n'
                'You can only use each effect of "Gold Saint - Deathmask of Cancer" once per turn.'
            ),
        ),
    ]

    for cid, name, atk, defe, rank, attribute, race, type_value, setcode, desc in cards:
        c.execute(
            "INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)",
            (cid, 4, 0, setcode, type_value, atk, defe, rank, race, attribute, 0),
        )
        c.execute(
            "INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
            (cid, name, desc, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""),
        )

    conn.commit()
    conn.close()
    print(f"Inserted/updated {len(cards)} cards (031-035).")


if __name__ == "__main__":
    main()


import sqlite3


def main() -> None:
    conn = sqlite3.connect("expansions/cards-unofficial.cdb")
    c = conn.cursor()

    SET_SAINT = 0x1D7
    SET_SILVER_SAINT = 0x1DA

    # Kiki is a civilian (not a Saint / Bronze Saint); 012+ are Silver Saints.
    setcode_kiki = 0
    setcode_silver = SET_SAINT | (SET_SILVER_SAINT << 16)

    cards = [
        (
            922100011,
            'Kiki - Messenger of the Cloth Sculptor',
            500,
            500,
            2,  # Level
            16,  # LIGHT
            0x100000,  # Psychic
            (
                '(Quick Effect): You can discard this card, then target 1 "Saint" monster you control; equip 1 "Cloth" '
                'Equip Spell from your Deck or GY to that target.\r\n'
                'During the Standby Phase of the next turn after this card was sent to the GY: You can banish this card; '
                'add up to 2 "Cloth" cards with different names from your GY to your hand.\r\n'
                'You can only use each effect of "Kiki - Messenger of the Cloth Sculptor" once per turn.'
            ),
            33,  # Effect Monster
            setcode_kiki,
        ),
        (
            922100012,
            "Silver Saint - Marin of Eagle",
            2200,
            1400,
            8,
            8,  # WIND
            1,  # Warrior
            (
                '1 Tuner + 1+ non-Tuner "Saint" monsters\r\n'
                'For the Synchro Summon of this card, you can treat 1 "Bronze Saint" monster you control as a Tuner.\r\n'
                '(Quick Effect): You can return this card to the hand; Special Summon 1 Level 4 or lower "Saint" monster '
                'from your hand or GY.\r\n'
                'You can only use this effect of "Silver Saint - Marin of Eagle" once per turn.'
            ),
            8225,  # Synchro/Effect
            setcode_silver,
        ),
        (
            922100013,
            "Silver Saint - Shaina of Ophiuchus",
            2400,
            1200,
            8,
            16,  # LIGHT
            1,
            (
                '1 Tuner + 1+ non-Tuner "Saint" monsters\r\n'
                'For the Synchro Summon of this card, you can treat 1 "Bronze Saint" monster you control as a Tuner.\r\n'
                'When this card declares an attack: You can negate the effects of all face-up monsters your opponent '
                'currently controls until the end of this Battle Phase.'
            ),
            8225,
            setcode_silver,
        ),
        (
            922100014,
            "Silver Saint - Algol of Perseus",
            2300,
            1800,
            8,
            1,  # EARTH
            1,
            (
                '1 Tuner + 1+ non-Tuner "Saint" monsters\r\n'
                'For the Synchro Summon of this card, you can treat 1 "Bronze Saint" monster you control as a Tuner.\r\n'
                "Opponent's monsters in this card's column are changed to Defense Position, also their effects are negated, "
                "and they cannot change their battle positions."
            ),
            8225,
            setcode_silver,
        ),
        (
            922100015,
            "Silver Saint - Misty of Lacerta",
            2000,
            2500,
            8,
            2,  # WATER
            1,
            (
                '1 Tuner + 1+ non-Tuner "Saint" monsters\r\n'
                'For the Synchro Summon of this card, you can treat 1 "Bronze Saint" monster you control as a Tuner.\r\n'
                'Your opponent cannot target "Saint" monsters you control with card effects, except this one.\r\n'
                'Once per turn, if this card would be destroyed by battle or card effect, it is not destroyed.'
            ),
            8225,
            setcode_silver,
        ),
        (
            922100016,
            "Silver Saint - Orphee of Lyra",
            2700,
            2000,
            8,
            16,
            1,
            (
                '1 Tuner + 1+ non-Tuner "Saint" monsters\r\n'
                'For the Synchro Summon of this card, you can treat 1 "Bronze Saint" monster you control as a Tuner.\r\n'
                '(Quick Effect): You can send 1 "Cloth" card you control to the GY; negate the effects of all monsters your '
                'opponent currently controls until the end of this turn.\r\n'
                'You can only use this effect of "Silver Saint - Orphee of Lyra" once per turn.'
            ),
            8225,
            setcode_silver,
        ),
        (
            922100017,
            "Silver Saint - Hound Asterion",
            2400,
            2000,
            8,
            16,
            1,
            (
                '1 Tuner + 1+ non-Tuner "Saint" monsters\r\n'
                'For the Synchro Summon of this card, you can treat 1 "Bronze Saint" monster you control as a Tuner.\r\n'
                "Once per turn: You can reveal 1 random card in your opponent's hand, then apply this effect based on its type.\r\n"
                "● Monster: Negate the effects of 1 face-up monster your opponent controls until the end of this turn.\r\n"
                "● Spell/Trap: Set 1 Spell/Trap your opponent controls face-down."
            ),
            8225,
            setcode_silver,
        ),
        (
            922100018,
            "Silver Saint - Whale Moses",
            2500,
            2200,
            8,
            2,
            1,
            (
                '1 Tuner + 1+ non-Tuner "Saint" monsters\r\n'
                'For the Synchro Summon of this card, you can treat 1 "Bronze Saint" monster you control as a Tuner.\r\n'
                'Once per turn (Quick Effect): You can target 1 face-up monster your opponent controls; return it to the hand.\r\n'
                'Also, for the rest of this turn, your opponent cannot Special Summon monsters with the same original name as '
                "that returned monster."
            ),
            8225,
            setcode_silver,
        ),
        (
            922100019,
            "Silver Saint - Centaurus Babel",
            2300,
            2100,
            8,
            8,
            1,
            (
                '1 Tuner + 1+ non-Tuner "Saint" monsters\r\n'
                'For the Synchro Summon of this card, you can treat 1 "Bronze Saint" monster you control as a Tuner.\r\n'
                'When your opponent activates a Spell/Trap Card or effect (Quick Effect): You can send 1 "Cloth" card from '
                'your hand or face-up field to the GY; negate that activation, and if you do, destroy that card.\r\n'
                'You can only use this effect of "Silver Saint - Centaurus Babel" once per turn.'
            ),
            8225,
            setcode_silver,
        ),
        (
            922100020,
            "Silver Saint - Crow Jamian",
            2400,
            1800,
            8,
            32,  # DARK
            1,
            (
                '1 Tuner + 1+ non-Tuner "Saint" monsters\r\n'
                'For the Synchro Summon of this card, you can treat 1 "Bronze Saint" monster you control as a Tuner.\r\n'
                "Once per turn: You can target 1 monster your opponent controls; it loses 800 ATK, also it cannot attack or "
                "activate its effects this turn. If that monster leaves the field this turn, inflict 400 damage to your opponent."
            ),
            8225,
            setcode_silver,
        ),
    ]

    for cid, name, atk, defe, level, attribute, race, desc, type_value, setcode in cards:
        c.execute(
            "INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)",
            (
                cid,
                4,
                0,
                setcode,
                type_value,
                atk,
                defe,
                level,
                race,
                attribute,
                0,
            ),
        )
        c.execute(
            "INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
            (cid, name, desc, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""),
        )

    conn.commit()
    conn.close()
    print(f"Inserted/updated {len(cards)} cards (011-020).")


if __name__ == "__main__":
    main()


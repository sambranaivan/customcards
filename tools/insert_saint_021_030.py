import sqlite3


def main() -> None:
    conn = sqlite3.connect("expansions/cards-unofficial.cdb")
    c = conn.cursor()

    SET_SAINT = 0x1D7
    SET_SILVER_SAINT = 0x1DA
    SET_GOLD_SAINT = 0x1DB

    # 021-027 are Silver Saints
    setcode_silver = SET_SAINT | (SET_SILVER_SAINT << 16)
    # 028-030 are Gold Saints
    setcode_gold = SET_SAINT | (SET_GOLD_SAINT << 16)

    cards = [
        (
            922100021,
            "Silver Saint - Cerberus Dante",
            2500,
            2300,
            8,
            32,  # DARK
            1,  # Warrior
            8225,  # Synchro/Effect
            setcode_silver,
            (
                '1 Tuner + 1+ non-Tuner "Saint" monsters\r\n'
                'For the Synchro Summon of this card, you can treat 1 "Bronze Saint" monster you control as a Tuner.\r\n'
                'Once per turn: You can target up to 2 cards in either GY; banish them. If a card(s) is banished by this '
                'effect, your opponent cannot activate cards or effects with the same original name as those banished cards '
                'for the rest of this turn.'
            ),
        ),
        (
            922100022,
            "Silver Saint - Auriga Capella",
            2600,
            1900,
            8,
            16,  # LIGHT
            1,
            8225,
            setcode_silver,
            (
                '1 Tuner + 1+ non-Tuner "Saint" monsters\r\n'
                'For the Synchro Summon of this card, you can treat 1 "Bronze Saint" monster you control as a Tuner.\r\n'
                'Once per turn (Quick Effect): You can target 1 Spell/Trap your opponent controls; destroy it, then if you '
                'control a face-up "Cloth" card, this card gains 400 ATK until the end of this turn.'
            ),
        ),
        (
            922100023,
            "Silver Saint - Canis Major Sirius",
            2500,
            2100,
            8,
            1,  # EARTH
            1,
            8225,
            setcode_silver,
            (
                '1 Tuner + 1+ non-Tuner "Saint" monsters\r\n'
                'For the Synchro Summon of this card, you can treat 1 "Bronze Saint" monster you control as a Tuner.\r\n'
                'When this card battles an opponent\'s monster, at the start of the Damage Step: You can make that opponent\'s '
                'monster lose 1000 ATK/DEF until the end of this turn.\r\n'
                'Once per turn, when your opponent activates a monster effect in the Battle Phase (Quick Effect): You can '
                'negate that effect.'
            ),
        ),
        (
            922100024,
            "Silver Saint - Musca Dio",
            2200,
            2200,
            8,
            32,
            1,
            8225,
            setcode_silver,
            (
                '1 Tuner + 1+ non-Tuner "Saint" monsters\r\n'
                'For the Synchro Summon of this card, you can treat 1 "Bronze Saint" monster you control as a Tuner.\r\n'
                'Once per turn: You can target 1 face-up monster your opponent controls; place 1 Fly Counter on it.\r\n'
                'Monsters with a Fly Counter have their effects negated, also they cannot be used as material for a Special '
                'Summon from the Extra Deck.'
            ),
        ),
        (
            922100025,
            "Silver Saint - Heracles Algethi",
            2700,
            2000,
            8,
            1,
            1,
            8225,
            setcode_silver,
            (
                '1 Tuner + 1+ non-Tuner "Saint" monsters\r\n'
                'For the Synchro Summon of this card, you can treat 1 "Bronze Saint" monster you control as a Tuner.\r\n'
                'Once per turn (Quick Effect): You can target 1 face-up monster your opponent controls; its ATK becomes 0 '
                'until the end of this turn, also this card can make a second attack during each Battle Phase this turn.'
            ),
        ),
        (
            922100026,
            "Silver Saint - Sagitta Ptolemy",
            2300,
            1700,
            8,
            16,
            1,
            8225,
            setcode_silver,
            (
                '1 Tuner + 1+ non-Tuner "Saint" monsters\r\n'
                'For the Synchro Summon of this card, you can treat 1 "Bronze Saint" monster you control as a Tuner.\r\n'
                'Once per turn: You can target 1 face-up monster your opponent controls; inflict damage to your opponent '
                'equal to half that monster\'s current ATK, and if you do, that target cannot activate its effects this turn.'
            ),
        ),
        (
            922100027,
            "Silver Saint - Cepheus Daidalos",
            2400,
            2400,
            8,
            16,
            1,
            8225,
            setcode_silver,
            (
                '1 Tuner + 1+ non-Tuner "Saint" monsters\r\n'
                'For the Synchro Summon of this card, you can treat 1 "Bronze Saint" monster you control as a Tuner.\r\n'
                'If this card is Synchro Summoned: You can Special Summon 1 Level 4 or lower "Saint" monster from your GY, '
                'but negate its effects.\r\n'
                'Once per turn (Quick Effect): You can target 1 face-up monster on the field; it cannot be destroyed by '
                'battle this turn, also it cannot activate its effects this turn.'
            ),
        ),
        (
            922100028,
            "Gold Saint - Flash of Hope of the Five",
            2500,
            0,
            4,  # Link rating stored in level
            16,
            1,
            67108897,  # Link/Effect
            setcode_gold,
            (
                '2+ "Saint" monsters\r\n'
                'This card gains 500 ATK for each Equip Card on the field.\r\n'
                'Once per turn (Quick Effect): You can target 1 "Cloth" Equip Spell in your GY; equip it to this card.\r\n'
                'This card gains the effects of "Saint" monsters currently equipped with their corresponding "Cloth" cards.'
            ),
        ),
        (
            922100029,
            "Gold Saint - Mu of Aries",
            2100,
            2600,
            8,  # Rank stored in level
            16,
            1,
            8388641,  # Xyz/Effect
            setcode_gold,
            (
                '2 Level 8 "Saint" monsters\r\n'
                'You can detach 1 material; add 1 "Cloth" card from your GY to your hand, or if that card was a "Gold Cloth", '
                'you can equip it to a monster you control instead.\r\n'
                'Once per turn: You can target 1 "Cloth" card in your GY; attach it to this card as material.\r\n'
                'You can only use each effect of "Gold Saint - Mu of Aries" once per turn.'
            ),
        ),
        (
            922100030,
            "Gold Saint - Aiolia of Leo",
            2800,
            2000,
            8,
            16,
            1,
            8388641,
            setcode_gold,
            (
                '2 Level 8 "Saint" monsters\r\n'
                'Once per turn: You can detach any number of materials from this card; destroy up to that many monsters your '
                'opponent controls.\r\n'
                'Once per turn: You can target 1 "Cloth" card in your GY; attach it to this card as material.\r\n'
                'You can only use each effect of "Gold Saint - Aiolia of Leo" once per turn.'
            ),
        ),
    ]

    for cid, name, atk, defe, level, attribute, race, type_value, setcode, desc in cards:
        c.execute(
            "INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)",
            (cid, 4, 0, setcode, type_value, atk, defe, level, race, attribute, 0),
        )
        c.execute(
            "INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
            (cid, name, desc, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""),
        )

    conn.commit()
    conn.close()
    print(f"Inserted/updated {len(cards)} cards (021-030).")


if __name__ == "__main__":
    main()


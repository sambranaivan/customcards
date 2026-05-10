import sqlite3


def main() -> None:
    conn = sqlite3.connect("expansions/saint-seiya.cdb")
    c = conn.cursor()

    # setcode for Bronze Saint monster: SET_SAINT(0x1D7) | SET_BRONZE_SAINT(0x1D9)
    setcode_monster = (0x1D9 << 16) | 0x1D7  # 30998999

    # setcode for Bronze Cloth: SET_CLOTH(0x1D8) | SET_BRONZE_CLOTH(0x1EC)
    setcode_cloth = (0x1EC << 16) | 0x1D8  # 32244184

    # ── 922100320: Bronze Saint - June of Chameleon ──────────────────────────
    desc_june = (
        'When this card is Normal or Special Summoned: You can add 1 "Bronze Cloth - Chameleon" '
        'from your Deck or GY to your hand.\r\n'
        'You can only use this effect of "Bronze Saint - June of Chameleon" once per turn.\r\n'
        'If this card is equipped with a "Cloth" Equip Spell: This card cannot be targeted by '
        'the opponent\'s card effects.\r\n'
        'Once per turn: You can target 1 "Bronze Saint" monster you control, other than this card, '
        'that is equipped with an Equip Spell; until the End Phase, your opponent cannot target '
        'that monster with card effects.\r\n'
        'You can only use this effect of "Bronze Saint - June of Chameleon" once per turn.'
    )
    c.execute(
        "INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)",
        (
            922100320,
            4,           # ot: Custom
            0,           # alias
            setcode_monster,
            33,          # type: TYPE_MONSTER(1) | TYPE_EFFECT(32)
            1300,        # atk
            1600,        # def
            4,           # level
            1,           # race: Warrior
            16,          # attribute: LIGHT
            0,           # category
        ),
    )
    strs_june = [
        'Add 1 "Bronze Cloth - Chameleon" from your Deck or GY to your hand?',
        'Target 1 "Bronze Saint" monster; opponent cannot target it with card effects until End Phase?',
        "", "", "", "", "", "", "", "", "", "", "", "", "", "",
    ]
    c.execute(
        "INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
        (922100320, "Bronze Saint - June of Chameleon", desc_june, *strs_june),
    )

    # ── 922100321: Bronze Cloth - Chameleon ──────────────────────────────────
    desc_cloth = (
        'Equip only to a "Saint" monster.\r\n'
        'The equipped monster cannot be targeted by the opponent\'s card effects.\r\n'
        'Once per turn: You can change the battle position of the equipped monster.\r\n'
        'You can only use this effect of "Bronze Cloth - Chameleon" once per turn.\r\n'
        'If the equipped monster would be destroyed by a card effect: You can send this card '
        'from the field to the GY instead; the equipped monster is not destroyed.\r\n'
        'You can only use this effect of "Bronze Cloth - Chameleon" once per turn.'
    )
    c.execute(
        "INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)",
        (
            922100321,
            4,           # ot: Custom
            0,           # alias
            setcode_cloth,
            262146,      # type: TYPE_SPELL(2) | TYPE_EQUIP(262144)
            0,           # atk
            0,           # def
            0,           # level
            0,           # race
            0,           # attribute
            0,           # category
        ),
    )
    strs_cloth = [
        "Change the battle position of the equipped monster?",
        "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",
    ]
    c.execute(
        "INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
        (922100321, "Bronze Cloth - Chameleon", desc_cloth, *strs_cloth),
    )

    conn.commit()
    conn.close()
    print("Inserted: 922100320 - Bronze Saint - June of Chameleon")
    print("Inserted: 922100321 - Bronze Cloth - Chameleon")


if __name__ == "__main__":
    main()

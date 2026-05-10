import sqlite3


def main() -> None:
    conn = sqlite3.connect("expansions/saint-seiya.cdb")
    c = conn.cursor()

    # setcode: SET_SAINT (0x1D7) | SET_BRONZE_SAINT (0x1D9)
    setcode = (0x1D9 << 16) | 0x1D7   # 30998999

    desc = (
        '3 Level 4 "Bronze Saint" monsters\r\n'
        'While this card has 3 or more Xyz Materials, it cannot be destroyed by battle or card effects, '
        'and your opponent cannot target it with card effects.\r\n'
        'Once per turn: You can detach 1 "Bronze Cloth" Equip Spell Xyz Material from this card; '
        'this card can make 2 attacks on monsters this turn, also for each of its attacks this turn, '
        'your opponent cannot activate cards or effects until the end of the Damage Step.\r\n'
        'You can only use this effect of "Bronze Saints - Burning Five Stars" once per turn.\r\n'
        'Once per turn: You can target 1 "Bronze Cloth" Equip Spell in your GY; attach it to this '
        'card as Xyz Material. If you activate this effect, you cannot activate the other effect of '
        '"Bronze Saints - Burning Five Stars" this turn.\r\n'
        'You can only use this effect of "Bronze Saints - Burning Five Stars" once per turn.\r\n'
        'When this card is destroyed and sent to the GY: You can Special Summon up to 3 "Bronze Saint" '
        'monsters from your GY.'
    )

    # type: TYPE_MONSTER(1) | TYPE_EFFECT(32) | TYPE_XYZ(8388608) = 8388641
    c.execute(
        "INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)",
        (
            922100308,
            4,         # ot: Custom
            0,         # alias
            setcode,
            8388641,   # type: Xyz Effect Monster
            2800,      # atk
            2400,      # def
            4,         # level (Rank 4)
            1,         # race: Warrior
            16,        # attribute: LIGHT
            0,         # category
        ),
    )
    strs = [
        "Activate the battle fury effect of \"Bronze Saints - Burning Five Stars\"?",
        "Attach 1 \"Bronze Cloth\" from GY as Xyz Material?",
        "Special Summon \"Bronze Saint\" monsters from GY?",
        "", "", "", "", "", "", "", "", "", "", "", "", "",
    ]
    c.execute(
        "INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
        (922100308, "Bronze Saints - Burning Five Stars", desc, *strs),
    )

    conn.commit()
    conn.close()
    print("Inserted: 922100308 - Bronze Saints - Burning Five Stars")


if __name__ == "__main__":
    main()

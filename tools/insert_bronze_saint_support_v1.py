import sqlite3


def main() -> None:
    conn = sqlite3.connect("expansions/saint-seiya.cdb")
    c = conn.cursor()

    SET_SAINT = 0x1D7  # 471

    cards = [
        {
            "id": 922100303,
            "name": "Bronze Cloth Awakening",
            "type": 65538,   # Quick-Play Spell
            "desc": (
                'Equip up to 2 "Bronze Cloth" Equip Spells with different names from your Deck '
                'to 1 "Bronze Saint" monster you control.\r\n'
                'You cannot Special Summon from the Extra Deck the turn you activate this card, '
                'except "Saint" monsters.\r\n'
                'You can only activate 1 "Bronze Cloth Awakening" per turn.'
            ),
            "strs": ["", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""],
        },
        {
            "id": 922100304,
            "name": "Legend of the Bronze Saints",
            "type": 524290,  # Field Spell
            "desc": (
                'All "Bronze Saint" monsters gain 500 ATK/DEF.\r\n'
                'Once per turn: You can target 1 "Bronze Saint" monster you control equipped '
                'with a "Bronze Cloth" Equip Spell; until the End Phase, that target gains ATK '
                'equal to its current DEF.\r\n'
                'Once per turn, if a "Bronze Saint" monster you control would be destroyed by '
                'battle or card effect: You can send 1 "Bronze Cloth" Equip Spell equipped to '
                'it to the GY instead.\r\n'
                'You can only use each effect of "Legend of the Bronze Saints" once per turn.'
            ),
            "strs": [
                "Activate the ATK boost effect of \"Legend of the Bronze Saints\"?",
                "Activate the destruction replacement of \"Legend of the Bronze Saints\"?",
                "", "", "", "", "", "", "", "", "", "", "", "", "", "",
            ],
        },
        {
            "id": 922100305,
            "name": "Saintly Bond",
            "type": 2,       # Normal Spell
            "desc": (
                'Target 1 "Bronze Saint" monster in your GY; Special Summon it, then you can '
                'equip 1 "Bronze Cloth" Equip Spell from your GY to it.\r\n'
                'If this card is in your GY: You can banish this card; add 1 "Bronze Saint" '
                'monster or 1 "Bronze Cloth" Equip Spell from your Deck to your hand.\r\n'
                'You can only use each effect of "Saintly Bond" once per turn.'
            ),
            "strs": [
                "Equip 1 \"Bronze Cloth\" from GY to the Special Summoned monster?",
                "Activate the GY effect of \"Saintly Bond\"?",
                "", "", "", "", "", "", "", "", "", "", "", "", "", "",
            ],
        },
        {
            "id": 922100306,
            "name": "Bronze Saint Oath",
            "type": 1048580, # Counter Trap
            "desc": (
                'When your opponent activates a card or effect while you control a "Bronze Saint" '
                'monster equipped with a "Cloth" card: Negate the activation, and if you do, '
                'destroy that card.\r\n'
                'You can only activate 1 "Bronze Saint Oath" per turn.'
            ),
            "strs": ["", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""],
        },
        {
            "id": 922100307,
            "name": "Cosmo Surge",
            "type": 65538,   # Quick-Play Spell
            "desc": (
                'Target 1 "Bronze Saint" monster you control; until the End Phase of this turn, '
                'it gains 500 ATK for each "Cloth" Equip Spell equipped to "Bronze Saint" monsters '
                'you control.\r\n'
                'You can only activate 1 "Cosmo Surge" per turn.'
            ),
            "strs": ["", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""],
        },
    ]

    for card in cards:
        c.execute(
            "INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)",
            (
                card["id"],
                4,           # ot: Custom
                0,           # alias
                SET_SAINT,   # setcode
                card["type"],
                0,           # atk
                0,           # def
                0,           # level
                0,           # race
                0,           # attribute
                0,           # category
            ),
        )
        strs = card.get("strs", [""] * 16)
        c.execute(
            "INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
            (
                card["id"],
                card["name"],
                card["desc"],
                *strs,
            ),
        )
        print(f"Inserted: {card['id']} - {card['name']}")

    conn.commit()
    conn.close()
    print("Done!")


if __name__ == "__main__":
    main()

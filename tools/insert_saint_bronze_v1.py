import re
import sqlite3


def main() -> None:
    conn = sqlite3.connect("expansions/cards-unofficial.cdb")
    c = conn.cursor()

    SET_SAINT = 0x1D7

    cards = [
        (
            922100000,
            "Saint - Seiya of Pegasus",
            1700,
            1200,
            16,  # LIGHT
            (
                'If this card is Normal or Special Summoned: You can add 1 "Cloth" Equip Spell or 1 "Saint" monster '
                'from your Deck to your hand.\r\n'
                'If you control no monsters, or all monsters you control are "Saint" monsters: You can Special Summon '
                'this card from your hand.\r\n'
                'Once per turn: You can pay 500 LP; equip 1 "Cloth" Equip Spell from your hand or GY to this card, '
                'also for the rest of this turn after this effect resolves, you cannot Special Summon from the Extra '
                'Deck, except "Saint" monsters.\r\n'
                'If this card is sent to the GY as material for the Summon of a "Saint" monster: You can equip 1 '
                '"Cloth" card you control to that monster, or attach it to that monster as material (if it is an Xyz '
                'Monster).\r\n'
                'You can only use each effect of "Saint - Seiya of Pegasus" once per turn.'
            ),
        ),
        (
            922100001,
            "Saint - Shiryu of Dragon",
            1500,
            1800,
            1,  # EARTH
            (
                '(Quick Effect): You can discard this card; "Cloth" cards you control cannot be destroyed by card '
                'effects this turn.\r\n'
                'Once per turn: You can pay 500 LP; equip 1 "Cloth" Equip Spell from your hand or GY to this card, '
                'also for the rest of this turn after this effect resolves, you cannot Special Summon from the Extra '
                'Deck, except "Saint" monsters.\r\n'
                'If this card is sent to the GY as material for the Summon of a "Saint" monster: You can equip 1 '
                '"Cloth" card you control to that monster, or attach it to that monster as material (if it is an Xyz '
                'Monster).\r\n'
                'You can only use each effect of "Saint - Shiryu of Dragon" once per turn.'
            ),
        ),
        (
            922100002,
            "Saint - Hyoga of Cygnus",
            1600,
            1400,
            2,  # WATER
            (
                "If this card battles an opponent's monster, after damage calculation: Change that opponent's monster "
                "to Defense Position, and if you do, negate its effects until the end of your opponent's next turn.\r\n"
                'Once per turn: You can pay 500 LP; equip 1 "Cloth" Equip Spell from your hand or GY to this card, '
                'also for the rest of this turn after this effect resolves, you cannot Special Summon from the Extra '
                'Deck, except "Saint" monsters.\r\n'
                'If this card is sent to the GY as material for the Summon of a "Saint" monster: You can equip 1 '
                '"Cloth" card you control to that monster, or attach it to that monster as material (if it is an Xyz '
                'Monster).\r\n'
                'You can only use each effect of "Saint - Hyoga of Cygnus" once per turn.'
            ),
        ),
        (
            922100003,
            "Saint - Shun of Andromeda",
            1300,
            1900,
            8,  # WIND
            (
                'Your opponent cannot target other "Saint" monsters you control for attacks.\r\n'
                'If this card is equipped with a "Cloth" card, it can attack while in Defense Position. Apply its ATK '
                "for damage calculation.\r\n"
                'Once per turn: You can pay 500 LP; equip 1 "Cloth" Equip Spell from your hand or GY to this card, '
                'also for the rest of this turn after this effect resolves, you cannot Special Summon from the Extra '
                'Deck, except "Saint" monsters.\r\n'
                'If this card is sent to the GY as material for the Summon of a "Saint" monster: You can equip 1 '
                '"Cloth" card you control to that monster, or attach it to that monster as material (if it is an Xyz '
                'Monster).\r\n'
                'You can only use each effect of "Saint - Shun of Andromeda" once per turn.'
            ),
        ),
        (
            922100004,
            "Saint - Ikki of Phoenix",
            1800,
            1000,
            4,  # FIRE
            (
                'If this card is in your GY: You can discard 1 "Saint" card; Special Summon this card.\r\n'
                'Once per turn: You can pay 500 LP; equip 1 "Cloth" Equip Spell from your hand or GY to this card, '
                'also for the rest of this turn after this effect resolves, you cannot Special Summon from the Extra '
                'Deck, except "Saint" monsters.\r\n'
                'If this card is sent to the GY as material for the Summon of a "Saint" monster: You can equip 1 '
                '"Cloth" card you control to that monster, or attach it to that monster as material (if it is an Xyz '
                'Monster).\r\n'
                'You can only use each effect of "Saint - Ikki of Phoenix" once per turn.'
            ),
        ),
        (
            922100005,
            "Saint - Jabu of Unicorn",
            1700,
            1000,
            16,  # LIGHT
            (
                'If you control a "Saint" monster: You can Special Summon this card from your hand. You can only '
                'Special Summon "Saint - Jabu of Unicorn" once per turn this way.\r\n'
                'If this card is Special Summoned: You can add 1 "Cloth" card from your GY to your hand, then discard '
                '1 card.\r\n'
                'If this card is sent to the GY as material for the Summon of a "Saint" monster: You can equip 1 '
                '"Cloth" card you control to that monster, or attach it to that monster as material (if it is an Xyz '
                'Monster).\r\n'
                'You can only use each effect of "Saint - Jabu of Unicorn" once per turn.'
            ),
        ),
        (
            922100006,
            "Saint - Ichi of Hydra",
            1400,
            1200,
            2,  # WATER
            (
                'Once per turn: You can discard 1 "Cloth" card; inflict 800 damage to your opponent, and if you do, '
                'this card can attack directly this turn.\r\n'
                'If this card is sent to the GY: You can send 1 "Cloth" card from your Deck to the GY.\r\n'
                'If this card is sent to the GY as material for the Summon of a "Saint" monster: You can equip 1 '
                '"Cloth" card you control to that monster, or attach it to that monster as material (if it is an Xyz '
                'Monster).\r\n'
                'You can only use each effect of "Saint - Ichi of Hydra" once per turn.'
            ),
        ),
        (
            922100007,
            "Saint - Geki of Bear",
            1600,
            1600,
            1,  # EARTH
            (
                'If this card is Normal or Special Summoned: You can add 1 Level 5 or higher "Saint" monster from your '
                'Deck to your hand.\r\n'
                'If this card is in your GY: You can target 1 "Cloth" card in your GY; add it to your hand, then '
                'banish this card.\r\n'
                'If this card is sent to the GY as material for the Summon of a "Saint" monster: You can equip 1 '
                '"Cloth" card you control to that monster, or attach it to that monster as material (if it is an Xyz '
                'Monster).\r\n'
                'You can only use each effect of "Saint - Geki of Bear" once per turn.'
            ),
        ),
        (
            922100008,
            "Saint - Ban of Lionet",
            1500,
            1300,
            4,  # FIRE
            (
                'If a "Saint" monster(s) you control is destroyed by battle: You can Special Summon this card from your '
                'hand or GY.\r\n'
                'If this card is Special Summoned: You can target 1 "Saint" monster in your GY; add it to your hand.\r\n'
                'If this card is sent to the GY as material for the Summon of a "Saint" monster: You can equip 1 '
                '"Cloth" card you control to that monster, or attach it to that monster as material (if it is an Xyz '
                'Monster).\r\n'
                'You can only use each effect of "Saint - Ban of Lionet" once per turn.'
            ),
        ),
        (
            922100009,
            "Saint - Nachi of Wolf",
            1200,
            1000,
            8,  # WIND
            (
                'If this card is sent to the GY as Link Material or Tributed: You can draw 1 card, then discard 1 card.\r\n'
                'Once per turn: You can target 1 "Cloth" card in your GY; shuffle it into the Deck, then draw 1 card.\r\n'
                'If this card is sent to the GY as material for the Summon of a "Saint" monster: You can equip 1 '
                '"Cloth" card you control to that monster, or attach it to that monster as material (if it is an Xyz '
                'Monster).\r\n'
                'You can only use each effect of "Saint - Nachi of Wolf" once per turn.'
            ),
        ),
        (
            922100010,
            "Mu - The Cloth Repairer",
            1200,
            2000,
            16,  # LIGHT
            (
                'If this card is Normal or Special Summoned: You can target up to 2 "Cloth" Equip Spells in your GY; '
                'add them to your hand.\r\n'
                'During your Main Phase: You can discard this card; add 1 "Athena\'s Sanctuary" from your '
                'Deck to your hand.\r\n'
                'You can only use each effect of "Mu - The Cloth Repairer" once per turn.'
            ),
        ),
    ]

    for cid, name, atk, defe, attribute, desc in cards:
        setcode = SET_SAINT if re.search(r"saint", name, re.I) else 0
        # datas: id, ot, alias, setcode, type, atk, def, level, race, attribute, category
        c.execute(
            "INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)",
            (
                cid,
                4,  # ot
                0,  # alias
                setcode,
                33,  # type: Effect Monster
                atk,
                defe,
                4,  # level
                1,  # race: Warrior
                attribute,
                0,  # category
            ),
        )

        # texts: id, name, desc, str1-str16
        c.execute(
            "INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
            (cid, name, desc, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""),
        )

    conn.commit()
    conn.close()
    print(f"Inserted/updated {len(cards)} cards.")


if __name__ == "__main__":
    main()


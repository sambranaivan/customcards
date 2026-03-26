import sqlite3

conn = sqlite3.connect('expansions/cards-unofficial.cdb')
c = conn.cursor()

GOKU_SETCODE = 0x1d0  # 464
TYPE_FUSION_EFFECT = 97  # TYPE_MONSTER | TYPE_EFFECT | TYPE_FUSION (1+32+64)

# Goku Super Saiyan 2 - 900000013
# Warrior / Effect / Fusion, LIGHT, Level 9, ATK 3700 / DEF 3500
c.execute('INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)',
    (900000013, 4, 0, GOKU_SETCODE, TYPE_FUSION_EFFECT, 3700, 3500, 9, 1, 16, 0))
c.execute('INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
    (900000013, 'Goku Super Saiyan 2',
     '1 "Goku" Normal Monster + 1 or more Level 6 or higher Warrior monsters.\n'
     'Must first be Special Summoned (from your Extra Deck) by Tributing 1 "Goku Super Saiyan" while your LP is lower than your opponent\'s.\n'
     'Unaffected by monster effects.\n'
     'This card can attack all monsters your opponent controls, once each.\n'
     'If this card is destroyed by battle: You can add 1 "Goku" card from your Deck to your hand.\n'
     'If this card is used as material for the Summon of "Super Saiyan 3 Goku", that monster can attack directly, and if it does, you can add 1 "Dragon Fist" from your Deck to your hand.',
     'Add 1 "Goku" card from your Deck to your hand',
     'Grant effects to "Super Saiyan 3 Goku"',
     'Add 1 "Dragon Fist" from your Deck to your hand',
     '', '', '', '', '', '', '', '', '', '', '', '', ''))

# Super Saiyan 3 Goku - 900000014 (completado - datos definitivos en 007_goku_super_saiyan_3_insert_card.py)
# Warrior / Effect / Fusion, LIGHT, Level 10, ATK 4000 / DEF 3700
c.execute('INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)',
    (900000014, 4, 0, GOKU_SETCODE, TYPE_FUSION_EFFECT, 4000, 3700, 10, 1, 16, 0))
c.execute('INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
    (900000014, 'Super Saiyan 3 Goku',
     '1 "Goku" Normal Monster + 2 or more Level 6 or higher Warrior monsters.\n'
     'Must first be Special Summoned (from your Extra Deck) by banishing 1 "Goku Super Saiyan" and 1 "Goku Super Saiyan 2" from your hand, field, or GY. '
     'You can only control 1 "Super Saiyan 3 Goku". '
     'Unaffected by Spell/Trap effects. '
     'Once per turn, if "Dragon Fist" is activated while this card is on the field: This card\'s ATK becomes double its current ATK, and it can make up to 3 attacks during each Battle Phase this turn. '
     'If this card is destroyed by battle or card effect: You can add 1 "Vegeta" monster and 1 "Potara Earrings" from your Deck to your hand.',
     'Double ATK and attack up to 3 times',
     'Add 1 "Vegeta" monster and 1 "Potara Earrings" to your hand',
     '', '', '', '', '', '', '', '', '', '', '', '', '', ''))

# Dragon Fist - 900000015 (placeholder)
# Normal Spell
c.execute('INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)',
    (900000015, 4, 0, 0, 2, 0, 0, 0, 0, 0, 0))
c.execute('INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
    (900000015, 'Dragon Fist',
     'Placeholder card for the "Goku" card group.',
     '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''))

conn.commit()
conn.close()
print('3 cards inserted: Goku Super Saiyan 2 (new), Super Saiyan 3 Goku (placeholder), Dragon Fist (placeholder)')

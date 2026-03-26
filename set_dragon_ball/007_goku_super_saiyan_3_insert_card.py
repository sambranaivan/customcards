import sqlite3

conn = sqlite3.connect('expansions/cards-unofficial.cdb')
c = conn.cursor()

GOKU_SETCODE = 0x1d0    # 464
VEGETA_SETCODE = 0x1d1  # 465
TYPE_FUSION_EFFECT = 97  # TYPE_MONSTER | TYPE_EFFECT | TYPE_FUSION (1+32+64)
TYPE_EFFECT_MONSTER = 33 # TYPE_MONSTER | TYPE_EFFECT (1+32)

# Super Saiyan 3 Goku - 900000014 (completing placeholder)
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

# Vegeta - 900000016 (placeholder)
# Warrior / Effect, LIGHT, Level 8, ATK 3000 / DEF 2800
c.execute('INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)',
    (900000016, 4, 0, VEGETA_SETCODE, TYPE_EFFECT_MONSTER, 3000, 2800, 8, 1, 16, 0))
c.execute('INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
    (900000016, 'Vegeta',
     'Placeholder card for the "Vegeta" card group.',
     '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''))

# Potara Earrings - 900000017 (completado - datos definitivos en 009_potara_earrings_insert_card.py)
# Quick-Play Spell
c.execute('INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)',
    (900000017, 4, 0, 0, 65538, 0, 0, 0, 0, 0, 0))
c.execute('INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
    (900000017, 'Potara Earrings',
     'You can activate this card from your hand during your opponent\'s turn. '
     'Fusion Summon 1 Fusion Monster from your Extra Deck, by banishing Fusion Materials from your hand, field, or GY. '
     'If "Vegito" is Special Summoned by this effect, it gains the following effect:\n'
     '● Your opponent cannot target this card with card effects.',
     'Fusion Summon using banished materials',
     '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''))

conn.commit()
conn.close()
print('3 cards inserted: Super Saiyan 3 Goku (completed), Vegeta (placeholder), Potara Earrings (placeholder)')

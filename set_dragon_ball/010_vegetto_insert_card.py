import sqlite3

conn = sqlite3.connect('expansions/cards-unofficial.cdb')
c = conn.cursor()

VEGETTO_SETCODE = 0x1d2
TYPE_FUSION_EFFECT = 97  # TYPE_MONSTER | TYPE_EFFECT | TYPE_FUSION (1+32+64)

# Vegetto - 900000019 (completing placeholder)
# Warrior / Effect / Fusion, LIGHT, Level 10, ATK 5000 / DEF 5000
c.execute('INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)',
    (900000019, 4, 0, VEGETTO_SETCODE, TYPE_FUSION_EFFECT, 5000, 5000, 10, 1, 16, 0))
c.execute('INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
    (900000019, 'Vegetto',
     '1 "Goku" Level 7 or higher monster + 1+ "Vegeta" Level 7 or higher monster\n'
     'You can also Special Summon this card by banishing "Potara Earrings" and the required '
     'Fusion Materials from your GY. Cannot be destroyed by battle or card effects. '
     'This card can only remain on the field for 3 turns. During the End Phase of its 3rd turn, '
     'return this card to the Extra Deck. When this card leaves the field: You can Special Summon '
     'the materials used for its Fusion Summon from your banished zone. This card\'s ATK/DEF become '
     'the combined original ATK/DEF of the materials used for its Fusion Summon. Any battle damage '
     'this card inflicts to your opponent is doubled.',
     'Special Summon materials from banished',
     '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''))

conn.commit()
conn.close()
print('Vegetto (900000019) inserted successfully.')

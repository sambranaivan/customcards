import sqlite3

conn = sqlite3.connect('expansions/cards-unofficial.cdb')
c = conn.cursor()

GOKU_SETCODE = 0x1d0  # 464
TYPE_EFFECT_MONSTER = 33  # TYPE_MONSTER | TYPE_EFFECT

# Goku Super Saiyan - 900000003 (completing placeholder)
# Warrior / Effect, LIGHT, Level 8, ATK 3200 / DEF 3200
c.execute('INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)',
    (900000003, 4, 0, GOKU_SETCODE, TYPE_EFFECT_MONSTER, 3200, 3200, 8, 1, 16, 0))
c.execute('INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
    (900000003, 'Goku Super Saiyan',
     'Once per turn, if a monster is destroyed: You can Special Summon this card from your hand or GY. If "Krillin" is destroyed: You can also Special Summon this card from your Deck. While "Krillin" is in your GY, this card\'s ATK becomes double its original ATK. Once per turn: You can destroy all Spell and Trap cards your opponent controls. This card cannot be destroyed by battle or card effects. If this card battles "Frieza - Namek Ultimate Form", it gains ATK equal to that monster\'s ATK + 1000. This card cannot attack directly.',
     'Special Summon this card',
     'Destroy all opponent Spells/Traps',
     '', '', '', '', '', '', '', '', '', '', '', '', '', ''))

# Krillin - 900000011 (placeholder)
# Warrior / Effect, EARTH, Level 4, ATK 1500 / DEF 1200
c.execute('INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)',
    (900000011, 4, 0, 0, TYPE_EFFECT_MONSTER, 1500, 1200, 4, 1, 1, 0))
c.execute('INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
    (900000011, 'Krillin',
     'Placeholder card for the "Goku" card group.',
     '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''))

# Frieza - Namek Ultimate Form - 900000012 (placeholder)
# Fiend / Effect, DARK, Level 9, ATK 3500 / DEF 3000
c.execute('INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)',
    (900000012, 4, 0, 0, TYPE_EFFECT_MONSTER, 3500, 3000, 9, 8, 32, 0))
c.execute('INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
    (900000012, 'Frieza - Namek Ultimate Form',
     'Placeholder card for the "Goku" card group.',
     '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''))

conn.commit()
conn.close()
print('3 cards inserted: Goku Super Saiyan (completed), Krillin (placeholder), Frieza - Namek Ultimate Form (placeholder)')

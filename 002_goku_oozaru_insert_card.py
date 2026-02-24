import sqlite3

conn = sqlite3.connect('expansions/cards-unofficial.cdb')
c = conn.cursor()

GOKU_SETCODE = 0x1d0  # 464
TYPE_EFFECT_MONSTER = 33  # TYPE_MONSTER | TYPE_EFFECT
TYPE_FIELD_SPELL = 524290  # TYPE_SPELL(2) | TYPE_FIELD(0x80000)

# Goku Oozaru - 900000004
# Beast / Effect, EARTH, Level 4, ATK 2000 / DEF 1250
c.execute('INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)',
    (900000004, 4, 0, GOKU_SETCODE, TYPE_EFFECT_MONSTER, 2000, 1250, 4, 16384, 1, 0))
c.execute('INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
    (900000004, 'Goku Oozaru',
     'While "Full Moon" is not on the field, this card\'s ATK/DEF become 0. If this card is Special Summoned by the effect of "Kid Goku": You can activate 1 "Full Moon" directly from your Deck. Gains 1000 ATK for each "Goku" or Warrior monster in your GY. This card cannot attack your opponent directly. Once per turn: You can destroy all other cards on the field. This card is not treated as "Golden Oozaru".',
     'Activate "Full Moon" from Deck', 'Destroy all other cards on the field',
     '', '', '', '', '', '', '', '', '', '', '', '', '', ''))

# Full Moon - 900000005 (placeholder)
# Field Spell
c.execute('INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)',
    (900000005, 4, 0, 0, TYPE_FIELD_SPELL, 0, 0, 0, 0, 0, 0))
c.execute('INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
    (900000005, 'Full Moon',
     'Placeholder Field Spell for the "Goku" card group.',
     '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''))

# Golden Oozaru - 900000006 (placeholder)
# Beast / Effect, EARTH, Level 8, ATK 3500 / DEF 3000
c.execute('INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)',
    (900000006, 4, 0, GOKU_SETCODE, TYPE_EFFECT_MONSTER, 3500, 3000, 8, 16384, 1, 0))
c.execute('INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
    (900000006, 'Golden Oozaru',
     'Placeholder card for the "Goku" card group.',
     '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''))

conn.commit()
conn.close()
print('3 cards inserted: Goku Oozaru, Full Moon (placeholder), Golden Oozaru (placeholder)')

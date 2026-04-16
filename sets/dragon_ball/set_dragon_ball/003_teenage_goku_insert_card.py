import sqlite3

conn = sqlite3.connect('expansions/cards-unofficial.cdb')
c = conn.cursor()

GOKU_SETCODE = 0x1d0  # 464
TYPE_EFFECT_MONSTER = 33  # TYPE_MONSTER | TYPE_EFFECT
TYPE_NORMAL_SPELL = 2  # TYPE_SPELL

# Teenage Goku - 900000007
# Warrior / Effect, LIGHT, Level 4, ATK 1750 / DEF 2100
c.execute('INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)',
    (900000007, 4, 0, GOKU_SETCODE, TYPE_EFFECT_MONSTER, 1750, 2100, 4, 1, 16, 0))
c.execute('INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
    (900000007, 'Teenage Goku',
     'Gains 100 ATK for each card your opponent controls. Once per turn: You can add 1 "Kamehameha" from your Deck to your hand. When this card is destroyed: You can Special Summon 1 "Goku" monster from your GY, except "Goku Super Saiyan".',
     'Add 1 "Kamehameha" from Deck to hand',
     'Special Summon 1 "Goku" monster from GY',
     '', '', '', '', '', '', '', '', '', '', '', '', '', ''))

# Kamehameha - 900000008
# Quick-Play Spell (definitive data in 014_kamehameha_insert_card.py)
TYPE_QUICKPLAY_SPELL = 65538  # TYPE_SPELL | TYPE_QUICKPLAY
c.execute('INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)',
    (900000008, 4, 0, 0, TYPE_QUICKPLAY_SPELL, 0, 0, 0, 0, 0, 0))
c.execute('INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
    (900000008, 'Kamehameha',
     'Quick-Play Spell. See 014_kamehameha_insert_card.py for full description.',
     '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''))

# Cleanup: remove old duplicate "Goku Super Saiyan" (900000009)
# Merged with "Goku Super Saiyan" (900000003) from 001_kid_goku_insert_card.py
c.execute('DELETE FROM datas WHERE id=900000009')
c.execute('DELETE FROM texts WHERE id=900000009')

conn.commit()
conn.close()
print('2 cards inserted: Teenage Goku, Kamehameha (placeholder)')
print('1 card removed: Goku Super Saiyan (900000009) - merged with Goku Super Saiyan (900000003)')

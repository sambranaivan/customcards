import sqlite3

conn = sqlite3.connect('expansions/cards-unofficial.cdb')
c = conn.cursor()

SET_SAIYAN = 0x1d4
TYPE_QUICKPLAY_SPELL = 65538  # TYPE_SPELL | TYPE_QUICKPLAY (2+65536)
TYPE_EFFECT = 33              # TYPE_MONSTER | TYPE_EFFECT

# Kamehameha - 900000008 (completing placeholder)
# Quick-Play Spell (allows activation during opponent's turn per card text)
c.execute('INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)',
    (900000008, 4, 0, 0, TYPE_QUICKPLAY_SPELL, 0, 0, 0, 0, 0, 0))
c.execute('INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
    (900000008, 'Kamehameha',
     'If you control a "Goku" monster, a "Gohan" monster, "Krillin", "Trunks", "Goten", '
     'AND "Master Roshi": Target 1 card on the field; destroy it. Your opponent cannot '
     'activate cards or effects in response to this card\'s activation.\n'
     'If your opponent controls more monsters than you do: You can activate this card as a '
     'Quick Effect; target 1 card on the field; send it to the GY, and if you do, end your '
     'opponent\'s turn.\n'
     'You can banish this card from your GY: Add 1 "Goku" monster, "Gohan" monster, "Krillin", '
     '"Trunks", or "Goten" from your Deck to your hand, OR Special Summon 1 "Master Roshi" from '
     'your Deck, and if you do, double its ATK.',
     'Destroy 1 card (cannot be responded to)',
     'Send to GY and end opponent\'s turn',
     '',
     'Add 1 character to hand',
     'Special Summon Master Roshi (double ATK)',
     'Banish: Add or Special Summon',
     '', '', '', '', '', '', '', '', '', ''))

# Trunks - 900000028 (placeholder)
# Warrior / Effect, LIGHT, Level 6, ATK 2500 / DEF 2000
c.execute('INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)',
    (900000028, 4, 0, SET_SAIYAN, TYPE_EFFECT, 2500, 2000, 6, 1, 16, 0))
c.execute('INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
    (900000028, 'Trunks',
     'Placeholder card for "Trunks".',
     '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''))

# Goten - 900000029 (placeholder)
# Warrior / Effect, LIGHT, Level 5, ATK 2000 / DEF 1800
c.execute('INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)',
    (900000029, 4, 0, SET_SAIYAN, TYPE_EFFECT, 2000, 1800, 5, 1, 16, 0))
c.execute('INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
    (900000029, 'Goten',
     'Placeholder card for "Goten".',
     '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''))

# Master Roshi - 900000030 (placeholder)
# Warrior / Effect, EARTH, Level 4, ATK 1000 / DEF 1000
c.execute('INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)',
    (900000030, 4, 0, 0, TYPE_EFFECT, 1000, 1000, 4, 1, 1, 0))
c.execute('INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
    (900000030, 'Master Roshi',
     'Placeholder card for "Master Roshi".',
     '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''))

conn.commit()
conn.close()
print('4 cards inserted: Kamehameha (completed), Trunks, Goten, Master Roshi (placeholders)')

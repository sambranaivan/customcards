import sqlite3

conn = sqlite3.connect('expansions/cards-unofficial.cdb')
c = conn.cursor()

SET_GOGETA = 0x1d3
SET_SAIYAN = 0x1d4

TYPE_FUSION_EFFECT = 97      # TYPE_MONSTER | TYPE_EFFECT | TYPE_FUSION
TYPE_SPELL = 2               # Normal Spell
TYPE_CONTINUOUS_SPELL = 131074  # TYPE_SPELL | TYPE_CONTINUOUS (2+131072)

gogeta_setcode = SET_GOGETA | (SET_SAIYAN << 16)

# Super Saiyan Gogeta - 900000025
# Warrior / Fusion / Effect, LIGHT, Level 10, ATK 3500 / DEF 5000
c.execute('INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)',
    (900000025, 4, 0, gogeta_setcode, TYPE_FUSION_EFFECT, 3500, 5000, 10, 1, 16, 0))
c.execute('INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
    (900000025, 'Super Saiyan Gogeta',
     '1 Level 7 or higher "Goku" monster + 1+ Level 7 or higher "Vegeta" monster\n'
     'Must be Fusion Summoned with "Metamor" or by a card effect that specifically lists this card. '
     'This card can only remain on the field for 3 turns. During the End Phase of its 3rd turn, '
     'send this card to the GY, then: Special Summon 1 Normal "Goku" monster and 1 Normal "Vegeta" '
     'monster from your Deck, GY, or banished zone, also you can add 1 "Genkidama" from your Deck '
     'to your hand, and if you do, you can activate it, then place 10 counters on it. '
     'This card gains ATK equal to the difference between your LP and your opponent\'s LP. '
     'This card is unaffected by card effects during the Battle Phase. '
     'When this card declares an attack: Negate the effects of all face-up cards your opponent controls '
     '(until the end of this turn).',
     'Add Genkidama from Deck',
     'Activate Genkidama with 10 counters',
     '', '', '', '', '', '', '', '', '', '', '', '', '', ''))

# Metamor - 900000026 (placeholder)
# Normal Spell
c.execute('INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)',
    (900000026, 4, 0, 0, TYPE_SPELL, 0, 0, 0, 0, 0, 0))
c.execute('INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
    (900000026, 'Metamor',
     'Placeholder card for the "Metamor" Fusion Dance spell.',
     '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''))

# Genkidama - 900000027 (placeholder)
# Continuous Spell
c.execute('INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)',
    (900000027, 4, 0, 0, TYPE_CONTINUOUS_SPELL, 0, 0, 0, 0, 0, 0))
c.execute('INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
    (900000027, 'Genkidama',
     'Placeholder card for "Genkidama" (Spirit Bomb).',
     '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''))

conn.commit()
conn.close()
print('3 cards inserted: Super Saiyan Gogeta (completed), Metamor and Genkidama (placeholders)')

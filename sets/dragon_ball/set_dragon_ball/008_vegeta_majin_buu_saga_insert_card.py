import sqlite3

conn = sqlite3.connect('expansions/cards-unofficial.cdb')
c = conn.cursor()

# Setcodes: Vegeta + Vegetto + Gogeta (packed as 16-bit segments)
SET_VEGETA = 0x1d1
SET_VEGETTO = 0x1d2
SET_GOGETA = 0x1d3
COMBINED_SETCODE = SET_VEGETA | (SET_VEGETTO << 16) | (SET_GOGETA << 32)

TYPE_EFFECT_MONSTER = 33  # TYPE_MONSTER | TYPE_EFFECT

# Vegeta (Majin Buu Saga) - 900000018
# Warrior / Effect, LIGHT, Level 7, ATK 2400 / DEF 2100
# Setcodes: Vegeta (0x1d1), Vegetto (0x1d2), Gogeta (0x1d3)
c.execute('INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)',
    (900000018, 4, 0, COMBINED_SETCODE, TYPE_EFFECT_MONSTER, 2400, 2100, 7, 1, 16, 0))
c.execute('INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
    (900000018, 'Vegeta (Majin Buu Saga)',
     'This card is always treated as a "Vegeta", "Vegetto", and "Gogeta" card. '
     'This card can be used as Fusion Material and must always be paired with a "Goku" monster. '
     'If this card is sent from your hand to the GY: You can add 1 "Goku" monster and 1 "Potara Earrings" from your Deck to your hand. '
     'This card is not treated as "Vegeta Super Saiyan" or "Vegeta Super Saiyan 2", but can be used as material for any "Vegeta" Extra Deck monster. '
     'You can only use each effect of "Vegeta (Majin Buu Saga)" once per turn.',
     'Add 1 "Goku" monster and 1 "Potara Earrings" to your hand',
     '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''))

conn.commit()
conn.close()
print(f'Vegeta (Majin Buu Saga) inserted (ID 900000018, setcode={COMBINED_SETCODE} = Vegeta+Vegetto+Gogeta)')

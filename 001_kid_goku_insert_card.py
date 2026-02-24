import sqlite3

conn = sqlite3.connect('expansions/cards-unofficial.cdb')
c = conn.cursor()

GOKU_SETCODE = 0x1d0  # 464

# Kid Goku - 900000001
c.execute('INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)',
    (900000001, 4, 0, GOKU_SETCODE, 33, 650, 250, 3, 1, 1, 0))
c.execute('INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
    (900000001, 'Kid Goku',
     'If your opponent controls a monster, you can Special Summon this card (from your hand). When this card is destroyed: You can Special Summon 1 "Goku" monster from your Deck, ignoring its Summoning conditions, except "Goku Super Saiyan".',
     'Special Summon a "Goku" monster from the Deck',
     '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''))

# Goku - 900000002 (placeholder)
c.execute('INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)',
    (900000002, 4, 0, GOKU_SETCODE, 33, 1800, 1200, 4, 1, 1, 0))
c.execute('INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
    (900000002, 'Goku',
     'Placeholder card for the "Goku" archetype.',
     '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''))

# Goku Super Saiyan - 900000003 (placeholder)
c.execute('INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)',
    (900000003, 4, 0, GOKU_SETCODE, 33, 3000, 2500, 8, 1, 16, 0))
c.execute('INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
    (900000003, 'Goku Super Saiyan',
     'Cannot be Normal Summoned/Set. Must be Special Summoned by a card effect.',
     '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''))

conn.commit()
conn.close()
print('All 3 cards inserted successfully!')

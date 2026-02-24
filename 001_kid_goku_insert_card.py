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

# Goku - 900000002
# Normal Monster, Warrior, LIGHT, Level 7, ATK 2500 / DEF 2300
c.execute('INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)',
    (900000002, 4, 0, GOKU_SETCODE, 17, 2500, 2300, 7, 1, 16, 0))
c.execute('INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
    (900000002, 'Goku',
     'A brave warrior belonging to a nearly extinct lineage of fighters. Possessor of a pure heart and an unbreakable will, he travels the universe in search of worthy opponents to surpass his own limits. It is said that when his fury awakens, a golden glow envelops him, releasing a power capable of shaking the foundations of the cosmos. His appetite for battle is surpassed only by his nobility.',
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

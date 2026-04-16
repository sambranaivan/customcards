import sqlite3

conn = sqlite3.connect('expansions/cards-unofficial.cdb')
c = conn.cursor()

VEGETTO_SETCODE = 0x1d2
TYPE_FUSION = 65  # TYPE_MONSTER | TYPE_FUSION (1+64) — non-effect Fusion (Normal)

# Vegetto Super Saiyan - 900000020
# Warrior / Fusion, LIGHT, Level 10, ATK 5000 / DEF 5000
c.execute('INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)',
    (900000020, 4, 0, VEGETTO_SETCODE, TYPE_FUSION, 5000, 5000, 10, 1, 16, 0))
c.execute('INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
    (900000020, 'Vegetto Super Saiyan',
     '1 Level 7 or higher "Goku" monster + 1 Level 7 or higher "Vegeta" monster\n'
     'Born from the convergence of two unparalleled warrior lineages through the sacred '
     'treasures of the gods. Possessing absolute confidence and a power that defies the logic '
     'of the universe, this being is not merely the sum of two combatants, but a new entity '
     'destined to eradicate absolute evil. It is said that when he crosses his arms, the very '
     'fabric of space-time trembles at his mere presence. His strength is infinite, and his '
     'resolve, unshakable.',
     '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''))

conn.commit()
conn.close()
print('Vegetto Super Saiyan (900000020) inserted successfully.')

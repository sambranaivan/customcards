import sqlite3

conn = sqlite3.connect('expansions/cards-unofficial.cdb')
c = conn.cursor()

SET_GOKU = 0x1d0
TYPE_NORMAL_SPELL = 2   # TYPE_SPELL
TYPE_EFFECT = 33        # TYPE_MONSTER | TYPE_EFFECT

# Dragon Fist - 900000015 (completing placeholder)
# Normal Spell
c.execute('INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)',
    (900000015, 4, 0, 0, TYPE_NORMAL_SPELL, 0, 0, 0, 0, 0, 0))
c.execute('INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
    (900000015, 'Dragon Fist',
     'Activate only while your LP are exactly 100, you control "Super Saiyan 3 Goku" '
     'or "Kid Goku GT", and your opponent controls a monster. This card\'s activation '
     'and effect cannot be negated, also your opponent cannot activate cards or effects '
     'in response to this card\'s activation.\n'
     'That "Super Saiyan 3 Goku" or "Kid Goku GT" you control has its ATK become 0, '
     'also it must attack an opponent\'s monster. It cannot be destroyed by that battle, '
     'also you take no battle damage from that battle. Before damage calculation: Send '
     'the opponent\'s battling monster to the GY, and if you do, you win the Duel.',
     'Send to GY and win the Duel',
     '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''))

# Kid Goku GT - 900000032 (placeholder)
# Warrior / Effect, LIGHT, Level 4, ATK 1800 / DEF 1500
c.execute('INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)',
    (900000032, 4, 0, SET_GOKU, TYPE_EFFECT, 1800, 1500, 4, 1, 16, 0))
c.execute('INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
    (900000032, 'Kid Goku GT',
     'Placeholder card for "Kid Goku GT".',
     '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''))

conn.commit()
conn.close()
print('2 cards inserted: Dragon Fist (completed), Kid Goku GT (placeholder)')

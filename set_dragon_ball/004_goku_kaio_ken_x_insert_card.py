import sqlite3

conn = sqlite3.connect('expansions/cards-unofficial.cdb')
c = conn.cursor()

GOKU_SETCODE = 0x1d0  # 464
TYPE_EFFECT_MONSTER = 33  # TYPE_MONSTER | TYPE_EFFECT

# Goku Kaio-ken X - 900000010
# Warrior / Effect, LIGHT, Level 5, ATK 2100 / DEF 2000
c.execute('INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)',
    (900000010, 4, 0, GOKU_SETCODE, TYPE_EFFECT_MONSTER, 2100, 2000, 5, 1, 16, 0))
c.execute('INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
    (900000010, 'Goku Kaio-ken X',
     'If you control a "Goku" monster (Level 7 or higher): You can equip this card from your hand or GY to that monster. The equipped monster\'s ATK becomes double its original ATK. Once per Duel, you can choose to either triple or quadruple the equipped monster\'s ATK until the end of this turn, but if you do, divide its ATK by the same amount during the End Phase. Once per Duel: You can increase the equipped monster\'s ATK by 5 times or up to 10 times its current ATK. If you activate this effect, destroy that monster at the end of this turn, and for the rest of this Duel, you cannot Summon or use any copies of that destroyed monster. If "Goku Kaio-ken X" is Normal Summoned: You can add 1 "Kamehameha" from your Deck, GY, or banishment to your hand.',
     'Equip to a Level 7+ "Goku" monster',
     'Triple or Quadruple ATK',
     'Multiply ATK 5 to 10 times',
     'Add 1 "Kamehameha" to hand',
     'Triple ATK',
     'Quadruple ATK',
     '', '', '', '', '', '', '', '', '', ''))

conn.commit()
conn.close()
print('1 card inserted: Goku Kaio-ken X')

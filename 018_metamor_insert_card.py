import sqlite3

conn = sqlite3.connect('expansions/cards-unofficial.cdb')
c = conn.cursor()

SET_GOGETA = 0x1d3
TYPE_CONTINUOUS_TRAP = 131076  # TYPE_TRAP | TYPE_CONTINUOUS (4+131072)
TYPES_TOKEN = 16401            # TYPE_MONSTER | TYPE_NORMAL | TYPE_TOKEN (1+16+16384)

# Metamor - 900000026 (completing placeholder, changed from Normal Spell to Continuous Trap)
c.execute('INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)',
    (900000026, 4, 0, 0, TYPE_CONTINUOUS_TRAP, 0, 0, 0, 0, 0, 0))
c.execute('INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
    (900000026, 'Metamor',
     'Once per turn: Randomly add 1 "Goku" monster and 1 "Vegeta" monster from your Deck '
     'to your hand, then reveal them. Apply the effect based on their Levels:\n'
     '● Both Level 6 or lower: Send both to the GY; Special Summon 2 "Gogeta Fail Tokens" '
     '(Warrior/LIGHT/Level 12/ATK 0/DEF 0) in Attack Position. For 3 turns: those Tokens '
     'cannot leave the field, neither player can Special Summon from the Extra Deck or '
     'activate cards/effects, your opponent can attack you directly, but you take no battle damage.\n'
     '● One Level 7+ and one Level 6 or lower: Special Summon 1 "Gogeta Fail Token". '
     'For 3 turns: your opponent draws 3 cards instead of 1 during their Draw Phase, '
     'but cannot attack, Summon, or activate cards/effects.\n'
     '● Both Level 7 or higher: Send both to the GY; Special Summon 1 "Super Saiyan Gogeta" '
     'from your Extra Deck (ignoring its Summoning conditions). This turn, negate the effects '
     'of all your opponent\'s face-up monsters and their ATK becomes 0.',
     'Fusion Dance: Random Goku + Vegeta',
     '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''))

# Gogeta Fail Token - 900000033
# Warrior / Normal / Token, LIGHT, Level 12, ATK 0 / DEF 0
c.execute('INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)',
    (900000033, 4, 0, SET_GOGETA, TYPES_TOKEN, 0, 0, 12, 1, 16, 0))
c.execute('INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
    (900000033, 'Gogeta Fail Token',
     'This Token cannot be used as material. '
     'The result of a failed Fusion Dance between Goku and Vegeta.',
     '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''))

conn.commit()
conn.close()
print('2 cards inserted: Metamor (completed), Gogeta Fail Token')

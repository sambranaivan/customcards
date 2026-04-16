import sqlite3

conn = sqlite3.connect('expansions/cards-unofficial.cdb')
c = conn.cursor()

TYPE_CONTINUOUS_SPELL = 131074  # TYPE_SPELL | TYPE_CONTINUOUS (2+131072)

# Genkidama - 900000027 (completing placeholder)
# Continuous Spell
c.execute('INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)',
    (900000027, 4, 0, 0, TYPE_CONTINUOUS_SPELL, 0, 0, 0, 0, 0, 0))
c.execute('INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
    (900000027, 'Genkidama',
     'During each of your Standby Phases: Place 1 Counter on this card. '
     'If this card has 20 or more Counters on it, you win the Duel.\n'
     'Once per turn: You can remove up to 5 Counters from this card, then target '
     '1 monster you control; it gains 500 ATK/DEF for each Counter removed, also '
     'it cannot be targeted or destroyed by your opponent\'s card effects until '
     'the end of this turn.\n'
     'This card must remain face-up on the field to activate and resolve these effects.',
     'Place 1 Counter',
     'Remove Counters: boost ATK/DEF + protection',
     '', '', '', '', '', '', '', '', '', '', '', '', '', ''))

conn.commit()
conn.close()
print('1 card inserted: Genkidama (completed)')

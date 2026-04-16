import sqlite3

conn = sqlite3.connect('expansions/cards-unofficial.cdb')
c = conn.cursor()

TYPE_NORMAL_SPELL = 2  # TYPE_SPELL

# Instant Transmission - 900000031
# Normal Spell
c.execute('INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)',
    (900000031, 4, 0, 0, TYPE_NORMAL_SPELL, 0, 0, 0, 0, 0, 0))
c.execute('INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
    (900000031, 'Instant Transmission',
     'Add up to 3 monsters from your Deck to your hand, then reveal them. '
     'Your opponent selects 1 of them; banish 1 of the remaining monsters '
     'and send the other to the GY. Special Summon the selected monster, '
     'ignoring its Summoning conditions, but negate its effects and halve its ATK.\n'
     'Once per Battle Phase, if the Summoned monster is a Level 7 or higher '
     '"Goku" monster: You can target 1 of the other monsters added by this card\'s effect '
     '(in the GY or banished); shuffle that "Goku" monster into the Deck, and if you do, '
     'Special Summon that target ignoring its Summoning conditions, also end the Battle Phase. '
     'During the End Phase: Send that Special Summoned monster to the GY, and if you do, you '
     'can add that "Goku" monster from your Deck to your hand.',
     '',
     'Swap: Return Goku, Special Summon',
     'Banish this card',
     'Send to GY',
     'Add Goku to hand',
     '', '', '', '', '', '', '', '', '', '', ''))

conn.commit()
conn.close()
print('1 card inserted: Instant Transmission')

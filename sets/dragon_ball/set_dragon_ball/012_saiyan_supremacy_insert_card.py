import sqlite3

conn = sqlite3.connect('expansions/cards-unofficial.cdb')
c = conn.cursor()

SET_SAIYAN = 0x1d4
SET_GOHAN = 0x1d5
SET_GOTENKS = 0x1d6
SET_GOGETA = 0x1d3

TYPE_FUSION_EFFECT = 97  # TYPE_MONSTER | TYPE_EFFECT | TYPE_FUSION (1+32+64)
TYPE_EFFECT = 33         # TYPE_MONSTER | TYPE_EFFECT (1+32)

# Saiyan Supremacy - 900000021
# Warrior / Fusion / Effect, LIGHT, Level 10, ATK ? / DEF 5000
c.execute('INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)',
    (900000021, 4, 0, SET_SAIYAN, TYPE_FUSION_EFFECT, -2, 5000, 10, 1, 16, 0))
c.execute('INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
    (900000021, 'Saiyan Supremacy',
     '1 "Vegetto" Fusion Monster + 1 "Ultimate Gohan" + 1 "Super Saiyan 3 Gotenks"\n'
     'OR 5 "Saiyan" monsters with different names\n'
     'This card can attack all monsters your opponent controls once each. '
     'This card is unaffected by other card effects. '
     'This card gains ATK equal to the combined original ATK of its Fusion Materials. '
     'If this card is destroyed: You can Special Summon 1 "Gogeta" monster from your Extra Deck, '
     'and if you do, it gains all of this card\'s original effects.',
     'Special Summon Gogeta from Extra Deck',
     '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''))

# Ultimate Gohan - 900000022 (placeholder)
# Warrior / Effect, LIGHT, Level 8, ATK 3000 / DEF 2500
gohan_setcode = SET_GOHAN | (SET_SAIYAN << 16)
c.execute('INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)',
    (900000022, 4, 0, gohan_setcode, TYPE_EFFECT, 3000, 2500, 8, 1, 16, 0))
c.execute('INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
    (900000022, 'Ultimate Gohan',
     'Placeholder card for "Ultimate Gohan".',
     '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''))

# Super Saiyan 3 Gotenks - 900000023 (placeholder)
# Warrior / Fusion / Effect, LIGHT, Level 10, ATK 3500 / DEF 3000
gotenks_setcode = SET_GOTENKS | (SET_SAIYAN << 16)
c.execute('INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)',
    (900000023, 4, 0, gotenks_setcode, TYPE_FUSION_EFFECT, 3500, 3000, 10, 1, 16, 0))
c.execute('INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
    (900000023, 'Super Saiyan 3 Gotenks',
     'Placeholder card for "Super Saiyan 3 Gotenks".',
     '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''))

# Gogeta - 900000024 (placeholder)
# Warrior / Fusion / Effect, LIGHT, Level 12, ATK 5000 / DEF 5000
gogeta_setcode = SET_GOGETA | (SET_SAIYAN << 16)
c.execute('INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)',
    (900000024, 4, 0, gogeta_setcode, TYPE_FUSION_EFFECT, 5000, 5000, 12, 1, 16, 0))
c.execute('INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
    (900000024, 'Gogeta',
     'Placeholder card for "Gogeta".',
     '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''))

conn.commit()
conn.close()
print('4 cards inserted: Saiyan Supremacy (completed), Ultimate Gohan, SS3 Gotenks, Gogeta (placeholders)')

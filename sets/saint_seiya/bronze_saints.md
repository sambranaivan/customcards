# Bronze Saints (source of truth)

This document replaces overlapping PSCT from `other_saints_card_effects.md` (Bronze Saints + Bronze Cloth sections there are outdated). **Authoritative data:** `expansions/saint-seiya.cdb` (`datas` + `texts`) and `script/unofficial/c{card_id}.lua`.

Older markdown used names like `Saint - Seiya of Pegasus` and outdated Equip Spell lines (hand discard to search; Standby re-equip). The game database uses **`Bronze Saint - …`** naming and the implemented GY effects on Bronze Cloth cards.

---

## Bronze Saint monsters

### Bronze Saint - Seiya of Pegasus
- **Card ID**: `922100000`
- **Lua**: `script/unofficial/c922100000.lua`
- **Card type**: Effect Monster
- **Attribute**: LIGHT
- **Monster type**: Warrior
- **Level**: 4
- **ATK / DEF**: 1700 / 1200

```text
If this card is Normal or Special Summoned: You can add 1 "Cloth" Equip Spell or 1 "Saint" monster from your Deck to your hand.
If you control no monsters: You can Special Summon this card from your hand.
You can pay 500 LP; equip 1 "Cloth" Equip Spell from your GY to this card, also, for the rest of this turn after this effect resolves, you cannot Special Summon from the Extra Deck, except "Saint" monsters.
If this card is sent to the GY as material for the Summon of a "Saint" monster: You can either equip 1 face-up "Cloth" Equip Spell you control to that monster, or attach it to it as material (if it is an Xyz Monster).
You can only use each effect of "Bronze Saint - Seiya of Pegasus" once per turn.
```

### Bronze Saint - Shiryu of Dragon
- **Card ID**: `922100001`
- **Lua**: `script/unofficial/c922100001.lua`
- **Card type**: Effect Monster
- **Attribute**: EARTH
- **Monster type**: Warrior
- **Level**: 4
- **ATK / DEF**: 1500 / 1800

```text
(Quick Effect): You can discard this card; "Cloth" cards you control cannot be destroyed by card effects until the end of this turn.
You can pay 500 LP; equip 1 "Cloth" Equip Spell from your GY to this card, also, for the rest of this turn after this effect resolves, you cannot Special Summon from the Extra Deck, except "Saint" monsters.
If this card is sent to the GY as material for the Summon of a "Saint" monster: You can either equip 1 face-up "Cloth" Equip Spell you control to that monster, or attach it to it as material (if it is an Xyz Monster).
You can only use each effect of "Bronze Saint - Shiryu of Dragon" once per turn.
```

### Bronze Saint - Hyoga of Cygnus
- **Card ID**: `922100002`
- **Lua**: `script/unofficial/c922100002.lua`
- **Card type**: Effect Monster
- **Attribute**: WATER
- **Monster type**: Warrior
- **Level**: 4
- **ATK / DEF**: 1600 / 1400

```text
If this card attacks an opponent's monster, before damage calculation: Change that opponent's monster to Defense Position, and if you do, negate its effects until the end of your opponent's next turn.
You can pay 500 LP; equip 1 "Cloth" Equip Spell from your GY to this card, also, for the rest of this turn after this effect resolves, you cannot Special Summon from the Extra Deck, except "Saint" monsters.
If this card is sent to the GY as material for the Summon of a "Saint" monster: You can either equip 1 face-up "Cloth" Equip Spell you control to that monster, or attach it to it as material (if it is an Xyz Monster).
You can only use each effect of "Bronze Saint - Hyoga of Cygnus" once per turn.
```

### Bronze Saint - Shun of Andromeda
- **Card ID**: `922100003`
- **Lua**: `script/unofficial/c922100003.lua`
- **Card type**: Effect Monster
- **Attribute**: WIND
- **Monster type**: Warrior
- **Level**: 4
- **ATK / DEF**: 1300 / 1900

```text
Your opponent cannot target other "Saint" monsters you control for attacks.
If this card is equipped with a "Cloth" Equip Spell, it can attack while in Defense Position. Use its DEF for damage calculation.
You can pay 500 LP; equip 1 "Cloth" Equip Spell from your GY to this card, also, for the rest of this turn after this effect resolves, you cannot Special Summon from the Extra Deck, except "Saint" monsters.
If this card is sent to the GY as material for the Summon of a "Saint" monster: You can either equip 1 face-up "Cloth" Equip Spell you control to that monster, or attach it to it as material (if it is an Xyz Monster).
You can only use each effect of "Bronze Saint - Shun of Andromeda" once per turn.
```

### Bronze Saint - Ikki of Phoenix
- **Card ID**: `922100004`
- **Lua**: `script/unofficial/c922100004.lua`
- **Card type**: Effect Monster
- **Attribute**: FIRE
- **Monster type**: Warrior
- **Level**: 4
- **ATK / DEF**: 1800 / 1000

```text
If this card is in your GY: You can discard 1 "Saint" card; Special Summon this card.
You can pay 500 LP; equip 1 "Cloth" Equip Spell from your GY to this card, also, for the rest of this turn after this effect resolves, you cannot Special Summon from the Extra Deck, except "Saint" monsters.
If this card is sent to the GY as material for the Summon of a "Saint" monster: You can either equip 1 face-up "Cloth" Equip Spell you control to that monster, or attach it to it as material (if it is an Xyz Monster).
You can only use each effect of "Bronze Saint - Ikki of Phoenix" once per turn.
```

### Bronze Saint - Jabu of Unicorn
- **Card ID**: `922100005`
- **Lua**: `script/unofficial/c922100005.lua`
- **Card type**: Effect Monster
- **Attribute**: LIGHT
- **Monster type**: Warrior
- **Level**: 4
- **ATK / DEF**: 1700 / 1000

```text
If you control a "Saint" monster: You can Special Summon this card from your hand.
You can only Special Summon "Bronze Saint - Jabu of Unicorn" once per turn this way.
If this card is Special Summoned: You can add 1 "Cloth" card from your GY to your hand, then discard 1 card.
If this card is sent to the GY as material for the Summon of a "Saint" monster: You can either equip 1 "Cloth" card you control to that monster, or attach 1 "Cloth" card you control to it as material (if it is an Xyz Monster).
You can only use each effect of "Bronze Saint - Jabu of Unicorn" once per turn.
```

### Bronze Saint - Ichi of Hydra
- **Card ID**: `922100006`
- **Lua**: `script/unofficial/c922100006.lua`
- **Card type**: Effect Monster
- **Attribute**: WATER
- **Monster type**: Warrior
- **Level**: 4
- **ATK / DEF**: 1400 / 1200

```text
You can discard 1 "Cloth" card; inflict 800 damage to your opponent, and if you do, this card can attack directly this turn.
If this card is sent to the GY: You can send 1 "Cloth" card from your Deck to the GY.
If this card is sent to the GY as material for the Summon of a "Saint" monster: You can either equip 1 face-up "Cloth" Equip Spell you control to that monster, or attach it to it as material (if it is an Xyz Monster).
You can only use each effect of "Bronze Saint - Ichi of Hydra" once per turn.
```

### Bronze Saint - Geki of Bear
- **Card ID**: `922100007`
- **Lua**: `script/unofficial/c922100007.lua`
- **Card type**: Effect Monster
- **Attribute**: EARTH
- **Monster type**: Warrior
- **Level**: 4
- **ATK / DEF**: 1600 / 1600

```text
If this card is Normal or Special Summoned: You can add 1 Level 5 or higher "Saint" monster from your Deck to your hand.
If this card is in your GY: You can add 1 "Cloth" card from your GY to your hand, and if you do, banish this card.
If this card is sent to the GY as material for the Summon of a "Saint" monster: You can either equip 1 face-up "Cloth" Equip Spell you control to that monster, or attach it to it as material (if it is an Xyz Monster).
You can only use each effect of "Bronze Saint - Geki of Bear" once per turn.
```

### Bronze Saint - Ban of Lionet
- **Card ID**: `922100008`
- **Lua**: `script/unofficial/c922100008.lua`
- **Card type**: Effect Monster
- **Attribute**: FIRE
- **Monster type**: Warrior
- **Level**: 4
- **ATK / DEF**: 1500 / 1300

```text
If a "Saint" monster(s) you control is destroyed by battle: You can Special Summon this card from your hand.
If this card is Special Summoned: You can target 1 "Saint" monster in your GY; add it to your hand.
If this card is sent to the GY as material for the Summon of a "Saint" monster: You can either equip 1 face-up "Cloth" Equip Spell you control to that monster, or attach it to it as material (if it is an Xyz Monster).
You can only use each effect of "Bronze Saint - Ban of Lionet" once per turn.
```

### Bronze Saint - Nachi of Wolf
- **Card ID**: `922100009`
- **Lua**: `script/unofficial/c922100009.lua`
- **Card type**: Effect Monster
- **Attribute**: WIND
- **Monster type**: Warrior
- **Level**: 4
- **ATK / DEF**: 1200 / 1000

```text
If this card is sent to the GY as Link Material or Tributed: You can draw 1 card, then discard 1 card.
You can shuffle 1 "Cloth" card from your GY into the Deck, then draw 1 card.
If this card is sent to the GY as material for the Summon of a "Saint" monster: You can either equip 1 face-up "Cloth" Equip Spell you control to that monster, or attach it to it as material (if it is an Xyz Monster).
You can only use each effect of "Bronze Saint - Nachi of Wolf" once per turn.
```

---

## Cloth support (same core set)

### Mu - The Cloth Repairer
- **Card ID**: `922100010`
- **Lua**: `script/unofficial/c922100010.lua`
- **Card type**: Effect Monster
- **Attribute**: LIGHT
- **Monster type**: Warrior
- **Level**: 4
- **ATK / DEF**: 1200 / 2000

```text
If this card is Normal or Special Summoned: You can target up to 2 "Cloth" Equip Spells in your GY; add them to your hand.
You can discard this card; add 1 "Athena's Sanctuary - Reforged" from your Deck to your hand.
You can only use each effect of "Mu - The Cloth Repairer" once per turn.
```

### Kiki - Messenger of the Cloth Sculptor
- **Card ID**: `922100011`
- **Lua**: `script/unofficial/c922100011.lua`
- **Card type**: Effect Monster
- **Attribute**: LIGHT
- **Monster type**: Psychic
- **Level**: 2
- **ATK / DEF**: 500 / 500

```text
(Quick Effect): You can discard this card, then target 1 "Saint" monster you control; equip 1 "Cloth" Equip Spell from your Deck or GY to that target.
During the Standby Phase of the next turn after this card was sent to the GY: You can banish this card; add up to 2 "Cloth" cards with different names from your GY to your hand.
You can only use each effect of "Kiki - Messenger of the Cloth Sculptor" once per turn.
```

---

## Bronze Cloth (Equip Spells)

### Bronze Cloth - Pegasus
- **Card ID**: `922100041`
- **Lua**: `script/unofficial/c922100041.lua`
- **Card type**: Equip Spell

```text
Equip only to a "Saint" monster.
The equipped monster gains 500 ATK.
If the equipped monster attacks, your opponent cannot activate cards or effects until the end of the Damage Step.
If the equipped monster is "Bronze Saint - Seiya of Pegasus", it can make up to 2 attacks on monsters during each Battle Phase, also if it destroys an opponent's monster by battle: Inflict 500 damage to your opponent.
If this card is sent to the GY: You can add 1 Level 4 or lower "Bronze Saint" monster from your Deck to your hand.
You can only use 1 effect of "Bronze Cloth - Pegasus" per turn, and only once that turn.
```

### Bronze Cloth - Dragon
- **Card ID**: `922100042`
- **Lua**: `script/unofficial/c922100042.lua`
- **Card type**: Equip Spell

```text
Equip only to a "Saint" monster.
The equipped monster gains 1000 DEF.
The equipped monster cannot be destroyed by monster effects.
If the equipped monster is "Bronze Saint - Shiryu of Dragon", your opponent cannot target it with card effects.
Once per turn, if the equipped monster in Defense Position would be destroyed by battle, it is not destroyed, and if you do, you can destroy 1 card your opponent controls.
If this card is sent to the GY: You can add 1 Level 4 or lower "Bronze Saint" monster from your Deck to your hand.
You can only use 1 effect of "Bronze Cloth - Dragon" per turn, and only once that turn.
```

### Bronze Cloth - Cygnus
- **Card ID**: `922100043`
- **Lua**: `script/unofficial/c922100043.lua`
- **Card type**: Equip Spell

```text
Equip only to a "Saint" monster.
Once per turn: You can target 1 face-up card your opponent controls; negate its effects until the end of this turn.
If the equipped monster is "Bronze Saint - Hyoga of Cygnus", monsters negated by this card's effect cannot change their battle positions, also they cannot be used as material for a Special Summon from the Extra Deck while this card is face-up on the field.
If this card is sent to the GY: You can add 1 Level 4 or lower "Bronze Saint" monster from your Deck to your hand.
You can only use 1 effect of "Bronze Cloth - Cygnus" per turn, and only once that turn.
```

### Bronze Cloth - Andromeda
- **Card ID**: `922100044`
- **Lua**: `script/unofficial/c922100044.lua`
- **Card type**: Equip Spell

```text
Equip only to a "Saint" monster.
While the equipped monster is in Defense Position, your opponent cannot declare attacks on other monsters you control, also they cannot activate the effects of monsters that were Special Summoned this turn.
If this card is equipped to "Bronze Saint - Shun of Andromeda", the equipped monster can attack directly.
If this card is sent to the GY: You can add 1 Level 4 or lower "Bronze Saint" monster from your Deck to your hand.
You can only use 1 effect of "Bronze Cloth - Andromeda" per turn, and only once that turn.
```

### Bronze Cloth - Phoenix
- **Card ID**: `922100045`
- **Lua**: `script/unofficial/c922100045.lua`
- **Card type**: Equip Spell

```text
Equip only to a "Saint" monster.
The equipped monster gains 1000 ATK.
If the equipped monster destroys an opponent's monster by battle: Inflict 1000 damage to your opponent.
If the equipped monster is "Bronze Saint - Ikki of Phoenix", and it would be sent to the GY: You can destroy this card instead, and if you do, Special Summon that monster, then you can destroy 1 card on the field.
If this card is sent to the GY: You can add 1 Level 4 or lower "Bronze Saint" monster from your Deck to your hand.
You can only use 1 effect of "Bronze Cloth - Phoenix" per turn, and only once that turn.
```

### Bronze Cloth - Unicorn
- **Card ID**: `922100046`
- **Lua**: `script/unofficial/c922100046.lua`
- **Card type**: Equip Spell

```text
Equip only to a "Saint" monster.
The equipped monster can make a second attack during each Battle Phase, but only on monsters.
If the equipped monster is "Bronze Saint - Jabu of Unicorn", you gain this effect.
● During your Main Phase, you can Normal Summon 1 "Bronze Saint" monster in addition to your Normal Summon/Set. (You can only gain this effect once per turn.)
If this card is sent to the GY: You can add 1 Level 4 or lower "Bronze Saint" monster from your Deck to your hand.
You can only use 1 effect of "Bronze Cloth - Unicorn" per turn, and only once that turn.
```

### Bronze Cloth - Hydra
- **Card ID**: `922100047`
- **Lua**: `script/unofficial/c922100047.lua`
- **Card type**: Equip Spell

```text
Equip only to a "Saint" monster.
If an opponent's monster battles the equipped monster, after damage calculation: That opponent's monster loses 1000 ATK/DEF.
If the equipped monster is "Bronze Saint - Ichi of Hydra", and it attacks directly, your opponent cannot activate effects in the GY until the end of this turn.
If this card is sent to the GY: You can add 1 Level 4 or lower "Bronze Saint" monster from your Deck to your hand.
You can only use 1 effect of "Bronze Cloth - Hydra" per turn, and only once that turn.
```

### Bronze Cloth - Bear
- **Card ID**: `922100048`
- **Lua**: `script/unofficial/c922100048.lua`
- **Card type**: Equip Spell

```text
Equip only to a "Saint" monster.
If the equipped monster destroys an opponent's monster by battle: Your opponent discards 1 random card.
If the equipped monster is "Bronze Saint - Geki of Bear", at the start of the Damage Step, if it battles an opponent's monster with higher ATK: You can destroy that opponent's monster.
If this card is sent to the GY: You can add 1 Level 4 or lower "Bronze Saint" monster from your Deck to your hand.
You can only use 1 effect of "Bronze Cloth - Bear" per turn, and only once that turn.
```

### Bronze Cloth - Lionet
- **Card ID**: `922100049`
- **Lua**: `script/unofficial/c922100049.lua`
- **Card type**: Equip Spell

```text
Equip only to a "Saint" monster.
The equipped monster gains 600 ATK.
If the equipped monster is "Bronze Saint - Ban of Lionet", once per turn: You can target 1 "Bronze Saint" monster in your GY; add it to your hand, then discard 1 card.
If this card is sent to the GY: You can add 1 Level 4 or lower "Bronze Saint" monster from your Deck to your hand.
You can only use 1 effect of "Bronze Cloth - Lionet" per turn, and only once that turn.
```

### Bronze Cloth - Wolf
- **Card ID**: `922100050`
- **Lua**: `script/unofficial/c922100050.lua`
- **Card type**: Equip Spell

```text
Equip only to a "Saint" monster.
The equipped monster gains 300 ATK/DEF.
Once per turn: You can target 1 "Cloth" card in your GY; shuffle it into the Deck, then the equipped monster gains 300 ATK until the end of this turn.
If the equipped monster is "Bronze Saint - Nachi of Wolf", you gain this effect.
● Once per turn: You can draw 1 card, then discard 1 card.
If this card is sent to the GY: You can add 1 Level 4 or lower "Bronze Saint" monster from your Deck to your hand.
You can only use 1 effect of "Bronze Cloth - Wolf" per turn, and only once that turn.
```

---

## Regenerating from the database

From the repo root: `python sets/saint_seiya/export_bronze_saints_md_from_cdb.py` (overwrites this file from `expansions/saint-seiya.cdb`). After changing card text in the `.cdb`, re-run that script; Lua behavior is not validated automatically.

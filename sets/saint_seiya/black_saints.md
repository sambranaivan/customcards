# Black Saints (source of truth)

PSCT and stats match **`expansions/saint-seiya.cdb`** (`datas` + `texts`). Each card lists its Lua path (`script/unofficial/c` + *id* + `.lua`) and a **Lua reference** block parsed from the `--[==[ ... ]==]` header in that script (documentation only; if it disagrees with the box text, trust the database and the registered effects in Lua).

For design drafts and cards not yet in this ID range, see **`black_saints_effects.md`**.

---

## Black Saint monsters

### Black Saint - Ikki, Leader of Death Queen Island
- **Card ID**: `922100148`
- **Lua**: `script/unofficial/c922100148.lua`
- **Card type**: Effect Monster
- **Attribute**: DARK
- **Monster type**: Warrior
- **Level**: 6
- **ATK / DEF**: 2400 / 1800

**Lua reference** (header block in script):

```text
ID: 922100148
Type: Monster / Effect Monster
Level: 6
Attribute: DARK
Race: Warrior
ATK/DEF: 2400/1800

Archetypes:
- Black Saint
- saint
- saint-seiya

Effect (EN):
If you control 2 or more "Black Saint" monsters, you can Special Summon this card
(from your hand).
If this card is in your GY: You can send 1 face-up "Fragment of Sagittarius" Equip Spell
you control to the GY; Special Summon this card.
If this card is Normal or Special Summoned: You can add 1 "Fragment of Sagittarius" card
from your Deck to your hand.
Once per turn (Quick Effect): You can send 1 face-up "Fragment of Sagittarius" Equip Spell
you control to the GY, then target 1 face-up card on the field; destroy it.
You can only use each effect of "Black Saint - Ikki, Leader of Death Queen Island" once
per turn.
```

**Card text** (`texts.desc`):

```text
If you control 2 or more "Black Saint" monsters, you can Special Summon this card (from your hand).
If this card is in your GY: You can send 1 face-up "Fragment of Sagittarius" Equip Spell you control to the GY; Special Summon this card.
If this card is Normal or Special Summoned: You can add 1 "Fragment of Sagittarius" card from your Deck to your hand.
Once per turn (Quick Effect): You can send 1 face-up "Fragment of Sagittarius" Equip Spell you control to the GY, then target 1 face-up card on the field; destroy it.
You can only use each effect of "Black Saint - Ikki, Leader of Death Queen Island" once per turn.
```

### Black Saint - Jango, Commander of the Shadow
- **Card ID**: `922100149`
- **Lua**: `script/unofficial/c922100149.lua`
- **Card type**: Effect Monster
- **Attribute**: DARK
- **Monster type**: Warrior
- **Level**: 4
- **ATK / DEF**: 1700 / 1000

**Lua reference** (header block in script):

```text
ID: 922100149
Type: Monster / Effect Monster
Level: 4
Attribute: DARK
Race: Warrior
ATK/DEF: 1700/1000

Archetypes:
- Black Saint
- saint
- saint-seiya

Effect (EN):
If this card is Normal or Special Summoned: You can send 1 "Fragment of Sagittarius" card from your Deck to the GY.
If a face-up "Fragment of Sagittarius" Equip Spell(s) you control is sent to the GY by card effect: You can Special Summon 1 Level 4 or lower "Black Saint" monster from your hand or GY, except "Black Saint - Jango, Commander of the Shadow".
You can only use each effect of "Black Saint - Jango, Commander of the Shadow" once per turn.
```

**Card text** (`texts.desc`):

```text
If this card is Normal or Special Summoned: You can send 1 "Fragment of Sagittarius" card from your Deck to the GY.
If a face-up "Fragment of Sagittarius" Equip Spell(s) you control is sent to the GY by card effect: You can Special Summon 1 Level 4 or lower "Black Saint" monster from your hand or GY, except "Black Saint - Jango, Commander of the Shadow".
You can only use each effect of "Black Saint - Jango, Commander of the Shadow" once per turn.
```

### Black Saint - Dark Pegasus
- **Card ID**: `922100150`
- **Lua**: `script/unofficial/c922100150.lua`
- **Card type**: Effect Monster
- **Attribute**: DARK
- **Monster type**: Warrior
- **Level**: 4
- **ATK / DEF**: 1800 / 1100

**Lua reference** (header block in script):

```text
ID: 922100150
Type: Monster / Effect Monster
Level: 4
Attribute: DARK
Race: Warrior
ATK/DEF: 1800/1100

Archetypes:
- Black Saint
- saint
- saint-seiya

Effect (EN):
If you control a "Black Saint" monster, you can Special Summon this card (from your hand).
You can only Special Summon "Black Saint - Dark Pegasus" once per turn this way.
Once per turn: You can equip 1 "Fragment of Sagittarius" Equip Spell from your hand or GY
to this card.
If this card declares an attack while equipped with a "Fragment of Sagittarius" card: Your
opponent cannot activate cards or effects until the end of the Damage Step.
```

**Card text** (`texts.desc`):

```text
If you control a "Black Saint" monster, you can Special Summon this card (from your hand).
You can only Special Summon "Black Saint - Dark Pegasus" once per turn this way.
Once per turn: You can equip 1 "Fragment of Sagittarius" Equip Spell from your hand or GY to this card.
If this card declares an attack while equipped with a "Fragment of Sagittarius" card: Your opponent cannot activate cards or effects until the end of the Damage Step.
```

### Black Saint - Dark Dragon
- **Card ID**: `922100151`
- **Lua**: `script/unofficial/c922100151.lua`
- **Card type**: Effect Monster
- **Attribute**: DARK
- **Monster type**: Warrior
- **Level**: 4
- **ATK / DEF**: 1600 / 1700

**Lua reference** (header block in script):

```text
ID: 922100151
Type: Monster / Effect Monster
Level: 4
Attribute: DARK
Race: Warrior
ATK/DEF: 1600/1700

Archetypes:
- Black Saint
- saint
- saint-seiya

Effect (EN):
If this card is Normal or Special Summoned: You can equip 1 "Fragment of Sagittarius" Equip Spell from your Deck to this card, but send it to the GY during the End Phase.
Once per turn (Quick Effect): You can send 1 Equip Card equipped to this card to the GY; this card cannot be destroyed by battle or card effects this turn.
If this card is sent to the GY: You can add 1 "Fragment of Sagittarius" card from your GY to your hand.
You can only use each effect of "Black Saint - Dark Dragon" once per turn.
```

**Card text** (`texts.desc`):

```text
If this card is Normal or Special Summoned: You can equip 1 "Fragment of Sagittarius" Equip Spell from your Deck to this card, but send it to the GY during the End Phase.
Once per turn (Quick Effect): You can send 1 Equip Card equipped to this card to the GY; this card cannot be destroyed by battle or card effects this turn.
If this card is sent to the GY: You can add 1 "Fragment of Sagittarius" card from your GY to your hand.
You can only use each effect of "Black Saint - Dark Dragon" once per turn.
```

### Black Saint - Dark Cygnus
- **Card ID**: `922100152`
- **Lua**: `script/unofficial/c922100152.lua`
- **Card type**: Effect Monster
- **Attribute**: DARK
- **Monster type**: Warrior
- **Level**: 4
- **ATK / DEF**: 1500 / 1300

**Lua reference** (header block in script):

```text
ID: 922100152
Type: Monster / Effect Monster
Level: 4
Attribute: DARK
Race: Warrior
ATK/DEF: 1500/1300

Archetypes:
- Black Saint
- saint
- saint-seiya

Effect (EN):
If this card is Normal or Special Summoned: You can target 1 face-up monster your opponent controls; change it to Defense Position.
Once per turn (Quick Effect): You can send 1 "Fragment of Sagittarius" Equip Spell equipped to a monster you control to the GY, then target 1 face-up monster your opponent controls; negate its effects until the end of this turn.
If this card is sent to the GY as material for the Summon of a "Black Saint" monster: You can equip 1 "Fragment of Sagittarius" Equip Spell from your GY to that Summoned monster.
You can only use each effect of "Black Saint - Dark Cygnus" once per turn.
```

**Card text** (`texts.desc`):

```text
If this card is Normal or Special Summoned: You can target 1 face-up monster your opponent controls; change it to Defense Position.
Once per turn (Quick Effect): You can send 1 "Fragment of Sagittarius" Equip Spell equipped to a monster you control to the GY, then target 1 face-up monster your opponent controls; negate its effects until the end of this turn.
If this card is sent to the GY as material for the Summon of a "Black Saint" monster: You can equip 1 "Fragment of Sagittarius" Equip Spell from your GY to that Summoned monster.
You can only use each effect of "Black Saint - Dark Cygnus" once per turn.
```

### Black Saint - Dark Andromeda
- **Card ID**: `922100153`
- **Lua**: `script/unofficial/c922100153.lua`
- **Card type**: Effect Monster
- **Attribute**: DARK
- **Monster type**: Warrior
- **Level**: 4
- **ATK / DEF**: 1400 / 1900

**Lua reference** (header block in script):

```text
ID: 922100153
Type: Monster / Effect Monster
Level: 4
Attribute: DARK
Race: Warrior
ATK/DEF: 1400/1900

Archetypes:
- Black Saint
- saint
- saint-seiya

Effect (EN):
Your opponent cannot target other "Black Saint" monsters you control for attacks.
Once per turn: You can equip 1 "Fragment of Sagittarius" Equip Spell from your hand or GY to this card.
If this card is equipped with 2 or more Equip Cards, your opponent cannot target this card with card effects.
If a face-up "Fragment of Sagittarius" Equip Spell(s) you control is sent to the GY by card effect: Draw 1 card.
You can only use this effect of "Black Saint - Dark Andromeda" once per turn.
```

**Card text** (`texts.desc`):

```text
Your opponent cannot target other "Black Saint" monsters you control for attacks.
Once per turn: You can equip 1 "Fragment of Sagittarius" Equip Spell from your hand or GY to this card.
If this card is equipped with 2 or more Equip Cards, your opponent cannot target this card with card effects.
If a face-up "Fragment of Sagittarius" Equip Spell(s) you control is sent to the GY by card effect: Draw 1 card.
You can only use this effect of "Black Saint - Dark Andromeda" once per turn.
```

### Black Saint - Dark Phoenix
- **Card ID**: `922100154`
- **Lua**: `script/unofficial/c922100154.lua`
- **Card type**: Effect Monster
- **Attribute**: DARK
- **Monster type**: Warrior
- **Level**: 4
- **ATK / DEF**: 1700 / 1000

**Lua reference** (header block in script):

```text
ID: 922100154
Type: Monster / Effect Monster
Level: 4
Attribute: DARK
Race: Warrior
ATK/DEF: 1700/1000

Archetypes:
- Black Saint
- saint
- saint-seiya

Effect (EN):
If you control "Black Saint - Ikki, Leader of Death Queen Island": You can Special Summon this card from your hand.
If this card is Normal or Special Summoned: You can send 1 "Fragment of Sagittarius" card from your Deck to the GY.
During your Main Phase: You can send 1 face-up "Fragment of Sagittarius" Equip Spell you control to the GY; Special Summon 1 "Black Saint - Dark Phoenix" from your Deck in Defense Position, also for the rest of this turn, you cannot Special Summon monsters from the Extra Deck, except DARK monsters.
You can only use each effect of "Black Saint - Dark Phoenix" once per turn.
```

**Card text** (`texts.desc`):

```text
If you control "Black Saint - Ikki, Leader of Death Queen Island": You can Special Summon this card from your hand.
If this card is Normal or Special Summoned: You can send 1 "Fragment of Sagittarius" card from your Deck to the GY.
During your Main Phase: You can send 1 face-up "Fragment of Sagittarius" Equip Spell you control to the GY; Special Summon 1 "Black Saint - Dark Phoenix" from your Deck in Defense Position, also for the rest of this turn, you cannot Special Summon monsters from the Extra Deck, except DARK monsters.
You can only use each effect of "Black Saint - Dark Phoenix" once per turn.
```

---

## Fragments of Sagittarius (Equip Spells)

### Fragment of Sagittarius - Helmet
- **Card ID**: `922100155`
- **Lua**: `script/unofficial/c922100155.lua`
- **Card type**: Equip Spell

**Lua reference** (header block in script):

```text
ID: 922100155
Type: Spell / Equip Spell

Archetypes:
- Fragment of Sagittarius
- saint-seiya

Effect (EN):
Equip only to a "Black Saint" monster.
The equipped monster gains 300 ATK.
Once per turn (Quick Effect): You can send this face-up card to the GY; negate the activation of an opponent's card or effect that targets your equipped monster, and if you do, destroy that card.
If this card is sent to the GY: You can add 1 "Black Saint" monster from your Deck to your hand.
You can only use 1 effect of "Fragment of Sagittarius - Helmet" per turn, and only once that turn.
```

**Card text** (`texts.desc`):

```text
Equip only to a "Black Saint" monster.
The equipped monster gains 300 ATK.
Once per turn (Quick Effect): You can send this face-up card to the GY; negate the activation of an opponent's card or effect that targets your equipped monster, and if you do, destroy that card.
If this card is sent to the GY: You can add 1 "Black Saint" monster from your Deck to your hand.
You can only use 1 effect of "Fragment of Sagittarius - Helmet" per turn, and only once that turn.
```

### Fragment of Sagittarius - Chestplate
- **Card ID**: `922100156`
- **Lua**: `script/unofficial/c922100156.lua`
- **Card type**: Equip Spell

**Lua reference** (header block in script):

```text
ID: 922100156
Type: Spell / Equip Spell

Archetypes:
- Fragment of Sagittarius
- saint-seiya

Effect (EN):
Equip only to a "Black Saint" monster.
The equipped monster gains 500 DEF.
If the equipped monster would be destroyed by battle or card effect, you can destroy this card instead.
Once per turn (Quick Effect): You can send this face-up card to the GY, then target 1 face-up monster your opponent controls; negate its effects until the end of this turn.
If this card is sent to the GY: You can add 1 "Black Saint" monster from your Deck to your hand.
You can only use 1 effect of "Fragment of Sagittarius - Chestplate" per turn, and only once that turn.
```

**Card text** (`texts.desc`):

```text
Equip only to a "Black Saint" monster.
The equipped monster gains 500 DEF.
If the equipped monster would be destroyed by battle or card effect, you can destroy this card instead.
Once per turn (Quick Effect): You can send this face-up card to the GY, then target 1 face-up monster your opponent controls; negate its effects until the end of this turn.
If this card is sent to the GY: You can add 1 "Black Saint" monster from your Deck to your hand.
You can only use 1 effect of "Fragment of Sagittarius - Chestplate" per turn, and only once that turn.
```

### Fragment of Sagittarius - Skirt
- **Card ID**: `922100157`
- **Lua**: `script/unofficial/c922100157.lua`
- **Card type**: Equip Spell

**Lua reference** (header block in script):

```text
ID: 922100157
Type: Spell / Equip Spell

Archetypes:
- Fragment of Sagittarius
- saint-seiya

Effect (EN):
Equip only to a "Black Saint" monster.
Your opponent's monsters that battle the equipped monster lose 500 ATK during damage calculation only.
Once per turn (Quick Effect): You can send this face-up card to the GY; change 1 face-up monster your opponent controls to Defense Position.
If this card is sent to the GY: You can add 1 "Black Saint" monster from your Deck to your hand.
You can only use 1 effect of "Fragment of Sagittarius - Skirt" per turn, and only once that turn.
```

**Card text** (`texts.desc`):

```text
Equip only to a "Black Saint" monster.
Your opponent's monsters that battle the equipped monster lose 500 ATK during damage calculation only.
Once per turn (Quick Effect): You can send this face-up card to the GY; change 1 face-up monster your opponent controls to Defense Position.
If this card is sent to the GY: You can add 1 "Black Saint" monster from your Deck to your hand.
You can only use 1 effect of "Fragment of Sagittarius - Skirt" per turn, and only once that turn.
```

### Fragment of Sagittarius - Left Arm
- **Card ID**: `922100158`
- **Lua**: `script/unofficial/c922100158.lua`
- **Card type**: Equip Spell

**Lua reference** (header block in script):

```text
ID: 922100158
Type: Spell / Equip Spell

Archetypes:
- Fragment of Sagittarius
- saint-seiya

Effect (EN):
Equip only to a "Black Saint" monster.
The equipped monster gains 400 ATK.
Once per turn (Quick Effect): You can send this face-up card to the GY, then target 1 card in your opponent's Spell & Trap Zone; return that target to the hand.
If this card is sent to the GY: You can add 1 "Black Saint" monster from your Deck to your hand.
You can only use 1 effect of "Fragment of Sagittarius - Left Arm" per turn, and only once that turn.
```

**Card text** (`texts.desc`):

```text
Equip only to a "Black Saint" monster.
The equipped monster gains 400 ATK.
Once per turn (Quick Effect): You can send this face-up card to the GY, then target 1 card in your opponent's Spell & Trap Zone; return that target to the hand.
If this card is sent to the GY: You can add 1 "Black Saint" monster from your Deck to your hand.
You can only use 1 effect of "Fragment of Sagittarius - Left Arm" per turn, and only once that turn.
```

### Fragment of Sagittarius - Right Arm
- **Card ID**: `922100159`
- **Lua**: `script/unofficial/c922100159.lua`
- **Card type**: Equip Spell

**Lua reference** (header block in script):

```text
ID: 922100159
Type: Spell / Equip Spell

Archetypes:
- Fragment of Sagittarius
- saint-seiya

Effect (EN):
Equip only to a "Black Saint" monster.
The equipped monster gains 600 ATK.
If the equipped monster destroys an opponent's monster by battle: Inflict 300 damage to your opponent.
Once per turn (Quick Effect): You can send this face-up card to the GY; destroy 1 face-up monster your opponent controls with original ATK less than or equal to the equipped monster's original ATK.
If this card is sent to the GY: You can add 1 "Black Saint" monster from your Deck to your hand.
You can only use 1 effect of "Fragment of Sagittarius - Right Arm" per turn, and only once that turn.
```

**Card text** (`texts.desc`):

```text
Equip only to a "Black Saint" monster.
The equipped monster gains 600 ATK.
If the equipped monster destroys an opponent's monster by battle: Inflict 300 damage to your opponent.
Once per turn (Quick Effect): You can send this face-up card to the GY; destroy 1 face-up monster your opponent controls with original ATK less than or equal to the equipped monster's original ATK.
If this card is sent to the GY: You can add 1 "Black Saint" monster from your Deck to your hand.
You can only use 1 effect of "Fragment of Sagittarius - Right Arm" per turn, and only once that turn.
```

### Fragment of Sagittarius - Right Leg
- **Card ID**: `922100160`
- **Lua**: `script/unofficial/c922100160.lua`
- **Card type**: Equip Spell

**Lua reference** (header block in script):

```text
ID: 922100160
Type: Spell / Equip Spell

Archetypes:
- Fragment of Sagittarius
- saint-seiya

Effect (EN):
Equip only to a "Black Saint" monster.
The equipped monster can make a second attack during each Battle Phase, but only on monsters.
Once per turn (Quick Effect): You can send this face-up card to the GY, then target 1 face-up Attack Position monster your opponent controls; it loses 1000 ATK until the end of this turn.
If this card is sent to the GY: You can add 1 "Black Saint" monster from your Deck to your hand.
You can only use 1 effect of "Fragment of Sagittarius - Right Leg" per turn, and only once that turn.
```

**Card text** (`texts.desc`):

```text
Equip only to a "Black Saint" monster.
The equipped monster can make a second attack during each Battle Phase, but only on monsters.
Once per turn (Quick Effect): You can send this face-up card to the GY, then target 1 face-up Attack Position monster your opponent controls; it loses 1000 ATK until the end of this turn.
If this card is sent to the GY: You can add 1 "Black Saint" monster from your Deck to your hand.
You can only use 1 effect of "Fragment of Sagittarius - Right Leg" per turn, and only once that turn.
```

### Fragment of Sagittarius - Left Leg
- **Card ID**: `922100161`
- **Lua**: `script/unofficial/c922100161.lua`
- **Card type**: Equip Spell

**Lua reference** (header block in script):

```text
ID: 922100161
Type: Spell / Equip Spell

Archetypes:
- Fragment of Sagittarius
- saint-seiya

Effect (EN):
Equip only to a "Black Saint" monster.
Your opponent cannot target the equipped monster with monster effects.
Once per turn (Quick Effect): You can send this face-up card to the GY, then target 1 "Fragment of Sagittarius" card in your GY, except "Fragment of Sagittarius - Left Leg"; add that target to your hand.
If this card is sent to the GY: You can add 1 "Black Saint" monster from your Deck to your hand.
You can only use 1 effect of "Fragment of Sagittarius - Left Leg" per turn, and only once that turn.
```

**Card text** (`texts.desc`):

```text
Equip only to a "Black Saint" monster.
Your opponent cannot target the equipped monster with monster effects.
Once per turn (Quick Effect): You can send this face-up card to the GY, then target 1 "Fragment of Sagittarius" card in your GY, except "Fragment of Sagittarius - Left Leg"; add that target to your hand.
If this card is sent to the GY: You can add 1 "Black Saint" monster from your Deck to your hand.
You can only use 1 effect of "Fragment of Sagittarius - Left Leg" per turn, and only once that turn.
```

---

## Boss monster

### Desecrated Sagittarius - Reassembled Gold Cloth
- **Card ID**: `922100162`
- **Lua**: `script/unofficial/c922100162.lua`
- **Card type**: Effect Monster
- **Attribute**: DARK
- **Monster type**: Warrior
- **Level**: 8
- **ATK / DEF**: 3000 / 2500

**Lua reference** (header block in script):

```text
ID: 922100162
Type: Monster / Effect Monster
Level: 8
Attribute: DARK
Race: Warrior
ATK/DEF: 3000/2500

Archetypes:
- saint-seiya
- Black Saint

Effect (EN):
(This card is always treated as a "Black Saint" card.)
Cannot be Normal Summoned/Set.
Must be Special Summoned (from your hand or GY) while you have 7 or more "Fragment of Sagittarius" cards with different names on your field and/or GY.
If this card is Special Summoned: You can equip up to 2 "Fragment of Sagittarius" Equip Spells from your GY to this card.
Gains these effects based on the number of Equip Cards equipped to it.
● 1+: Cannot be destroyed by battle.
● 2+: Cannot be targeted by your opponent's Spell/Trap effects.
● 3+: Unaffected by your opponent's monster effects.
● 5+: Once per turn (Quick Effect): You can send 1 Equip Card equipped to this card to the GY; negate the activation, and if you do, destroy that card.
You can only Special Summon "Desecrated Sagittarius - Reassembled Gold Cloth" once per turn this way.
```

**Card text** (`texts.desc`):

```text
(This card is always treated as a "Black Saint" card.)
Cannot be Normal Summoned/Set.
Must be Special Summoned (from your hand or GY) while you have 7 or more "Fragment of Sagittarius" cards with different names on your field and/or GY.
If this card is Special Summoned: You can equip up to 2 "Fragment of Sagittarius" Equip Spells from your GY to this card.
Gains these effects based on the number of Equip Cards equipped to it.
● 1+: Cannot be destroyed by battle.
● 2+: Cannot be targeted by your opponent's Spell/Trap effects.
● 3+: Unaffected by your opponent's monster effects.
● 5+: Once per turn (Quick Effect): You can send 1 Equip Card equipped to this card to the GY; negate the activation, and if you do, destroy that card.
You can only Special Summon "Desecrated Sagittarius - Reassembled Gold Cloth" once per turn this way.
```

---

## Spells and Traps

### Death Queen Island
- **Card ID**: `922100163`
- **Lua**: `script/unofficial/c922100163.lua`
- **Card type**: Field Spell

**Lua reference** (header block in script):

```text
ID: 922100163
Type: Spell / Field Spell

Archetypes:
- saint-seiya

Effect (EN):
All "Black Saint" monsters you control gain 300 ATK/DEF.
When this card is activated: You can send 1 "Fragment of Sagittarius" card from your Deck to the GY.
Once per turn: You can target 1 "Black Saint" monster you control; equip 1 "Fragment of Sagittarius" Equip Spell from your GY to that target.
If a face-up "Fragment of Sagittarius" Equip Spell(s) you control is sent to the GY by card effect: You can add 1 "Black Saint" monster from your Deck to your hand, except "Black Saint - Ikki, Leader of Death Queen Island".
You can only use this effect of "Death Queen Island" once per turn.
```

**Card text** (`texts.desc`):

```text
All "Black Saint" monsters you control gain 300 ATK/DEF.
When this card is activated: You can send 1 "Fragment of Sagittarius" card from your Deck to the GY.
Once per turn: You can target 1 "Black Saint" monster you control; equip 1 "Fragment of Sagittarius" Equip Spell from your GY to that target.
If a face-up "Fragment of Sagittarius" Equip Spell(s) you control is sent to the GY by card effect: You can add 1 "Black Saint" monster from your Deck to your hand, except "Black Saint - Ikki, Leader of Death Queen Island".
You can only use this effect of "Death Queen Island" once per turn.
```

### The Stolen Gold Cloth
- **Card ID**: `922100164`
- **Lua**: `script/unofficial/c922100164.lua`
- **Card type**: Normal Spell

**Lua reference** (header block in script):

```text
ID: 922100164
Type: Spell / Normal Spell

Archetypes:
- saint-seiya

Effect (EN):
Send 1 "Fragment of Sagittarius" card from your Deck to the GY, then target 1 "Black Saint" monster you control; equip 1 "Fragment of Sagittarius" Equip Spell from your GY to that target.
If you control "Black Saint - Ikki, Leader of Death Queen Island", you can send up to 2 "Fragment of Sagittarius" cards with different names from your Deck to the GY instead.
You can only activate 1 "The Stolen Gold Cloth" per turn.
```

**Card text** (`texts.desc`):

```text
Send 1 "Fragment of Sagittarius" card from your Deck to the GY, then target 1 "Black Saint" monster you control; equip 1 "Fragment of Sagittarius" Equip Spell from your GY to that target.
If you control "Black Saint - Ikki, Leader of Death Queen Island", you can send up to 2 "Fragment of Sagittarius" cards with different names from your Deck to the GY instead.
You can only activate 1 "The Stolen Gold Cloth" per turn.
```

### Desecrated Sagittarius - The Heist
- **Card ID**: `922100165`
- **Lua**: `script/unofficial/c922100165.lua`
- **Card type**: Counter Trap

**Lua reference** (header block in script):

```text
ID: 922100165
Type: Trap / Counter Trap

Archetypes:
- saint-seiya

Effect (EN):
When your opponent activates a card or effect, while you control a "Black Saint" monster equipped with a "Fragment of Sagittarius" card: Send 1 "Fragment of Sagittarius" Equip Spell you control to the GY; negate the activation, and if you do, destroy that card.
Then, if you control "Black Saint - Ikki, Leader of Death Queen Island", you can destroy 1 card your opponent controls.
You can only activate 1 "Desecrated Sagittarius - The Heist" per turn.
```

**Card text** (`texts.desc`):

```text
When your opponent activates a card or effect, while you control a "Black Saint" monster equipped with a "Fragment of Sagittarius" card: Send 1 "Fragment of Sagittarius" Equip Spell you control to the GY; negate the activation, and if you do, destroy that card.
Then, if you control "Black Saint - Ikki, Leader of Death Queen Island", you can destroy 1 card your opponent controls.
You can only activate 1 "Desecrated Sagittarius - The Heist" per turn.
```

### Oath of the Shadow
- **Card ID**: `922100166`
- **Lua**: `script/unofficial/c922100166.lua`
- **Card type**: Magia continua (Continuous Spell)

**Lua reference** (header block in script):

```text
ID: 922100166
Type: Spell / Continuous Spell

Archetypes:
- saint-seiya

Effect (EN):
Once per turn: You can send 1 "Fragment of Sagittarius" card from your hand or face-up field to the GY; Special Summon 1 "Black Saint" monster from your GY.
While you control "Black Saint - Ikki, Leader of Death Queen Island", you can equip 1 "Fragment of Sagittarius" card from your GY to the monster Special Summoned by this effect.
```

**Card text** (`texts.desc`):

```text
Once per turn: You can send 1 "Fragment of Sagittarius" card from your hand or face-up field to the GY; Special Summon 1 "Black Saint" monster from your GY.
While you control "Black Saint - Ikki, Leader of Death Queen Island", you can equip 1 "Fragment of Sagittarius" card from your GY to the monster Special Summoned by this effect.
```

---

## Crossover and lore support

### Bronze Saint - Seiya, Cosmos of His Companions
- **Card ID**: `922100167`
- **Lua**: `script/unofficial/c922100167.lua`
- **Card type**: Effect Monster
- **Attribute**: LIGHT
- **Monster type**: Warrior
- **Level**: 7
- **ATK / DEF**: 2600 / 1900

**Lua reference** (header block in script):

```text
ID: 922100167
Type: Monster / Effect Monster
Level: 7
Attribute: LIGHT
Race: Warrior
ATK/DEF: 2600/1900

Archetypes:
- saint-seiya

Effect (EN):
If your opponent controls a "Black Saint" monster, you can Special Summon this card (from your hand).
If this card is Normal or Special Summoned: You can send 1 "Saint" monster from your Deck to the GY, then target 1 face-up "Black Saint" monster your opponent controls; negate its effects until the end of this turn.
Once per turn (Quick Effect): You can target 1 "Fragment of Sagittarius" Equip Spell your opponent controls; send it to the GY, and if you do, this card gains 800 ATK until the end of this turn.
At the start of the Damage Step, if this card battles a "Black Saint" monster while you have 3 or more "Saint" monsters with different names in your GY: Destroy that opponent's monster.
You can only use each effect of "Bronze Saint - Seiya, Cosmos of His Companions" once per turn.
```

**Card text** (`texts.desc`):

```text
If your opponent controls a "Black Saint" monster, you can Special Summon this card (from your hand).
If this card is Normal or Special Summoned: You can send 1 "Saint" monster from your Deck to the GY, then target 1 face-up "Black Saint" monster your opponent controls; negate its effects until the end of this turn.
Once per turn (Quick Effect): You can target 1 "Fragment of Sagittarius" Equip Spell your opponent controls; send it to the GY, and if you do, this card gains 800 ATK until the end of this turn.
At the start of the Damage Step, if this card battles a "Black Saint" monster while you have 3 or more "Saint" monsters with different names in your GY: Destroy that opponent's monster.
You can only use each effect of "Bronze Saint - Seiya, Cosmos of His Companions" once per turn.
```

### Esmeralda, Light of Death Queen Island
- **Card ID**: `922100168`
- **Lua**: `script/unofficial/c922100168.lua`
- **Card type**: Effect Monster
- **Attribute**: LIGHT
- **Monster type**: Spellcaster
- **Level**: 2
- **ATK / DEF**: 400 / 1200

**Lua reference** (header block in script):

```text
ID: 922100168
Type: Monster / Effect Monster
Level: 2
Attribute: LIGHT
Race: Spellcaster
ATK/DEF: 400/1200

Archetypes:
- saint-seiya

Effect (EN):
If this card is Normal or Special Summoned: You can add 1 "Death Queen Island" or 1 "Black Saint" Spell/Trap from your Deck to your hand.
When a card or effect is activated that targets this card (Quick Effect): You can Special Summon 1 "Black Saint - Ikki, Leader of Death Queen Island" from your hand, Deck, or GY.
When this card is targeted for an attack: You can negate the attack, and if you do, change the battle position of this card, then you can Special Summon 1 "Black Saint - Ikki, Leader of Death Queen Island" from your hand, Deck, or GY.
You can only use 1 "Esmeralda, Light of Death Queen Island" effect per turn, and only once that turn.
```

**Card text** (`texts.desc`):

```text
If this card is Normal or Special Summoned: You can add 1 "Death Queen Island" or 1 "Black Saint" Spell/Trap from your Deck to your hand.
When a card or effect is activated that targets this card (Quick Effect): You can Special Summon 1 "Black Saint - Ikki, Leader of Death Queen Island" from your hand, Deck, or GY.
When this card is targeted for an attack: You can negate the attack, and if you do, change the battle position of this card, then you can Special Summon 1 "Black Saint - Ikki, Leader of Death Queen Island" from your hand, Deck, or GY.
You can only use 1 "Esmeralda, Light of Death Queen Island" effect per turn, and only once that turn.
```

### Guilty, Master of Hell
- **Card ID**: `922100169`
- **Lua**: `script/unofficial/c922100169.lua`
- **Card type**: Effect Monster
- **Attribute**: DARK
- **Monster type**: Warrior
- **Level**: 5
- **ATK / DEF**: 2100 / 1500

**Lua reference** (header block in script):

```text
ID: 922100169
Type: Monster / Effect Monster
Level: 5
Attribute: DARK
Race: Warrior
ATK/DEF: 2100/1500

Archetypes:
- saint-seiya

Effect (EN):
If you control a "Black Saint" monster, you can Special Summon this card (from your hand).
If this card is Normal or Special Summoned: You can send 1 "Fragment of Sagittarius" card
from your Deck to the GY.
Once per turn (Quick Effect): You can send 1 "Fragment of Sagittarius" Equip Spell you
control to the GY; negate the activation of an opponent's monster effect.
If this face-up card is destroyed by battle or by your opponent's card effect: You can
Special Summon 1 "Black Saint - Ikki, Leader of Death Queen Island" from your hand or GY,
then you can equip 1 "Fragment of Sagittarius" Equip Spell from your GY to it.
You can only use each effect of "Guilty, Master of Hell" once per turn.
```

**Card text** (`texts.desc`):

```text
If you control a "Black Saint" monster, you can Special Summon this card (from your hand).
If this card is Normal or Special Summoned: You can send 1 "Fragment of Sagittarius" card from your Deck to the GY.
Once per turn (Quick Effect): You can send 1 "Fragment of Sagittarius" Equip Spell you control to the GY; negate the activation of an opponent's monster effect.
If this face-up card is destroyed by battle or by your opponent's card effect: You can Special Summon 1 "Black Saint - Ikki, Leader of Death Queen Island" from your hand or GY, then you can equip 1 "Fragment of Sagittarius" Equip Spell from your GY to it.
You can only use each effect of "Guilty, Master of Hell" once per turn.
```

### Esmeralda's Last Will
- **Card ID**: `922100170`
- **Lua**: `script/unofficial/c922100170.lua`
- **Card type**: Quick-Play Spell

**Lua reference** (header block in script):

```text
ID: 922100170
Type: Spell / Quick-Play Spell

Archetypes:
- saint-seiya

Effect (EN):
Target 1 "Black Saint" monster you control; this turn, it gains 800 ATK, also it cannot be destroyed by battle.
Then, if you control "Black Saint - Ikki, Leader of Death Queen Island", you can send 1 "Fragment of Sagittarius" card from your Deck to the GY.
You can only activate 1 "Esmeralda's Last Will" per turn.
```

**Card text** (`texts.desc`):

```text
Target 1 "Black Saint" monster you control; this turn, it gains 800 ATK, also it cannot be destroyed by battle.
Then, if you control "Black Saint - Ikki, Leader of Death Queen Island", you can send 1 "Fragment of Sagittarius" card from your Deck to the GY.
You can only activate 1 "Esmeralda's Last Will" per turn.
```

### Guilty's Cruel Trial
- **Card ID**: `922100171`
- **Lua**: `script/unofficial/c922100171.lua`
- **Card type**: Continuous Spell

**Lua reference** (header block in script):

```text
ID: 922100171
Type: Spell / Continuous Spell

Archetypes:
- saint-seiya

Effect (EN):
When this card is activated: You can add 1 "Esmeralda, Light of Death Queen Island" or 1 "Guilty, Master of Hell" from your Deck to your hand.
Once per turn, if a "Fragment of Sagittarius" Equip Spell you control is sent to the GY by card effect: You can draw 1 card, then discard 1 card.
If you control "Black Saint - Ikki, Leader of Death Queen Island", your opponent cannot target "Esmeralda, Light of Death Queen Island" with card effects.
You can only activate 1 "Guilty's Cruel Trial" per turn.
```

**Card text** (`texts.desc`):

```text
When this card is activated: You can add 1 "Esmeralda, Light of Death Queen Island" or 1 "Guilty, Master of Hell" from your Deck to your hand.
Once per turn, if a "Fragment of Sagittarius" Equip Spell you control is sent to the GY by card effect: You can draw 1 card, then discard 1 card.
If you control "Black Saint - Ikki, Leader of Death Queen Island", your opponent cannot target "Esmeralda, Light of Death Queen Island" with card effects.
You can only activate 1 "Guilty's Cruel Trial" per turn.
```

---

## Regenerating from the database

From the repo root: `python sets/saint_seiya/export_black_saints_md_from_cdb.py` (overwrites this file from `expansions/saint-seiya.cdb`).

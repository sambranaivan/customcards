# Review: Fix Bronze Cloth Effects

**Superseded for card text:** Implemented PSCT and stats are documented in [`../bronze_saints.md`](../bronze_saints.md) (exported from `expansions/saint-seiya.cdb`). This file kept as historical design notes.

**Date**: 2026-05-11
**Scope**: All 10 Bronze Cloth Equip Spells (IDs 922100041–922100050)

## Changes Proposed

### Remove (all 10 cards)
> You can discard this card; add 1 Level 4 "Saint" monster from your Deck to your hand.

Reason: not legal as a hand-activation effect on an Equip Spell.

### Replace GY re-equip effect (all 10 cards)
Old:
> If this face-up Equip Card in its owner's Spell & Trap Zone is sent to the GY: You can target 1 "Saint" monster you control; during your next Standby Phase, equip this card to that target, but banish it when it leaves the field.

New (generic — searches any low-level Saint):
> If this card is sent to the GY: You can add 1 Level 4 or lower "Saint" monster from your Deck or GY to your hand.

### Preserve (all 10 cards)
- Equip restriction: `Equip only to a "Saint" monster.`
- Generic battle/stat effect
- Specific saint synergy (`If the equipped monster is "Saint - X of Y"...`)
- OPYOT restriction

---

## Full Proposed Texts

### Bronze Cloth - Pegasus (922100041)
```
Equip only to a "Saint" monster.
The equipped monster gains 500 ATK.
If the equipped monster attacks, your opponent cannot activate cards or effects until the end of the Damage Step.
If the equipped monster is "Saint - Seiya of Pegasus", it can make up to 2 attacks on monsters during each Battle Phase, also if it destroys an opponent's monster by battle: Inflict 500 damage to your opponent.
If this card is sent to the GY: You can add 1 Level 4 or lower "Saint" monster from your Deck or GY to your hand.
You can only use 1 effect of "Bronze Cloth - Pegasus" per turn, and only once that turn.
```

### Bronze Cloth - Dragon (922100042)
```
Equip only to a "Saint" monster.
The equipped monster gains 1000 DEF.
The equipped monster cannot be destroyed by monster effects.
If the equipped monster is "Saint - Shiryu of Dragon", your opponent cannot target it with card effects.
Once per turn, if the equipped monster in Defense Position would be destroyed by battle, it is not destroyed, and if you do, you can destroy 1 card your opponent controls.
If this card is sent to the GY: You can add 1 Level 4 or lower "Saint" monster from your Deck or GY to your hand.
You can only use 1 effect of "Bronze Cloth - Dragon" per turn, and only once that turn.
```

### Bronze Cloth - Cygnus (922100043)
```
Equip only to a "Saint" monster.
Once per turn: You can target 1 face-up card your opponent controls; negate its effects until the end of this turn.
If the equipped monster is "Saint - Hyoga of Cygnus", monsters negated by this card's effect cannot change their battle positions, also they cannot be used as material for a Special Summon from the Extra Deck while this card is face-up on the field.
If this card is sent to the GY: You can add 1 Level 4 or lower "Saint" monster from your Deck or GY to your hand.
You can only use 1 effect of "Bronze Cloth - Cygnus" per turn, and only once that turn.
```

### Bronze Cloth - Andromeda (922100044)
```
Equip only to a "Saint" monster.
The equipped monster can attack directly.
If the equipped monster is "Saint - Shun of Andromeda", while it is in Defense Position, your opponent cannot declare attacks on other monsters you control, also they cannot activate the effects of monsters that were Special Summoned this turn.
If this card is sent to the GY: You can add 1 Level 4 or lower "Saint" monster from your Deck or GY to your hand.
You can only use 1 effect of "Bronze Cloth - Andromeda" per turn, and only once that turn.
```

### Bronze Cloth - Phoenix (922100045)
```
Equip only to a "Saint" monster.
The equipped monster gains 1000 ATK.
If the equipped monster destroys an opponent's monster by battle: Inflict 1000 damage to your opponent.
If the equipped monster is "Saint - Ikki of Phoenix", and it would be sent to the GY: You can destroy this card instead, and if you do, Special Summon that monster, then you can destroy 1 card on the field.
If this card is sent to the GY: You can add 1 Level 4 or lower "Saint" monster from your Deck or GY to your hand.
You can only use 1 effect of "Bronze Cloth - Phoenix" per turn, and only once that turn.
```

### Bronze Cloth - Unicorn (922100046)
```
Equip only to a "Saint" monster.
The equipped monster can make a second attack during each Battle Phase, but only on monsters.
If the equipped monster is "Saint - Jabu of Unicorn", you gain this effect.
● During your Main Phase, you can Normal Summon 1 "Saint" monster in addition to your Normal Summon/Set. (You can only gain this effect once per turn.)
If this card is sent to the GY: You can add 1 Level 4 or lower "Saint" monster from your Deck or GY to your hand.
You can only use 1 effect of "Bronze Cloth - Unicorn" per turn, and only once that turn.
```

### Bronze Cloth - Hydra (922100047)
```
Equip only to a "Saint" monster.
If an opponent's monster battles the equipped monster, after damage calculation: That opponent's monster loses 1000 ATK/DEF.
If the equipped monster is "Saint - Ichi of Hydra", and it attacks directly, your opponent cannot activate effects in the GY until the end of this turn.
If this card is sent to the GY: You can add 1 Level 4 or lower "Saint" monster from your Deck or GY to your hand.
You can only use 1 effect of "Bronze Cloth - Hydra" per turn, and only once that turn.
```

### Bronze Cloth - Bear (922100048)
```
Equip only to a "Saint" monster.
If the equipped monster destroys an opponent's monster by battle: Your opponent discards 1 random card.
If the equipped monster is "Saint - Geki of Bear", at the start of the Damage Step, if it battles an opponent's monster with higher ATK: You can destroy that opponent's monster.
If this card is sent to the GY: You can add 1 Level 4 or lower "Saint" monster from your Deck or GY to your hand.
You can only use 1 effect of "Bronze Cloth - Bear" per turn, and only once that turn.
```

### Bronze Cloth - Lionet (922100049)
```
Equip only to a "Saint" monster.
The equipped monster gains 600 ATK.
If the equipped monster is "Saint - Ban of Lionet", once per turn: You can target 1 "Saint" monster in your GY; add it to your hand, then discard 1 card.
If this card is sent to the GY: You can add 1 Level 4 or lower "Saint" monster from your Deck or GY to your hand.
You can only use 1 effect of "Bronze Cloth - Lionet" per turn, and only once that turn.
```

### Bronze Cloth - Wolf (922100050)
```
Equip only to a "Saint" monster.
The equipped monster gains 300 ATK/DEF.
Once per turn: You can target 1 "Cloth" card in your GY; shuffle it into the Deck, then the equipped monster gains 300 ATK until the end of this turn.
If the equipped monster is "Saint - Nachi of Wolf", you gain this effect.
● Once per turn: You can draw 1 card, then discard 1 card.
If this card is sent to the GY: You can add 1 Level 4 or lower "Saint" monster from your Deck or GY to your hand.
You can only use 1 effect of "Bronze Cloth - Wolf" per turn, and only once that turn.
```

---

## Design Notes

- **Generic search**: The GY search now adds any Level 4 or lower "Saint" monster (not just the cloth's specific bearer). This makes the Cloths more flexible — each one is a combo piece that can extend into any Saint, improving deckbuilding variety and reducing bricked hands.
- **Phoenix interaction**: When Ikki's cloth is destroyed as a substitute (via the synergy effect) and goes to the GY, the search effect triggers — recovering any Level 4 or lower Saint. Narratively: the Cloth's sacrifice calls a fellow Saint to continue the fight.
- **OPYOT tradeoff**: Using an active effect (Cygnus negate, Dragon indestructible trigger, etc.) blocks the GY search that same turn. Intentional.
- **GY search covers Deck or GY**: Allows recovery even when Saints were already used, preventing bricked hands in later turns.

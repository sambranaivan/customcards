# Black Saints — Balance Review & Suggestions (PSCT)

This document analyzes the balance of the Black Saints archetype: monsters, Fragments of
Sagittarius, support spells/traps, and the boss monster. Each entry includes the current
effect, the identified issue, and a corrected PSCT proposal where applicable.

---

## Archetype Overview

The Black Saints revolve around the **7 Fragments of Sagittarius** (pieces of the stolen
Gold Cloth). The core loop is:

1. Send Fragments to the GY to activate chained effects (swarm, search, draw)
2. Equip Fragments to Black Saints to unlock their Quick Effects
3. Use “Fragment leaves the field” as a trigger for Jango, Andromeda, Death Queen Island
4. Eventually Special Summon the boss when all 7 Fragments have hit the GY

**Ikki** is the central pivot — nearly every card has a bonus condition tied to his presence.

---

## Critical Issues

### Desecrated Sagittarius - Reassembled Gold Cloth — Summon Condition Unreachable in Practice

**Current effect:**
```
Cannot be Normal Summoned/Set.
Must be Special Summoned (from your hand or GY) while you have 7 "Fragment of Sagittarius"
cards with different names in your GY.
If this card is Special Summoned: You can equip up to 2 "Fragment of Sagittarius" Equip
Spells from your GY to this card.
Gains these effects based on the number of Equip Cards equipped to it.
● 1+: Cannot be destroyed by battle.
● 3+: Unaffected by your opponent's activated monster effects.
● 5+: Once per turn (Quick Effect): You can send 1 Equip Card equipped to this card to
      the GY; negate the activation of a card or effect, and if you do, destroy that card.
```

**Problem:** Requires all 7 different Fragments **simultaneously** in the GY. The archetype
actively recycles Fragments back to the hand:
- **Left Leg**: adds 1 Fragment from GY to hand each turn
- **Dark Dragon** (GY effect): recovers 1 Fragment from GY to hand
- **Left Leg** (sent trigger): draw 1, discard 1 — pulls resources out of GY
- **Left Arm** (sent trigger): sets a Black Saint S/T from Deck, incentivizing GY usage

Any Fragment recovery breaks the "7 simultaneous" requirement. Reaching it in practice
means actively ignoring the deck's own recovery tools for multiple turns.

**Proposed fix — reduce and reframe the condition:**
```
Cannot be Normal Summoned/Set.
Must be Special Summoned (from your hand or GY) while you have 5 or more "Fragment of
Sagittarius" cards with different names in your GY, and you have had all 7 different
"Fragment of Sagittarius" cards in your GY at any point during this Duel.
If this card is Special Summoned: You can equip up to 2 "Fragment of Sagittarius" Equip
Spells from your GY to this card.
Gains these effects based on the number of Equip Cards equipped to it.
● 1+: Cannot be destroyed by battle.
● 2+: Cannot be targeted by your opponent's Spell and Trap Card effects.
● 3+: Unaffected by your opponent's activated monster effects.
● 5+: Once per turn (Quick Effect): You can send 1 Equip Card equipped to this card to
      the GY; negate the activation of a card or effect, and if you do, destroy that card.
You can only Special Summon "Desecrated Sagittarius - Reassembled Gold Cloth" once per turn this way.
```

> **Changes:**
> - Summon condition splits into "5 in GY now" + "all 7 sent at some point" — rewards
>   millings without punishing recovery.
> - Added `● 2+: Cannot be targeted by Spell/Trap effects` to close the gap where the boss
>   is fully unprotected from board wipes between the 1+ and 3+ thresholds.
> - Added hard OPT on the Special Summon to prevent loop potential.

---

### Guilty, Master of Hell — Level 5 with No Special Summon Condition

**Current effect:**
```
If this card is Normal or Special Summoned: You can send 1 "Fragment of Sagittarius" card
from your Deck to the GY.
Once per turn (Quick Effect): You can send 1 "Fragment of Sagittarius" Equip Spell you
control to the GY; negate the activation of an opponent's monster effect.
If this face-up card is destroyed by battle or by your opponent's card effect: You can
Special Summon 1 "Black Saint - Ikki, Leader of Death Queen Island" from your hand or GY,
then you can equip 1 "Fragment of Sagittarius" Equip Spell from your GY to it.
You can only use each effect of "Guilty, Master of Hell" once per turn.
```

**Problem:** Level 5 requires a Tribute for Normal Summon and has no Special Summon
condition from hand. Guilty mills a Fragment on summon and negates monster effects at Quick
speed — both essential roles. However, if you open with Guilty in hand and no Tribute fodder,
he is a dead card. His destruction trigger (which revives Ikki) is too important to risk
him sitting in hand unplayable.

**Proposed fix:**
```
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

> **Change:** Adding a conditional SSY from hand while controlling a Black Saint keeps the
> threshold high enough (requires a board) without making him a free drop. Thematically,
> Guilty arrives on Death Queen Island when the Black Saints are already operating.

---

## Moderate Issues

### Black Saint - Dark Pegasus — Missing OPT on Special Summon

**Current effect:**
```
If you control a "Black Saint" monster, you can Special Summon this card (from your hand).
Once per turn: You can equip 1 "Fragment of Sagittarius" Equip Spell from your hand or GY
to this card.
If this card declares an attack while equipped with a "Fragment of Sagittarius" card: Your
opponent cannot activate cards or effects until the end of the Damage Step.
```

**Problem:** The Special Summon condition has no OPT clause. With 2 copies in hand and 1
Black Saint on field: SSY first copy (now 2 Black Saints on field), SSY second copy (now 3).
This creates free board flooding with 0 additional cost.

**Proposed fix:**
```
If you control a "Black Saint" monster, you can Special Summon this card (from your hand).
You can only Special Summon "Black Saint - Dark Pegasus" once per turn this way.
Once per turn: You can equip 1 "Fragment of Sagittarius" Equip Spell from your hand or GY
to this card.
If this card declares an attack while equipped with a "Fragment of Sagittarius" card: Your
opponent cannot activate cards or effects until the end of the Damage Step.
```

> **Change:** Standard OPT on the SSY condition. One line fix.

---

### Black Saint - Ikki, Leader of Death Queen Island — No Access from Hand

**Current effect:**
```
If this card is in your GY: You can send 1 face-up "Fragment of Sagittarius" Equip Spell
you control to the GY; Special Summon this card.
If this card is Normal or Special Summoned: You can add 1 "Fragment of Sagittarius" card
from your Deck to your hand.
Once per turn (Quick Effect): You can send 1 face-up "Fragment of Sagittarius" Equip Spell
you control to the GY, then target 1 face-up card on the field; destroy it.
You can only use each effect of "Black Saint - Ikki, Leader of Death Queen Island" once
per turn.
```

**Problem:** Ikki has no way to enter from hand by himself. He depends entirely on:
- His own GY effect (requires a Fragment already equipped to a monster)
- Esmeralda being destroyed by the opponent
- Guilty being destroyed by battle or opponent's effect

If Ikki is in hand alongside a bricked Esmeralda or Guilty, the entire engine stalls.
The dependency chain (need Black Saint → need Fragment equipped → need Esmeralda/Guilty
destroyed) is fragile in early game.

**Proposed fix:**
```
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

> **Change:** High threshold (requires 2+ Black Saints) prevents a Turn 1 free drop but
> allows Ikki to enter naturally once the swarm is established. Thematically, Ikki leads
> from the front once his subordinates are in position.

---

## Minor Issues

### Fragment of Sagittarius - Right Arm — Removal Threshold Uses Current ATK

**Current effect:**
```
Equip only to a "Black Saint" monster.
The equipped monster gains 700 ATK.
If the equipped monster destroys an opponent's monster by battle: Inflict 500 damage to
your opponent.
Once per turn (Quick Effect): You can send this face-up card to the GY; destroy 1 face-up
monster your opponent controls with ATK less than or equal to the equipped monster's ATK.
```

**Problem:** The Quick Effect destruction uses the equipped monster's **current ATK**, which
already includes the +700 from Right Arm itself. Dark Pegasus + Right Arm = 1800 + 700 =
2500 ATK threshold. Other ATK-boosting Fragments can push this further. At Quick speed, this
unconditional removal covers the majority of mid-game threats.

The cost (sending the Fragment to GY) is real and triggers the archetype's chain of effects,
which somewhat compensates. However, using current ATK instead of original ATK allows the
threshold to be inflated with stacking.

**Proposed fix:**
```
Equip only to a "Black Saint" monster.
The equipped monster gains 700 ATK.
If the equipped monster destroys an opponent's monster by battle: Inflict 500 damage to
your opponent.
Once per turn (Quick Effect): You can send this face-up card to the GY; destroy 1 face-up
monster your opponent controls with original ATK less than or equal to the equipped
monster's original ATK.
```

> **Change:** "original ATK" on both sides prevents the threshold from being inflated by
> equip stacking. Dark Pegasus's original ATK is 1800, which is a fair removal ceiling.

---

## Summary Table

| Card | Verdict | Priority |
|---|---|---|
| **Desecrated Sagittarius - Reassembled Gold Cloth** | Summon condition breaks with own recovery tools | Critical |
| **Guilty, Master of Hell** | Level 5 with no SSY from hand; bricks easily | Critical |
| **Black Saint - Dark Pegasus** | SSY has no OPT; multiple copies per turn | Moderate |
| **Desecrated Sagittarius (protection gap)** | No Spell/Trap protection between 1+ and 3+ equips | Moderate |
| **Ikki (hand access)** | No self-SSY from hand; creates dependency chain bricks | Minor |
| **Fragment - Right Arm** | Current ATK threshold inflatable with equip stacking | Minor |

---

## Cards That Are Well Designed (OK)

### Black Saint - Dark Dragon
```
If this card is Normal or Special Summoned: You can equip 1 "Fragment of Sagittarius" Equip
Spell from your Deck to this card, but send it to the GY during the End Phase.
Once per turn (Quick Effect): You can send 1 Equip Card equipped to this card to the GY;
this card cannot be destroyed by battle or card effects this turn.
If this card is sent to the GY: You can add 1 "Fragment of Sagittarius" card from your GY
to your hand.
You can only use each effect of "Black Saint - Dark Dragon" once per turn.
```
> Three effects that chain naturally: auto-equip feeds the engine → End Phase send triggers
> Jango/Andromeda/Island → GY effect recovers a Fragment back. The cleanest card in the set.

---

### Black Saint - Dark Cygnus
```
If this card is Normal or Special Summoned: You can target 1 face-up monster your opponent
controls; change it to Defense Position.
Once per turn (Quick Effect): You can send 1 "Fragment of Sagittarius" Equip Spell equipped
to a monster you control to the GY; negate its effects until the end of this turn.
If this card is sent to the GY as material for the Summon of a "Black Saint" monster: You
can equip 1 "Fragment of Sagittarius" Equip Spell from your GY to that Summoned monster.
You can only use each effect of "Black Saint - Dark Cygnus" once per turn.
```
> Good utility, fair ATK (1500). The material-used trigger keeps equip resources flowing
> when used for Extra Deck summons.

---

### Black Saint - Dark Phoenix
```
If you control "Black Saint - Ikki, Leader of Death Queen Island": You can Special Summon
this card from your hand.
If this card is Normal or Special Summoned: You can send 1 "Fragment of Sagittarius" card
from your Deck to the GY.
During your Main Phase: You can send 1 face-up "Fragment of Sagittarius" Equip Spell you
control to the GY; Special Summon 1 "Black Saint - Dark Phoenix" from your Deck in Defense
Position, also for the rest of this turn, you cannot Special Summon monsters from the Extra
Deck, except DARK monsters.
You can only use each effect of "Black Saint - Dark Phoenix" once per turn.
```
> Self-clone is interesting and mills 2 Fragments across both summons. The Extra Deck
> restriction is appropriate compensation for cloning from Deck.

---

### Black Saint - Jango, Commander of the Shadow
```
If this card is Normal or Special Summoned: You can send 1 "Fragment of Sagittarius" card
from your Deck to the GY.
If a face-up "Fragment of Sagittarius" Equip Spell(s) you control is sent to the GY by
card effect: You can Special Summon 1 Level 4 or lower "Black Saint" monster from your
hand or GY, except "Black Saint - Jango, Commander of the Shadow".
You can only use each effect of "Black Saint - Jango, Commander of the Shadow" once per turn.
```
> Excellent trigger mechanic. Every Fragment departure swarms the board. Synergizes
> naturally with every other card in the archetype.

---

### Black Saint - Dark Andromeda
```
Your opponent cannot target other "Black Saint" monsters you control for attacks.
Once per turn: You can equip 1 "Fragment of Sagittarius" Equip Spell from your hand or GY
to this card.
If this card is equipped with 2 or more Equip Cards, your opponent cannot target this card
with card effects.
If a face-up "Fragment of Sagittarius" Equip Spell(s) you control is sent to the GY by
card effect: Draw 1 card.
You can only use this effect of "Black Saint - Dark Andromeda" once per turn.
```
> The draw has OPT so it fires at most once per turn regardless of how many Fragments
> leave simultaneously. Protection scales well with equip count.

---

### Esmeralda, Light of Death Queen Island
```
If this card is Normal or Special Summoned: You can add 1 "Death Queen Island" or 1
"Black Saint" Spell/Trap from your Deck to your hand.
(Quick Effect): You can Tribute this card, then target 1 "Black Saint" monster you control;
it cannot be destroyed by battle or card effects this turn.
If this card is sent from the field to the GY by an opponent's card: You can Special Summon
1 "Black Saint - Ikki, Leader of Death Queen Island" from your hand or GY.
You can only use each effect of "Esmeralda, Light of Death Queen Island" once per turn.
```
> Three completely distinct effects, all thematic: searcher, protection sacrifice, and
> revenge summon. One of the best-designed support cards in the archetype.

---

### Death Queen Island
```
All "Black Saint" monsters you control gain 300 ATK/DEF.
When this card is activated: You can send 1 "Fragment of Sagittarius" card from your Deck
to the GY.
Once per turn: You can target 1 "Black Saint" monster you control; equip 1 "Fragment of
Sagittarius" Equip Spell from your GY to that target.
If a face-up "Fragment of Sagittarius" Equip Spell(s) you control is sent to the GY by
card effect: You can add 1 "Black Saint" monster from your Deck to your hand, except
"Black Saint - Ikki, Leader of Death Queen Island".
You can only use this effect of "Death Queen Island" once per turn.
```
> All effects have OPT, preventing loops. Activation mill + equip recovery + search on
> Fragment departure creates a strong but fair advantage engine. Excluding Ikki from the
> search keeps him special.

---

### Legacy of the Desecrated Sagittarius
```
When your opponent activates a card or effect, while you control a "Black Saint" monster
equipped with a "Fragment of Sagittarius" card: Send 1 "Fragment of Sagittarius" Equip
Spell you control to the GY; negate the activation, and if you do, destroy that card.
Then, if you control "Black Saint - Ikki, Leader of Death Queen Island", you can destroy
1 card your opponent controls.
You can only activate 1 "Legacy of the Desecrated Sagittarius" per turn.
```
> Solemn Strike-level Counter Trap at the cost of a Fragment. The Ikki bonus (destroy 1
> additional card) is strong but requires board presence. OPT prevents multi-activation.

---

### Oath of the Shadow
```
Once per turn: You can send 1 "Fragment of Sagittarius" card from your hand or face-up
field to the GY; Special Summon 1 "Black Saint" monster from your GY, but negate its
effects.
While you control "Black Saint - Ikki, Leader of Death Queen Island", monsters Special
Summoned by this effect can activate their effects.
If this face-up card leaves the field, destroy all monsters Special Summoned by this effect.
```
> Strong recursion engine but costs 1 Fragment per turn. The Ikki dependency for full
> effects and the self-destruction clause on removal are clean counterplay levers.

---

### Fragments: Helmet, Chestplate, Skirt, Left Arm, Left Leg, Right Leg
All six are well balanced — each has a distinct role, a clear GY/send trigger, and the
stat bonuses are appropriately modest. They form a complete toolkit without any single
piece being mandatory.

---

## Full Proposed Text — Cards with Changes

### Desecrated Sagittarius - Reassembled Gold Cloth (revised)
```
Cannot be Normal Summoned/Set.
Must be Special Summoned (from your hand or GY) while you have 5 or more "Fragment of
Sagittarius" cards with different names in your GY, and you have had all 7 different
"Fragment of Sagittarius" cards sent to your GY at any point during this Duel.
If this card is Special Summoned: You can equip up to 2 "Fragment of Sagittarius" Equip
Spells from your GY to this card.
Gains these effects based on the number of Equip Cards equipped to it.
● 1+: Cannot be destroyed by battle.
● 2+: Cannot be targeted by your opponent's Spell and Trap Card effects.
● 3+: Unaffected by your opponent's activated monster effects.
● 5+: Once per turn (Quick Effect): You can send 1 Equip Card equipped to this card to
      the GY; negate the activation of a card or effect, and if you do, destroy that card.
You can only Special Summon "Desecrated Sagittarius - Reassembled Gold Cloth" once per turn this way.
```

### Guilty, Master of Hell (revised)
```
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

### Black Saint - Dark Pegasus (revised)
```
If you control a "Black Saint" monster, you can Special Summon this card (from your hand).
You can only Special Summon "Black Saint - Dark Pegasus" once per turn this way.
Once per turn: You can equip 1 "Fragment of Sagittarius" Equip Spell from your hand or GY
to this card.
If this card declares an attack while equipped with a "Fragment of Sagittarius" card: Your
opponent cannot activate cards or effects until the end of the Damage Step.
```

### Black Saint - Ikki, Leader of Death Queen Island (revised)
```
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

### Fragment of Sagittarius - Right Arm (revised)
```
Equip only to a "Black Saint" monster.
The equipped monster gains 700 ATK.
If the equipped monster destroys an opponent's monster by battle: Inflict 500 damage to
your opponent.
Once per turn (Quick Effect): You can send this face-up card to the GY; destroy 1 face-up
monster your opponent controls with original ATK less than or equal to the equipped
monster's original ATK.
```

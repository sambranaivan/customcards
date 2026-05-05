# Saint Seiya — WindBot Guide
## Deck: **Saint Seiya - Bronze Only**

This document is a **programming guide** for a WindBot executor for the deck:

- Decklist: `deck/Saint Seiya - Bronze Only.ydk`
- Cards DB: `expansions/saint-seiya.cdb`
- Scripts: `script/unofficial/c{ID}.lua`

The deck is **Main-only** (no Extra/Side). Its win plan is:

- **Go first**: build a board with
  - **3+ face-up "Saint" monsters with different names** (turns on `922100082`),
  - **at least 1 "Saint" equipped with a "Cloth" Equip** (turns on `922100103`),
  - backed by **Counter Traps** + protection spells.
- **Go second**: survive the opponent’s push with protection/negates, then stabilize into the same “3 names + 1 equipped” shell and win by battle pressure from Cloths.

---

## Deck contents (by ID)

### Monsters
- `922100000` **Bronze Saint - Seiya of Pegasus**
- `922100001` **Bronze Saint - Shiryu of Dragon**
- `922100002` **Bronze Saint - Hyoga of Cygnus**
- `922100003` **Bronze Saint - Shun of Andromeda**
- `922100004` **Bronze Saint - Ikki of Phoenix**
- `922100005` **Bronze Saint - Jabu of Unicorn**
- `922100006` **Bronze Saint - Ichi of Hydra**
- `922100007` **Bronze Saint - Geki of Bear**
- `922100008` **Bronze Saint - Ban of Lionet**
- `922100009` **Bronze Saint - Nachi of Wolf**
- `922100010` **Mu of Aries - The Cloth Repairer**
- `922100011` **Kiki - Messenger of the Cloth Sculptor**

### Bronze Cloth (Equip Spells)
All these share a key consistency effect:
**Discard this card → add 1 Level 4 "Saint" monster from Deck to hand.**

- `922100041` Bronze Cloth - Pegasus
- `922100042` Bronze Cloth - Dragon
- `922100043` Bronze Cloth - Cygnus
- `922100044` Bronze Cloth - Andromeda
- `922100045` Bronze Cloth - Phoenix
- `922100046` Bronze Cloth - Unicorn
- `922100047` Bronze Cloth - Hydra
- `922100048` Bronze Cloth - Bear
- `922100049` Bronze Cloth - Lionet
- `922100050` Bronze Cloth - Wolf

### Spells / Traps
- `922100079` Athena's Sanctuary (Field Spell - base)
- `922100081` Raise Your Cosmos! (Normal Spell)
- `922100086` Awakening of the Cosmos (Quick-Play)
- `922100088` Athena's Call (Normal Spell)
- `922100092` Bond of Brotherhood (Quick-Play)
- `922100082` Athena Exclamation (Counter Trap)
- `922100101` Crystal Wall (Counter Trap)
- `922100103` The Pope's Verdict (Counter Trap)

---

## Roles (for decision making)

### Starters (openers / fix hands)
- `922100088` **Athena's Call**: main starter. If you control no monsters it can search `922100011` instead.
- `922100000` **Seiya**: best starter (summon-search + self-SS if you control no monsters).
- Any **Bronze Cloth in hand**: acts as a “starter” because it converts into a Level 4 Saint search.
- `922100081` **Raise Your Cosmos!**: fixes hands while setting GY (send 1 Saint from Deck; add a different-name Saint).

### Extenders (increase bodies / unique names)
- `922100005` **Jabu**: hand extender (SS if you control a Saint). On SS: add 1 Cloth from GY, then discard 1.
- `922100004` **Ikki**: GY extender (revive by discarding 1 Saint).
- `922100010` **Mu**: resource extender (on summon, add up to 2 Cloth Equips from GY).
- `922100011` **Kiki**:
  - Quick effect from hand: discard → equip 1 Cloth Equip from **Deck or GY** to a Saint you control.
  - Next turn Standby: banish from GY → add up to 2 different-name Cloths from GY.

### Payoffs / “board requirements”
- `922100082` **Athena Exclamation** turns on at **3+ different-name Saints**.
- `922100103` **The Pope’s Verdict** turns on if you control a **Saint equipped with a Cloth**.

### Stabilizers / protection
- `922100079` **Athena's Sanctuary**: global +300/+300; once/turn destruction replacement by sending an equipped Cloth to GY.
- `922100086` **Awakening**: 1-turn indestructible + GY destruction replacement.
- `922100092` **Bond**: protects from opponent’s effects (incl. banish); draws if chained to opponent monster effect.

---

## Key interactions (what matters to the bot)

### Live checks (boolean state)
Define these every decision step:

- `HasEquippedSaint`:
  - true if you control a face-up Saint monster whose EquipGroup contains a face-up card in `SET_CLOTH`.
  - Enables `922100103`.

- `SaintDistinctNamesOnField`:
  - count of **unique** Saint card IDs among your face-up Saints.
  - Enables `922100082` if ≥ 3.

- `CanExtendToThreeNamesThisTurn`:
  - true if you can plausibly reach `SaintDistinctNamesOnField >= 3` this turn via:
    - additional Normal Summon lines (see Unicorn Cloth on Jabu),
    - Jabu SS,
    - Cloth discard → search,
    - Seiya search,
    - Athena’s Call search,
    - Raise Your Cosmos (send+add).

### Threat tiers (simple, executor-friendly)
When deciding to spend Counter Traps:

- **Tier S**: board wipes / removal that breaks the “3 names” core, or effects that remove the *equipped Saint*.
- **Tier A**: strong tempo plays (high-impact search/negate engines, wincon setups).
- **Tier B**: value plays (small removal, minor advantage).

Use:
- `Athena Exclamation (082)` mostly for **Tier S/A**.
- `Pope’s Verdict (103)` for **Tier S/A** if it stops Spell/Trap lines.
- `Crystal Wall (101)` whenever opponent targets your Saints with a negatable activation (usually Tier S/A by definition).

---

## Coinflip policy (choose go-first vs go-second plan)

WindBot has access to duel state: `Duel.GetTurnPlayer()`, whether we started, etc.

**Plan selection**:

```pseudo
function ChooseMacroPlan():
  if Duel.IsFirstTurn() and Duel.GetTurnPlayer() == AI:
    return GO_FIRST_CONTROL
  else:
    return GO_SECOND_SURVIVE_THEN_STABILIZE
```

If you want strict “coinflip” semantics:
- going first ⇒ control plan
- going second ⇒ survive/pressure plan

---

## Literal priority tree (pseudo-code)

### Shared helpers

```pseudo
function CountDistinctSaintNamesOnField() -> int
function HasEquippedSaint() -> bool

function Have(cardId) -> bool           // hand+field+GY checks as needed
function InHand(cardId) -> bool
function InGY(cardId) -> bool
function OnField(cardId) -> bool

function CanActivate(cardId) -> bool
function CanNormalSummon(cardId) -> bool
function CanSpecialSummon(cardId) -> bool

function NeedThirdName() -> bool:
  return CountDistinctSaintNamesOnField() < 3

function NeedEquipForVerdict() -> bool:
  // only “must” if we either already set Verdict, or have it in hand and expect to set it
  return (OnField(922100103) or InHand(922100103)) and not HasEquippedSaint()
```

### Turn 1+ Main Phase (GO_FIRST_CONTROL)

```pseudo
function MainPhase_GoFirst():
  // 0) Field spell if it improves survival and doesn't reduce combo
  if InHand(922100079) and CanActivate(922100079):
    Activate(922100079)

  // 1) Starter priority
  if InHand(922100088) and CanActivate(922100088):
    Activate_AthenasCall()
  else if CanSpecialSummon(922100000) and FieldIsEmpty():
    SpecialSummon(922100000)                 // Seiya from hand
  else if CanNormalSummon(922100000):
    NormalSummon(922100000)
  else if HaveAnyBronzeClothInHand():
    Use_ClothDiscardSearch_SaintLv4()
  else if InHand(922100081) and CanActivate(922100081):
    Activate_RaiseYourCosmos()

  // 2) After first body: push for 2nd/3rd distinct name
  while NeedThirdName():
    if CanSpecialSummon(922100005) and ControlAnySaint():
      SpecialSummon(922100005)               // Jabu extender
      ResolveJabu_OnSPSummon()
      continue

    // Cloth in hand becomes a Saint search
    if HaveAnyBronzeClothInHand():
      Use_ClothDiscardSearch_SaintLv4()
      continue

    // Seiya search can fetch a Saint if we already have Cloth access
    if PendingSeiyaSearch():
      ResolveSeiyaSearch_PreferSaintForNames()
      continue

    // Athena's Call can fetch missing name
    if InHand(922100088) and CanActivate(922100088):
      Activate_AthenasCall()
      continue

    // Raise cosmos if still not there
    if InHand(922100081) and CanActivate(922100081):
      Activate_RaiseYourCosmos()
      continue

    break

  // 3) Ensure Verdict live if we will set it
  if NeedEquipForVerdict():
    if InHand(922100011) and CanActivate(922100011):   // Kiki quick equip (can be used proactively)
      UseKiki_EquipBestClothFromDeckOrGY()
    else if HaveFaceUpSaint() and HaveClothThatCanEquipNow():
      Equip_ClothToBestSaint()
    else if HaveSeiyaOnFieldAndCanUseEquipEffect():
      UseSeiya_EquipFromHandOrGY()

  // 4) Set Counter Traps
  if InHand(922100103): Set(922100103)                 // best generic S/T negate if equip is live
  if InHand(922100101): Set(922100101)                 // target-negate
  if InHand(922100082) and CountDistinctSaintNamesOnField() >= 3:
    Set(922100082)
  else if InHand(922100082):
    // if not live yet, still can set; but value drops. prefer if hand is safe.
    Set(922100082) if HandSizeOrBoardSuggestsSafety()

  // 5) If excess resources: equip for value (pick one)
  if HasSpareEquipAction():
    EquipChoice_GoFirstValue()
```

### Turn 1+ Main Phase (GO_SECOND_SURVIVE_THEN_STABILIZE)

```pseudo
function MainPhase_GoSecond():
  // 0) If threatened, prioritize protection line first (if available)
  if InHand(922100079) and CanActivate(922100079):
    Activate(922100079)

  // 1) Establish at least 1 Saint + 1 equip (to turn on Verdict) if possible
  if FieldIsEmpty() and CanSpecialSummon(922100000) and InHand(922100000):
    SpecialSummon(922100000)
  else if CanNormalSummonBestSaint():
    NormalSummon(BestSaintForSurvival())

  // 2) Get equip online ASAP (so Verdict works)
  if not HasEquippedSaint():
    if InHand(922100011) and CanActivate(922100011) and ControlAnySaint():
      UseKiki_EquipBestClothFromDeckOrGY()
    else if HaveClothThatCanEquipNow():
      Equip_ClothToBestSaint()
    else if HaveSeiyaOnFieldAndCanUseEquipEffect():
      UseSeiya_EquipFromHandOrGY()

  // 3) Extend towards 3 distinct names if safe
  if BoardIsStableEnoughToExtend():
    if InHand(922100088) and CanActivate(922100088):
      Activate_AthenasCall()
    if HaveAnyBronzeClothInHand():
      Use_ClothDiscardSearch_SaintLv4()
    if CanSpecialSummon(922100005) and ControlAnySaint():
      SpecialSummon(922100005)
      ResolveJabu_OnSPSummon()
    if InHand(922100081) and CanActivate(922100081) and NeedThirdName():
      Activate_RaiseYourCosmos()

  // 4) Set interaction
  if InHand(922100103): Set(922100103)
  if InHand(922100101): Set(922100101)
  if InHand(922100082): Set(922100082)                 // even if not live immediately, can become live next

  // 5) Consider battle pressure lines if opponent is exposed
  if CanPushForDamage():
    EquipChoice_GoSecondPressure()
    EnterBattle()
```

---

## Literal implementations of key subroutines

### `Activate_AthenasCall()`

```pseudo
function Activate_AthenasCall():
  if FieldIsEmpty() and DeckContains(922100011) and (NeedEquipForVerdict() or NoOtherStarterInHand()):
    Search(922100011)   // Kiki
  else:
    if not Have(922100000) and DeckContains(922100000):
      Search(922100000) // Seiya
    else:
      Search(ChooseSaintLv4ToMaximizeDistinctNamesOrSurvival())
```

### `ResolveSeiyaSearch_PreferSaintForNames()`

Seiya can search **Cloth Equip** or **Saint monster**.

```pseudo
function ResolveSeiyaSearch_PreferSaintForNames():
  if not HaveAnyBronzeClothAccessSoon():   // no Cloth in hand, no Kiki, no Seiya equip line ready
    AddToHand(ChooseBronzeClothForPlan())
  else:
    AddToHand(ChooseSaintToIncreaseDistinctNamesFirst())
```

### `Use_ClothDiscardSearch_SaintLv4()`

```pseudo
function Use_ClothDiscardSearch_SaintLv4():
  cloth = ChooseClothToDiscard_MinOpportunityCost()
  Discard(cloth)
  Search(ChooseSaintLv4ToMaximizeDistinctNamesOrSurvival())
```

**ChooseClothToDiscard_MinOpportunityCost()**:
- Prefer discarding Cloths that are **least useful to equip right now**.
- If you already have a “must-equip” Cloth for a matchup (e.g. `922100043` vs a key face-up threat), keep it.

### `UseKiki_EquipBestClothFromDeckOrGY()`

```pseudo
function UseKiki_EquipBestClothFromDeckOrGY():
  Discard(922100011)
  targetSaint = ChooseEquipTargetSaint()
  cloth = ChooseClothToEquip_FromDeckOrGY(targetSaint)
  Equip(cloth, targetSaint)
```

**ChooseEquipTargetSaint()**:
- If you want to preserve 3 bodies: prefer equipping **Shun** (harder to attack around).
- If you want pressure: prefer **Seiya** or **Ikki**.
- If you expect targeting removal: prefer **Shiryu + Dragon Cloth**.

**ChooseClothToEquip_FromDeckOrGY()** (simple priority):
- If you need interaction: `922100043` (Cygnus) > `922100042` (Dragon)
- If you need survival: `922100042` (Dragon) > `922100044` (Andromeda on Shun)
- If you need pressure: `922100045` (Phoenix) > `922100041` (Pegasus)

### `Activate_RaiseYourCosmos()`

```pseudo
function Activate_RaiseYourCosmos():
  sendId = ChooseSaintToSendToGY()
  SendFromDeckToGY(sendId)
  addId = ChooseDifferentNameSaintToAdd(sendId)
  AddToHand(addId)
```

**ChooseSaintToSendToGY()**:
- Default: send `922100004` (Ikki) if you foresee revival lines.
- If you specifically need Cloths in GY quickly: plan for `922100006` (Ichi) lines later.

---

## Equip choice policies (one-step scoring)

### Go-first value equip (`EquipChoice_GoFirstValue`)

```pseudo
function EquipChoice_GoFirstValue():
  if NeedEquipForVerdict():
    Equip(best_defensive_or_interactive_cloth)
    return

  // already have Verdict live: choose best “board stickiness”
  if HaveSaint(922100003): Equip(922100044, 922100003) if possible    // Shun + Andromeda lock-ish
  else if HaveSaint(922100001): Equip(922100042, 922100001) if possible // Shiryu + Dragon anti-target
  else if HaveSaint(922100002): Equip(922100043, 922100002) if possible // Hyoga + Cygnus control
  else Equip(922100042, BestSaint) if possible
```

### Go-second pressure equip (`EquipChoice_GoSecondPressure`)

```pseudo
function EquipChoice_GoSecondPressure():
  if HaveSaint(922100000): Equip(922100041, 922100000) if possible  // Seiya + Pegasus: multi-attacks & damage
  else if HaveSaint(922100004): Equip(922100045, 922100004) if possible // Ikki + Phoenix: stickiness + pop
  else Equip(922100045, BestAttackerSaint) if possible
```

---

## Counter Trap activation policies (literal)

### `922100101` Crystal Wall

```pseudo
on EVENT_CHAINING:
  if ChainTargetsAnyOfMySaints() and Duel.IsChainNegatable():
    Activate(922100101)
```

### `922100103` The Pope’s Verdict

```pseudo
on EVENT_CHAINING:
  if OpponentActivatesSpellOrTrap() and Duel.IsChainNegatable() and HasEquippedSaint():
    if ThreatTierOfChain() >= A:
      Activate(922100103)
```

### `922100082` Athena Exclamation

```pseudo
on EVENT_CHAINING:
  if Duel.IsChainNegatable() and CountDistinctSaintNamesOnField() >= 3:
    if ThreatTierOfChain() >= A:
      Activate(922100082)
```

---

## Notes / implementation tips

- Many Saints (Seiya/Shiryu/Hyoga/Shun/Ikki) have “pay 500 LP: equip a Cloth from hand/GY” **and then** apply an **Extra Deck lock**. Since this deck has **no Extra Deck**, the lock is free; the bot can treat that equip as “always safe”.
- Always preserve the invariant:
  - if you have (or will set) `922100103`, keep **HasEquippedSaint == true** before ending your turn.
- Try to keep `CountDistinctSaintNamesOnField() >= 3` when holding `922100082` set, even if that means choosing a weaker attacker.


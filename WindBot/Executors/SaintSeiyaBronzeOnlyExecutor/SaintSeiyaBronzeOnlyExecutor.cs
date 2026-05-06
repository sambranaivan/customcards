using System;
using System.Collections.Generic;
using System.Linq;
using YGOSharp.OCGWrapper.Enums;
using WindBot;
using WindBot.Game;
using WindBot.Game.AI;


/*
================================================================================
WindBot design reference — embedded from repo markdown (read alongside code).

Source file: sets/saint_seiya/bots/Saint Seiya - Bronze Only.md

Maintenance: evolve the AI in this .cs; keep this comment in sync when strategy
intent changes so the executor stays the single place for behavior + rationale.

The guide is the full target spec; `Activate*` / `Resolve*` / `Summon*` methods below
implement a practical subset (WindBot defaults cover the rest where registered).

--- embedded guide (markdown as plain text) ---
================================================================================
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


================================================================================
--- end embedded guide ---
*/

namespace WindBot.Game.AI.Decks
{
    [Deck("SaintSeiyaBronzeOnly", "AI_SaintSeiyaBronzeOnly", "Normal")]
    public class SaintSeiyaBronzeOnlyExecutor : DefaultExecutor
    {
        // Guide coverage notes (embedded MD is the full spec):
        // - Not modeled: full go-second macro loop, Battle-Phase Hyoga trigger, S/A "threat tier" without chain metadata,
        //   Mu → Athena's Sanctuary - Reforged (922100080), Saint-as-material Cloth attach/equip, some Lv4 one-offs (Ichi burn, etc.).
        // - OnSelectHand stays go-first; counters still lean on engine legality + Util.IsChainTarget where applicable.

        private const int BuildVersion = 12;
        private const string BuildTag = "2026-05-06-v12-discard-mill-search-priorities";
        private static bool _buildTagLogged;

        public class CardId
        {
            // Monsters
            public const int Seiya = 922100000;
            public const int Shiryu = 922100001;
            public const int Hyoga = 922100002;
            public const int Shun = 922100003;
            public const int Ikki = 922100004;
            public const int Jabu = 922100005;
            public const int Ichi = 922100006;
            public const int Geki = 922100007;
            public const int Ban = 922100008;
            public const int Nachi = 922100009;
            public const int Mu = 922100010;
            public const int Kiki = 922100011;

            // Cloth equips (discard to search a Level 4 "Saint")
            public const int ClothPegasus = 922100041;
            public const int ClothDragon = 922100042;
            public const int ClothCygnus = 922100043;
            public const int ClothAndromeda = 922100044;
            public const int ClothPhoenix = 922100045;
            public const int ClothUnicorn = 922100046;
            public const int ClothHydra = 922100047;
            public const int ClothBear = 922100048;
            public const int ClothLionet = 922100049;
            public const int ClothWolf = 922100050;

            // Spells/Traps
            public const int AthenasSanctuary = 922100079;
            public const int RaiseYourCosmos = 922100081;
            public const int AthenaExclamation = 922100082;
            public const int AwakeningOfTheCosmos = 922100086;
            public const int AthenasCall = 922100088;
            public const int BondOfBrotherhood = 922100092;
            public const int CrystalWall = 922100101;
            public const int PopesVerdict = 922100103;
        }

        private static readonly int[] Saints =
        {
            CardId.Seiya, CardId.Shiryu, CardId.Hyoga, CardId.Shun, CardId.Ikki,
            CardId.Jabu, CardId.Ichi, CardId.Geki, CardId.Ban, CardId.Nachi,
            CardId.Mu, CardId.Kiki
        };

        private static readonly int[] Lv4Saints =
        {
            CardId.Seiya, CardId.Shiryu, CardId.Hyoga, CardId.Shun, CardId.Ikki,
            CardId.Jabu, CardId.Ichi, CardId.Geki, CardId.Ban, CardId.Nachi
        };

        private static readonly int[] Cloths =
        {
            CardId.ClothPegasus, CardId.ClothDragon, CardId.ClothCygnus, CardId.ClothAndromeda,
            CardId.ClothPhoenix, CardId.ClothUnicorn, CardId.ClothHydra, CardId.ClothBear,
            CardId.ClothLionet, CardId.ClothWolf
        };

        public SaintSeiyaBronzeOnlyExecutor(GameAI ai, Duel duel)
            : base(ai, duel)
        {
            if (!_buildTagLogged)
            {
                _buildTagLogged = true;
                try { Logger.WriteLine("[SaintSeiyaBronzeOnlyExecutor] v" + BuildVersion + " build=" + BuildTag); }
                catch { }
            }

            // Counter traps / interaction (reactive)
            AddExecutor(ExecutorType.Activate, CardId.CrystalWall, ActivateCrystalWall);
            AddExecutor(ExecutorType.Activate, CardId.PopesVerdict, ActivatePopesVerdict);
            AddExecutor(ExecutorType.Activate, CardId.AthenaExclamation, ActivateAthenaExclamation);

            // Protection / setup
            AddExecutor(ExecutorType.Activate, CardId.AwakeningOfTheCosmos, ActivateAwakening);
            AddExecutor(ExecutorType.Activate, CardId.BondOfBrotherhood, ActivateBond);
            AddExecutor(ExecutorType.Activate, CardId.AthenasSanctuary, ActivateSanctuary);

            // Equip online early (guide: Verdict / board shell)
            AddExecutor(ExecutorType.Activate, CardId.Kiki, ResolveKikiActivate);

            // Starters / consistency
            AddExecutor(ExecutorType.Activate, CardId.AthenasCall, ActivateAthenasCall);
            AddExecutor(ExecutorType.Summon, CardId.Seiya, SummonSeiya);
            AddExecutor(ExecutorType.Activate, CardId.Seiya, ResolveSeiyaEffect);
            AddExecutor(ExecutorType.Activate, CardId.RaiseYourCosmos, ActivateRaiseYourCosmos);
            foreach (var cloth in Cloths)
                AddExecutor(ExecutorType.Activate, cloth, ResolveClothActivate);

            // Pay-LP equip (Bronze Saints — guide: safe Extra lock in Main-only deck)
            AddExecutor(ExecutorType.Activate, CardId.Shiryu, ResolveShiryuActivate);
            AddExecutor(ExecutorType.Activate, CardId.Hyoga, ResolveHyogaActivate);
            AddExecutor(ExecutorType.Activate, CardId.Shun, ResolveShunActivate);

            // Extenders — Jabu: Activate only (ignition SS from hand; trigger after SS — not Normal Summon)
            AddExecutor(ExecutorType.SpSummon, CardId.Jabu, SpSummonJabuFromHandIfBridged);
            AddExecutor(ExecutorType.Activate, CardId.Jabu, ResolveJabuActivate);
            // Normal Summon priority ≈ ATK (WindBot tries executors in registration order).
            AddExecutor(ExecutorType.Summon, CardId.Ikki, SummonSaintLv4);
            AddExecutor(ExecutorType.Summon, CardId.Hyoga, SummonSaintLv4);
            AddExecutor(ExecutorType.Summon, CardId.Geki, SummonSaintLv4);
            AddExecutor(ExecutorType.Summon, CardId.Shiryu, SummonSaintLv4);
            AddExecutor(ExecutorType.Summon, CardId.Ban, SummonSaintLv4);
            AddExecutor(ExecutorType.Summon, CardId.Ichi, SummonSaintLv4);
            AddExecutor(ExecutorType.Summon, CardId.Shun, SummonSaintLv4);
            AddExecutor(ExecutorType.Summon, CardId.Nachi, SummonSaintLv4);
            AddExecutor(ExecutorType.Summon, CardId.Mu, SummonMu);
            AddExecutor(ExecutorType.Activate, CardId.Mu, ResolveMuEffect);
            AddExecutor(ExecutorType.Activate, CardId.Ikki, ResolveIkkiEffect);

            // Setting traps near end of turn
            AddExecutor(ExecutorType.SpellSet, SpellSetPolicy);

            // Repos last
            AddExecutor(ExecutorType.Repos, DefaultMonsterRepos);
        }

        public override bool OnSelectHand()
        {
            return true; // prefer going first
        }

        /// <summary>
        /// Never Normal Set Level 4 Saints here: we need face-up names / effects. Defensive posture is FaceUpDefence via <see cref="OnSelectPosition"/>.
        /// </summary>
        public override bool OnSelectMonsterSummonOrSet(ClientCard card)
        {
            return false;
        }

        private void PreselectDiscardPreferIchi()
        {
            // Some executor builds don't expose OnSelectCard overrides to plugins.
            // We can still bias upcoming selection prompts by queuing a selection.
            if (Bot.HasInHand(CardId.Ichi))
                AI.SelectNextCard(CardId.Ichi);
        }

        /// <summary>
        /// WindBot maps the AI to <c>Duel.Fields[0]</c>; turn player index follows <c>Duel.Player</c> (0 = our turn).
        /// Block burning reactive protection Quick-Plays during an open Main Phase on our own turn.
        /// </summary>
        public override bool OnPreActivate(ClientCard card)
        {
            if (card != null
                && (card.IsCode(CardId.AwakeningOfTheCosmos) || card.IsCode(CardId.BondOfBrotherhood))
                && IsOpenOwnMainPhaseNoChain())
                return false;
            return base.OnPreActivate(card);
        }

        private bool ChainIsEmpty()
        {
            return Duel.CurrentChain == null || Duel.CurrentChain.Count == 0;
        }

        /// <summary>Open Main1/Main2 on our turn with no chain — typical "beginner" misuse window for protection QPs.</summary>
        private bool IsOpenOwnMainPhaseNoChain()
        {
            return Duel.Player == 0 && IsMainPhase() && ChainIsEmpty();
        }

        private void TrySendCustomChat(int index, params object[] args)
        {
            try
            {
                if (AI == null)
                    return;
                var method = AI.GetType().GetMethod("SendCustomChat");
                if (method == null)
                    return;
                method.Invoke(AI, new object[] { index, args });
            }
            catch
            {
                // Ignore: dialogs are optional and vary by WindBot build.
            }
        }

        private int DistinctSaintNamesOnField()
        {
            return Bot.MonsterZone
                .Where(c => c != null && c.IsFaceup() && Saints.Contains(c.Id))
                .Select(c => c.Id)
                .Distinct()
                .Count();
        }

        private bool ControlAnySaint()
        {
            return Bot.MonsterZone.Any(c => c != null && c.IsFaceup() && Saints.Contains(c.Id));
        }

        private bool FieldIsEmpty()
        {
            return Bot.GetMonsterCount() == 0;
        }

        private bool HasClothInGraveyard()
        {
            return Bot.Graveyard.IsExistingMatchingCard(c => Cloths.Contains(c.Id));
        }

        /// <summary>Guide: HasEquippedSaint — Saint with a face-up Cloth equip.</summary>
        private bool HasEquippedSaint()
        {
            return Bot.MonsterZone.Any(m =>
                m != null
                && m.IsFaceup()
                && Saints.Contains(m.Id)
                && m.EquipCards != null
                && m.EquipCards.Any(eq => eq != null && eq.IsFaceup() && Cloths.Contains(eq.Id)));
        }

        /// <summary>Guide: NeedEquipForVerdict — will run Verdict and need an equipped Saint.</summary>
        private bool NeedEquipForVerdict()
        {
            return (Bot.HasInHand(CardId.PopesVerdict) || Bot.HasInSpellZone(CardId.PopesVerdict))
                   && !HasEquippedSaint();
        }

        private bool HasStarterInHandBesidesAthenasCall()
        {
            return Bot.HasInHand(CardId.Seiya)
                   || Bot.Hand.IsExistingMatchingCard(c => Cloths.Contains(c.Id))
                   || Bot.HasInHand(CardId.RaiseYourCosmos);
        }

        /// <summary>Guide: ResolveSeiyaSearch — Cloth access "soon" (hand, Kiki, or Seiya+GY equip line).</summary>
        private bool HasBronzeClothAccessSoon()
        {
            if (Bot.Hand.IsExistingMatchingCard(c => Cloths.Contains(c.Id)))
                return true;
            if (Bot.HasInHand(CardId.Kiki))
                return true;
            if (HasSeiyaFaceup() && HasClothInGraveyard() && Bot.LifePoints >= 500 && HasFreeMainSpellZoneForEquip())
                return true;
            return false;
        }

        /// <summary>aux.Stringid index for "pay 500 LP; equip Cloth" on each Saint (script-dependent).</summary>
        private static int GetPayEquipStringOption(int monsterId)
        {
            switch (monsterId)
            {
                case CardId.Seiya: return 2;
                case CardId.Shun: return 0;
                case CardId.Shiryu:
                case CardId.Hyoga:
                case CardId.Ikki:
                    return 1;
                default:
                    return -1;
            }
        }

        private bool IsActivateDescriptionPayEquip(int monsterId)
        {
            var opt = GetPayEquipStringOption(monsterId);
            if (opt < 0)
                return false;
            return ActivateDescription == Util.GetStringId(monsterId, opt);
        }

        /// <summary>Guide: ChooseClothToDiscard_MinOpportunityCost — discard low-tier Cloths first.</summary>
        private static int ClothDiscardTier(int clothId)
        {
            switch (clothId)
            {
                case CardId.ClothWolf:
                case CardId.ClothLionet:
                case CardId.ClothBear:
                case CardId.ClothHydra:
                    return 0;
                case CardId.ClothPegasus:
                case CardId.ClothUnicorn:
                case CardId.ClothPhoenix:
                    return 1;
                case CardId.ClothAndromeda:
                case CardId.ClothDragon:
                case CardId.ClothCygnus:
                    return 2;
                default:
                    return 1;
            }
        }

        private bool ThisClothIsPreferredDiscardAmongHandCloths()
        {
            var inHand = Bot.Hand.Where(c => c != null && Cloths.Contains(c.Id)).ToList();
            if (inHand.Count <= 1)
                return true;
            var best = inHand.Min(c => ClothDiscardTier(c.Id));
            return ClothDiscardTier(Card.Id) <= best;
        }

        /// <summary>Kiki equips from Deck or GY — bitmask Deck|Grave.</summary>
        private bool ClothAccessibleFromDeckOrGraveyard(int clothId)
        {
            return Bot.GetRemainingCount(clothId, (int)(CardLocation.Deck | CardLocation.Grave)) > 0;
        }

        /// <summary>Ikki's ignition equip only selects from Hand or GY.</summary>
        private bool ClothAccessibleFromHandOrGraveyard(int clothId)
        {
            return Bot.HasInHand(clothId)
                   || Bot.Graveyard.IsExistingMatchingCard(c => c.IsCode(clothId));
        }

        private bool HasFreeMainSpellZoneForEquip()
        {
            for (var i = 0; i < 5; i++)
                if (Bot.SpellZone[i] == null)
                    return true;
            return false;
        }

        /// <summary>Bronze Saint → matching Cloth for synergy (Mu/Kiki have no pairing).</summary>
        private static int? ClothMatchingSaint(int saintMonsterId)
        {
            switch (saintMonsterId)
            {
                case CardId.Seiya: return CardId.ClothPegasus;
                case CardId.Shiryu: return CardId.ClothDragon;
                case CardId.Hyoga: return CardId.ClothCygnus;
                case CardId.Shun: return CardId.ClothAndromeda;
                case CardId.Ikki: return CardId.ClothPhoenix;
                case CardId.Jabu: return CardId.ClothUnicorn;
                case CardId.Ichi: return CardId.ClothHydra;
                case CardId.Geki: return CardId.ClothBear;
                case CardId.Ban: return CardId.ClothLionet;
                case CardId.Nachi: return CardId.ClothWolf;
                default: return null;
            }
        }

        /// <summary>Inverse map: Cloth sent from field to GY → prefer that Saint for delayed re-equip.</summary>
        private static int? PreferredSaintIdForCloth(int clothId)
        {
            switch (clothId)
            {
                case CardId.ClothPegasus: return CardId.Seiya;
                case CardId.ClothDragon: return CardId.Shiryu;
                case CardId.ClothCygnus: return CardId.Hyoga;
                case CardId.ClothAndromeda: return CardId.Shun;
                case CardId.ClothPhoenix: return CardId.Ikki;
                case CardId.ClothUnicorn: return CardId.Jabu;
                case CardId.ClothHydra: return CardId.Ichi;
                case CardId.ClothBear: return CardId.Geki;
                case CardId.ClothLionet: return CardId.Ban;
                case CardId.ClothWolf: return CardId.Nachi;
                default: return null;
            }
        }

        private int[] BuildSaintTargetPriorityForClothReequip(int clothId)
        {
            var order = new List<int>();
            var pref = PreferredSaintIdForCloth(clothId);
            if (pref.HasValue)
                order.Add(pref.Value);
            foreach (var id in Saints)
                if (!order.Contains(id))
                    order.Add(id);
            return order.ToArray();
        }

        private int[] BuildIkkiEquipClothPriority()
        {
            var order = new List<int> { CardId.ClothPhoenix };
            foreach (var id in Cloths)
                if (id != CardId.ClothPhoenix)
                    order.Add(id);
            return order.Where(ClothAccessibleFromHandOrGraveyard).ToArray();
        }

        private int[] BuildKikiClothPriorityForTarget(ClientCard saintTarget)
        {
            var preferred = saintTarget != null ? ClothMatchingSaint(saintTarget.Id) : null;
            var fallback = new[]
            {
                CardId.ClothCygnus,
                CardId.ClothDragon,
                CardId.ClothAndromeda,
                CardId.ClothPhoenix,
                CardId.ClothPegasus,
                CardId.ClothUnicorn,
                CardId.ClothHydra,
                CardId.ClothBear,
                CardId.ClothLionet,
                CardId.ClothWolf
            };
            var ordered = new List<int>();
            if (preferred.HasValue && ClothAccessibleFromDeckOrGraveyard(preferred.Value))
                ordered.Add(preferred.Value);
            foreach (var id in fallback)
                if (!ordered.Contains(id))
                    ordered.Add(id);
            return ordered.ToArray();
        }

        private bool HasSeiyaFaceup()
        {
            return Bot.MonsterZone.Any(c => c != null && c.IsFaceup() && c.IsCode(CardId.Seiya));
        }

        private bool IsMainPhase()
        {
            return Duel.Phase == DuelPhase.Main1 || Duel.Phase == DuelPhase.Main2;
        }

        private int ChooseSaintToMaximizeDistinct()
        {
            var onField = new HashSet<int>(Bot.MonsterZone.Where(c => c != null && c.IsFaceup()).Select(c => c.Id));
            foreach (var id in Lv4Saints)
                if (!onField.Contains(id) && Bot.GetRemainingCount(id, 3) > 0)
                    return id;
            return CardId.Seiya;
        }

        /// <summary>
        /// Deck → hand L4 Saint picks (Cloth discard, Seiya, Athena's Call, Raise Your Cosmos).
        /// With a Saint already out, Jabu is a free Special Summon + Cloth from GY — grab him first if still in Deck.
        /// </summary>
        private int ChooseLv4SaintForDeckSearch()
        {
            var onField = new HashSet<int>(Bot.MonsterZone.Where(c => c != null && c.IsFaceup()).Select(c => c.Id));

            // User strategy: when searching a Saint, prefer Ban for SS lines.
            if (!onField.Contains(CardId.Ban)
                && !Bot.HasInHand(CardId.Ban)
                && Bot.GetRemainingCount(CardId.Ban, 3) > 0)
                return CardId.Ban;

            if (ControlAnySaint()
                && Bot.GetMonsterCount() < 5
                && !onField.Contains(CardId.Jabu)
                && !Bot.HasInHand(CardId.Jabu)
                && Bot.GetRemainingCount(CardId.Jabu, 3) > 0)
                return CardId.Jabu;
            return ChooseSaintToMaximizeDistinct();
        }

        private bool ActivateSanctuary()
        {
            if (!IsMainPhase())
                return false;
            if (Bot.HasInSpellZone(CardId.AthenasSanctuary))
                return false;
            return true;
        }

        private bool ResolveSeiyaEquipLegality()
        {
            return Bot.LifePoints >= 500 && HasFreeMainSpellZoneForEquip() && HasClothInGraveyard();
        }

        private int[] BuildPayEquipClothOrder(int saintMonsterId)
        {
            var list = new List<int>();
            var pref = ClothMatchingSaint(saintMonsterId);
            if (pref.HasValue)
                list.Add(pref.Value);
            foreach (var id in Cloths)
                if (!list.Contains(id))
                    list.Add(id);
            return list.ToArray();
        }

        private bool ResolveSeiyaEquipFromGy()
        {
            if (!ResolveSeiyaEquipLegality())
                return false;
            var order = BuildPayEquipClothOrder(CardId.Seiya);
            var gyOnly = order.Where(id => Bot.Graveyard.IsExistingMatchingCard(c => c.IsCode(id))).ToArray();
            if (gyOnly.Length == 0)
                return false;
            AI.SelectCard(gyOnly);
            return true;
        }

        private bool ResolveSeiyaDeckSearch()
        {
            if (!HasBronzeClothAccessSoon())
            {
                AI.SelectCard(new[]
                {
                    CardId.ClothCygnus,
                    CardId.ClothDragon,
                    CardId.ClothAndromeda,
                    CardId.ClothPhoenix,
                    CardId.ClothPegasus
                });
                return true;
            }
            AI.SelectCard(ChooseLv4SaintForDeckSearch());
            return true;
        }

        private bool ResolvePayEquipSaint(int saintMonsterId)
        {
            if (!IsMainPhase())
                return false;
            if (Bot.LifePoints < 500)
                return false;
            if (!HasFreeMainSpellZoneForEquip())
                return false;
            var order = BuildPayEquipClothOrder(saintMonsterId);
            var filtered = order.Where(ClothAccessibleFromHandOrGraveyard).ToArray();
            if (filtered.Length == 0)
                return false;
            AI.SelectCard(filtered);
            return true;
        }

        private bool ActivateAthenasCall()
        {
            if (!IsMainPhase())
                return false;

            // Guide: empty field → Kiki if NeedEquipForVerdict or no other starter in hand.
            if (FieldIsEmpty() && Bot.GetRemainingCount(CardId.Kiki, 3) > 0)
            {
                if (NeedEquipForVerdict() || !HasStarterInHandBesidesAthenasCall())
                {
                    TrySendCustomChat(0);
                    AI.SelectCard(CardId.Kiki);
                    return true;
                }
            }

            // Prefer Seiya as the best starter if available.
            if (!Bot.HasInHand(CardId.Seiya) && Bot.GetRemainingCount(CardId.Seiya, 3) > 0)
            {
                TrySendCustomChat(1);
                AI.SelectCard(CardId.Seiya);
                return true;
            }

            TrySendCustomChat(0);
            AI.SelectCard(ChooseLv4SaintForDeckSearch());
            return true;
        }

        private bool SummonSeiya()
        {
            return IsMainPhase();
        }

        private bool SummonSaintLv4()
        {
            if (!IsMainPhase())
                return false;

            // This deck wants bodies + distinct names. Even if the enemy has a bigger monster,
            // we still develop field and rely on equips/counters; positioning is handled separately.
            if (Bot.GetMonsterCount() >= 5)
                return false;

            // Prefer to keep normal summon for Seiya early if we can still do it.
            if (Bot.HasInHand(CardId.Seiya) && !Card.IsCode(CardId.Seiya))
                return false;

            // Summon if we need names, or if we have spare hand to build board.
            if (DistinctSaintNamesOnField() < 3)
                return true;

            // Competent line: do not "skip" Normal Summon while hand still carries Level 4 Saints and MMZ is open.
            int lv4InHand = Bot.Hand.Count(c => Lv4Saints.Contains(c.Id));
            if (lv4InHand >= 2 && Bot.GetMonsterCount() <= 3)
                return true;

            if (NeedEquipForVerdict() && Bot.GetMonsterCount() < 5)
                return true;

            if (!HasEquippedSaint()
                && Bot.Hand.IsExistingMatchingCard(c => Cloths.Contains(c.Id))
                && Bot.GetMonsterCount() < 4)
                return true;

            if (Bot.GetHandCount() >= 5)
                return true;

            // If we have counter traps to set, having more names/equipped body helps enable them next turn.
            if (Bot.Hand.IsExistingMatchingCard(c => c.IsCode(CardId.AthenaExclamation) || c.IsCode(CardId.PopesVerdict)))
                return true;

            return false;
        }

        /// <summary>
        /// Prefer FaceUpDefence when their strongest line threatens ATK mode but DEF mode walls better (or solo / behind-on-ATK lines).
        /// </summary>
        private bool PreferFaceUpDefenceSummon(int atkStat, int defStat, IList<CardPosition> positions)
        {
            if (positions == null || !positions.Contains(CardPosition.FaceUpDefence))
                return false;

            int enemyBestAtk = Util.GetBestAttack(Enemy);

            // Classic wall: loses as attacker (ATK) but survives battle when defending (DEF vs their best ATK).
            if (enemyBestAtk > atkStat && enemyBestAtk <= defStat)
                return true;

            // Solo body (no other monsters yet): do not leave ATK into their best attacker if DEF is legal.
            if (Bot.GetMonsterCount() == 0 && enemyBestAtk >= atkStat)
                return true;

            // Multi-monster: any visible attacker beats our printed ATK — DEF avoids an unfavourable crash when attacked.
            if (Enemy.GetMonsters().Any(m => m != null && m.IsFaceup() && m.Attack > atkStat))
                return true;

            return false;
        }

        public override CardPosition OnSelectPosition(int cardId, IList<CardPosition> positions)
        {
            var named = YGOSharp.OCGWrapper.NamedCard.Get(cardId);
            if (named != null && named.Attack == 0 && positions != null && positions.Contains(CardPosition.FaceUpDefence))
                return CardPosition.FaceUpDefence;

            int atkStat = Card != null ? Card.Attack : (named != null ? named.Attack : 0);
            int defStat = Card != null ? Card.Defense : (named != null ? named.Defense : 0);

            if (PreferFaceUpDefenceSummon(atkStat, defStat, positions))
                return CardPosition.FaceUpDefence;

            return base.OnSelectPosition(cardId, positions);
        }

        private bool ResolveSeiyaEffect()
        {
            var d = ActivateDescription;
            var seiya = CardId.Seiya;

            // Hand — Stringid 1: SS if you control no monsters.
            if ((Card.Location & CardLocation.Hand) != 0)
            {
                if (!IsMainPhase())
                    return false;
                if (d == Util.GetStringId(seiya, 1) || d == -1)
                    return FieldIsEmpty() && Bot.GetMonsterCount() < 5;
                return false;
            }

            if ((Card.Location & CardLocation.MonsterZone) == 0 || !Card.IsCode(seiya))
                return false;

            if (!IsMainPhase())
                return false;

            // Field — Stringid 2: pay 500; equip Cloth from GY (explicit description only).
            if (d == Util.GetStringId(seiya, 2))
                return ResolveSeiyaEquipFromGy();

            // Field — on Normal/Special Summon: add Cloth or Saint (Stringid 0 in script).
            // Custom / Ignis often sends an ActivateDescription that does NOT match Util.GetStringId(id,0)
            // (that helper is only id*16+n). Any other field activation is treated as this search.
            return ResolveSeiyaDeckSearch();
        }

        /// <summary>
        /// Bronze Cloth: hand ignition (discard → search L4 Saint), GY trigger (target Saint → re-equip next Standby),
        /// and Standby Phase equip resolution on the registered Cloth in GY.
        /// </summary>
        private bool ResolveClothActivate()
        {
            if (!Cloths.Contains(Card.Id))
                return false;

            if ((Card.Location & CardLocation.Hand) != 0)
                return ActivateClothDiscardFromHand();

            if ((Card.Location & CardLocation.Grave) != 0)
            {
                if (Duel.Phase == DuelPhase.Standby)
                {
                    if (!HasFreeMainSpellZoneForEquip())
                        return false;
                    return true;
                }

                return ActivateClothSentFromFieldToGyReequip();
            }

            return false;
        }

        private bool ActivateClothSentFromFieldToGyReequip()
        {
            // "If this face-up Equip in S/T Zone is sent to the GY: target 1 Saint you control; next Standby Phase equip this card."
            if (!ControlAnySaint())
                return false;

            AI.SelectCard(BuildSaintTargetPriorityForClothReequip(Card.Id));
            return true;
        }

        private bool ActivateClothDiscardFromHand()
        {
            // Cloths: "Discard this card; add 1 Level 4 Saint monster from Deck to hand."
            // Only do this in Main Phase, and only if it helps reach 3 distinct names or fix an empty board.
            if (!IsMainPhase())
                return false;

            if (!ThisClothIsPreferredDiscardAmongHandCloths())
                return false;

            if (FieldIsEmpty())
            {
                AI.SelectCard(CardId.Seiya, CardId.Shun, CardId.Shiryu);
                return true;
            }

            if (DistinctSaintNamesOnField() < 3)
            {
                AI.SelectCard(ChooseLv4SaintForDeckSearch());
                return true;
            }

            // Strategy update: Seiya equips only from GY now.
            // If Seiya is already established but we have no Cloth in GY, discard a Cloth to seed GY.
            if (HasSeiyaFaceup() && !HasClothInGraveyard())
            {
                AI.SelectCard(ChooseLv4SaintForDeckSearch());
                return true;
            }

            return false;
        }

        private bool ActivateRaiseYourCosmos()
        {
            if (!IsMainPhase())
                return false;

            if (DistinctSaintNamesOnField() >= 3)
                return false;

            // Send Ikki by default for revival lines.
            AI.SelectCard(CardId.Ikki);
            // Add a different-name Saint to hand.
            AI.SelectNextCard(ChooseLv4SaintForDeckSearch());
            return true;
        }

        private bool ResolveKikiActivate()
        {
            if ((Card.Location & CardLocation.Hand) != 0)
                return ActivateKikiEquip();
            if ((Card.Location & CardLocation.Grave) != 0 && Duel.Phase == DuelPhase.Standby)
                return Bot.Graveyard.IsExistingMatchingCard(c => Cloths.Contains(c.Id));
            return false;
        }

        private bool ActivateKikiEquip()
        {
            // Kiki (hand): discard -> equip a Cloth from Deck/GY to a Saint you control.
            // Guide: key line to turn on Verdict (NeedEquipForVerdict).
            if (!IsMainPhase())
                return false;

            if (!ControlAnySaint())
                return false;

            // Pick equip target: Shun (sticky) > Seiya (pressure) > Shiryu (defensive)
            var target = Bot.MonsterZone.FirstOrDefault(c => c != null && c.IsFaceup() && c.IsCode(CardId.Shun))
                         ?? Bot.MonsterZone.FirstOrDefault(c => c != null && c.IsFaceup() && c.IsCode(CardId.Seiya))
                         ?? Bot.MonsterZone.FirstOrDefault(c => c != null && c.IsFaceup() && c.IsCode(CardId.Shiryu))
                         ?? Bot.MonsterZone.FirstOrDefault(c => c != null && c.IsFaceup() && Saints.Contains(c.Id));

            if (target == null)
                return false;

            TrySendCustomChat(2, target.Name);
            AI.SelectCard(target);

            AI.SelectNextCard(BuildKikiClothPriorityForTarget(target));

            return true;
        }

        private bool ResolveShiryuActivate()
        {
            if ((Card.Location & CardLocation.Hand) != 0)
            {
                if (ActivateDescription != Util.GetStringId(CardId.Shiryu, 0) && ActivateDescription != -1)
                    return false;
                if (Duel.Player == 0)
                    return false;
                return Bot.SpellZone.Any(z => z != null && z.IsFaceup() && Cloths.Contains(z.Id));
            }
            if (!IsMainPhase())
                return false;
            if ((Card.Location & CardLocation.MonsterZone) == 0)
                return false;
            if (IsActivateDescriptionPayEquip(CardId.Shiryu) || ActivateDescription == -1)
                return ResolvePayEquipSaint(CardId.Shiryu);
            return false;
        }

        private bool ResolveHyogaActivate()
        {
            if (!IsMainPhase())
                return false;
            if ((Card.Location & CardLocation.MonsterZone) == 0)
                return false;
            if (IsActivateDescriptionPayEquip(CardId.Hyoga) || ActivateDescription == -1)
                return ResolvePayEquipSaint(CardId.Hyoga);
            return false;
        }

        private bool ResolveShunActivate()
        {
            if (!IsMainPhase())
                return false;
            if ((Card.Location & CardLocation.MonsterZone) == 0)
                return false;
            if (ActivateDescription == Util.GetStringId(CardId.Shun, 0) || ActivateDescription == -1)
                return ResolvePayEquipSaint(CardId.Shun);
            return false;
        }

        private bool SummonMu()
        {
            if (!IsMainPhase())
                return false;
            if (Bot.GetMonsterCount() >= 5)
                return false;
            if (!ControlAnySaint())
                return false;
            if (!Bot.Graveyard.IsExistingMatchingCard(c => Cloths.Contains(c.Id)))
                return false;
            return Bot.GetHandCount() > 0;
        }

        private bool ResolveMuEffect()
        {
            if (!IsMainPhase())
                return false;

            // Stringid 1: discard Mu; search Athena's Sanctuary - Reforged (handled by engine if legal).
            if (ActivateDescription == Util.GetStringId(CardId.Mu, 1))
                return false;

            // Stringid 0: on summon — add Cloths from GY.
            if (Bot.Graveyard.IsExistingMatchingCard(c => Cloths.Contains(c.Id)))
            {
                AI.SelectCard(Cloths);
                return true;
            }

            return false;
        }

        /// <summary>Some WindBot builds route hand ignition SS through SpSummon.</summary>
        private bool SpSummonJabuFromHandIfBridged()
        {
            if (!IsMainPhase())
                return false;
            if ((Card.Location & CardLocation.Hand) == 0)
                return false;
            return ControlAnySaint() && Bot.GetMonsterCount() < 5;
        }

        private bool ResolveJabuActivate()
        {
            // Hand — Stringid 0: ignition SS if you control a Saint (only ignition from hand on this card).
            if ((Card.Location & CardLocation.Hand) != 0)
            {
                if (!IsMainPhase())
                    return false;
                return ControlAnySaint() && Bot.GetMonsterCount() < 5;
            }

            // Material-from-GY line — leave to engine/default unless extended later.
            if ((Card.Location & CardLocation.Grave) != 0)
                return false;

            // Monster zone — Stringid 1: optional after SP Summon — add 1 Cloth from GY, then discard (handled by engine).
            if ((Card.Location & CardLocation.MonsterZone) == 0)
                return false;
            if (!IsMainPhase())
                return false;
            // Stringid 2: sent as material — leave unhandled here.
            if (ActivateDescription == Util.GetStringId(CardId.Jabu, 2))
                return false;

            var clothInGy = Bot.Graveyard.FirstOrDefault(c => c != null && Cloths.Contains(c.Id));
            if (clothInGy == null)
                return false;
            AI.SelectCard(clothInGy);
            PreselectDiscardPreferIchi(); // after add-from-GY, effect discards 1
            return true;
        }

        private bool ResolveIkkiEffect()
        {
            if (!IsMainPhase())
                return false;

            var d = ActivateDescription;

            // Field: pay 500 LP; equip 1 "Cloth" from Hand or GY (Stringid 1).
            if ((Card.Location & CardLocation.MonsterZone) != 0)
            {
                if (d != -1 && d != Util.GetStringId(CardId.Ikki, 1))
                    return false;
                if (Bot.LifePoints < 500)
                    return false;
                if (!HasFreeMainSpellZoneForEquip())
                    return false;
                var clothOrder = BuildIkkiEquipClothPriority();
                if (clothOrder.Length == 0)
                    return false;
                AI.SelectCard(clothOrder);
                return true;
            }

            // GY: discard 1 "Saint" → Special Summon (Stringid 0).
            if ((Card.Location & CardLocation.Grave) == 0)
                return false;
            if (d != -1 && d != Util.GetStringId(CardId.Ikki, 0))
                return false;

            if (DistinctSaintNamesOnField() >= 3)
                return false;

            if (!Bot.Hand.IsExistingMatchingCard(c => Saints.Contains(c.Id) && c.Id != CardId.Ikki))
                return false;

            // Ikki revive cost = discard 1 "Saint": prioritize Ichi for discard synergy when available.
            if (Bot.HasInHand(CardId.Ichi))
                AI.SelectCard(CardId.Ichi);
            else
                AI.SelectCard(ChooseSaintToMaximizeDistinct());
            return true;
        }

        private bool ActivateAwakening()
        {
            // Save for reactive windows — never burn during open Main on our turn (OnPreActivate also enforces).
            if (IsOpenOwnMainPhaseNoChain())
                return false;
            return true;
        }

        private bool ActivateBond()
        {
            if (IsOpenOwnMainPhaseNoChain())
                return false;
            return true;
        }

        private bool ActivateCrystalWall()
        {
            // Guide: when a chain targets your Saints (Tier S/A interaction).
            if (Duel.Player == 0)
                return false;
            return Bot.MonsterZone.Any(m =>
                m != null && m.IsFaceup() && Saints.Contains(m.Id) && Util.IsChainTarget(m));
        }

        private bool ActivatePopesVerdict()
        {
            // Guide: 103 when equipped Saint shell is live (engine also gates).
            TrySendCustomChat(4);
            return Duel.Player != 0 && HasEquippedSaint();
        }

        private bool ActivateAthenaExclamation()
        {
            // Guide: 082 when ≥3 distinct names and meaningful interaction (engine also gates legality).
            TrySendCustomChat(3);
            return Duel.Player != 0 && DistinctSaintNamesOnField() >= 3;
        }

        private bool SpellSetPolicy()
        {
            // Set counter traps at end of main phase if possible.
            if (!IsMainPhase())
                return false;

            // Prefer keeping Cloths in hand for discard-search instead of setting.
            if (Cloths.Contains(Card.Id))
                return false;

            if (Card.IsCode(CardId.PopesVerdict))
                return ControlAnySaint() || HasEquippedSaint();

            if (Card.IsCode(CardId.AthenaExclamation))
                return DistinctSaintNamesOnField() >= 3 || Bot.GetHandCount() >= 6;

            return DefaultSpellSet();
        }
    }
}


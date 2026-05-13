# WindBot API Reference

## Project Structure (Plugin Mode A)

```
WindBot/
├── WindBot.exe              # Prebuilt main binary
├── ExecutorBase.dll         # Shared API (DefaultExecutor, GameAI, etc.)
├── Decks/                   # .ydk deck files (AI_{Name}.ydk)
├── Dialogs/                 # .json dialog files
│   └── default.json         # Default dialog (has "custom" array)
├── bots.json                # Bot roster for EDOPro
└── Executors/               # Plugin DLLs + source folders
    ├── {Name}Executor.dll   # Compiled plugin
    └── {Name}Executor/      # Source folder
        ├── {Name}Executor.cs
        └── {Name}Executor.csproj
```

## Card Enums (YGOSharp.OCGWrapper.Enums)

### CardAttribute
`Earth`, `Water`, `Fire`, `Wind`, `Light`, `Dark`, `Divine`

### CardRace
`Warrior`, `Spellcaster`, `Fairy`, `Fiend`, `Zombie`, `Machine`,
`Aqua`, `Pyro`, `Rock`, `WingedBeast`, `Plant`, `Insect`,
`Thunder`, `Dragon`, `Beast`, `BeastWarrior`, `Dinosaur`, `Fish`,
`SeaSerpent`, `Reptile`, `Psychic`, `Divine`, `CreatorGod`, `Wyrm`, `Cyberse`

### CardType (flags, combinable)
`Monster`, `Spell`, `Trap`, `Normal`, `Effect`, `Fusion`, `Ritual`,
`Synchro`, `Xyz`, `Pendulum`, `Link`, `Token`,
`QuickPlay`, `Continuous`, `Equip`, `Field`, `Counter`,
`Flip`, `Toon`, `Spirit`, `Union`, `Gemini`, `Tuner`

### CardLocation (flags)
`Deck`, `Hand`, `MonsterZone`, `SpellZone`, `Grave`, `Removed`,
`Extra`, `Overlay`, `Onfield`, `Faceup`, `Facedown`

### CardPosition
`FaceUpAttack`, `FaceDownAttack`, `FaceUpDefence`, `FaceDownDefence`

### DuelPhase
`Draw`, `Standby`, `Main1`, `Battle`, `BattleStart`, `BattleStep`,
`Damage`, `DamageCal`, `Main2`, `End`

### ExecutorType
`Summon`, `SpSummon`, `Repos`, `MonsterSet`, `SpellSet`, `Activate`,
`SummonOrSet`, `GoToBattlePhase`, `GoToMainPhase2`, `GoToEndPhase`

---

## Core Objects

### Bot / Enemy (ClientField)

```csharp
Bot.MonsterZone       // ClientCard[7] — zones 0-4 main, 5-6 extra
Bot.SpellZone         // ClientCard[8] — zones 0-4 main, 5 field, 6-7 pendulum
Bot.Hand              // CardGroup
Bot.Graveyard         // CardGroup
Bot.Banished          // CardGroup
Bot.Deck              // CardGroup
Bot.ExtraDeck         // CardGroup
Bot.LifePoints        // int
Bot.BattlingMonster   // ClientCard (during battle)
```

### Query Methods

```csharp
Bot.HasInHand(int id)
Bot.HasInMonstersZone(int id)
Bot.HasInSpellZone(int id)
Bot.HasInGraveyard(int id)
Bot.HasInExtra(int id)
Bot.HasInBanished(int id)
Bot.GetRemainingCount(int id, int originalCount) // copies left in deck
Bot.GetMonsterCount()
Bot.GetSpellCount()
Bot.GetHandCount()
```

### Card Matching

```csharp
Bot.MonsterZone.GetMatchingCardsCount(card => card.Level == 4)
Bot.MonsterZone.IsExistingMatchingCard(card => card.IsTuner())
Bot.Graveyard.GetMatchingCardsCount(card => card.HasRace(CardRace.Fairy))
Bot.Hand.IsExistingMatchingCard(card => card.IsCode(CardId.X))
Bot.Hand.Count(card => someArray.Contains(card.Id)) // LINQ
Bot.MonsterZone.FirstOrDefault(c => c != null && c.IsFaceup() && c.IsCode(id))
Bot.MonsterZone.Any(c => c != null && c.IsFaceup() && someSet.Contains(c.Id))
```

### ClientCard Properties

```csharp
Card.Id               // int passcode
Card.Location          // CardLocation
Card.Controller        // 0=bot, 1=opponent
Card.IsCode(int id)
Card.IsFacedown() / Card.IsFaceup()
Card.IsAttack() / Card.IsDefense()
Card.HasRace(CardRace.X)
Card.HasAttribute(CardAttribute.X)
Card.HasType(CardType.X)
Card.IsTuner()
Card.Level / Card.Rank / Card.LinkCount
Card.Attack / Card.Defense
Card.EquipCards         // List<ClientCard> (cards equipped to this)
Card.EquipTarget        // ClientCard (card this is equipped to)
```

### Duel Properties

```csharp
Duel.Player            // 0=bot's turn, 1=opponent's turn
Duel.Turn              // int turn number
Duel.Phase             // DuelPhase enum
Duel.LastChainPlayer   // who activated last chain link
Duel.CurrentChain      // IList of chain links (reflection needed for details)
```

### AI Selection

```csharp
AI.SelectCard(int id)                        // select one card by ID
AI.SelectCard(int[] ids)                     // preference order
AI.SelectCard(ClientCard card)               // select specific card object
AI.SelectNextCard(int id)                    // for multi-select prompts
AI.SelectNextCard(int[] ids)                 // preference order for next pick
AI.SelectMaterials(int[] ids)                // summon materials
AI.SelectMaterials(CardLocation loc)         // materials from location
AI.SelectOption(int index)                   // option prompt
AI.SelectYesNo(bool yes)                     // yes/no prompt
AI.SelectPlace(int zones)                    // zone selection (Zones.z0, etc.)
```

### Util (AIUtil)

```csharp
Util.GetProblematicEnemyCard()       // highest priority threat
Util.GetProblematicEnemyMonster()
Util.GetProblematicEnemySpell()
Util.GetBestEnemyCard()
Util.GetBestEnemyMonster()
Util.IsTurn1OrMain2()
Util.IsChainTarget(ClientCard card)  // is this card targeted by current chain?
Util.GetStringId(int cardId, int idx) // effect description ID for ActivateDescription matching
```

### ActivateDescription

```csharp
ActivateDescription    // int — set by engine before calling your Activate handler
// Match against Lua StringId values to distinguish multi-effect cards:
if (ActivateDescription == Util.GetStringId(CardId.MyCard, 0)) { /* effect 1 */ }
if (ActivateDescription == Util.GetStringId(CardId.MyCard, 1)) { /* effect 2 */ }
if (ActivateDescription == -1) { /* unknown/default */ }
```

---

## Overridable Methods

```csharp
public override bool OnSelectHand()           // true=go first
public override void OnNewTurn()              // reset per-turn flags
public override bool OnSelectMonsterSummonOrSet(ClientCard card) // true=set, false=summon
public override bool OnPreActivate(ClientCard card)              // gate before Activate handlers
public override CardPosition OnSelectPosition(int cardId, IList<CardPosition> positions)
public override BattlePhaseAction OnBattle(IList<ClientCard> attackers, IList<ClientCard> defenders)
public override bool OnPreBattleBetween(ClientCard attacker, ClientCard defender)
public override int OnSelectPlace(long cardId, int player, CardLocation location, int available)
```

---

## Default Helper Methods

| Method | Use for |
|--------|---------|
| `DefaultRaigeki` | Destroy all enemy monsters |
| `DefaultDarkHole` | Destroy all monsters |
| `DefaultHarpiesFeatherDusterFirst` | Destroy all enemy spells/traps |
| `DefaultMysticalSpaceTyphoon` | Destroy a spell/trap |
| `DefaultCosmicCyclone` | Banish a spell/trap |
| `DefaultBookOfMoon` | Flip face-down |
| `DefaultCompulsoryEvacuationDevice` | Bounce to hand |
| `DefaultSolemnJudgment` | Negate (pay half LP) |
| `DefaultSolemnWarning` | Negate summon |
| `DefaultSolemnStrike` | Negate effect/summon |
| `DefaultTorrentialTribute` | Destroy all on summon |
| `DefaultTrap` | Generic trap |
| `DefaultSpellSet` | Set spells/traps |
| `DefaultMonsterSummon` | Summon if > tributes |
| `DefaultMonsterRepos` | Smart position change |
| `DefaultField` | Activate if no field |
| `DefaultMaxxC` | Activate on opponent's turn |
| `DefaultAshBlossomAndJoyousSpring` | Negate search/SS from deck |
| `DefaultEffectVeiler` | Negate monster effect |
| `DefaultCalledByTheGrave` | Banish from GY |
| `DefaultInfiniteImpermanence` | Negate monster effect |
| `DefaultCallOfTheHaunted` | Revive monster |

---

## WindBot Dialogs System

### Dialog Class Fields (via reflection on `AI._dialogs`)

| Field | Type | Triggered by |
|-------|------|-------------|
| `_welcome` | `string[]` | Bot joins room |
| `_deckerror` | `string[]` | Deck loading error |
| `_duelstart` | `string[]` | Duel begins |
| `_newturn` | `string[]` | Bot's new turn |
| `_endturn` | `string[]` | Bot ends turn |
| `_directattack` | `string[]` | Bot attacks directly |
| `_attack` | `string[]` | Bot attacks a monster |
| `_ondirectattack` | `string[]` | Opponent attacks bot directly |
| `_activate` | `string[]` | Bot activates an effect |
| `_summon` | `string[]` | Bot summons a monster |
| `_setmonster` | `string[]` | Bot sets a monster |
| `_chaining` | `string[]` | Bot chains to an effect |
| `Chat` | `Action<int,string>` | The chat callback |
| `Rand` | `Random` | RNG for message selection |

### Custom Messages

The `default.json` dialog file supports a `"custom"` array. Access via `SendCustomChat(int index, params object[] args)` (reflection needed in plugin mode).

### Silencing Default Dialogs

To prevent spam, set all auto-triggered arrays to `new string[0]` via reflection in the constructor. See executor-template.md for the implementation.

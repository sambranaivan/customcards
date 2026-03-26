# Executor Template

## Minimal Executor

```csharp
using System;
using System.Collections.Generic;
using System.Linq;
using YGOSharp.OCGWrapper.Enums;
using WindBot;
using WindBot.Game;
using WindBot.Game.AI;

namespace WindBot.Game.AI.Decks
{
    [Deck("DeckName", "AI_DeckFileName", "Normal")]
    public class DeckNameExecutor : DefaultExecutor
    {
        public class CardId
        {
            // Map every card in the YDK to a const with its passcode
            public const int ExampleCard = 12345678;
        }

        private bool _normalSummonUsed = false;

        public DeckNameExecutor(GameAI ai, Duel duel)
            : base(ai, duel)
        {
            // Hand traps / counters
            // AddExecutor(ExecutorType.Activate, CardId.HandTrap, HandTrapCondition);

            // Removal
            // AddExecutor(ExecutorType.Activate, CardId.Raigeki, DefaultRaigeki);

            // Key setup
            // AddExecutor(ExecutorType.Activate, CardId.FieldSpell, FieldSpellActivate);

            // Summons
            // AddExecutor(ExecutorType.Summon, CardId.Starter, StarterSummon);
            // AddExecutor(ExecutorType.Activate, CardId.Starter, StarterEffect);

            // Extra Deck
            // AddExecutor(ExecutorType.SpSummon, CardId.BossXyz, BossXyzSummon);
            // AddExecutor(ExecutorType.Activate, CardId.BossXyz, BossXyzEffect);

            // Set traps
            AddExecutor(ExecutorType.SpellSet, DefaultSpellSet);

            // Repos (always last)
            AddExecutor(ExecutorType.Repos, DefaultMonsterRepos);
        }

        public override bool OnSelectHand()
        {
            return true; // go first
        }

        public override void OnNewTurn()
        {
            _normalSummonUsed = false;
        }
    }
}
```

## ExecutorType Values

| Type | When AI evaluates it |
|------|---------------------|
| `Summon` | Normal Summon a monster |
| `SpSummon` | Special Summon (Link, Synchro, Xyz, Fusion, inherent) |
| `Repos` | Change battle position |
| `MonsterSet` | Set a monster face-down |
| `SpellSet` | Set a spell/trap |
| `Activate` | Activate a card effect |
| `SummonOrSet` | Normal Summon or Set (AI decides) |
| `GoToBattlePhase` | Enter Battle Phase |
| `GoToMainPhase2` | Enter Main Phase 2 |
| `GoToEndPhase` | End turn |

## AddExecutor Signatures

```csharp
// Always activate (no condition)
AddExecutor(ExecutorType.Activate, CardId.Card);

// Activate with custom condition
AddExecutor(ExecutorType.Activate, CardId.Card, MyConditionMethod);

// Activate with built-in default condition
AddExecutor(ExecutorType.Activate, CardId.Card, DefaultRaigeki);

// No specific card (e.g., generic set/repos)
AddExecutor(ExecutorType.SpellSet, DefaultSpellSet);
AddExecutor(ExecutorType.Repos, DefaultMonsterRepos);
```

## Common Condition Patterns

### Check hand/field/grave for cards
```csharp
Bot.HasInHand(CardId.X)
Bot.HasInMonstersZone(CardId.X)
Bot.HasInSpellZone(CardId.X)
Bot.HasInGraveyard(CardId.X)
Bot.HasInExtra(CardId.X)
Bot.HasInBanished(CardId.X)
Bot.GetRemainingCount(CardId.X, originalCount)  // cards left in deck
```

### Count monsters/spells
```csharp
Bot.GetMonsterCount()
Bot.GetSpellCount()
Bot.GetSpellCountWithoutField()
Bot.GetHandCount()
Enemy.GetMonsterCount()
Enemy.GetSpellCount()
```

### Find enemy threats
```csharp
Util.GetProblematicEnemyCard()       // highest priority threat
Util.GetProblematicEnemyMonster()    // problematic monster
Util.GetProblematicEnemySpell()      // problematic spell/trap
Util.GetBestEnemyCard()              // strongest enemy card
Util.GetBestEnemyMonster()           // strongest enemy monster
```

### Game state checks
```csharp
Util.IsTurn1OrMain2()
Duel.Player           // 0 = bot's turn, 1 = opponent's turn
Duel.LastChainPlayer  // who activated last chain link
Duel.Phase            // current phase (DuelPhase enum)
Bot.LifePoints
Enemy.LifePoints
```

### Card properties (inside conditions, `Card` = current card being evaluated)
```csharp
Card.Location          // CardLocation enum
Card.IsCode(CardId.X)
Card.IsFacedown()
Card.IsFaceup()
Card.IsAttack()
Card.IsDefense()
Card.HasRace(CardRace.Fairy)
Card.HasAttribute(CardAttribute.Light)
Card.HasType(CardType.Synchro)
Card.IsTuner()
Card.Level
Card.Attack
Card.Defense
```

### AI Selection (tell the AI which cards to pick)
```csharp
AI.SelectCard(CardId.X);                    // select one specific card
AI.SelectCard(new[] { CardId.A, CardId.B }); // preference order
AI.SelectNextCard(target);                   // for multi-select prompts
AI.SelectMaterials(new[] { CardId.A });      // for summon materials
AI.SelectMaterials(CardLocation.Deck);       // materials from location
AI.SelectOption(0);                          // select option index
AI.SelectYesNo(true);                        // yes/no prompt
AI.SelectPlace(Zones.z0 + Zones.z1);        // select zones
```

### Matching cards in zones
```csharp
Bot.MonsterZone.GetMatchingCardsCount(card => card.Level == 4)
Bot.MonsterZone.IsExistingMatchingCard(card => card.IsTuner())
Bot.Graveyard.GetMatchingCardsCount(card => card.HasRace(CardRace.Fairy))
Bot.Hand.IsExistingMatchingCard(card => card.IsCode(CardId.X))
```

## Overridable Methods

```csharp
public override bool OnSelectHand()           // true=go first
public override void OnNewTurn()              // reset per-turn flags
public override CardPosition OnSelectPosition(int cardId, IList<CardPosition> positions)
public override BattlePhaseAction OnBattle(IList<ClientCard> attackers, IList<ClientCard> defenders)
public override bool OnPreBattleBetween(ClientCard attacker, ClientCard defender)
public override int OnSelectPlace(long cardId, int player, CardLocation location, int available)
```

## Default Helper Methods (from DefaultExecutor)

| Method | Use for |
|--------|---------|
| `DefaultRaigeki` | Destroy all enemy monsters |
| `DefaultDarkHole` | Destroy all monsters |
| `DefaultHarpiesFeatherDusterFirst` | Destroy all enemy spells/traps |
| `DefaultHammerShot` | Destroy highest ATK monster |
| `DefaultMysticalSpaceTyphoon` | Destroy a spell/trap |
| `DefaultCosmicCyclone` | Banish a spell/trap |
| `DefaultBookOfMoon` | Flip a monster face-down |
| `DefaultCompulsoryEvacuationDevice` | Bounce a monster to hand |
| `DefaultSolemnJudgment` | Negate anything (pay half LP) |
| `DefaultSolemnWarning` | Negate a summon |
| `DefaultSolemnStrike` | Negate effect or summon |
| `DefaultTorrentialTribute` | Destroy all when summon |
| `DefaultTrap` | Generic trap activation |
| `DefaultSpellSet` | Set spells/traps if room |
| `DefaultMonsterSummon` | Summon if stronger than tributes |
| `DefaultMonsterRepos` | Smart battle position change |
| `DefaultField` | Activate if no field spell |
| `DefaultPotOfDesires` | Draw if 15+ cards in deck |
| `DefaultMaxxC` | Activate during opponent's turn |
| `DefaultAshBlossomAndJoyousSpring` | Negate search/mill/SS from deck |
| `DefaultGhostOgreAndSnowRabbit` | Negate activated field card |
| `DefaultEffectVeiler` | Negate monster effect |
| `DefaultCalledByTheGrave` | Banish hand trap from GY |
| `DefaultInfiniteImpermanence` | Negate monster effect |
| `DefaultCallOfTheHaunted` | Revive monster |
| `DefaultScapegoat` | Tokens during opponent's turn |

# Executor Templates

## Plugin DLL Template (Mode A)

### .csproj

```xml
<?xml version="1.0" encoding="utf-8"?>
<Project ToolsVersion="4.0" DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <PropertyGroup>
    <Configuration Condition=" '$(Configuration)' == '' ">Release</Configuration>
    <Platform Condition=" '$(Platform)' == '' ">x86</Platform>
    <ProjectGuid>{GENERATE-NEW-GUID}</ProjectGuid>
    <OutputType>Library</OutputType>
    <RootNamespace>WindBot.Game.AI.Decks</RootNamespace>
    <AssemblyName>MyDeckExecutor</AssemblyName>
    <TargetFrameworkVersion>v4.0</TargetFrameworkVersion>
    <FileAlignment>512</FileAlignment>
    <LangVersion>5</LangVersion>
  </PropertyGroup>

  <PropertyGroup Condition=" '$(Configuration)|$(Platform)' == 'Release|x86' ">
    <Optimize>true</Optimize>
    <OutputPath>..\</OutputPath>
    <Prefer32Bit>false</Prefer32Bit>
    <DebugType>pdbonly</DebugType>
    <PlatformTarget>x86</PlatformTarget>
  </PropertyGroup>

  <ItemGroup>
    <Reference Include="System" />
    <Reference Include="System.Core" />
  </ItemGroup>

  <ItemGroup>
    <Reference Include="ExecutorBase">
      <HintPath>..\..\ExecutorBase.dll</HintPath>
      <Private>false</Private>
    </Reference>
    <Reference Include="WindBot">
      <HintPath>..\..\WindBot.exe</HintPath>
      <Private>false</Private>
    </Reference>
  </ItemGroup>

  <ItemGroup>
    <Compile Include="MyDeckExecutor.cs" />
  </ItemGroup>

  <Import Project="$(MSBuildToolsPath)\Microsoft.CSharp.targets" />
</Project>
```

Notes:
- `OutputPath` = `..\` so the DLL lands in `WindBot/Executors/` next to the folder
- `HintPath` references the prebuilt `ExecutorBase.dll` and `WindBot.exe` two levels up
- `Private` = `false` — don't copy these to output
- Generate a fresh GUID for each new executor project

### Executor .cs (Plugin)

```csharp
using System;
using System.Collections.Generic;
using System.Linq;
using YGOSharp.OCGWrapper.Enums;
using WindBot;
using WindBot.Game;
using WindBot.Game.AI;

/*
================================================================================
WindBot design reference — embedded from strategy guide.
Source: sets/my_archetype/bots/MyDeck.md
================================================================================
# My Deck — WindBot Guide
... paste strategy guide here ...
================================================================================
*/

namespace WindBot.Game.AI.Decks
{
    [Deck("MyDeck", "AI_MyDeck")]
    public class MyDeckExecutor : DefaultExecutor
    {
        // ── Build tracking ──
        private const int BuildVersion = 1;
        private const string BuildTag = "2026-01-01-v1-initial";
        private static bool _buildTagLogged;

        // ── Card ID constants (verified from .cdb) ──
        public class CardId
        {
            public const int StarterMonster = 12345678;
            public const int ComboExtender = 23456789;
            // ... map every card in the YDK
        }

        // ── Card group sets (for reuse in conditions) ──
        private static readonly int[] KeyMonsters = { CardId.StarterMonster, CardId.ComboExtender };

        // ── Constructor ──
        public MyDeckExecutor(GameAI ai, Duel duel)
            : base(ai, duel)
        {
            if (!_buildTagLogged)
            {
                _buildTagLogged = true;
                try { Logger.WriteLine("[MyDeckExecutor] v" + BuildVersion + " build=" + BuildTag); }
                catch { }
            }

            SilenceDefaultDialogs(ai);

            // 1. Counter traps / hand traps (reactive, highest priority)
            // AddExecutor(ExecutorType.Activate, CardId.CounterTrap, ActivateCounterTrap);

            // 2. Protection quick-plays
            // AddExecutor(ExecutorType.Activate, CardId.ProtectionQP, ActivateProtection);

            // 3. Removal
            // AddExecutor(ExecutorType.Activate, CardId.Raigeki, DefaultRaigeki);

            // 4. Key setup
            // AddExecutor(ExecutorType.Activate, CardId.FieldSpell, DefaultField);

            // 5. Combo starters
            // AddExecutor(ExecutorType.Summon, CardId.StarterMonster, SummonStarter);
            // AddExecutor(ExecutorType.Activate, CardId.StarterMonster, ResolveStarterEffect);

            // 6. Extenders
            // AddExecutor(ExecutorType.SpSummon, CardId.ComboExtender, SpSummonExtender);
            // AddExecutor(ExecutorType.Activate, CardId.ComboExtender, ResolveExtenderEffect);

            // 7. Normal Summons (prioritized)
            // foreach (var id in Lv4Monsters)
            //     AddExecutor(ExecutorType.Summon, id, PrioritizedNormalSummon);

            // 8. Set traps
            AddExecutor(ExecutorType.SpellSet, DefaultSpellSet);

            // 9. Repos (always last)
            AddExecutor(ExecutorType.Repos, DefaultMonsterRepos);
        }

        // ── Overrides ──

        public override bool OnSelectHand()
        {
            return true; // go first
        }

        // ── Dialog Control ──

        private static void SilenceDefaultDialogs(GameAI ai)
        {
            try
            {
                var dialogsField = ai.GetType().GetField("_dialogs",
                    System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
                if (dialogsField == null) return;
                var dialogs = dialogsField.GetValue(ai);
                if (dialogs == null) return;

                var empty = new string[0];
                string[] fieldNames = new string[]
                {
                    "_welcome", "_deckerror", "_duelstart", "_newturn", "_endturn",
                    "_directattack", "_attack", "_ondirectattack",
                    "_activate", "_summon", "_setmonster", "_chaining"
                };
                var dtype = dialogs.GetType();
                foreach (var name in fieldNames)
                {
                    var f = dtype.GetField(name,
                        System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
                    if (f != null && f.FieldType == typeof(string[]))
                        f.SetValue(dialogs, empty);
                }
            }
            catch { }
        }

        private readonly HashSet<int> _chatSentThisTurn = new HashSet<int>();
        private int _chatLastTurnCount = -1;

        private void TrySendCustomChat(int index, params object[] args)
        {
            try
            {
                int turnCount = Duel.Turn;
                if (turnCount != _chatLastTurnCount)
                {
                    _chatSentThisTurn.Clear();
                    _chatLastTurnCount = turnCount;
                }
                if (_chatSentThisTurn.Contains(index)) return;
                if (AI == null) return;
                var method = AI.GetType().GetMethod("SendCustomChat");
                if (method == null) return;
                method.Invoke(AI, new object[] { index, args });
                _chatSentThisTurn.Add(index);
            }
            catch { }
        }

        // ── Chain Ownership Helpers ──

        private bool ChainIsEmpty()
        {
            return Duel.CurrentChain == null || Duel.CurrentChain.Count == 0;
        }

        private bool IsLastChainFromOpponent()
        {
            var activator = TryGetLastChainActivatorPlayer();
            if (activator.HasValue) return activator.Value != 0;
            return Duel.Player != 0;
        }

        private int? TryGetLastChainActivatorPlayer()
        {
            var link = TryGetLastChainLink();
            if (link == null) return null;
            var p = TryReadIntMember(link, "Player", "Controller", "Activator");
            if (p.HasValue) return p.Value;
            var card = TryReadObjMember(link, "Card", "Handler", "Source");
            return TryReadIntMember(card, "Controller", "Player", "Owner");
        }

        private object TryGetLastChainLink()
        {
            try
            {
                if (Duel == null || Duel.CurrentChain == null || Duel.CurrentChain.Count == 0)
                    return null;
                return Duel.CurrentChain[Duel.CurrentChain.Count - 1];
            }
            catch { return null; }
        }

        private static int? TryReadIntMember(object obj, params string[] names)
        {
            if (obj == null) return null;
            var t = obj.GetType();
            var flags = System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance;
            foreach (var n in names)
            {
                var prop = t.GetProperty(n, flags);
                if (prop != null) { try { return Convert.ToInt32(prop.GetValue(obj, null)); } catch { } }
                var field = t.GetField(n, flags);
                if (field != null) { try { return Convert.ToInt32(field.GetValue(obj)); } catch { } }
            }
            return null;
        }

        private static object TryReadObjMember(object obj, params string[] names)
        {
            if (obj == null) return null;
            var t = obj.GetType();
            var flags = System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance;
            foreach (var n in names)
            {
                var prop = t.GetProperty(n, flags);
                if (prop != null) { try { return prop.GetValue(obj, null); } catch { } }
                var field = t.GetField(n, flags);
                if (field != null) { try { return field.GetValue(obj); } catch { } }
            }
            return null;
        }

        // ── Attack Target (via reflection) ──

        private ClientCard TryGetAttackedMonster()
        {
            try
            {
                var prop = Duel.GetType().GetProperty("AttackTarget",
                    System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
                if (prop == null) return null;
                return prop.GetValue(Duel, null) as ClientCard;
            }
            catch { return null; }
        }

        // ── Condition helpers ──

        private bool IsMainPhase()
        {
            return Duel.Phase == DuelPhase.Main1 || Duel.Phase == DuelPhase.Main2;
        }
    }
}
```

---

## Monolithic Template (Mode B)

Same structure as Plugin but:
- File goes in `Game/AI/Decks/{Name}Executor.cs`
- No separate `.csproj` — register in `WindBot.csproj` instead:
  ```xml
  <Compile Include="Game\AI\Decks\{Name}Executor.cs" />
  ```
- `[Deck]` attribute has 3 params: `[Deck("DeckName", "AI_DeckFileName", "Normal")]`
- `SilenceDefaultDialogs` and reflection helpers may not be needed (full source access)

---

## Embedded Guide Pattern

Paste the full strategy guide as a comment block at the top of the `.cs` file:

```csharp
/*
================================================================================
WindBot design reference — embedded from strategy guide.
Source: path/to/guide.md
Maintenance: keep this comment in sync when strategy changes.
================================================================================
# Deck Name — WindBot Guide
...full markdown content...
================================================================================
*/
```

This ensures the AI behavior rationale lives alongside the code. When the guide changes, update both the comment and the affected methods.

---

## Normal Summon Priority Pattern

Instead of registering each monster in a fixed order:

```csharp
// BAD: fixed priority, can't adapt to hand state
AddExecutor(ExecutorType.Summon, CardId.MonsterA, SummonGeneric);
AddExecutor(ExecutorType.Summon, CardId.MonsterB, SummonGeneric);
```

Use a dynamic priority system:

```csharp
// GOOD: evaluates all candidates in hand
foreach (var id in Lv4Monsters)
    AddExecutor(ExecutorType.Summon, id, PrioritizedNormalSummon);

private int NormalSummonPriority(int id)
{
    if (id == CardId.ComboStarter) return 100;
    if (SaintsWithNSTrigger.Contains(id)) return 80;
    if (SaintsWithIgnitionEffect.Contains(id)) return 60;
    return 30; // vanilla body
}

private bool PrioritizedNormalSummon()
{
    if (!IsMainPhase()) return false;
    int myPriority = NormalSummonPriority(Card.Id);
    // Yield to higher-priority candidates still in hand
    foreach (var c in Bot.Hand)
    {
        if (c == null || c.Id == Card.Id) continue;
        if (!Lv4Monsters.Contains(c.Id)) continue;
        if (NormalSummonPriority(c.Id) > myPriority) return false;
    }
    return true; // add board-development conditions as needed
}
```

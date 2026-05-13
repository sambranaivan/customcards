---
name: windbot-executor-creator
description: Create WindBot AI deck executors for EDOPro/ProjectIgnis. Handles YDK deck files, C# executor scripts, csproj registration, bots.json config, and MSBuild compilation. Supports both monolithic (inside WindBot source) and plugin DLL (external .csproj) architectures. Use when the user wants to create, program, or edit a WindBot AI, deck executor, or mentions WindBot, AI opponent, bot deck, or EDOPro AI.
---

# WindBot Executor Creator for EDOPro

## Two Architecture Modes

This project supports **two** executor architectures. Detect which one applies before starting.

### Mode A: Plugin DLL (current project default)

The executor lives in its own folder with a standalone `.csproj` that compiles to a DLL loaded dynamically by `WindBot.exe`. Use when `WindBot/WindBot.exe` and `WindBot/ExecutorBase.dll` already exist as prebuilt binaries.

| Component | Path |
|-----------|------|
| Deck file | `WindBot/Decks/AI_{Name}.ydk` |
| Executor source | `WindBot/Executors/{Name}Executor/{Name}Executor.cs` |
| Project file | `WindBot/Executors/{Name}Executor/{Name}Executor.csproj` |
| Compiled DLL | `WindBot/Executors/{Name}Executor.dll` |
| Bot config | `WindBot/bots.json` |
| Dialog file | `WindBot/Dialogs/default.json` (shared, or custom per bot) |

### Mode B: Monolithic (inside WindBot source tree)

The executor is a `.cs` file compiled into `WindBot.exe` via the main solution. Use when you have the full WindBot source (`WindBot.sln`, `WindBot.csproj`, etc.).

| Component | Path |
|-----------|------|
| Deck file | `Decks/AI_{Name}.ydk` |
| Executor source | `Game/AI/Decks/{Name}Executor.cs` |
| Project registration | `WindBot.csproj` (add `<Compile>` entry) |
| Bot config | `bots.json` |

**Detection heuristic**: If `WindBot/ExecutorBase.dll` exists as a standalone file → Mode A. If `WindBot.sln` exists → Mode B.

---

## Workflow

### Step 1: Prepare the YDK

Place in `WindBot/Decks/AI_{Name}.ydk` (Mode A) or `Decks/AI_{Name}.ydk` (Mode B).

YDK structure: `#main`, `#extra`, `!side` sections with one passcode per line.

**CRITICAL**: Ask the user for a strategy guide or document. If one exists (e.g., a markdown file describing combos, priorities, and matchup plans), **embed it as a comment block** at the top of the executor `.cs` file. This is the single source of truth for AI behavior and keeps intent alongside code.

### Step 2: Verify Card IDs

**Never guess passcodes.** Verify using local `.cdb` files (SQLite):

```python
import sqlite3
conn = sqlite3.connect("expansions/saint-seiya.cdb")  # adjust path
# Single lookup
row = conn.execute("SELECT t.name, t.desc FROM texts t WHERE t.id = ?", (PASSCODE,)).fetchone()
# Batch verify entire YDK
with open("WindBot/Decks/AI_MyDeck.ydk") as f:
    ids = [int(l.strip()) for l in f if l.strip().isdigit()]
for cid in ids:
    row = conn.execute("SELECT name FROM texts WHERE id=?", (cid,)).fetchone()
    print(f"{cid} = {row[0] if row else '??? NOT FOUND'}")
```

CDB tables: `datas` (id, type, atk, def, level, race, attribute, setcode) + `texts` (id, name, desc, str1..str16). Multiple `.cdb` files may exist — check all.

For official cards, use YGOPRODeck API: `https://db.ygoprodeck.com/api/v7/cardinfo.php?id={passcode}`

### Step 3: Read Lua Scripts

Before writing any activation logic, **always read the Lua script** for that card (`script/unofficial/c{ID}.lua`). The Lua is the source of truth for:

- **Effect types**: trigger, ignition, quick, continuous
- **Event codes**: `EVENT_SUMMON_SUCCESS`, `EVENT_TO_GRAVE`, `EVENT_FREE_CHAIN`, etc.
- **Costs and targets**: what the card discards, pays, or targets
- **StringId values**: `Util.GetStringId(id, N)` values for `ActivateDescription` matching
- **Conditions and restrictions**: OPT limits, location requirements

### Step 4: Create the Executor

See [executor-template.md](executor-template.md) for full templates (Plugin and Monolithic).

**Key structure (Plugin mode):**

```csharp
namespace WindBot.Game.AI.Decks
{
    [Deck("DeckName", "AI_DeckFileName")]
    public class NameExecutor : DefaultExecutor
    {
        private const int BuildVersion = 1;
        private const string BuildTag = "YYYY-MM-DD-v1-initial";

        public class CardId { /* passcode constants */ }

        public NameExecutor(GameAI ai, Duel duel) : base(ai, duel)
        {
            SilenceDefaultDialogs(ai);
            // AddExecutor calls in PRIORITY ORDER
        }
    }
}
```

**AddExecutor priority order:**
1. Counter traps / hand traps (react to opponent)
2. Protection quick-plays (reactive)
3. Removal spells
4. Key setup (field spells, continuous, equips)
5. Main combo starters
6. Combo extenders / special summons
7. Extra Deck summons
8. Normal Summons (with priority method)
9. Set traps
10. Repos (always last)

### Step 5: Create csproj (Plugin mode only)

See [executor-template.md](executor-template.md) for the `.csproj` template. Key points:
- `TargetFrameworkVersion` = `v4.0`, `LangVersion` = `5`
- References `ExecutorBase.dll` and `WindBot.exe` via relative `HintPath`
- `OutputPath` = `..\` (outputs DLL next to the folder)

For Mode B: add `<Compile Include="Game\AI\Decks\{Name}Executor.cs" />` to `WindBot.csproj`.

### Step 6: Register in bots.json

```json
{
    "name": "Display Name",
    "deck": "DeckName",
    "difficulty": 2,
    "masterRules": [ 5 ]
}
```

- `"deck"` must match `[Deck]` attribute param 1
- `"difficulty"`: 0-3 (easy to hard)

### Step 7: Compile

**Plugin mode (Mode A):**
```powershell
C:\Windows\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe "WindBot\Executors\{Name}Executor\{Name}Executor.csproj" /t:Build /p:Configuration=Release /v:minimal
```

**Monolithic mode (Mode B):**
```powershell
& $msbuild WindBot.sln /p:Configuration=Release /p:Platform=x86 /v:minimal /t:WindBot /t:ExecutorBase
```

If the DLL is locked by a running `WindBot.exe`, kill it first:
```powershell
tasklist /FI "IMAGENAME eq WindBot.exe"
taskkill /F /IM WindBot.exe
```

### Step 8: Build Versioning

Every significant change increments `BuildVersion` and updates `BuildTag`:
```csharp
private const int BuildVersion = 2;
private const string BuildTag = "2026-05-12-v2-fix-activation-timing";
```

Log on first load:
```csharp
if (!_buildTagLogged) {
    _buildTagLogged = true;
    try { Logger.WriteLine("[NameExecutor] v" + BuildVersion + " build=" + BuildTag); } catch { }
}
```

---

## Critical Design Patterns

### Reactive Cards: Always Check Chain Ownership

When a card reacts to chains (counter traps, protection quick-plays), **always verify the chain comes from the opponent**, not from your own effects:

```csharp
private bool IsLastChainFromOpponent()
{
    var activator = TryGetLastChainActivatorPlayer();
    if (activator.HasValue) return activator.Value != 0;
    return Duel.Player != 0; // fallback
}
```

Without this, cards like protection spells will "burn" when the bot's own equip spells target its monsters.

### Normal Summon Priority

Don't register each monster separately in a fixed order. Use a **single prioritized handler** that dynamically evaluates which monster in hand is the best Normal Summon:

```csharp
foreach (var id in Lv4Monsters)
    AddExecutor(ExecutorType.Summon, id, PrioritizedNormalSummon);
```

Where `PrioritizedNormalSummon()` checks if `Card.Id` has the highest `NormalSummonPriority()` among all candidates in hand. Priority tiers: combo starters > NS/SS triggers > ignition effects > vanilla bodies.

### Dialog Control

WindBot sends automatic chat messages for every action (summon, activate, attack, etc.). For custom decks, **silence these** and use only targeted custom messages:

```csharp
private static void SilenceDefaultDialogs(GameAI ai) { /* see template */ }
private void TrySendCustomChat(int index, params object[] args) { /* with per-turn cooldown */ }
```

### Reflection for Missing API

The plugin `ExecutorBase.dll` may not expose all properties. Use reflection as a workaround:

```csharp
// Chain link activator player
var link = Duel.CurrentChain[Duel.CurrentChain.Count - 1];
var player = link.GetType().GetProperty("Player")?.GetValue(link, null);

// Attack target
var prop = Duel.GetType().GetProperty("AttackTarget");
var target = prop?.GetValue(Duel, null) as ClientCard;
```

See [api-reference.md](api-reference.md) for the full reflection helpers catalog.

---

## Compilation Constraints

- **Framework**: .NET Framework 4.0
- **Language**: C# 5 — NO expression-bodied members, NO local functions, NO `Array.Empty<T>()`, NO string interpolation `$""`
- **Platform**: x86
- Use `new string[0]` instead of `Array.Empty<string>()`
- Use `string.Format()` instead of `$""`
- Local lambdas inside methods must be refactored to private methods

---

## Additional Resources

- [executor-template.md](executor-template.md) — Full code templates (Plugin + Monolithic)
- [api-reference.md](api-reference.md) — Complete API, enums, reflection helpers
- [common-pitfalls.md](common-pitfalls.md) — Anti-patterns and proven fixes

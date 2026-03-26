---
name: windbot-executor-creator
description: Create WindBot AI deck executors for EDOPro/ProjectIgnis. Handles YDK deck files, C# executor scripts, card ID verification, csproj registration, bots.json config, and MSBuild compilation. Use when the user wants to create, program, or edit a WindBot AI, deck executor, or mentions WindBot, AI opponent, bot deck, or EDOPro AI.
---

# WindBot Executor Creator for EDOPro

## Overview

A WindBot AI executor requires 3 files + 2 registrations:

| Component | Path | Format |
|-----------|------|--------|
| Deck file | `Decks/AI_{Name}.ydk` | YDK (passcodes) |
| Executor | `Game/AI/Decks/{Name}Executor.cs` | C# |
| Project registration | `WindBot.csproj` | XML `<Compile>` entry |
| Bot config | `bots.json` | JSON entry |
| Compiled output | `bin/Release/WindBot.exe` | MSBuild |

## Workflow

### Step 1: Prepare the YDK Deck File

Place in `Decks/AI_{Name}.ydk`. Each line after `#main` is a card passcode (integer). Structure:

```
#created by ...
#main
12580477
18144507
...
#extra
63101468
...
!side
```

**Strategy comments**: Encourage the user to add strategy comments (lines starting with `#`) at the top of the YDK. These are critical for writing good AI logic.

### Step 2: Verify Card IDs

**CRITICAL**: Never guess card passcodes. Always verify using one of:

1. **Local `.cdb` files** (preferred for custom cards):
   Any `.cdb` file in the project is a SQLite database with two tables:

   **Lookup card name by passcode:**
   ```python
   import sqlite3
   conn = sqlite3.connect("cards.cdb")
   row = conn.execute("SELECT t.name, t.desc, d.type, d.atk, d.def, d.level, d.race, d.attribute FROM texts t JOIN datas d ON t.id = d.id WHERE t.id = ?", (PASSCODE,)).fetchone()
   ```

   **Search card by name:**
   ```python
   rows = conn.execute("SELECT t.id, t.name FROM texts t WHERE t.name LIKE ?", ('%CardName%',)).fetchall()
   ```

   **Batch-verify all YDK passcodes at once:**
   ```python
   import sqlite3
   conn = sqlite3.connect("cards.cdb")
   with open("Decks/AI_MyDeck.ydk") as f:
       ids = [int(l.strip()) for l in f if l.strip().isdigit()]
   for cid in ids:
       row = conn.execute("SELECT name FROM texts WHERE id=?", (cid,)).fetchone()
       print(f"{cid} = {row[0] if row else '??? NOT FOUND'}")
   ```

   **CDB Schema:**
   - `datas`: `id`, `ot`, `alias`, `setcode`, `type`, `atk`, `def`, `level`, `race`, `attribute`, `category`
   - `texts`: `id`, `name`, `desc`, `str1`..`str16`
   - `id` is the card passcode, same as in the YDK file
   - Multiple `.cdb` files may exist (official + custom expansions). Check all if a card is not found.

2. **YGOPRODeck API** (for official cards only):
   ```
   https://db.ygoprodeck.com/api/v7/cardinfo.php?id={passcode}
   ```
   Returns JSON with `name`, `type`, `race`, `atk`, `def`, `level`, `attribute`.
   Rate limit: 20 req/s. Use the batch script above for large decks instead.

3. **MongoDB MCP** (if configured):
   Use the mongodb MCP tool to query the card database.

Map every passcode from the YDK to its correct card name before writing the executor. A single wrong ID mapping will cause the AI to malfunction silently.

### Step 3: Create the Executor

Create `Game/AI/Decks/{Name}Executor.cs`. See [executor-template.md](executor-template.md) for the base template.

**Key structure:**

```csharp
[Deck("DeckName", "AI_DeckFileName", "Normal")]
public class NameExecutor : DefaultExecutor
{
    public class CardId { /* passcode constants */ }

    public NameExecutor(GameAI ai, Duel duel) : base(ai, duel)
    {
        // AddExecutor calls in PRIORITY ORDER (top = evaluated first)
    }
}
```

**Rules:**
- `[Deck]` param 1 = logical name (used in bots.json `"deck"` field)
- `[Deck]` param 2 = YDK filename without `.ydk` extension
- `[Deck]` param 3 = difficulty: `"Easy"` or `"Normal"`
- `AddExecutor` order = priority. AI evaluates top-to-bottom, executes first `true`.
- Constructor takes `(GameAI ai, Duel duel)`, always call `: base(ai, duel)`

**Recommended AddExecutor priority order:**
1. Hand traps / counter traps (react to opponent)
2. Removal spells (clear threats)
3. Key setup (field spells, continuous spells)
4. Main combo starters (normal summons)
5. Combo extenders (special summons, searches)
6. Extra Deck summons (Link, Synchro, Xyz, Fusion)
7. Floodgates / lock pieces
8. Boss monsters
9. Draw / recovery spells
10. Fallback summons
11. Set traps
12. Repos (always last)

### Step 4: Register in WindBot.csproj

Add a `<Compile>` entry in the `<ItemGroup>` alongside other executors:

```xml
<Compile Include="Game\AI\Decks\{Name}Executor.cs" />
```

**Important**: This project uses old-style `.csproj` — files are NOT auto-included.

### Step 5: Register in bots.json

Add an entry to the JSON array:

```json
{
    "name": "Display Name",
    "deck": "DeckName",
    "difficulty": 2,
    "masterRules": [ 5 ]
}
```

- `"deck"` must match `[Deck]` param 1 exactly
- `"difficulty"`: 0=easy, 1=below average, 2=average, 3=hard
- `"masterRules"`: array of supported rule sets (3, 4, 5, 7)

### Step 6: Compile

```powershell
$msbuild = "C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\MSBuild\Current\Bin\MSBuild.exe"
& $msbuild WindBot.sln /p:Configuration=Release /p:Platform=x86 /v:minimal /t:WindBot /t:ExecutorBase
```

- Build targets `WindBot` and `ExecutorBase` only (excludes `libWindbot` which needs Xamarin)
- Output: `bin\Release\WindBot.exe` + `bin\Release\ExecutorBase.dll`
- If MSBuild path differs, find it with:
  ```powershell
  Get-ChildItem "${env:ProgramFiles(x86)}\Microsoft Visual Studio" -Recurse -Filter "MSBuild.exe" -ErrorAction SilentlyContinue | Select-Object -First 2 -ExpandProperty FullName
  ```

### Step 7: Deploy to EDOPro

Copy `bin\Release\*` to the `WindBot\` folder inside the ProjectIgnis installation, replacing existing files.

## Available API Reference

See [api-reference.md](api-reference.md) for the full list of:
- `ExecutorType` enum values
- `DefaultExecutor` helper methods (e.g., `DefaultRaigeki`, `DefaultSpellSet`)
- `Bot` / `Enemy` (`ClientField`) query methods
- `Util` (`AIUtil`) utility methods
- `AI` (`GameAI`) selection methods

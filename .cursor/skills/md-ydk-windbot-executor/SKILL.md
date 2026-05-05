---
name: md-ydk-windbot-executor
description: Creates a WindBot executor from a strategy/logic Markdown file plus a .ydk decklist. Use when the user says to convert a “bots md” to a WindBot executor, mentions “executor”, “WindBot”, “logic md”, “.ydk”, or asks to create an AI executor for a specific deck.
disable-model-invocation: true
---

# MD+YDK → WindBot Executor (ProjectIgnis)

This skill converts:
- a **logic guide** in Markdown (priority tree, conditions, target selections), and
- a **decklist** in `.ydk` (passcodes)

into a working WindBot deck entry:
- `WindBot/Decks/AI_<DeckKey>.ydk`
- `WindBot/bots.json` entry
- an **external executor plugin** compiled to `WindBot/Executors/<DeckKey>Executor.dll`

## Assumptions (ProjectIgnis)
- The repo includes a runnable `WindBot/WindBot.exe` (binary).
- The binary can load external executors from `WindBot/Executors/*.dll`.
- MSBuild available at `C:/Windows/Microsoft.NET/Framework/v4.0.30319/MSBuild.exe` (works with .NET 4.0 projects).

If any assumption fails, follow **Troubleshooting**.

## Inputs (must be provided by user)
- **Logic MD** path, e.g. `sets/<set>/bots/<name>.md`
- **Deck YDK** path, e.g. `deck/<name>.ydk`

## Output naming
Pick a stable deck key:
- **DeckKey**: `SaintSeiyaBronzeOnly` (PascalCase, no spaces)
- **AI deck file**: `AI_<DeckKey>.ydk`
- **[Deck] attribute name**: `<DeckKey>` (must match `bots.json` `"deck"`)

## Workflow

### 1) Read + extract “decision contracts” from MD
From the MD, extract:
- **Macro plan**: go-first vs go-second
- **Live checks**: e.g. “distinct names on field”, “has equipped monster”, etc.
- **Priority order** for:
  - starters
  - extenders
  - protection
  - set/hold rules
  - negation policies (counter traps)
- **Selection policies**: what to search/equip/target, and in what order.

Write these down as a short list of rules you will implement directly as conditions in the executor.

### 2) Read YDK and map all passcodes
Parse `.ydk`:
- Everything under `#main` / `#extra` and before `!side` are passcodes.
- Create `CardId` constants for **every unique** passcode that will be referenced by logic.

Never guess passcodes. If the `.ydk` already contains the custom IDs, treat them as authoritative.

### 3) Create WindBot AI deck file
Create `WindBot/Decks/AI_<DeckKey>.ydk` by copying the user’s decklist as-is.

### 4) Register the bot in `WindBot/bots.json`
Append an entry:

```json
{
  "name": "<Display Name>",
  "deck": "<DeckKey>",
  "difficulty": 2,
  "masterRules": [ 5 ]
}
```

Rules:
- `"deck"` **must exactly match** the `[Deck("<DeckKey>", ...)]` name.
- Choose `masterRules` based on the user’s environment (default: `[5]`).

### 5) Implement executor as external plugin (default path)
Create:
- `WindBot/Executors/<DeckKey>Executor/<DeckKey>Executor.csproj`
- `WindBot/Executors/<DeckKey>Executor/<DeckKey>Executor.cs`

Constraints for maximum compatibility:
- `ToolsVersion="4.0"`
- `TargetFrameworkVersion v4.0`
- `LangVersion 5`
- Reference:
  - `WindBot/WindBot.exe`
  - `WindBot/ExecutorBase.dll`

Executor skeleton requirements:
- Namespace: `WindBot.Game.AI.Decks`
- Class: `<DeckKey>Executor : DefaultExecutor`
- Attribute: `[Deck("<DeckKey>", "AI_<DeckKey>", "Normal")]`
- AddExecutor ordering:
  1. reactive counters
  2. protection/setup
  3. starters/searches
  4. extenders
  5. set policy
  6. repos (last)

Important: in older WindBot binaries, some helpers (e.g. `Duel.IsChainNegatable()`) may not exist.
Prefer conservative checks and rely on the engine’s “can activate” gating.

### 6) Compile the plugin
Build with framework MSBuild:

```powershell
& "C:\Windows\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe" `
  "C:\ProjectIgnis\WindBot\Executors\<DeckKey>Executor\<DeckKey>Executor.csproj" `
  /p:Configuration=Release /p:Platform=x86 /v:minimal
```

Expected outputs:
- `WindBot/Executors/<DeckKey>Executor.dll`
- `WindBot/Executors/<DeckKey>Executor.pdb` (optional)

### 7) Verify in logs (required)
Restart the client / WindBot session and confirm:
- Log shows the deck key printed (often as the selected deck)
- `Decks initialized, N found.` increased by **+1**
- No “Deck not found, loading random”

If it still says “Deck not found”:
- the plugin didn’t load OR `[Deck]` name doesn’t match OR the `.ydk` filename key doesn’t match.

## Troubleshooting

### A) “Deck not found, loading random”
Check all three must-match fields:
- `bots.json` → `"deck": "<DeckKey>"`
- Executor attribute → `[Deck("<DeckKey>", "AI_<DeckKey>", ...)]`
- File name → `WindBot/Decks/AI_<DeckKey>.ydk`

Then restart and verify `N found` increased by 1.

### B) Plugin compiles but `N found` does not increase
Likely the binary doesn’t load external executors, or it loads from a different folder.
Next step:
- integrate the executor into WindBot source (requires WindBot source + modern toolchain), then rebuild `WindBot.exe`.

### C) Build errors about `/langversion` or ToolsVersion
Fix csproj to:
- `ToolsVersion="4.0"`
- `<LangVersion>5</LangVersion>`
- `<TargetFrameworkVersion>v4.0</TargetFrameworkVersion>`

### D) Missing API members (compile errors like `Duel.IsChainNegatable`)
Remove those calls and use simpler guards:
- `return Duel.Player != 0;` for “opponent turn only” activations
- keep the card-specific legality to the engine

## Deliverables checklist (what “done” means)
- [ ] `WindBot/Decks/AI_<DeckKey>.ydk` created
- [ ] `WindBot/bots.json` updated with `"deck": "<DeckKey>"`
- [ ] executor plugin compiled to `WindBot/Executors/<DeckKey>Executor.dll`
- [ ] restart verification: `Decks initialized, N found` increased by +1
- [ ] no “Deck not found” in log for this deck


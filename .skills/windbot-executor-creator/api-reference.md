# WindBot API Quick Reference

## Project Structure

```
windbot/
├── WindBot.sln                    # Solution (build this)
├── WindBot.csproj                 # Main project (exe)
├── ExecutorBase/                  # Shared library (dll)
│   └── Game/AI/
│       ├── Executor.cs            # Abstract base class
│       ├── DefaultExecutor.cs     # Default helpers
│       ├── AIUtil.cs              # Utility methods (Util.*)
│       ├── GameAI.cs              # AI selection methods (AI.*)
│       ├── CardExecutor.cs        # Executor entry (type, id, func)
│       ├── ExecutorType.cs        # Enum: Summon, Activate, etc.
│       ├── DeckAttribute.cs       # [Deck] attribute
│       └── Enums/                 # Card enums (dangerous, floodgate, etc.)
├── Game/
│   ├── AI/Decks/                  # All executor .cs files go here
│   ├── DecksManager.cs            # Auto-discovers [Deck] classes
│   ├── GameBehavior.cs            # Wires AI to game client
│   └── GameClient.cs              # Network client
├── Decks/                         # .ydk deck files
├── Dialogs/                       # .json dialog files
├── bots.json                      # Bot roster for EDOPro
└── Program.cs                     # Entry point
```

## Card Enums (YGOSharp.OCGWrapper.Enums)

### CardAttribute
`Earth`, `Water`, `Fire`, `Wind`, `Light`, `Dark`, `Divine`

### CardRace
`Warrior`, `Spellcaster`, `Fairy`, `Fiend`, `Zombie`, `Machine`,
`Aqua`, `Pyro`, `Rock`, `WingedBeast`, `Plant`, `Insect`,
`Thunder`, `Dragon`, `Beast`, `BeastWarrior`, `Dinosaur`, `Fish`,
`SeaSerpent`, `Reptile`, `Psychic`, `Divine`, `CreatorGod`,
`Wyrm`, `Cyberse`

### CardType (flags, can combine)
`Monster`, `Spell`, `Trap`, `Normal`, `Effect`, `Fusion`, `Ritual`,
`Synchro`, `Xyz`, `Pendulum`, `Link`, `Token`,
`QuickPlay`, `Continuous`, `Equip`, `Field`, `Counter`,
`Flip`, `Toon`, `Spirit`, `Union`, `Gemini`, `Tuner`

### CardLocation (flags)
`Deck`, `Hand`, `MonsterZone`, `SpellZone`, `Grave`, `Removed`,
`Extra`, `Overlay`, `Onfield`, `Faceup`, `Facedown`

### CardPosition
`FaceUpAttack`, `FaceDownAttack`, `FaceUpDefence`, `FaceDownDefence`

## ClientField Properties (Bot / Enemy)

```csharp
Bot.MonsterZone     // ClientCard[7] - monster zones (0-4 main, 5-6 extra)
Bot.SpellZone       // ClientCard[8] - spell/trap zones (0-4 main, 5 field, 6-7 pendulum)
Bot.Hand            // CardGroup
Bot.Graveyard       // CardGroup
Bot.Banished        // CardGroup
Bot.Deck            // CardGroup
Bot.ExtraDeck       // CardGroup
Bot.LifePoints      // int
Bot.BattlingMonster // ClientCard (during battle)
```

## Card ID Verification

Always verify passcodes before writing an executor. Two methods:

### Method 1: Local CDB (preferred, works for custom cards)

Any `.cdb` in the project root is a SQLite database:

```python
import sqlite3
conn = sqlite3.connect("cards.cdb")

# Single card lookup
row = conn.execute("""
    SELECT t.name, t.desc, d.type, d.atk, d.def, d.level, d.race, d.attribute
    FROM texts t JOIN datas d ON t.id = d.id
    WHERE t.id = ?
""", (PASSCODE,)).fetchone()

# Batch verify entire YDK
with open("Decks/AI_MyDeck.ydk") as f:
    ids = [int(l.strip()) for l in f if l.strip().isdigit()]
for cid in ids:
    row = conn.execute("SELECT name FROM texts WHERE id=?", (cid,)).fetchone()
    print(f"{cid} = {row[0] if row else '??? NOT FOUND'}")
```

**CDB Tables:**
- `datas`: `id` (PK), `ot`, `alias`, `setcode`, `type`, `atk`, `def`, `level`, `race`, `attribute`, `category`
- `texts`: `id` (PK), `name`, `desc`, `str1`..`str16` (str1-16 are effect descriptions for prompts)

If a card is not found in one `.cdb`, check other `.cdb` files in the project (custom expansions).

### Method 2: YGOPRODeck API (official cards only)

```
GET https://db.ygoprodeck.com/api/v7/cardinfo.php?id={passcode}
```

Response includes: `id`, `name`, `type`, `race`, `atk`, `def`, `level`, `attribute`, `archetype`.
Rate limit: 20 requests/second. Use the CDB batch script for large decks instead.

## Compilation Notes

- **Framework**: .NET Framework 4.0, C# 6, Platform x86
- **ExecutorBase** uses `AnyCPU` platform; the solution maps `x86 → AnyCPU` for it
- **Do NOT build the full .sln** if Xamarin is not installed — `libWindbot` will fail
- Use `/t:WindBot /t:ExecutorBase` targets to skip libWindbot
- Pre-existing warnings in other executors are normal and can be ignored

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Project Is

A custom Yu-Gi-Oh! card set manager for **EDOPro (ProjectIgnis)**. It creates unofficial card sets (Dragon Ball, Pokémon, Saint Seiya) with full game effect implementations, card rendering, and WindBot AI executor support.

## Key Commands

### Insert / update cards into the database (Python)
```bash
# Single card (run from inside the set's subdirectory)
python 001_kid_goku_insert_card.py

# All cards in a set (ordered)
for f in $(ls *_insert_card.py | sort); do python "$f"; done
```

### Card image generation
```bash
# Render a single card
python sets/generate_cardmaker_from_sets_sqlite.py --card-id 922100000

# Re-render all cards
python sets/generate_cardmaker_from_sets_sqlite.py --regenerate

# Generate Instagram-ready image
python sets/generate_instagram_from_sets_sqlite.py --card-id 922100000
```

### Database inspection
```bash
python sets/inspect_cdb.py
```

### SQL — find next available unofficial ID
```sql
SELECT MAX(id) FROM datas WHERE id >= 100000000;
```

### Testing cards in-game
Restart EDOPro → Deck Editor → search by name/ID → Test Hand or LAN duel. Check EDOPro console for Lua errors.

## Architecture

### Three-layer design

```
Data Layer          Logic Layer             Presentation Layer
-----------         -----------             ------------------
expansions/         script/unofficial/      pics/{ID}.jpg
  cards-unofficial    c{ID}.lua               (card artwork)
  .cdb (SQLite)     script/archetype_       sets/cardmaker_output/
sets/sets.sqlite3     setcode_constants.lua   (rendered cards)
```

**Data Layer** — two SQLite files:
- `expansions/cards-unofficial.cdb`: the game-facing database with tables `datas` (numeric stats + bitmasks) and `texts` (name, effect description, prompt strings `str1..str16`)
- `sets/sets.sqlite3`: richer metadata tracking (schema at `sets/schema.sql`) with `cards` and `erratas` tables for errata history and Lua SHA256 tracking

**Logic Layer** — one Lua file per card:
- `script/unofficial/c{ID}.lua` — implements card effects using the ProjectIgnis/EDOPro API
- `script/archetype_setcode_constants.lua` — registry of all custom archetype setcodes
- `script/cards_specific_functions.lua` — shared utility functions
- `script/proc_*.lua` — summon procedure helpers (fusion, synchro, xyz, ritual, pendulum, link)

**Presentation Layer** — Python generators:
- `sets/generate_cardmaker_from_sets_sqlite.py` — calls CardMaker tool to render card images from `sets.sqlite3`
- `sets/generate_instagram_from_sets_sqlite.py` — blends artwork into social-ready images
- `sets/generate_openai_images_from_db.py` — generates AI artwork via OpenAI API

### Set-specific modules

Each card set lives under `sets/{set_name}/`:
- `insert_seed_cards.py` — initializes the set
- `{N}_{card_name}_insert_card.py` — one idempotent insert script per card (uses `INSERT OR REPLACE`)
- `*.md` — archetype design docs and card effect definitions (PSCT format)

WindBot AI executor source is under `repositories/windbot/` (git submodule). Compilation instructions: `docs/windbot-saint-seiya-bronze-only.md`.

## Custom Card Workflow

See `.agents/skills/projectignis-custom-card/SKILL.md` for the full step-by-step process. Summary:

1. **Check `placeholders.md`** — reuse existing placeholder IDs when a card was pre-registered.
2. **Pick ID** — unofficial cards use IDs `>= 100000000`. Query `MAX(id)` to find next free.
3. **Insert DB rows** — `datas` (stats/bitmasks) + `texts` (name + desc).
4. **Write Lua script** — `script/unofficial/c{ID}.lua`, starting with `local s,id=GetID()`.
5. **Add archetype setcode** — if custom archetype, append to `archetype_setcode_constants.lua` under `--Custom archetypes`; store decimal value in `datas.setcode`.
6. **Create placeholders** — for any named card referenced in effects that doesn't exist yet.

## DB Bitmask Reference (quick lookup)

Full reference: `.agents/skills/projectignis-custom-card/reference.md`

**type** (sum values):
- Normal Monster: `17` (1+16) | Effect Monster: `33` (1+32) | Fusion Effect: `97` (1+32+64)
- Quick-Play Spell: `65538` (2+65536) | Continuous Trap: `131076` (4+131072)
- Link Effect: `67108897` (1+32+67108864)

**attribute**: EARTH=1, WATER=2, FIRE=4, WIND=8, LIGHT=16, DARK=32, DIVINE=64

**race** (common): Warrior=1, Spellcaster=2, Fairy=4, Fiend=8, Machine=32, Dragon=8192

**Pendulum level encoding**: `level + (scale_left << 24) + (scale_right << 16)`

**ot field**: 1=OCG, 2=TCG, 3=OCG+TCG, 4=Custom

## Lua Script Skeleton

```lua
--Card Name
local s,id=GetID()
function s.initial_effect(c)
  -- register effects here
end
```

Use `str1..str16` in `texts` only when Lua uses `aux.Stringid(id, n)` for in-game prompt strings. Escape single quotes in SQL by doubling: `This card''s effect`.

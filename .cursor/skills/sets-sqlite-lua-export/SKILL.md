---
name: sets-sqlite-lua-export
description: Exports ProjectIgnis custom card Lua scripts from sets/sets.sqlite3 in one run, writing each script file under script/unofficial/ and prepending card stats, effect text, archetypes, and setcodes as Lua comments. Use when the user asks to read sets/sets.sqlite3, generate c<ID>.lua files, export all cards at once, or start exporting from a specific card_id.
disable-model-invocation: true
---

# Sets SQLite → Lua Export (all at once)

## Goal

Generate `script/unofficial/c<ID>.lua` files from `sets/sets.sqlite3` **in a single run**, ensuring each `.lua` contains:

- A **metadata comment block** with: card stats, effect text, **archetypes**, and setcodes.
- A **valid Lua skeleton** (`local s,id=GetID()` + `s.initial_effect`) when `lua_text` is missing.

This repo already contains the exporter script: `tools/export_sets_lua_batch.py`.

## Source of truth

- **DB**: `sets/sets.sqlite3` table `cards`
- **Exporter**: `tools/export_sets_lua_batch.py`
- **Output**: `script/unofficial/` (or `lua_path` if present in DB)

## How to export

### Export everything (recommended)

```bash
python c:/ProjectIgnis/tools/export_sets_lua_batch.py --all
```

### Export everything starting from a specific `card_id`

```bash
python c:/ProjectIgnis/tools/export_sets_lua_batch.py --all --start-card-id 922100172
```

### Only create files that don’t exist yet

```bash
python c:/ProjectIgnis/tools/export_sets_lua_batch.py --all --only-missing
```

### Legacy (debug) mode: limit/offset

```bash
python c:/ProjectIgnis/tools/export_sets_lua_batch.py --limit 5 --offset 0
```

## Output format requirements (Lua)

Each output file must begin with a comment header like:

- Card name
- `--[==[` block containing:
  - **ID**
  - **Type/Subtype**
  - **Stats** (when Monster): Level/Rank/Link/PScale, Attribute, Race, ATK/DEF
  - **Archetypes** (from `archetypes_json`)
  - **Setcodes** (from `setcodes_json`)
  - **Effect (EN)** and/or **Efecto (ES)**
  - Closing `--]==]`

If the DB row has `lua_text`, export it (but still prepend the metadata block if it’s not already present).
If `lua_text` is empty, export a minimal skeleton that loads in EDOPro.

## Quick verification

After exporting, verify that:

- Files exist under `script/unofficial/` (or the `lua_path` specified by DB).
- The header includes **Archetypes** and (when present) **Setcodes**.
- The Lua body contains `local s,id=GetID()` and `function s.initial_effect(c)`.

## Common issues

- If PowerShell chaining fails, run commands one per line (don’t rely on `&&`).
- If `sqlite3.exe` is not installed, use the Python exporter (it uses the built-in `sqlite3` module).


---
name: yugioh-card-creator
description: Create custom Yu-Gi-Oh! cards for EDOPro/ProjectIgnis. Handles SQLite database entries, Lua effect scripts, archetype setcode management, placeholder tracking, and replicable Python insert scripts. Use when the user wants to create, edit, or manage custom Yu-Gi-Oh! cards, or mentions EDOPro, ProjectIgnis, card scripting, or .cdb files.
---

# Yu-Gi-Oh! Custom Card Creator for EDOPro

## Overview

Creating a custom card requires 3 components:

| Component | Path | Format |
|-----------|------|--------|
| Database entry | `expansions/cards-unofficial.cdb` | SQLite (`datas` + `texts` tables) |
| Effect script | `script/unofficial/c{ID}.lua` | Lua |
| Image (optional) | `pics/{ID}.jpg` | JPG |

## Workflow

### Step 0: Identify the Set & Check Placeholders

Each card set has its own placeholder file: `set_{name}_placeholders.md` (e.g., `set_goku_placeholders.md`).

1. **Identify which set** the card belongs to. Ask the user if unclear.
2. **Check the set's placeholder file.** If the card name matches an existing placeholder (`[ ]`):
   - Use the existing ID and script file
   - Edit the Lua script with real effects
   - Update the DB entry with final stats
   - Mark as `[x]` in the placeholder file
3. **Starting a new set?** Create `set_{name}_placeholders.md` with the standard header and table. Reserve an ID range to avoid collisions with other sets.

### Step 1: Determine the Next ID

Custom cards use IDs starting from `900000001`. Query the max:

```python
python -c "import sqlite3; c=sqlite3.connect('expansions/cards-unofficial.cdb').cursor(); c.execute('SELECT MAX(id) FROM datas WHERE id>=900000000'); print(c.fetchone())"
```

### Step 2: Calculate DB Values

Use the bitmask tables in [reference.md](reference.md) to compute:
- **type**: Sum of type flags (e.g., Monster+Effect+Fusion = 1+32+64 = 97)
- **race**: Monster race value (e.g., Warrior = 1, Dragon = 8192)
- **attribute**: EARTH=1, WATER=2, FIRE=4, WIND=8, LIGHT=16, DARK=32
- **setcode**: Archetype code. Multiple archetypes pack as 16-bit segments:
  ```python
  setcode = SET_A | (SET_B << 16) | (SET_C << 32)
  ```
- **ot**: Always `4` for custom cards

### Step 3: Create the Insert Script

Convention: `{NRO}_{card_name}_insert_card.py` (e.g., `001_kid_goku_insert_card.py`)

```python
import sqlite3
conn = sqlite3.connect('expansions/cards-unofficial.cdb')
c = conn.cursor()

# datas: id, ot, alias, setcode, type, atk, def, level, race, attribute, category
c.execute('INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)',
    (900000001, 4, 0, 0x1d0, 33, 2500, 2000, 4, 1, 16, 0))

# texts: id, name, desc, str1-str16 (19 values total)
c.execute('INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
    (900000001, 'Card Name', 'Effect description.',
     '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''))

conn.commit()
conn.close()
```

**Critical:** `texts` table has 19 columns (id, name, desc, str1-str16). Count carefully.

### Step 4: Create the Lua Script

File: `script/unofficial/c{ID}.lua`

```lua
--Card Name
local s,id=GetID()
function s.initial_effect(c)
    -- Register effects here
end
s.listed_names={ID1,ID2}     -- Referenced card IDs
s.listed_series={0x1d0}      -- Referenced archetypes
```

See [reference.md](reference.md) for effect types, codes, and patterns.
See [examples.md](examples.md) for complete card implementations.

### Step 5: Create Placeholders for Referenced Cards

If the card references other cards by name that don't exist yet:

1. Assign sequential IDs
2. Insert minimal DB entries with placeholder description
3. Create empty Lua scripts:
   ```lua
   --Placeholder Name
   local s,id=GetID()
   function s.initial_effect(c)
   end
   ```
4. Add rows to the set's placeholder file (`set_{name}_placeholders.md`)

### Step 6: Run the Insert Script

```
cd ProjectRoot; python {NRO}_{name}_insert_card.py
```

### Step 7: Update Tracking Files

- **`set_{name}_placeholders.md`**: Add new placeholders or mark completed ones `[x]`
- **`archetype_setcode_constants.lua`**: Add new `SET_NAME = 0xVALOR` if needed

## Archetype Management

Custom archetypes go in `script/archetype_setcode_constants.lua` under `--Custom archetypes`:

```lua
--Custom archetypes
SET_GOKU    = 0x1d0
SET_VEGETA  = 0x1d1
SET_VEGETTO = 0x1d2
SET_GOGETA  = 0x1d3
```

Find the last used hex value and increment. Use the hex value in the `setcode` DB column.

## Multi-Set Placeholder Management

Each set gets its own placeholder file to avoid collisions when working across sets.

### Naming Convention

```
set_{name}_placeholders.md
```

Examples: `set_goku_placeholders.md`, `set_frieza_placeholders.md`, `set_cell_placeholders.md`

### ID Range Allocation

Assign non-overlapping ID ranges per set to avoid collisions:

| Set | ID Range | Placeholder File |
|-----|----------|------------------|
| Goku | `900000001`–`900000199` | `set_goku_placeholders.md` |
| *(next set)* | `900000200`–`900000399` | `set_{name}_placeholders.md` |

When starting a new set, query the DB for the max used ID and reserve the next block of 200.

### Placeholder File Template

```markdown
# Set {Name} — Placeholders Pendientes

Registro de cartas placeholder del **Set {Name}** (IDs `NNNNNNNNN`–`NNNNNNNNN`).
Cuando vayas a crear una carta nueva de este set, **consulta esta lista primero**.

## Convenciones

- `[ ]` = Placeholder pendiente (script mínimo, sin efectos reales).
- `[x]` = Placeholder completado (ya se implementó la carta real con sus efectos).
- Al completar un placeholder, actualiza también su `_insert_card.py` correspondiente.

---

## Lista de Placeholders

| Estado | Nombre | ID | Script | Arquetipo | Creado por | Insert script |
|---|---|---|---|---|---|---|
```

### Workflow with Multiple Sets

1. **Before creating a card**: List `set_*_placeholders.md` files to find which set the card belongs to.
2. **Cross-set references**: If a card in Set A references a card from Set B, create the placeholder in Set B's file with an ID from Set B's range.
3. **Shared archetypes**: Multiple sets can share archetypes (e.g., `SET_SAIYAN` used by both Goku and Vegeta sets). These are managed centrally in `archetype_setcode_constants.lua`.

### Row Format

```markdown
| [ ] | Card Name | `900000005` | `script/unofficial/c900000005.lua` | Goku (`0x1d0`) | `002_insert.py` | `002_insert.py` |
```

- `[ ]` = pending placeholder
- `[x]` = completed (real card implemented)

## Quick Reference: Common Type Values

| Card | type value |
|------|------------|
| Normal Monster | 17 (1+16) |
| Effect Monster | 33 (1+32) |
| Fusion/Effect | 97 (1+32+64) |
| Ritual/Effect | 129 (1+128) |
| Synchro/Effect | 8225 (1+32+8192) |
| Xyz/Effect | 8388641 (1+32+8388608) |
| Link/Effect | 67108897 (1+32+67108864) |
| Normal Spell | 2 |
| Field Spell | 524290 (2+524288) |
| Equip Spell | 262146 (2+262144) |
| Quick-Play Spell | 65538 (2+65536) |
| Continuous Spell | 131074 (2+131072) |
| Normal Trap | 4 |
| Counter Trap | 524292 (4+524288) |
| Continuous Trap | 131076 (4+131072) |

## Additional Resources

- For complete bitmask tables, DB schema, and Lua API patterns: [reference.md](reference.md)
- For real card implementation examples: [examples.md](examples.md)

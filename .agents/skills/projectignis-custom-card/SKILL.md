---
name: projectignis-custom-card
description: Create, edit, rename, and manage custom Yu-Gi-Oh!/EDOPro cards in ProjectIgnis. Handles SQLite database entries, Lua effect scripts, archetype setcode management, equip spell patterns, card renaming across all files, placeholder tracking, batch integration from Lua templates, and DB syncing. Use when the user asks to create/add/edit/rename a custom card, insert into .cdb files, write c{ID}.lua scripts, manage archetypes/setcodes, modify equip restrictions, add "treated as" clauses, or do batch template integration.
---

# ProjectIgnis Custom Card — Unified Skill

## File Locations

| Component | Path |
|-----------|------|
| DB (Saint Seiya) | `expansions/saint-seiya.cdb` |
| DB (other custom) | `expansions/cards-unofficial.cdb` |
| Lua scripts | `script/unofficial/c{ID}.lua` |
| Artwork | `pics/{ID}.jpg` |
| Archetype constants | `script/archetype_setcode_constants.lua` |
| String configs | `config/strings.conf`, `config/languages/Español/strings.conf` |
| Insert tools | `tools/insert_saint_*.py` |

## Lua Script Header Format

Every script must have a standardized comment block as source of truth:

```lua
--Card Name Here
--[==[
-- ID: 922100XXX
-- Type: Monster / Effect Monster
-- Level: 4
-- Attribute: DARK
-- Race: Warrior
-- ATK/DEF: 1800/1200
--
-- Archetypes:
-- - saint-seiya
-- - Black Saint
--
-- Effect (EN):
-- (This card is always treated as a "Black Saint" card.)
-- Effect text line 1.
-- Effect text line 2.
-- You can only use each effect of "Card Name Here" once per turn.
--]==]
--Card Name Here
local s,id=GetID()
```

Rules:
- Card name appears at line 1 AND after `--]==]`
- `Effect (EN):` must match `texts.desc` in the DB exactly (minus line wrapping)
- `Archetypes:` lists human-readable names matching the setcodes in DB

## Core Workflows

### Create a New Card

1. **Pick ID** — query max ID in the target `.cdb`
2. **Create DB rows** — `datas` (stats + bitmasks) + `texts` (name + desc)
3. **Create Lua script** — `script/unofficial/c{ID}.lua` with header + effects
4. **Add setcodes** if custom archetype (see Setcode Management)
5. **Create placeholders** for any referenced cards that don't exist yet

### Rename a Card

Renaming requires updating **all** of these locations:

1. **Lua header** — both name lines (top + after `--]==]`) and any self-reference in `Effect (EN):`
2. **DB** — `texts.name` + any self-reference in `texts.desc`
3. **Documentation** — grep all `.md` files under `sets/` for old name
4. **Insert scripts** — grep `tools/` for old name
5. **Deck files** — grep `deck/*.ydk` for old name (appears in `#comments`)
6. **Other Lua scripts** — grep for old name in case other cards reference it

Workflow:
```
1. Grep the entire project for the old name
2. Update each file (StrReplace with replace_all=true for docs)
3. Update DB via Python temp script
4. Final grep to verify zero remaining references
```

### Update DB via Python Temp Script

For DB changes, use this pattern (PowerShell-safe):

```python
# Write to _tmp_<action>.py, execute, then delete
import sqlite3
conn = sqlite3.connect(r"c:\ProjectIgnis\expansions\saint-seiya.cdb")
cur = conn.cursor()
cur.execute("UPDATE texts SET name=?, desc=? WHERE id=?", (new_name, new_desc, card_id))
print(f"Rows updated: {cur.rowcount}")
conn.commit()
conn.close()
```

Always:
- Use raw string `r"..."` for Windows paths
- Print row count for verification
- Delete the temp file after execution
- For unicode output, add `sys.stdout.reconfigure(encoding='utf-8')` before print

## Setcode Management

### Packing Multiple Archetypes

Up to 4 archetypes as 16-bit segments in a 64-bit integer:

```python
setcode = SET_A | (SET_B << 16) | (SET_C << 32) | (SET_D << 48)
```

Example: card with SET_SAINT (0x1D7) + SET_BLACK_SAINT (0x1E1):
```python
new_setcode = SET_SAINT | (SET_BLACK_SAINT << 16)  # = 0x1E101D7
```

### Adding a Setcode to an Existing Card

1. Read current setcode from DB
2. Find next free 16-bit slot (check which shifts are zero)
3. OR-in the new setcode at the free slot
4. Update DB + insert scripts + `listed_series` in Lua

### "Treated as" Pattern

When a card needs an archetype it doesn't have in its name:

**DB**: Add the setcode to `datas.setcode` (packed)

**Lua header**: Add to Archetypes list + first line of Effect (EN):
```
-- (This card is always treated as a "Black Saint" card.)
```

**DB desc**: Prepend the same line to `texts.desc`

**Lua code**: Add to `s.listed_series`

No Lua effect registration needed — EDOPro handles `IsSetCard()` via the DB setcode automatically.

## Equip Spell Patterns

### Standard Equip with Restriction

```lua
function s.initial_effect(c)
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)

    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_EQUIP_LIMIT)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetValue(s.eqlimit)
    c:RegisterEffect(e1)
end

function s.eqlimit(e,c)
    return c:IsSetCard(SET_BLACK_SAINT)  -- "Equip only to a 'Black Saint' monster."
end
```

### Removing Equip Restriction

Change `s.eqlimit` to accept any monster:
```lua
function s.eqlimit(e,c)
    return c:IsMonster()
end
```

And remove `Equip only to a "X" monster.` from header + DB desc.

### Batch Equip Restriction Changes

When changing equip restrictions across multiple cards:
1. Identify all affected scripts (grep for the restriction text)
2. Update each Lua: header line + `s.eqlimit` function
3. Batch-update DB via a single Python script iterating over IDs
4. Update documentation files

## Batch Template Integration

For bulk card ranges (e.g., 172–302):

### Parameters
- `SCRIPTS_DIR`: directory containing templates (e.g., `script/unofficial`)
- `ID_START`, `ID_END`: inclusive range
- `DB_PATH`: destination `.cdb`

### Steps
1. **(Optional) Normalize boilerplate** — only if scripts are still templates
2. **Upsert DB rows** — run the matching `tools/insert_saint_*.py`
3. **Implement real Lua logic** — author effects matching `Effect (EN):`
4. **Audit** — verify no empty `s.initial_effect` bodies remain

### Audit Command (PowerShell)

```bash
python -c "import re, pathlib; p=pathlib.Path('script/unofficial'); empty=[cid for cid in range(ID_START,ID_END+1) if re.search(r'function\s+s\.initial_effect\(c\)\s*\n\s*end\s*\n', (p/f'c{cid}.lua').read_text(encoding='utf-8',errors='replace').replace('\r\n','\n'))]; print('empty_count',len(empty)); print('empty_ids',empty)"
```

## Effect Scripting Guidelines

- Keep effects "EDOPro-safe": avoid brittle chain inspection unless needed
- Use `EFFECT_SPSUMMON_PROC` for custom summon procedures
- Use `EFFECT_DESTROY_REPLACE` for destruction substitutes
- Use `c:EnableReviveLimit()` for monsters that cannot be Normal Summoned
- Use `SetCountLimit(1,id)` for HOPT; `{id,1}` for second HOPT on same card
- Use `EFFECT_COUNT_CODE_OATH` for "You can only activate 1 per turn"
- Negate attack: `Duel.NegateAttack()` with `EVENT_ATTACK_ANNOUNCE`
- Mirror Force pattern: `Duel.Destroy(g,REASON_EFFECT)` on attack position group

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| `???` archetypes in EDOPro | Missing `!setname` entries | Add to both `config/strings.conf` files |
| "Custom card (scripted)." | Missing DB `texts` row | Re-run DB upsert for that ID |
| ANIME tag | `ot=4` in DB | Set `ot=3` |
| `sqlite3` not found in shell | CLI tool not in PATH | Use `python -c "import sqlite3; ..."` or temp `.py` files |
| PowerShell heredoc fails | `<<` syntax unsupported | Write temp `.py` file, execute, delete |
| `rg` lock error on `.edopro_lock` | File locked by running EDOPro | Add `glob="!**/.edopro_lock"` to Grep calls |

## Additional Resources

- For complete bitmask tables, DB schema, Lua API: [reference.md](reference.md)
- For real card implementation examples: [examples.md](examples.md)

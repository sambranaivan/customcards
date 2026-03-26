---
name: projectignis-custom-card
description: Create and register custom (unofficial) Yu-Gi-Oh!/EDOPro cards in ProjectIgnis. Use when the user asks to create/add/edit a custom card, insert into cards-unofficial.cdb, write a c{ID}.lua script under script/unofficial, add pics/{ID}.jpg, create placeholders, or add custom archetype setcodes.
---

# ProjectIgnis Custom Card Creator

## Scope

This skill defines the **standard ProjectIgnis workflow** for creating/editing **unofficial/custom cards**:

- DB entry in `expansions/cards-unofficial.cdb` (tables: `datas`, `texts`)
- Lua script in `script/unofficial/c{ID}.lua`
- Optional image in `pics/{ID}.jpg` (and `pics/field/{ID}.png` for field visuals)
- Optional placeholder handling via `placeholders.md`
- Optional new archetype setcodes via `script/archetype_setcode_constants.lua`

If the user is working on **official** cards, do not use this workflow.

## Quick workflow (do in this order)

1. **Check placeholders first**
   - If the desired card name already exists in `placeholders.md` as pending (`[ ]`), **reuse that ID and script** instead of creating a new card.

2. **Pick an ID**
   - For unofficial cards, use IDs **>= 100000000**.
   - Find the next free ID by querying the DB max ID in that range.

3. **Create/Update DB rows**
   - Insert into `datas` (numeric stats + bitmasks).
   - Insert into `texts` (name + description; `str1..str16` only when the Lua needs prompt strings via `aux.Stringid`).

4. **Create/Update the Lua script**
   - Create `script/unofficial/c{ID}.lua` with `local s,id=GetID()` and `function s.initial_effect(c) ... end`.
   - Ensure the effect text in DB matches the real behavior in Lua.

5. **Add image (optional)**
   - Put artwork at `pics/{ID}.jpg`.
   - Recommended size 177x254 (or proportional).

6. **If archetype is custom, add setcode**
   - Append under `--Custom archetypes` in `script/archetype_setcode_constants.lua`.
   - Use the next available hex value and store the **decimal** setcode value in DB `datas.setcode`.

7. **If card references other cards by name, ensure they exist**
   - If referenced cards don’t exist, create **placeholders** (minimal DB + minimal Lua) and register them in `placeholders.md`.

8. **Test**
   - Restart EDOPro, search by name/ID, and test effects in Test Hand / LAN duel.
   - If Lua errors occur, inspect EDOPro console output and fix script.

## Defaults and conventions

- **DB file**: `expansions/cards-unofficial.cdb`
- **Lua path**: `script/unofficial/c{ID}.lua`
- **Artwork**: `pics/{ID}.jpg`
- **Placeholders register**: `placeholders.md`
- **Insert scripts (optional but recommended)**: `*_insert_card.py` using `INSERT OR REPLACE` to stay idempotent

## When to create placeholders (rules)

Create placeholders when:
- A card effect names another card that must exist for `IsCode`, name filtering, or “Summon 1 ‘X’ … except ‘Y’” style logic.
- The named card does not exist in the DB yet.

Placeholder minimum:
- DB rows in `datas` and `texts` with a usable name.
- Lua script that can be empty (`function s.initial_effect(c) end`) unless it must be non-summonable (then use `c:EnableReviveLimit()` + an impossible summon proc).

## Output requirements (what to produce)

When the user requests a new card, produce:
- The chosen **ID**
- The **SQL** for `datas` and `texts` (or a Python insert script if requested)
- The full **Lua** script for `script/unofficial/c{ID}.lua`
- Any **setcode** additions (if needed)
- Any **placeholder** cards created/updated (if needed)
- A short **test plan** (EDOPro steps)

## Reference

For bitmask values, examples, and formulas (Pendulum/Link encoding), see:
- [reference.md](reference.md)


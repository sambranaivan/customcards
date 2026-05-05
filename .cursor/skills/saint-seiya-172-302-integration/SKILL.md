---
name: lua-template-card-integration
description: Integrates custom cards from EDOPro-style Lua templates into one or more .cdb databases. Uses comment blocks inside c<id>.lua templates as source of truth (name, stats, archetypes, Effect (EN)), optionally normalizes boilerplate (listed_series), upserts datas/texts into a chosen .cdb, and audits that no scripts remain with empty s.initial_effect. Use when the user mentions integrating templates, syncing Lua comments to DB, bulk upserts, card ranges, or auditing template scripts.
disable-model-invocation: true
---

# Lua template → DB integration (generic)

## Scope

Use this skill when the user asks to **integrate / sync / implement / audit** custom cards based on **Lua templates** (typically `c<id>.lua`) where the **comment block** is the source of truth, specifically:

- Parse card metadata and `Effect (EN)` from each template’s comment block.
- Upsert `datas`/`texts` into a user-chosen `.cdb` (path can change).
- Optionally normalize template boilerplate (e.g., `s.listed_series`) when templates are still boilerplate.
- Ensure **no template** remains with an empty `s.initial_effect`.

## Preconditions (quick checks)

- The templates exist (some folder, e.g. `script/unofficial/`).
- The destination DB exists (some `.cdb` under `expansions/`, or another path).
- If templates reference custom archetypes/setcodes:
  - Setcode constants exist (e.g. `script/archetype_setcode_constants.lua`).
  - `!setname` strings exist for any new setcodes in:
    - `config/strings.conf`
    - `config/languages/Español/strings.conf`

If any of these are missing, fix them first before doing DB syncs.

## Workflow (do in this order)

### 0) Capture the parameters (do not guess)

Collect these as explicit variables:

- `SCRIPTS_DIR`: directory containing templates (example: `script/unofficial`)
- `ID_START`, `ID_END`: inclusive range of ids (example: `922100172`..`922100302`)
- `DB_PATH`: destination `.cdb` (example: `expansions/saint-seiya.cdb`)

If the user wants multiple folders/ranges/DBs, handle one batch at a time.

### 1) (Optional) Normalize Lua boilerplate (only if templates are still boilerplate)

Run (only if you explicitly verified the script won’t overwrite real logic):

```bash
python tools/rewrite_lua_172_302_listed_series.py
```

Notes:
- This script is **batch-specific**. Use it only if it matches the user’s current template conventions and only when the scripts are still boilerplate.
- If the scripts already contain real logic, **do NOT run** any rewrite script that overwrites the body.
- If a generic rewrite is needed, create a new tool script that:
  - preserves the comment block
  - rewrites only a narrow boilerplate slice (or only `s.listed_series`)
  - is parameterized by `SCRIPTS_DIR`, `ID_START`, `ID_END`

### 2) Upsert DB rows into the chosen `.cdb`

Run:

```bash
python tools/insert_saint_172_302_into_saint_seiya_cdb.py
```

Expectations:
- This script is **batch-specific**. Use it only if it matches the user’s current template format and DB target.
- If the DB/template format changed, create a new generic inserter tool script that:
  - parses the comment block format currently in use
  - is parameterized by `SCRIPTS_DIR`, `ID_START`, `ID_END`, `DB_PATH`
  - upserts `datas` and `texts`
  - enforces any house rules the user requests (e.g. `ot=3`)

### 3) Implement real Lua logic (template scripts)

Author real effects in the template scripts based on the comment `Effect (EN)`.

Guidelines:
- Keep effects stable and “EDOPro-safe”: avoid brittle chain inspection unless needed.
- Prefer existing EDOPro idioms:
  - `EFFECT_SPSUMMON_PROC` for custom summon procedures.
  - `EFFECT_DESTROY_REPLACE` / `EFFECT_TO_GRAVE_REDIRECT` for replacements/redirects.
  - Column logic via `GetColumnGroup()` where possible; if exact column semantics are hard, implement a conservative approximation.
- Token creation: use `id+1000` style reserved codes or explicit token params when supported by the environment.

### 4) Audit comment coverage + metadata (optional but recommended)

Run:

```bash
python tools/audit_saint_172_302_comments.py
```

Use this to find:
- Missing IDs/scripts in the range.
- Broken or empty `Effect (EN)` blocks.
- Unexpected archetype tags that require new setcodes / `!setname`.

### 5) Audit “no empty initial_effect” (required)

Run this check (PowerShell friendly):

```bash
python -c "import re, pathlib; SCRIPTS_DIR='script/unofficial'; ID_START=922100172; ID_END=922100302; p=pathlib.Path(SCRIPTS_DIR); empty=[]; \
[(empty.append(cid)) for cid in range(ID_START,ID_END+1) \
 if re.search(r'function\\s+s\\.initial_effect\\(c\\)\\s*\\n\\s*end\\s*\\n', \
 (p/f'c{cid}.lua').read_text(encoding='utf-8',errors='replace').replace('\\r\\n','\\n').replace('\\r','\\n'))]; \
print('empty_count',len(empty)); print('empty_ids',empty)"
```

Success criteria:
- `empty_count 0`

## Troubleshooting

### “???|???|???” archetypes in EDOPro

Cause: missing `!setname` entries for custom setcodes.

Fix:
- Add `!setname 0x???? <Name>` to both `config/strings.conf` and `config/languages/Español/strings.conf`.

### “Custom card (scripted).”

Cause: DB `texts` row missing or description/name not inserted for that id.

Fix:
- Re-run the correct DB upsert tool for the current batch.
- Ensure the comment block contains a valid `Effect (EN)` section.

### ANIME tag appears

Cause: `ot=4` in DB rows.

Fix:
- Use `python tools/set_ot_saint_seiya_cdb.py` or update affected rows to `ot=3`.


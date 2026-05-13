---
name: render-card-images
description: Generate CardMaker and Instagram PNG images for custom Yu-Gi-Oh! cards. Use when the user asks to render, regenerate, re-render card images, generate PNGs, or mentions cardmaker/instagram output for card IDs or deck files (.ydk).
---

# Render Card Images

Generate card PNGs from the `saint-seiya.cdb` database using two scripts in sequence:
1. **CardMaker** — renders the card layout (template + art + text)
2. **Instagram** — composites card over blurred artwork for social media

## Scripts

| Script | Output dir | What it produces |
|--------|-----------|-----------------|
| `sets/generate_cardmaker_from_sets_sqlite.py` | `sets/cardmaker_output/{id}.png` | Full card render |
| `sets/generate_instagram_from_sets_sqlite.py` | `sets/instagram_output/{id}.png` + `sets/instagram_output_sheet/{id}.png` | Social-media images (center + sheet variants) |

## Workflow

### 1. Determine card IDs

**From a deck file (.ydk):**

```python
python -c "
ids=set(); f=open(r'path/to/deck.ydk'); sec=False
for line in f:
    line=line.strip()
    if line=='#main' or line=='#extra': sec=True; continue
    if line=='!side': break
    if sec and line.split('#')[0].strip().isdigit(): ids.add(line.split('#')[0].strip())
f.close()
for i in sorted(ids): print(i)
"
```

**From specific IDs:** use them directly.

**From the database (name pattern):**

```python
python -c "
import sqlite3; conn=sqlite3.connect(r'expansions/saint-seiya.cdb')
for r in conn.execute(\"SELECT id, name FROM texts WHERE name LIKE '%PATTERN%' ORDER BY id\").fetchall(): print(r[0], r[1])
conn.close()
"
```

### 2. Render with PowerShell loop

Use a PowerShell `foreach` loop (the project shell is PowerShell — do NOT use `&&`):

```powershell
$ids = @(922100001,922100002,922100003)

# Step 1: CardMaker
foreach($id in $ids){ python sets/generate_cardmaker_from_sets_sqlite.py --card-id $id --regenerate }

# Step 2: Instagram (must run AFTER CardMaker since it reads cardmaker_output)
foreach($id in $ids){ python sets/generate_instagram_from_sets_sqlite.py --card-id $id --regenerate }
```

For a single card, run both sequentially with `;`:

```powershell
python sets/generate_cardmaker_from_sets_sqlite.py --card-id 922100001 --regenerate; python sets/generate_instagram_from_sets_sqlite.py --card-id 922100001 --regenerate
```

### 3. Verify output

Each invocation prints a summary line. Confirm:
- `generated=1` (CardMaker) or `generated=2` (Instagram: center + sheet)
- `errors=0`

## Key flags

| Flag | Script | Purpose |
|------|--------|---------|
| `--card-id ID` | both | Render a single card |
| `--regenerate` | both | Overwrite existing output |
| `--cdb PATH` | both | Alternative .cdb file (default: `expansions/saint-seiya.cdb`) |
| `--from ID` | instagram | Process IDs >= value |
| `--to ID` | instagram | Process IDs <= value |

## Tips

- **Always run CardMaker before Instagram** — the instagram script reads from `sets/cardmaker_output/`.
- **Set `block_until_ms`** high enough (~6s per card for CardMaker, ~2s for Instagram). For 30 cards use 300000.
- For `.ydk` files, extract unique IDs only (decks have duplicates).
- The side deck (`!side` section) may contain cards too — ask the user if they should be included.

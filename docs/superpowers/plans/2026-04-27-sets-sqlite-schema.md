# Sets SQLite Schema Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create `sets/sets.sqlite3` and apply the approved `cards` + `erratas` schema.

**Architecture:** Use Python's stdlib `sqlite3` to create the database file and execute a single DDL script (idempotent `CREATE TABLE IF NOT EXISTS` + `CREATE INDEX IF NOT EXISTS`). Keep `cards` as the current state and `erratas` as the history snapshots.

**Tech Stack:** Python 3 (`sqlite3`), SQLite file under `sets/`.

---

### Task 1: Create a schema SQL file (source of truth)

**Files:**
- Create: `C:/ProjectIgnis/sets/schema.sql`

- [ ] **Step 1: Write `sets/schema.sql`**

```sql
PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS cards (
  card_id            INTEGER PRIMARY KEY,

  name_en            TEXT,
  name_es            TEXT,
  aliases_json       TEXT,

  card_type          TEXT NOT NULL CHECK (card_type IN ('Monster','Spell','Trap')),

  level              INTEGER,
  rank               INTEGER,
  link               INTEGER,
  pendulum_scale     INTEGER,
  attribute          TEXT,
  race               TEXT,
  atk                INTEGER,
  def                INTEGER,

  is_psct            INTEGER NOT NULL DEFAULT 1 CHECK (is_psct IN (0,1)),
  effect_text_en     TEXT,
  effect_text_es     TEXT,

  archetypes_json    TEXT,
  setcodes_json      TEXT,

  lua_path           TEXT,
  lua_sha256         TEXT,
  lua_text           TEXT,

  updated_ts         TEXT NOT NULL,
  updated_reason     TEXT,
  updated_source_ref TEXT,
  updated_notes      TEXT
);

CREATE TABLE IF NOT EXISTS erratas (
  errata_id           INTEGER PRIMARY KEY AUTOINCREMENT,
  card_id             INTEGER NOT NULL REFERENCES cards(card_id),
  errata_ts           TEXT NOT NULL,
  errata_reason       TEXT,
  errata_source_ref   TEXT,
  errata_notes        TEXT,

  prev_name_en        TEXT,
  prev_name_es        TEXT,
  prev_aliases_json   TEXT,
  prev_card_type      TEXT,
  prev_level          INTEGER,
  prev_rank           INTEGER,
  prev_link           INTEGER,
  prev_pendulum_scale INTEGER,
  prev_attribute      TEXT,
  prev_race           TEXT,
  prev_atk            INTEGER,
  prev_def            INTEGER,
  prev_is_psct        INTEGER,
  prev_effect_text_en TEXT,
  prev_effect_text_es TEXT,
  prev_archetypes_json TEXT,
  prev_setcodes_json   TEXT,
  prev_lua_path       TEXT,
  prev_lua_sha256     TEXT,
  prev_lua_text       TEXT
);

CREATE INDEX IF NOT EXISTS ix_erratas_card_id_ts
ON erratas(card_id, errata_ts DESC);
```

- [ ] **Step 2: (Optional) Validate SQL is parseable**

Run (no output expected on success): `python -c "import sqlite3; sqlite3.connect(':memory:').executescript(open('sets/schema.sql','r',encoding='utf-8').read())"`

---

### Task 2: Create `sets/sets.sqlite3` and apply schema

**Files:**
- Create: `C:/ProjectIgnis/sets/sets.sqlite3`

- [ ] **Step 1: Ensure `sets/` directory exists**

Run: `powershell -Command "Test-Path .\\sets"`
Expected: `True`

- [ ] **Step 2: Create DB file and apply DDL**

Run:

```bash
python -c "import sqlite3; from pathlib import Path; ddl=Path('sets/schema.sql').read_text(encoding='utf-8'); db=Path('sets/sets.sqlite3'); conn=sqlite3.connect(db); conn.execute('PRAGMA foreign_keys=ON'); conn.executescript(ddl); conn.commit(); conn.close(); print('ok', db)"
```

Expected: `ok sets/sets.sqlite3`

---

### Task 3: Verify schema in `sets/sets.sqlite3`

**Files:**
- Verify: `C:/ProjectIgnis/sets/sets.sqlite3`

- [ ] **Step 1: List tables + indexes**

Run:

```bash
python -c "import sqlite3; conn=sqlite3.connect('sets/sets.sqlite3'); cur=conn.cursor(); print('tables', [r[0] for r in cur.execute(\"SELECT name FROM sqlite_master WHERE type='table' ORDER BY name\")]); print('indexes', [r[0] for r in cur.execute(\"SELECT name FROM sqlite_master WHERE type='index' ORDER BY name\")]); conn.close()"
```

Expected:
- tables include `cards`, `erratas`, and `sqlite_sequence` (optional, created when AUTOINCREMENT used)
- indexes include `ix_erratas_card_id_ts`


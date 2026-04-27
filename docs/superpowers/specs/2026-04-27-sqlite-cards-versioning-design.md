---
title: "SQLite: cartas vigentes + historial de erratas"
date: 2026-04-27
repo: ProjectIgnis
status: draft
---

## Objetivo

Gestionar cartas custom y sus **arquetipos** de forma estructurada en una base SQLite simple, pudiendo:

- Mantener **solo el estado vigente** por carta en `cards`.
- Registrar un historial de **erratas/correcciones** (stats/PSCT/Lua/arquetipos) en una tabla `erratas` referenciada por `card_id`.
- Auditar cambios de **script Lua** (vía `lua_path` + `lua_sha256`, y opcionalmente almacenando el contenido completo).
- Consultar fácilmente:
  - La **versión vigente** de una carta.
  - El **histórico completo** por carta.
  - Qué cartas cambiaron (por rango de fecha/motivo).

## Principios de diseño

- **Identidad estable**: `card_id` es el ID numérico estable (EDOPro / `c{ID}.lua` / `.cdb`).
- **Estado vigente separado del historial**:
  - `cards` tiene **1 fila por `card_id`** (vigente).
  - `erratas` guarda **snapshots anteriores** + metadatos de corrección.
- **Sin normalización extra (C1)**: arquetipos y setcodes se guardan en JSON en la misma tabla (`archetypes_json`, `setcodes_json`).

## Alcance / No alcance

### En alcance

- Esquema SQLite para versionado interno (no reemplaza la DB de EDOPro).
- Metadatos de revisión: fecha, motivo, referencia de fuente.
- Soporte para nombres por idioma y alias.

### Fuera de alcance (por ahora)

- Normalización de arquetipos a tablas separadas.
- Validación JSON estricta en SQLite (se puede agregar si se habilita/usa JSON1, pero no se asume).
- Un pipeline automático “Git ↔ SQLite ↔ `.cdb`” (se planifica en una etapa posterior).

## Esquema propuesto

### Tabla `cards` (solo vigente)

Notas:

- `card_id` es PK: **una fila por carta**.
- Las correcciones generan un registro en `erratas` con el estado previo, y luego se actualiza `cards`.

```sql
CREATE TABLE IF NOT EXISTS cards (
  -- Stable identity (EDOPro id)
  card_id           INTEGER PRIMARY KEY,

  -- Names / aliases (simple)
  name_en           TEXT,
  name_es           TEXT,
  aliases_json      TEXT, -- JSON array of strings (optional)

  -- Classification
  card_type         TEXT NOT NULL CHECK (card_type IN ('Monster','Spell','Trap')),

  -- Monster stats (nullable for non-monsters)
  level             INTEGER,
  rank              INTEGER,
  link              INTEGER,
  pendulum_scale    INTEGER,
  attribute         TEXT,
  race              TEXT,
  atk               INTEGER,
  def               INTEGER,

  -- Text (snapshot)
  is_psct           INTEGER NOT NULL DEFAULT 1 CHECK (is_psct IN (0,1)),
  effect_text_en    TEXT,
  effect_text_es    TEXT,

  -- Archetypes / setcodes (snapshot)
  archetypes_json   TEXT, -- JSON array e.g. ["specter","hades"]
  setcodes_json     TEXT, -- JSON array e.g. [0x1234,0xABCD] (optional)

  -- Lua script snapshot linkage
  lua_path          TEXT, -- e.g. script/unofficial/c12345678.lua
  lua_sha256        TEXT, -- hex string
  lua_text          TEXT, -- optional (store full script)

  -- Current state metadata
  updated_ts        TEXT NOT NULL, -- ISO8601
  updated_reason    TEXT,          -- errata|balance|typo|initial
  updated_source_ref TEXT,         -- file path / issue / commit
  updated_notes     TEXT
);
```

### Tabla `erratas` (historial)

Idea: cada vez que se modifica `cards`, se inserta en `erratas` una fila con el **estado anterior completo** (snapshot) + metadatos de corrección.

```sql
CREATE TABLE IF NOT EXISTS erratas (
  errata_id          INTEGER PRIMARY KEY AUTOINCREMENT,
  card_id            INTEGER NOT NULL REFERENCES cards(card_id),
  errata_ts          TEXT NOT NULL, -- ISO8601
  errata_reason      TEXT,          -- errata|balance|typo|rename|script-fix
  errata_source_ref  TEXT,          -- file path / issue / commit
  errata_notes       TEXT,

  -- Snapshot BEFORE applying the correction
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

## Reglas operativas (cómo corregir / “versionar”)

### Crear una carta (versión inicial)

- Insertar una fila con:
  - `card_id` estable
  - `updated_reason = 'initial'`
  - `updated_ts` en formato ISO8601 (ej: `strftime('%Y-%m-%dT%H:%M:%fZ','now')`)

### Aplicar una corrección (errata/balance/typo)

Regla: el estado vigente vive en `cards`, pero **antes de modificarlo** se archiva el estado previo en `erratas`.

Transacción recomendada:

1. Insertar en `erratas` un snapshot del estado actual de `cards`.
2. Actualizar `cards` con los campos corregidos + `updated_*`.

Pseudo-SQL:

```sql
BEGIN;

-- 1) Guardar snapshot previo en erratas
INSERT INTO erratas (
  card_id, errata_ts, errata_reason, errata_source_ref, errata_notes,
  prev_name_en, prev_name_es, prev_aliases_json,
  prev_card_type,
  prev_level, prev_rank, prev_link, prev_pendulum_scale, prev_attribute, prev_race, prev_atk, prev_def,
  prev_is_psct, prev_effect_text_en, prev_effect_text_es,
  prev_archetypes_json, prev_setcodes_json,
  prev_lua_path, prev_lua_sha256, prev_lua_text
)
SELECT
  c.card_id, strftime('%Y-%m-%dT%H:%M:%fZ','now'), ?, ?, ?,
  c.name_en, c.name_es, c.aliases_json,
  c.card_type,
  c.level, c.rank, c.link, c.pendulum_scale, c.attribute, c.race, c.atk, c.def,
  c.is_psct, c.effect_text_en, c.effect_text_es,
  c.archetypes_json, c.setcodes_json,
  c.lua_path, c.lua_sha256, c.lua_text
FROM cards c
WHERE c.card_id = ?;

-- 2) Actualizar estado vigente
UPDATE cards
SET
  name_en = ?,
  name_es = ?,
  aliases_json = ?,
  card_type = ?,
  level = ?,
  rank = ?,
  link = ?,
  pendulum_scale = ?,
  attribute = ?,
  race = ?,
  atk = ?,
  def = ?,
  is_psct = ?,
  effect_text_en = ?,
  effect_text_es = ?,
  archetypes_json = ?,
  setcodes_json = ?,
  lua_path = ?,
  lua_sha256 = ?,
  lua_text = ?,
  updated_ts = strftime('%Y-%m-%dT%H:%M:%fZ','now'),
  updated_reason = ?,
  updated_source_ref = ?,
  updated_notes = ?
WHERE card_id = ?;

COMMIT;
```

## Consultas típicas

### Obtener la versión vigente de una carta

```sql
SELECT *
FROM cards
WHERE card_id = ?;
```

### Obtener el histórico completo de una carta

```sql
SELECT errata_id, errata_ts, errata_reason, errata_source_ref, errata_notes
FROM erratas
WHERE card_id = ?
ORDER BY errata_ts ASC, errata_id ASC;
```

### Listar cartas con cambios recientes (por timestamp)

```sql
SELECT card_id, updated_ts, updated_reason, name_en
FROM cards
WHERE updated_ts >= ? AND updated_ts < ?
ORDER BY updated_ts DESC;
```

### Detectar cartas con script cambiado (por hash)

```sql
SELECT card_id, updated_ts, lua_path, lua_sha256
FROM cards
WHERE lua_sha256 IS NOT NULL
ORDER BY updated_ts DESC;
```

## Decisiones abiertas

- **`lua_text`**: si se guarda, se puede reproducir exactamente el script de esa versión; si no, se audita por path+hash y se versiona el `.lua` en Git.
- **Formato JSON**: `archetypes_json`, `setcodes_json`, `aliases_json` se guardan como `TEXT` sin validación fuerte; opcionalmente se puede agregar una validación en la capa de inserción.
- **Nombres por idioma**: se eligió `name_en` / `name_es` por simplicidad; si aparecen más idiomas, conviene migrar a `names_json`.


PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS cards (
  card_id            INTEGER PRIMARY KEY,

  name_en            TEXT,
  name_es            TEXT,
  aliases_json       TEXT,

  card_type          TEXT NOT NULL CHECK (card_type IN ('Monster','Spell','Trap')),
  card_sub_type      TEXT,

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


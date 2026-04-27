import json
import sqlite3
from pathlib import Path


DB_PATH = Path(r"c:\ProjectIgnis\sets\sets.sqlite3")

RENAMES: dict[str, str] = {
    "Steel Saint - Sho of the Sky Armor": "Steel Saint - Sho of Sky Armor",
}


def _ensure_aliases(existing_json: str | None, alias: str) -> str:
    aliases: list[str]
    if existing_json:
        try:
            v = json.loads(existing_json)
            aliases = v if isinstance(v, list) else []
        except Exception:
            aliases = []
    else:
        aliases = []

    if alias not in aliases:
        aliases.append(alias)
    aliases = sorted(set(aliases))
    return json.dumps(aliases, ensure_ascii=False)


def main() -> None:
    conn = sqlite3.connect(DB_PATH)
    conn.execute("PRAGMA foreign_keys=ON")
    cur = conn.cursor()

    matched = 0
    updated = 0

    for old, new in RENAMES.items():
        rows = cur.execute(
            """
            SELECT
              card_id,
              name_en,
              aliases_json,
              card_type,
              level, rank, link, pendulum_scale, attribute, race, atk, def,
              is_psct, effect_text_en, effect_text_es,
              archetypes_json, setcodes_json,
              lua_path, lua_sha256, lua_text
            FROM cards
            WHERE name_en = ?
            """,
            (old,),
        ).fetchall()

        matched += len(rows)

        for (
            card_id,
            name_en,
            aliases_json,
            card_type,
            level,
            rank,
            link,
            pendulum_scale,
            attribute,
            race,
            atk,
            defe,
            is_psct,
            effect_text_en,
            effect_text_es,
            archetypes_json,
            setcodes_json,
            lua_path,
            lua_sha256,
            lua_text,
        ) in rows:
            conn.execute("BEGIN")
            # 1) Snapshot previous row into erratas
            cur.execute(
                """
                INSERT INTO erratas (
                  card_id, errata_ts, errata_reason, errata_source_ref, errata_notes,
                  prev_name_en, prev_name_es, prev_aliases_json,
                  prev_card_type,
                  prev_level, prev_rank, prev_link, prev_pendulum_scale, prev_attribute, prev_race, prev_atk, prev_def,
                  prev_is_psct, prev_effect_text_en, prev_effect_text_es,
                  prev_archetypes_json, prev_setcodes_json,
                  prev_lua_path, prev_lua_sha256, prev_lua_text
                ) VALUES (
                  ?, strftime('%Y-%m-%dT%H:%M:%fZ','now'), 'rename', ?, ?,
                  ?, NULL, ?,
                  ?,
                  ?, ?, ?, ?, ?, ?, ?, ?,
                  ?, ?, ?,
                  ?, ?,
                  ?, ?, ?
                )
                """,
                (
                    card_id,
                    "sets/migrations/2026-04-27_normalize_steel_saint_names.py",
                    f'Normalized name_en from "{old}" to "{new}".',
                    name_en,
                    aliases_json,
                    card_type,
                    level,
                    rank,
                    link,
                    pendulum_scale,
                    attribute,
                    race,
                    atk,
                    defe,
                    is_psct,
                    effect_text_en,
                    effect_text_es,
                    archetypes_json,
                    setcodes_json,
                    lua_path,
                    lua_sha256,
                    lua_text,
                ),
            )

            # 2) Update current row
            new_aliases = _ensure_aliases(aliases_json, old)
            cur.execute(
                """
                UPDATE cards
                SET
                  name_en = ?,
                  aliases_json = ?,
                  updated_ts = strftime('%Y-%m-%dT%H:%M:%fZ','now'),
                  updated_reason = 'rename',
                  updated_source_ref = ?,
                  updated_notes = ?
                WHERE card_id = ?
                """,
                (
                    new,
                    new_aliases,
                    "sets/migrations/2026-04-27_normalize_steel_saint_names.py",
                    f'Normalized name_en from "{old}" to "{new}".',
                    card_id,
                ),
            )
            conn.commit()
            updated += 1

    remaining = cur.execute(
        "SELECT COUNT(*) FROM cards WHERE name_en IN (%s)"
        % ",".join(["?"] * len(RENAMES)),
        tuple(RENAMES.keys()),
    ).fetchone()[0]

    print(f"matched={matched} updated={updated} remaining_old_names={remaining}")
    conn.close()


if __name__ == "__main__":
    main()


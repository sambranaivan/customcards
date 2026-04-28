import argparse
import hashlib
import json
import os
import sqlite3
from dataclasses import dataclass


@dataclass(frozen=True)
class CardRow:
    card_id: int
    name_en: str | None
    name_es: str | None
    card_type: str
    card_sub_type: str | None
    level: int | None
    rank: int | None
    link: int | None
    pendulum_scale: int | None
    attribute: str | None
    race: str | None
    atk: int | None
    def_: int | None
    effect_text_en: str | None
    effect_text_es: str | None
    archetypes_json: str | None
    setcodes_json: str | None
    lua_path: str | None
    lua_text: str | None


def normalize_path(p: str) -> str:
    p = p.replace("\\", "/").strip()
    if p.startswith("./"):
        p = p[2:]
    return p


def default_lua_path(card_id: int) -> str:
    return f"script/unofficial/c{card_id}.lua"


def ensure_parent_dir(path: str) -> None:
    parent = os.path.dirname(path)
    if parent:
        os.makedirs(parent, exist_ok=True)


def render_fallback_lua(card_id: int, name: str) -> str:
    # Minimal placeholder script that loads in EDOPro.
    return "\n".join(
        [
            f"--{name}",
            "local s,id=GetID()",
            "function s.initial_effect(c)",
            "end",
            "",
        ]
    )


def _fmt(v: object | None) -> str:
    if v is None:
        return "-"
    if isinstance(v, str):
        v = v.strip()
        return v if v else "-"
    return str(v)


def render_card_comment(card: CardRow) -> str:
    name = (card.name_en or card.name_es or f"Card {card.card_id}").strip()
    lines: list[str] = []
    lines.append(f"--{name}")
    lines.append("--[==[")
    lines.append(f"-- ID: {card.card_id}")
    lines.append(
        f"-- Type: {card.card_type}{(' / ' + card.card_sub_type.strip()) if card.card_sub_type and card.card_sub_type.strip() else ''}"
    )

    if card.card_type == "Monster":
        if card.level is not None:
            lines.append(f"-- Level: {_fmt(card.level)}")
        if card.rank is not None:
            lines.append(f"-- Rank: {_fmt(card.rank)}")
        if card.link is not None:
            lines.append(f"-- Link: {_fmt(card.link)}")
        if card.pendulum_scale is not None:
            lines.append(f"-- Pendulum Scale: {_fmt(card.pendulum_scale)}")
        lines.append(f"-- Attribute: {_fmt(card.attribute)}")
        lines.append(f"-- Race: {_fmt(card.race)}")
        lines.append(f"-- ATK/DEF: {_fmt(card.atk)}/{_fmt(card.def_)}")

    def _append_json_list(label: str, raw: str | None) -> None:
        if not raw or not raw.strip():
            return
        try:
            parsed = json.loads(raw)
        except Exception:
            lines.append("--")
            lines.append(f"-- {label}: {raw.strip()}")
            return

        lines.append("--")
        lines.append(f"-- {label}:")
        if isinstance(parsed, list):
            if not parsed:
                lines.append("-- - (empty)")
            else:
                for item in parsed:
                    lines.append(f"-- - {item}")
        else:
            pretty = json.dumps(parsed, ensure_ascii=False, indent=2).splitlines()
            for l in pretty:
                lines.append(f"-- {l}")

    _append_json_list("Archetypes", card.archetypes_json)
    _append_json_list("Setcodes", card.setcodes_json)

    effect_en = (card.effect_text_en or "").strip()
    effect_es = (card.effect_text_es or "").strip()
    if effect_en or effect_es:
        lines.append("--")
        if effect_en:
            lines.append("-- Effect (EN):")
            for l in effect_en.splitlines():
                lines.append(f"-- {l}".rstrip())
        if effect_es:
            lines.append("--")
            lines.append("-- Efecto (ES):")
            for l in effect_es.splitlines():
                lines.append(f"-- {l}".rstrip())

    lines.append("--]==]")
    lines.append("")
    return "\n".join(lines)


def merge_comment_with_lua(comment: str, lua_body: str) -> str:
    body = lua_body.lstrip("\ufeff").strip()
    if "--[==[" in body and "--]==]" in body:
        return body + ("\n" if not body.endswith("\n") else "")
    merged = comment + body + ("\n" if not body.endswith("\n") else "")
    return merged


def sha256_text(s: str) -> str:
    return hashlib.sha256(s.encode("utf-8")).hexdigest()


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--db", default="c:/ProjectIgnis/sets/sets.sqlite3")
    ap.add_argument("--limit", type=int, default=5)
    ap.add_argument("--offset", type=int, default=0)
    ap.add_argument(
        "--only-missing",
        action="store_true",
        help="Only export cards whose resolved lua file does not exist on disk",
    )
    args = ap.parse_args()

    con = sqlite3.connect(args.db)
    cur = con.cursor()
    cur.execute(
        """
        SELECT
          card_id,
          name_en,
          name_es,
          card_type,
          card_sub_type,
          level,
          rank,
          link,
          pendulum_scale,
          attribute,
          race,
          atk,
          def,
          effect_text_en,
          effect_text_es,
          archetypes_json,
          setcodes_json,
          lua_path,
          lua_text
        FROM cards
        ORDER BY card_id
        LIMIT ? OFFSET ?
        """,
        (args.limit, args.offset),
    )

    exported = 0
    for row in cur.fetchall():
        (
            card_id,
            name_en,
            name_es,
            card_type,
            card_sub_type,
            level,
            rank,
            link,
            pendulum_scale,
            attribute,
            race,
            atk,
            def_val,
            effect_text_en,
            effect_text_es,
            archetypes_json,
            setcodes_json,
            lua_path,
            lua_text,
        ) = row
        card = CardRow(
            card_id=card_id,
            name_en=name_en,
            name_es=name_es,
            card_type=card_type,
            card_sub_type=card_sub_type,
            level=level,
            rank=rank,
            link=link,
            pendulum_scale=pendulum_scale,
            attribute=attribute,
            race=race,
            atk=atk,
            def_=def_val,
            effect_text_en=effect_text_en,
            effect_text_es=effect_text_es,
            archetypes_json=archetypes_json,
            setcodes_json=setcodes_json,
            lua_path=lua_path,
            lua_text=lua_text,
        )
        rel = normalize_path(card.lua_path) if card.lua_path else default_lua_path(card.card_id)
        abs_path = os.path.join("c:/ProjectIgnis", rel.replace("/", os.sep))

        if args.only_missing and os.path.exists(abs_path):
            continue

        name = (card.name_en or card.name_es or f"Card {card.card_id}").strip()
        lua = (card.lua_text or "").strip()
        if not lua:
            lua = render_fallback_lua(card.card_id, name)
        comment = render_card_comment(card)
        lua = merge_comment_with_lua(comment, lua)

        ensure_parent_dir(abs_path)
        with open(abs_path, "w", encoding="utf-8", newline="\n") as f:
            f.write(lua)

        exported += 1
        print(f"{card.card_id}\t{rel}\tsha256:{sha256_text(lua)}\t{name}")

    con.close()
    print(f"\nEXPORTED {exported}")


if __name__ == "__main__":
    main()


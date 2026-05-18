#!/usr/bin/env python3
"""Build a distributable EDOPro content repo for Saint Seiya Bronze + Black Saints decks.

Reads deck/*.ydk, exports a subset of expansions/saint-seiya.cdb, and copies scripts,
pics, strings, init.lua, decks, WindBot executors/decks/bots.json, and a compact lflist.
"""
from __future__ import annotations

import argparse
import json
import re
import shutil
import sqlite3
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_SOURCE_CDB = ROOT / "expansions" / "saint-seiya.cdb"
DEFAULT_SCRIPT_DIR = ROOT / "script" / "unofficial"
DEFAULT_PICS_DIR = ROOT / "pics"
DEFAULT_CARDMAKER_DIR = ROOT / "sets" / "cardmaker_output"
PUBLIC_REPO_URL = "https://github.com/sambranaivan/edopro_ssy_public.git"
# Path in user_configs.json / EDOPro client (synced under ./repositories/)
CLIENT_REPO_PATH = "repositories/edopro_ssy_public"
# Local publish + git push target (not wiped when EDOPro clears ./repositories/)
DEFAULT_OUTPUT = ROOT / "repositories_external" / "edopro_ssy_public"
DEFAULT_DECKS = (
    ROOT / "deck" / "Saint Seiya - Bronze Only.ydk",
    ROOT / "deck" / "Saint Seiya - Black Saints.ydk",
)
WINDBOT_ROOT = ROOT / "WindBot"
WINDBOT_EXECUTOR_DLLS = (
    "SaintSeiyaBronzeOnlyExecutor.dll",
    "SaintSeiyaBlackSaintsExecutor.dll",
)
WINDBOT_AI_DECKS = (
    "AI_SaintSeiyaBronzeOnly.ydk",
    "AI_SaintSeiyaBlackSaints.ydk",
)
WINDBOT_BOT_DECK_KEYS = frozenset({"SaintSeiyaBronzeOnly", "SaintSeiyaBlackSaints"})

ARCHETYPE_INIT_START = "SET_SAINT"
ARCHETYPE_INIT_END = "SET_BRONZE_CLOTH"
STRINGS_MARKER_START = "# Saint Seiya custom archetypes"
STRINGS_MARKER_END = "# Pokemon Archetypes"

LFLIST_ID = 922199002
LFLIST_NAME = "Saint Seiya Decks (Bronze + Black Saints)"


def parse_ydk_ids(path: Path) -> set[int]:
    ids: set[int] = set()
    for raw in path.read_text(encoding="utf-8", errors="replace").splitlines():
        line = raw.strip()
        if not line or line.startswith("#") or line.startswith("!"):
            continue
        if line.isdigit():
            ids.add(int(line))
    return ids


def collect_deck_ids(deck_paths: list[Path]) -> tuple[set[int], dict[str, list[int]]]:
    by_deck: dict[str, list[int]] = {}
    all_ids: set[int] = set()
    for deck in deck_paths:
        ids = sorted(parse_ydk_ids(deck))
        by_deck[deck.name] = ids
        all_ids.update(ids)
    return all_ids, by_deck


def extract_archetype_init_lua(source: Path) -> str:
    text = source.read_text(encoding="utf-8")
    start = text.find(ARCHETYPE_INIT_START)
    end = text.find(ARCHETYPE_INIT_END)
    if start == -1 or end == -1:
        raise RuntimeError("Could not locate Saint Seiya SET_* block in archetype_setcode_constants.lua")
    end = text.find("\n", end) + 1
    block = text[start:end].rstrip()
    return (
        "-- Saint Seiya setcodes (auto-generated; keep in sync with strings.conf)\n"
        f"{block}\n"
    )


def extract_strings_conf(source: Path) -> str:
    lines = source.read_text(encoding="utf-8").splitlines()
    out: list[str] = []
    capture = False
    for line in lines:
        if line.strip() == STRINGS_MARKER_START:
            capture = True
        if capture:
            if line.strip() == STRINGS_MARKER_END:
                break
            out.append(line)
    if not out:
        raise RuntimeError("Could not locate Saint Seiya !setname block in config/strings.conf")
    return "\n".join(out) + "\n"


def export_subset_cdb(source: Path, dest: Path, card_ids: set[int]) -> None:
    if dest.exists():
        dest.unlink()
    dest.parent.mkdir(parents=True, exist_ok=True)

    src = sqlite3.connect(str(source))
    dst = sqlite3.connect(str(dest))
    try:
        src_cur = src.cursor()
        dst_cur = dst.cursor()

        for table in ("datas", "texts"):
            ddl = src_cur.execute(
                "SELECT sql FROM sqlite_master WHERE type='table' AND name=?",
                (table,),
            ).fetchone()[0]
            dst_cur.execute(ddl)

        placeholders = ",".join("?" for _ in card_ids)
        id_list = sorted(card_ids)
        for table in ("datas", "texts"):
            rows = src_cur.execute(
                f"SELECT * FROM {table} WHERE id IN ({placeholders})",
                id_list,
            ).fetchall()
            if len(rows) != len(id_list):
                found = {r[0] for r in rows}
                missing = sorted(card_ids - found)
                raise RuntimeError(f"Missing rows in {table} for ids: {missing}")
            cols = [d[1] for d in src_cur.execute(f"pragma table_info({table})").fetchall()]
            col_sql = ",".join(cols)
            qmarks = ",".join("?" for _ in cols)
            dst_cur.executemany(
                f"INSERT INTO {table} ({col_sql}) VALUES ({qmarks})",
                rows,
            )

        dst.commit()
    finally:
        src.close()
        dst.close()


def png_to_jpg(png_path: Path, jpg_path: Path) -> None:
    from PIL import Image

    with Image.open(png_path) as im:
        rgb = im.convert("RGB")
        rgb.save(jpg_path, "JPEG", quality=92)


def copy_card_assets(
    card_ids: set[int],
    script_src: Path,
    pics_src: Path,
    script_dst: Path,
    pics_dst: Path,
    *,
    cardmaker_src: Path | None = None,
    require_pics: bool = False,
) -> tuple[list[str], list[str]]:
    """Returns (fatal_missing, pic_missing). Fatal = missing Lua."""
    fatal: list[str] = []
    pic_missing: list[str] = []
    script_dst.mkdir(parents=True, exist_ok=True)
    pics_dst.mkdir(parents=True, exist_ok=True)
    for cid in sorted(card_ids):
        lua = script_src / f"c{cid}.lua"
        pic = pics_src / f"{cid}.jpg"
        if not lua.is_file():
            fatal.append(f"lua:c{cid}.lua")
        else:
            shutil.copy2(lua, script_dst / lua.name)
        if pic.is_file():
            shutil.copy2(pic, pics_dst / pic.name)
            continue
        if cardmaker_src:
            png = cardmaker_src / f"{cid}.png"
            if png.is_file():
                jpg_out = pics_dst / f"{cid}.jpg"
                try:
                    png_to_jpg(png, jpg_out)
                except ImportError:
                    shutil.copy2(png, pics_dst / f"{cid}.png")
                continue
        pic_missing.append(str(cid))
    if require_pics and pic_missing:
        fatal.extend(f"pic:{cid}.jpg" for cid in pic_missing)
    return fatal, pic_missing


def write_lflist(path: Path, card_ids: set[int], root: Path) -> None:
    """Whitelist lflist: forbid every id from bundled DBs except deck cards."""
    allowed = set(card_ids)
    db_paths: list[Path] = []
    for candidate in (
        root / "cards.cdb",
        root / "expansions" / "cards.cdb",
        root / "expansions" / "cards-unofficial.cdb",
        root / "expansions" / "saint-seiya.cdb",
        path.parent.parent / "saint-seiya-decks.cdb",
    ):
        if candidate.exists():
            db_paths.append(candidate)

    all_ids: set[int] = set()
    for db in dict.fromkeys(db_paths):
        con = sqlite3.connect(str(db))
        try:
            all_ids.update(int(r[0]) for r in con.execute("SELECT id FROM datas"))
        finally:
            con.close()

    forbidden = sorted(i for i in all_ids if i not in allowed)
    allowed_present = sorted(i for i in all_ids if i in allowed)

    lines = [
        "# Auto-generated by tools/publish_saint_seiya_decks_repo.py",
        "# Whitelist: only cards from Bronze Only + Black Saints decks.",
        f"# Allowed cards: {len(allowed_present)}",
        "",
        f"!list {LFLIST_ID} {LFLIST_NAME}",
        "#forbidden",
    ]
    lines.extend(f"{cid} 0" for cid in forbidden)
    lines.append("#allowed (explicit, max 3)")
    lines.extend(f"{cid} 3" for cid in allowed_present)
    lines.append("")
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(lines), encoding="utf-8")


def write_readme(
    path: Path,
    card_ids: set[int],
    by_deck: dict[str, list[int]],
    output: Path,
) -> None:
    deck_lines = "\n".join(
        f"- `{name}`: {len(ids)} unique ids" for name, ids in sorted(by_deck.items())
    )
    id_block = ", ".join(str(i) for i in sorted(card_ids))
    text = f"""# ProjectIgnis — Saint Seiya (Bronze + Black Saints)

EDOPro content pack with **{len(card_ids)}** cards from:

{deck_lines}

Requires a full [Project Ignis / EDOPro](https://github.com/edo9300/edopro) install (official `cards.cdb`, core scripts, etc.).

## Install

Add to `config/user_configs.json` (merge with existing `repos`):

```json
{{
  "repos": [
    {{
      "url": "{PUBLIC_REPO_URL}",
      "repo_name": "Saint Seiya (public)",
      "repo_path": "{CLIENT_REPO_PATH}",
      "data_path": "",
      "script_path": "script",
      "pics_path": "pics",
      "lflist_path": "lflists",
      "should_update": true,
      "should_read": true
    }}
  ]
}}
```

Local folder (no Git): set `"not_git_repo": true`, point `repo_path` at this directory, `"should_update": false`.

Restart the client after the repository finishes syncing (Repositories tab).

## Decks

Import from `decks/`:

- `Saint Seiya - Bronze Only.ydk`
- `Saint Seiya - Black Saints.ydk`

Optional banlist: `lflists/saint-seiya-decks.lflist.conf` (whitelist mode).

## WindBot

Copy into your EDOPro `WindBot/` folder (see `windbot/README.txt`):

- `windbot/Executors/*.dll` → `WindBot/Executors/`
- `windbot/Decks/AI_*.ydk` → `WindBot/Decks/`
- Merge `windbot/bots.json` entries into `WindBot/bots.json` (SSY Bronze Saints + SSY Black Saints)

Requires a WindBot build that loads external executor plugins from `WindBot/Executors/`.

## Regenerate from ProjectIgnis source

```bash
python tools/publish_saint_seiya_decks_repo.py
```

## Card IDs

{id_block}
"""
    path.write_text(text, encoding="utf-8")


def extract_windbot_bots_entries(source: Path) -> list[dict]:
    data = json.loads(source.read_text(encoding="utf-8"))
    if not isinstance(data, list):
        raise RuntimeError(f"Expected bots.json array in {source}")
    entries = [b for b in data if b.get("deck") in WINDBOT_BOT_DECK_KEYS]
    if len(entries) != len(WINDBOT_BOT_DECK_KEYS):
        found = {b.get("deck") for b in entries}
        missing = sorted(WINDBOT_BOT_DECK_KEYS - found)
        raise RuntimeError(f"Missing bots.json entries for deck keys: {', '.join(missing)}")
    return entries


def copy_windbot_bundle(out: Path) -> None:
    """Copy plugin DLLs, AI decks, and Saint Seiya bots.json fragment into out/windbot/."""
    windbot_out = out / "windbot"
    executors_out = windbot_out / "Executors"
    decks_out = windbot_out / "Decks"
    executors_out.mkdir(parents=True, exist_ok=True)
    decks_out.mkdir(parents=True, exist_ok=True)

    src_executors = WINDBOT_ROOT / "Executors"
    missing: list[str] = []
    for name in WINDBOT_EXECUTOR_DLLS:
        src = src_executors / name
        if not src.is_file():
            missing.append(name)
            continue
        shutil.copy2(src, executors_out / name)

    src_decks = WINDBOT_ROOT / "Decks"
    for name in WINDBOT_AI_DECKS:
        src = src_decks / name
        if not src.is_file():
            missing.append(name)
            continue
        shutil.copy2(src, decks_out / name)

    bots_src = WINDBOT_ROOT / "bots.json"
    if not bots_src.is_file():
        missing.append("bots.json")
    else:
        entries = extract_windbot_bots_entries(bots_src)
        (windbot_out / "bots.json").write_text(
            json.dumps(entries, indent=4) + "\n",
            encoding="utf-8",
        )

    if missing:
        raise FileNotFoundError(
            "WindBot assets missing (build executors and ensure AI decks exist):\n  "
            + "\n  ".join(missing)
        )

    (windbot_out / "README.txt").write_text(
        "WindBot bundle for Saint Seiya (Bronze + Black Saints).\n\n"
        "Requires ProjectIgnis/EDOPro WindBot with plugin support (ExecutorBase.dll).\n\n"
        "Install into your game folder (merge, do not replace entire bots.json):\n\n"
        "  1. Copy windbot/Executors/*.dll to WindBot/Executors/\n"
        "  2. Copy windbot/Decks/*.ydk to WindBot/Decks/\n"
        "  3. Merge windbot/bots.json entries into WindBot/bots.json\n"
        "     (append the two objects before the closing ] of the array)\n"
        "  4. Restart EDOPro / WindBot\n\n"
        "Verify log: \"Decks initialized, N found\" increases by 2 and no\n"
        "\"Deck not found\" for SaintSeiyaBronzeOnly / SaintSeiyaBlackSaints.\n",
        encoding="utf-8",
    )


def write_repos_example(path: Path) -> None:
    example = {
        "repos": [
            {
                "url": PUBLIC_REPO_URL,
                "repo_name": "Saint Seiya (public)",
                "repo_path": CLIENT_REPO_PATH,
                "data_path": "",
                "script_path": "script",
                "pics_path": "pics",
                "lflist_path": "lflists",
                "should_update": True,
                "should_read": True,
            }
        ]
    }
    path.write_text(json.dumps(example, indent="\t") + "\n", encoding="utf-8")


def prepare_output_dir(out: Path) -> None:
    """Clear publish artifacts; keep .git when output is a cloned repository."""
    if not out.exists():
        out.mkdir(parents=True)
        return
    if (out / ".git").exists():
        for child in out.iterdir():
            if child.name == ".git":
                continue
            if child.is_dir():
                shutil.rmtree(child)
            else:
                child.unlink()
        return
    shutil.rmtree(out)
    out.mkdir(parents=True)


def main() -> int:
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")

    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument(
        "--output",
        type=Path,
        default=DEFAULT_OUTPUT,
        help=f"Output directory (default: {DEFAULT_OUTPUT.relative_to(ROOT)})",
    )
    p.add_argument(
        "--deck",
        type=Path,
        action="append",
        default=[],
        help="Extra .ydk deck file (repeatable)",
    )
    p.add_argument("--source-cdb", type=Path, default=DEFAULT_SOURCE_CDB)
    p.add_argument("--skip-lflist", action="store_true", help="Skip huge whitelist lflist generation")
    p.add_argument(
        "--require-pics",
        action="store_true",
        help="Fail if pics/{id}.jpg (or cardmaker PNG) is missing",
    )
    p.add_argument(
        "--cardmaker-dir",
        type=Path,
        default=DEFAULT_CARDMAKER_DIR,
        help="Fallback art from sets/cardmaker_output/{id}.png",
    )
    p.add_argument(
        "--skip-windbot",
        action="store_true",
        help="Do not copy WindBot DLLs, AI decks, or bots.json fragment",
    )
    args = p.parse_args()

    deck_paths = list(DEFAULT_DECKS) + args.deck
    for deck in deck_paths:
        if not deck.is_file():
            print(f"error: deck not found: {deck}", file=sys.stderr)
            return 1
    if not args.source_cdb.is_file():
        print(f"error: source cdb not found: {args.source_cdb}", file=sys.stderr)
        return 1

    card_ids, by_deck = collect_deck_ids(deck_paths)
    out = args.output
    prepare_output_dir(out)

    print(f"cards: {len(card_ids)} unique ids from {len(deck_paths)} deck(s)")

    cdb_out = out / "saint-seiya-decks.cdb"
    export_subset_cdb(args.source_cdb, cdb_out, card_ids)
    print(f"wrote: {cdb_out.relative_to(ROOT)}")

    cardmaker = args.cardmaker_dir if args.cardmaker_dir.is_dir() else None
    fatal, pic_missing = copy_card_assets(
        card_ids,
        DEFAULT_SCRIPT_DIR,
        DEFAULT_PICS_DIR,
        out / "script" / "unofficial",
        out / "pics",
        cardmaker_src=cardmaker,
        require_pics=args.require_pics,
    )
    if fatal:
        print("error: missing assets:", ", ".join(fatal), file=sys.stderr)
        return 1
    pic_count = len(card_ids) - len(pic_missing)
    print(f"copied: {len(card_ids)} lua, {pic_count} pics")
    if pic_missing:
        missing_path = out / "pics" / "MISSING.txt"
        missing_path.write_text(
            "\n".join(pic_missing) + "\n",
            encoding="utf-8",
        )
        print(
            f"warning: {len(pic_missing)} pics missing — add pics/{{id}}.jpg "
            f"or render with sets/generate_cardmaker_from_sets_sqlite.py (see pics/README.txt)",
            file=sys.stderr,
        )
        (out / "pics" / "README.txt").write_text(
            "EDOPro expects pics/{card_id}.jpg for deck art in-game.\n"
            "This bundle was built without local JPGs.\n\n"
            "Add artwork:\n"
            "  1. Place {id}.jpg files here, or\n"
            "  2. Run CardMaker then copy PNGs:\n"
            "     python sets/generate_cardmaker_from_sets_sqlite.py --card-id ID\n"
            "     (re-run publish with --cardmaker-dir if PNGs exist)\n\n"
            f"Missing IDs listed in MISSING.txt ({len(pic_missing)} cards).\n",
            encoding="utf-8",
        )

    init_path = out / "script" / "init.lua"
    init_path.parent.mkdir(parents=True, exist_ok=True)
    init_path.write_text(
        extract_archetype_init_lua(ROOT / "script" / "archetype_setcode_constants.lua"),
        encoding="utf-8",
    )
    print(f"wrote: {init_path.relative_to(ROOT)}")

    strings_path = out / "strings.conf"
    strings_path.write_text(extract_strings_conf(ROOT / "config" / "strings.conf"), encoding="utf-8")
    print(f"wrote: {strings_path.relative_to(ROOT)}")

    decks_dir = out / "decks"
    decks_dir.mkdir(parents=True, exist_ok=True)
    for deck in deck_paths:
        shutil.copy2(deck, decks_dir / deck.name)
    print(f"copied: {len(deck_paths)} deck(s) -> {decks_dir.relative_to(ROOT)}")

    manifest = {
        "generated_by": "tools/publish_saint_seiya_decks_repo.py",
        "source_cdb": str(args.source_cdb.relative_to(ROOT)),
        "card_count": len(card_ids),
        "card_ids": sorted(card_ids),
        "decks": by_deck,
    }
    manifest_path = out / "deck-manifest.json"
    manifest_path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print(f"wrote: {manifest_path.relative_to(ROOT)}")

    if not args.skip_lflist:
        lflist_path = out / "lflists" / "saint-seiya-decks.lflist.conf"
        write_lflist(lflist_path, card_ids, ROOT)
        print(f"wrote: {lflist_path.relative_to(ROOT)}")

    if not args.skip_windbot:
        try:
            copy_windbot_bundle(out)
        except FileNotFoundError as exc:
            print(f"error: {exc}", file=sys.stderr)
            return 1
        print(
            f"copied: windbot/ ({len(WINDBOT_EXECUTOR_DLLS)} dlls, "
            f"{len(WINDBOT_AI_DECKS)} AI decks, bots.json fragment)"
        )

    write_readme(out / "README.md", card_ids, by_deck, out)
    write_repos_example(out / "user_configs.repos.example.json")
    print(f"wrote: {(out / 'README.md').relative_to(ROOT)}")
    print(f"done: {out.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

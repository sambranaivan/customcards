"""CLI — compact duel summary from .yrpX replays."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

from .aggregators import analyze_replay


def _default_output_dir() -> Path:
    return Path(__file__).resolve().parents[2] / "stats"


def _default_cdb() -> Path:
    return Path(__file__).resolve().parents[2] / "expansions" / "saint-seiya.cdb"


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description=(
            "Summarize EDOPro .yrpX replays: winner, play-by-play, final LP and field."
        )
    )
    parser.add_argument(
        "replays",
        nargs="+",
        help="Replay file(s), directory, or glob pattern",
    )
    parser.add_argument(
        "-o",
        "--output",
        type=Path,
        default=None,
        help="Output directory (default: ./stats/)",
    )
    parser.add_argument(
        "--cdb",
        type=Path,
        default=None,
        help="Card database (default: expansions/saint-seiya.cdb)",
    )
    parser.add_argument(
        "--stdout",
        action="store_true",
        help="Print JSON to stdout",
    )
    args = parser.parse_args(argv)

    paths: list[Path] = []
    for arg in args.replays:
        if "*" in arg or "?" in arg:
            paths.extend(sorted(Path().glob(arg)))
            continue
        p = Path(arg)
        if p.is_dir():
            paths.extend(sorted(p.glob("*.yrpX")))
            paths.extend(sorted(p.glob("*.yrp")))
        else:
            paths.append(p)

    if not paths:
        print("No replay files found.", file=sys.stderr)
        return 1

    cdb = args.cdb or _default_cdb()
    output_dir = args.output or _default_output_dir()
    if not args.stdout:
        output_dir.mkdir(parents=True, exist_ok=True)

    index: list[dict] = []
    failed = 0

    for path in paths:
        result = analyze_replay(path, cdb_path=cdb)
        if args.stdout:
            print(json.dumps(result, indent=2, ensure_ascii=False))
        else:
            out_path = output_dir / f"{path.stem}.json"
            out_path.write_text(
                json.dumps(result, indent=2, ensure_ascii=False),
                encoding="utf-8",
            )
            print(f"Wrote {out_path}")

        if not args.stdout:
            row = {
                "source": result.get("source", str(path)),
                "status": result.get("status"),
            }
            if result.get("status") == "ok":
                row["winner"] = result.get("winner")
                row["play_count"] = len(result.get("plays", []))
            else:
                row["error"] = result.get("error")
                failed += 1
            index.append(row)

    if not args.stdout and index:
        (output_dir / "index.json").write_text(
            json.dumps(index, indent=2, ensure_ascii=False),
            encoding="utf-8",
        )

    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())

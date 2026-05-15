"""Resolve card passcodes via a single .cdb (default: saint-seiya.cdb)."""

from __future__ import annotations

import sqlite3
from pathlib import Path

DEFAULT_CDB = Path(__file__).resolve().parents[2] / "expansions" / "saint-seiya.cdb"


class CardLookup:
    """Lazy SQLite lookup — one connection, in-memory cache only."""

    def __init__(self, cdb_path: Path | str | None = None):
        self._cache: dict[int, str] = {}
        self._path = Path(cdb_path) if cdb_path else DEFAULT_CDB
        self._conn: sqlite3.Connection | None = None

    def _connection(self) -> sqlite3.Connection | None:
        if self._conn is not None:
            return self._conn
        if not self._path.is_file():
            return None
        self._conn = sqlite3.connect(f"file:{self._path}?mode=ro", uri=True)
        return self._conn

    def close(self) -> None:
        if self._conn is not None:
            self._conn.close()
            self._conn = None

    def __enter__(self) -> CardLookup:
        return self

    def __exit__(self, *args: object) -> None:
        self.close()

    def name(self, code: int) -> str:
        if not code:
            return "?"
        if code in self._cache:
            return self._cache[code]
        conn = self._connection()
        if conn is not None:
            try:
                row = conn.execute(
                    "SELECT name FROM texts WHERE id = ?", (code,)
                ).fetchone()
                if row:
                    self._cache[code] = row[0]
                    return row[0]
            except sqlite3.Error:
                pass
        self._cache[code] = str(code)
        return str(code)

import base64
import json
import os
import sqlite3
import time
import urllib.error
import urllib.request
from dataclasses import dataclass
from pathlib import Path


REPO_ROOT = Path(r"c:\ProjectIgnis")
DB_PATH = REPO_ROOT / "sets" / "sets.sqlite3"
OUT_DIR = REPO_ROOT / "api_output"

OPENAI_API_KEY_ENV = "OPENAI_API_KEY"
OPENAI_IMAGES_URL = "https://api.openai.com/v1/images/generations"

# As requested
MODEL = "gpt-image-2"
SIZE = "1024x1024"
QUALITY = "low"
N = 1


@dataclass(frozen=True)
class Card:
    card_id: int
    image_prompt: str


def _get_api_key() -> str:
    key = (os.environ.get(OPENAI_API_KEY_ENV) or "").strip()
    if not key:
        raise SystemExit(f"Missing env var: {OPENAI_API_KEY_ENV}")
    return key


def _fetch_cards(conn: sqlite3.Connection) -> list[Card]:
    conn.row_factory = sqlite3.Row
    rows = conn.execute(
        """
        SELECT card_id, image_prompt
        FROM cards
        WHERE image_prompt IS NOT NULL AND trim(image_prompt) <> ''
        ORDER BY card_id
        """
    ).fetchall()
    return [Card(card_id=int(r["card_id"]), image_prompt=str(r["image_prompt"])) for r in rows]


def _post_json(url: str, payload: dict, *, api_key: str, timeout_s: int = 120) -> dict:
    body = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(url, data=body, method="POST")
    req.add_header("Authorization", f"Bearer {api_key}")
    req.add_header("Content-Type", "application/json")

    try:
        with urllib.request.urlopen(req, timeout=timeout_s) as resp:
            raw = resp.read().decode("utf-8")
        return json.loads(raw)
    except urllib.error.HTTPError as e:
        body_text = ""
        try:
            body_text = e.read().decode("utf-8", errors="replace")
        except Exception:
            pass
        err = urllib.error.HTTPError(e.url, e.code, e.msg, e.hdrs, e.fp)  # type: ignore[arg-type]
        setattr(err, "_body_text", body_text)
        raise err


def _save_b64_png(b64_json: str, out_path: Path) -> None:
    png_bytes = base64.b64decode(b64_json)
    tmp = out_path.with_suffix(".tmp")
    tmp.write_bytes(png_bytes)
    tmp.replace(out_path)


def main() -> None:
    api_key = _get_api_key()
    OUT_DIR.mkdir(parents=True, exist_ok=True)

    conn = sqlite3.connect(DB_PATH)
    try:
        cards = _fetch_cards(conn)
    finally:
        conn.close()

    total = len(cards)
    if total == 0:
        print("No cards with image_prompt found.")
        return

    generated = 0
    skipped_existing = 0
    errors = 0

    for idx, card in enumerate(cards, start=1):
        out_path = OUT_DIR / f"{card.card_id}.png"

        if out_path.exists():
            skipped_existing += 1
            print(
                f"[{idx}/{total}] SKIP card_id={card.card_id} (exists) | "
                f"generated={generated} skipped_existing={skipped_existing} errors={errors}"
            )
            continue

        payload = {
            "model": MODEL,
            "prompt": card.image_prompt,
            "n": N,
            "size": SIZE,
            "quality": QUALITY,
        }

        ok = False
        for attempt in range(1, 6):
            try:
                resp = _post_json(OPENAI_IMAGES_URL, payload, api_key=api_key)
                data = resp.get("data") or []
                if not data or not isinstance(data, list) or "b64_json" not in data[0]:
                    raise RuntimeError(f"Unexpected response shape for card_id={card.card_id}")
                _save_b64_png(str(data[0]["b64_json"]), out_path)
                generated += 1
                ok = True
                break
            except urllib.error.HTTPError as e:
                status = getattr(e, "code", None)
                retryable = status in (408, 409, 429, 500, 502, 503, 504)
                err_body = getattr(e, "_body_text", "") or ""

                if status == 403 and (
                    "must be verified" in err_body.lower() or "organization" in err_body.lower()
                ):
                    raise SystemExit(
                        "OpenAI returned 403 for model access. "
                        "Your organization likely needs verification to use `gpt-image-2`."
                    )

                if not retryable or attempt == 5:
                    errors += 1
                    print(
                        f"HTTPError card_id={card.card_id} status={status} attempt={attempt} "
                        f"body={err_body[:400]}"
                    )
                    break

                sleep_s = min(30, 2**attempt)
                print(f"Retry card_id={card.card_id} status={status} attempt={attempt} sleep={sleep_s}s")
                time.sleep(sleep_s)
            except Exception as e:
                if attempt == 5:
                    errors += 1
                    print(f"Error card_id={card.card_id} attempt={attempt} err={e}")
                    break
                sleep_s = min(30, 2**attempt)
                print(f"Retry card_id={card.card_id} attempt={attempt} err={e} sleep={sleep_s}s")
                time.sleep(sleep_s)

        if ok:
            print(
                f"[{idx}/{total}] OK   card_id={card.card_id} -> {out_path} | "
                f"generated={generated} skipped_existing={skipped_existing} errors={errors}"
            )
        else:
            print(
                f"[{idx}/{total}] ERR  card_id={card.card_id} | "
                f"generated={generated} skipped_existing={skipped_existing} errors={errors}"
            )

    print(
        f"Done total={total} generated={generated} skipped_existing={skipped_existing} "
        f"errors={errors} out_dir={OUT_DIR}"
    )


if __name__ == "__main__":
    main()


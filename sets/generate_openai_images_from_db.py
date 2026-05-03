import base64
import argparse
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
PROMPTS_DIR = OUT_DIR / "prompts"

OPENAI_API_KEY_ENV = "OPENAI_API_KEY"
OPENAI_IMAGES_URL = "https://api.openai.com/v1/images/generations"
OPENAI_RESPONSES_URL = "https://api.openai.com/v1/responses"

# As requested
MODEL = "gpt-image-2"
SIZE = "1024x1024"
QUALITY = "low"
N = 1

# Reasoning step (prompt optimizer)
REASONING_MODEL = "gpt-5.4-mini"
DEFAULT_THINKING = "low"  # low | medium | high | off
DEFAULT_WEBSEARCH = True


@dataclass(frozen=True)
class Card:
    card_id: int
    name: str


def _get_api_key() -> str:
    key = (os.environ.get(OPENAI_API_KEY_ENV) or "").strip()
    if not key:
        raise SystemExit(f"Missing env var: {OPENAI_API_KEY_ENV}")
    return key


def _fetch_cards(conn: sqlite3.Connection) -> list[Card]:
    conn.row_factory = sqlite3.Row
    rows = conn.execute(
        """
        SELECT
          card_id,
          COALESCE(NULLIF(TRIM(name_es), ''), NULLIF(TRIM(name_en), ''), '') AS name
        FROM cards
        WHERE COALESCE(NULLIF(TRIM(name_es), ''), NULLIF(TRIM(name_en), ''), '') <> ''
        ORDER BY card_id
        """
    ).fetchall()
    return [Card(card_id=int(r["card_id"]), name=str(r["name"])) for r in rows]


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


def _extract_responses_output_text(resp: dict) -> str:
    """
    Best-effort extractor for Responses API plain text output.
    We accept multiple possible shapes to be robust across SDK/raw responses.
    """
    # Some client wrappers expose output_text directly.
    if isinstance(resp.get("output_text"), str) and resp["output_text"].strip():
        return resp["output_text"].strip()

    out = resp.get("output")
    if not isinstance(out, list):
        return ""

    chunks: list[str] = []
    for item in out:
        if not isinstance(item, dict):
            continue
        if item.get("type") != "message":
            continue
        content = item.get("content")
        if not isinstance(content, list):
            continue
        for part in content:
            if not isinstance(part, dict):
                continue
            # Typical: {"type":"output_text","text":"..."}
            if part.get("type") in ("output_text", "text") and isinstance(part.get("text"), str):
                t = part["text"].strip()
                if t:
                    chunks.append(t)
    return "\n".join(chunks).strip()


def _improve_prompt_with_reasoning(
    *,
    api_key: str,
    idea: str,
    thinking: str,
    websearch: bool,
    timeout_s: int = 120,
) -> str:
    instruction = f"""
Use web search to confirm/refresh canon visual details (colors, armor version, setting, key motifs)
for Saint Seiya-related subjects when needed, then convert this idea into a final prompt for image generation.

Requirements:
- TCG art Style
- anime 90s modernized
- Full body (when applicable; for items like armor/cloth, show the item clearly)
- Heroic pose (or iconic display for non-character items)
- Detailed metallic armor but not overdesigned
- Cosmic background
- Ethereal spirit in background corresponding to the character 
- No text, no watermark
- Prompt in English
- Do not explain anything; return ONLY the final prompt

Idea:
{idea}
""".strip()

    payload: dict = {
        "model": REASONING_MODEL,
        "reasoning": {"effort": thinking},
        "input": instruction,
    }
    if websearch:
        payload["tools"] = [{"type": "web_search_preview"}]
    resp = _post_json(OPENAI_RESPONSES_URL, payload, api_key=api_key, timeout_s=timeout_s)
    out = _extract_responses_output_text(resp)
    return out.strip()


def _write_text_atomic(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(path.suffix + ".tmp")
    tmp.write_text(text, encoding="utf-8")
    tmp.replace(path)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Generate images from cards.name_es/name_en using a reasoning step (optional) + OpenAI Images API."
    )
    parser.add_argument(
        "--websearch",
        dest="websearch",
        action="store_true",
        default=DEFAULT_WEBSEARCH,
        help="Enable web search tool in the reasoning step (default).",
    )
    parser.add_argument(
        "--no-websearch",
        dest="websearch",
        action="store_false",
        help="Disable web search tool in the reasoning step.",
    )
    parser.add_argument(
        "--thinking",
        choices=["off", "low", "medium", "high"],
        default=DEFAULT_THINKING,
        help="Reasoning effort for the prompt-optimizer model. Use 'off' to skip the reasoning step entirely.",
    )
    args = parser.parse_args()

    api_key = _get_api_key()
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    PROMPTS_DIR.mkdir(parents=True, exist_ok=True)

    conn = sqlite3.connect(DB_PATH)
    try:
        cards = _fetch_cards(conn)
    finally:
        conn.close()

    total = len(cards)
    if total == 0:
        print("No cards with name_es/name_en found.")
        return

    generated = 0
    skipped_existing = 0
    errors = 0

    for idx, card in enumerate(cards, start=1):
        out_path = OUT_DIR / f"{card.card_id}.png"
        prompt_path = PROMPTS_DIR / f"{card.card_id}.txt"

        if out_path.exists():
            skipped_existing += 1
            print(
                f"[{idx}/{total}] SKIP card_id={card.card_id} (exists) | "
                f"generated={generated} skipped_existing={skipped_existing} errors={errors}"
            )
            continue

        # Step 1: reasoning model rewrites/optimizes the prompt.
        final_prompt = ""
        if args.thinking == "off":
            card_name = card.name.strip()
            final_prompt = (
                f"TCG art style, {card_name} from Saint Seiya, ratio 1:1, "
                "no text, no artifacts, no frames"
            )
        else:
            if prompt_path.exists():
                final_prompt = prompt_path.read_text(encoding="utf-8").strip()

            if not final_prompt:
                for attempt in range(1, 4):
                    try:
                        final_prompt = _improve_prompt_with_reasoning(
                            api_key=api_key,
                            idea=card.name,
                            thinking=args.thinking,
                            websearch=args.websearch,
                        )
                        if not final_prompt:
                            raise RuntimeError("Empty prompt from reasoning step")
                        _write_text_atomic(prompt_path, final_prompt)
                        print(f"[{idx}/{total}] PROMPT card_id={card.card_id} -> {prompt_path}")
                        break
                    except urllib.error.HTTPError as e:
                        status = getattr(e, "code", None)
                        err_body = getattr(e, "_body_text", "") or ""
                        # For reasoning, fail fast on auth/config issues.
                        if attempt == 3 or status not in (408, 409, 429, 500, 502, 503, 504):
                            errors += 1
                            print(
                                f"[{idx}/{total}] ERR  card_id={card.card_id} reasoning_status={status} "
                                f"attempt={attempt} body={err_body[:400]}"
                            )
                            final_prompt = ""
                            break
                        sleep_s = min(20, 2**attempt)
                        print(
                            f"[{idx}/{total}] RETRY card_id={card.card_id} reasoning_status={status} "
                            f"attempt={attempt} sleep={sleep_s}s"
                        )
                        time.sleep(sleep_s)
                    except Exception as e:
                        if attempt == 3:
                            errors += 1
                            print(f"[{idx}/{total}] ERR  card_id={card.card_id} reasoning_attempt={attempt} err={e}")
                            final_prompt = ""
                            break
                        sleep_s = min(20, 2**attempt)
                        print(
                            f"[{idx}/{total}] RETRY card_id={card.card_id} reasoning_attempt={attempt} err={e} sleep={sleep_s}s"
                        )
                        time.sleep(sleep_s)

        if not final_prompt:
            # If reasoning fails, do not generate an image to avoid wasting calls with a bad prompt.
            print(
                f"[{idx}/{total}] ERR  card_id={card.card_id} (no final prompt) | "
                f"generated={generated} skipped_existing={skipped_existing} errors={errors}"
            )
            continue

        payload = {
            "model": MODEL,
            "prompt": final_prompt,
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


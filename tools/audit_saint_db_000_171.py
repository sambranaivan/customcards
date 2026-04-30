import sqlite3


def main() -> None:
    start = 922100000
    end = 922100171
    ids = list(range(start, end + 1))

    conn = sqlite3.connect("expansions/cards-unofficial.cdb")
    c = conn.cursor()

    c.execute("SELECT id FROM datas WHERE id BETWEEN ? AND ? ORDER BY id", (start, end))
    datas = {r[0] for r in c.fetchall()}

    c.execute("SELECT id, desc FROM texts WHERE id BETWEEN ? AND ? ORDER BY id", (start, end))
    texts = {r[0]: (r[1] or "") for r in c.fetchall()}

    missing_datas = [i for i in ids if i not in datas]
    missing_texts = [i for i in ids if i not in texts]
    placeholders = [i for i in ids if i in texts and texts[i].strip() == "Custom card (scripted)."]
    empty_desc = [i for i in ids if i in texts and not texts[i].strip()]

    print(f"range: {start}..{end} ({len(ids)} ids)")
    print(f"missing_datas: {len(missing_datas)}")
    if missing_datas:
        print(missing_datas)
    print(f"missing_texts: {len(missing_texts)}")
    if missing_texts:
        print(missing_texts)
    print(f"placeholder_desc: {len(placeholders)}")
    if placeholders:
        print(placeholders)
    print(f"empty_desc: {len(empty_desc)}")
    if empty_desc:
        print(empty_desc)

    conn.close()


if __name__ == "__main__":
    main()


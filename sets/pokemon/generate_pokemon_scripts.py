import sqlite3
import sys
from pathlib import Path
import import_pokemon_set_from_excel as imp

def main():
    print("Iniciando generador de scripts Lua...")
    
    script_dir = Path(__file__).resolve().parent
    repo_root = script_dir.parents[1]

    db_path = repo_root / "expansions" / "cards-unofficial.cdb"
    if not db_path.exists():
        print(f"Error: No se encontro la BD {db_path}")
        sys.exit(1)
        
    conn = sqlite3.connect(str(db_path))
    c = conn.cursor()
    c.execute("SELECT datas.id, texts.name, texts.desc FROM datas JOIN texts ON datas.id = texts.id WHERE datas.id >= 920000000 AND datas.id < 923000000")
    cards = c.fetchall()
    
    scripts_dir = repo_root / "script" / "unofficial"
    scripts_dir.mkdir(parents=True, exist_ok=True)
    generated_count = 0
    for cid, name, desc in cards:
        script_path = scripts_dir / f"c{cid}.lua"
        if not script_path.exists(): # Solo generamos si no existe
            desc_commented = "\n".join(f"    -- {line}" for line in (desc or "").splitlines())
            content = f"-- {name}\nlocal s,id=GetID()\nfunction s.initial_effect(c)\n    -- TODO: Programar efecto\n{desc_commented}\nend\n"
            with open(script_path, "w", encoding="utf-8") as f:
                f.write(content)
            generated_count += 1
            
    conn.close()
    print(f"✅ Se generaron {generated_count}/379 scripts .lua.")
    
    print("Extrayendo mapas de setcodes desde Excel...")
    excel_path = script_dir / "Pokemon_YGO_Todas_Las_Cartas.xlsx"
    wb = imp.load_workbook(str(excel_path), data_only=True)
    monsters = imp.read_sheet_rows(wb["Monstruos"], 1, 12)
    spells = imp.read_sheet_rows(wb["Spells"], 1, 6)
    traps = imp.read_sheet_rows(wb["Traps"], 1, 6)

    setcode_rows = []
    setcode_rows.extend((row[1], row[9]) for row in monsters)
    setcode_rows.extend((row[1], row[4]) for row in spells)
    setcode_rows.extend((row[1], row[4]) for row in traps)

    setcode_map = imp.build_setcode_map(setcode_rows)
    
    setcodes_out_path = script_dir / "pokemon_setcodes.txt"
    with open(setcodes_out_path, "w", encoding="utf-8") as f:
        # Formateando de manera que puedan pegarse en lua
        f.write("-- Pokemon Archetypes\n")
        
        longest_key = max((len(k) for k in setcode_map.keys()), default=0) if setcode_map else 0
        fmt_string = "SET_{:<" + str(longest_key+5) + "} = {}"
        
        for k, v in setcode_map.items():
            # Limpieza para nombre de variable válido en Lua
            clean_name = k.upper().replace(" ", "_").replace("-", "_").replace(".", "").replace("'", "")
            f.write(fmt_string.format(clean_name, hex(v)) + "\n")
            
    print(f"✅ Se extrajeron {len(setcode_map)} setcodes y se guardaron en {setcodes_out_path}")

if __name__ == "__main__":
    main()

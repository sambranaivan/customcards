import sqlite3
import os
import sys
import import_pokemon_set_from_excel as imp

def main():
    print("Iniciando generador de scripts Lua...")
    
    db_path = "expansions/cards-unofficial.cdb"
    if not os.path.exists(db_path):
        print(f"Error: No se encontro la BD {db_path}")
        sys.exit(1)
        
    conn = sqlite3.connect(db_path)
    c = conn.cursor()
    c.execute("SELECT datas.id, texts.name, texts.desc FROM datas JOIN texts ON datas.id = texts.id WHERE datas.id >= 920000000 AND datas.id < 923000000")
    cards = c.fetchall()
    
    os.makedirs("script/unofficial", exist_ok=True)
    generated_count = 0
    for cid, name, desc in cards:
        script_path = f"script/unofficial/c{cid}.lua"
        if not os.path.exists(script_path): # Solo generamos si no existe
            desc_commented = "\n".join(f"    -- {line}" for line in (desc or "").splitlines())
            content = f"-- {name}\nlocal s,id=GetID()\nfunction s.initial_effect(c)\n    -- TODO: Programar efecto\n{desc_commented}\nend\n"
            with open(script_path, "w", encoding="utf-8") as f:
                f.write(content)
            generated_count += 1
            
    conn.close()
    print(f"✅ Se generaron {generated_count}/379 scripts .lua.")
    
    print("Extrayendo mapas de setcodes desde Excel...")
    wb = imp.load_workbook("Pokemon_YGO_Todas_Las_Cartas.xlsx", data_only=True)
    monsters = imp.read_sheet_rows(wb["Monstruos"], 1, 12)
    spells = imp.read_sheet_rows(wb["Spells"], 1, 6)
    traps = imp.read_sheet_rows(wb["Traps"], 1, 6)

    setcode_rows = []
    setcode_rows.extend((row[1], row[9]) for row in monsters)
    setcode_rows.extend((row[1], row[4]) for row in spells)
    setcode_rows.extend((row[1], row[4]) for row in traps)

    setcode_map = imp.build_setcode_map(setcode_rows)
    
    with open("pokemon_setcodes.txt", "w", encoding="utf-8") as f:
        # Formateando de manera que puedan pegarse en lua
        f.write("-- Pokemon Archetypes\n")
        
        longest_key = max((len(k) for k in setcode_map.keys()), default=0) if setcode_map else 0
        fmt_string = "SET_{:<" + str(longest_key+5) + "} = {}"
        
        for k, v in setcode_map.items():
            # Limpieza para nombre de variable válido en Lua
            clean_name = k.upper().replace(" ", "_").replace("-", "_").replace(".", "").replace("'", "")
            f.write(fmt_string.format(clean_name, hex(v)) + "\n")
            
    print(f"✅ Se extrajeron {len(setcode_map)} setcodes y se guardaron en pokemon_setcodes.txt")

if __name__ == "__main__":
    main()

import os

try:
    with open('pokemon_setcodes.txt', 'r', encoding='utf-8') as f:
        lines = f.readlines()
        
    out_lines = []
    for line in lines:
        if line.startswith('SET_'):
            parts = line.strip().split('=')
            set_var = parts[0].strip().replace('SET_', '')
            hex_val = parts[1].strip()
            name = set_var.replace('_', ' ').title()
            out_lines.append(f"!setname {hex_val} {name}\n")
            
    content = "".join(out_lines)
    
    # Append to Main strings.conf
    main_conf = 'config/strings.conf'
    if os.path.exists(main_conf):
        with open(main_conf, 'a', encoding='utf-8') as f:
            f.write("\n# Pokemon Archetypes\n")
            f.write(content)
            
    # Append to Spanish strings.conf
    es_conf = 'config/languages/Español/strings.conf'
    if os.path.exists(es_conf):
        with open(es_conf, 'a', encoding='utf-8') as f:
            f.write("\n# Pokemon Archetypes\n")
            f.write(content)
            
    print("¡Strings actualizados con éxito!")
except Exception as e:
    print(f"Error: {e}") 

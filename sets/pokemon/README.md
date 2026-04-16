## Set Pokémon

Archivos de trabajo del set Pokémon (fuente y utilidades).

- **Fuente**: `Pokemon_YGO_Todas_Las_Cartas.xlsx`
- **Import a la DB**: `import_pokemon_set_from_excel.py` (escribe en `expansions/cards-unofficial.cdb`)
- **Generación de placeholders Lua + setcodes**: `generate_pokemon_scripts.py`
- **Setcodes exportados**: `pokemon_setcodes.txt`
- **Actualizar strings.conf**: `update_strings.py`

Ejecución típica (desde la raíz del repo):

```bash
python sets/pokemon/import_pokemon_set_from_excel.py
python sets/pokemon/generate_pokemon_scripts.py
python sets/pokemon/update_strings.py
```


# Saint Seiya — Structure Decks y Booster Packs

Plan de **productos jugables** (Structure Deck + Booster mensual) sobre el bloque de IDs custom **`922100000`–`922100302`** y expansiones futuras.

---

## Convenciones

| Concepto | Detalle |
|----------|---------|
| **Base de datos de release** | `expansions/saint-seiya.cdb` (tablas `datas` / `texts`) |
| **Scripts** | `script/unofficial/c{ID}.lua` |
| **Metadatos de diseño** | `sets/sets.sqlite3` (tabla `cards`, campo `archetypes_json`) |
| **Normalización arquetipos ↔ setcode** | `tools/normalize_saint_seiya_archetypes.py` (alinea `-- Archetypes:` en Lua con `datas.setcode` y `archetypes_json`) |

### Arquetipos relevantes (Silver / Envoy)

- **Silver Saint Synchro**: llevan `Silver Saint` en el header; **no** llevan `Envoy of the Pope` salvo que la carta sea explícitamente Envoy.
- **Silver Saint no-Synchro “Envoy”**: llevan **`Silver Saint` + `Envoy of the Pope`** para que las **Silver Cloth** (`SET_SILVER_SAINT` en `EFFECT_EQUIP_LIMIT`) equipen tanto a Synchros como a Envoys.
- **Envoy que no son Silver** (p. ej. **Ghost Saint**): solo `Envoy of the Pope` + su sub-arquetipo; **no** se fuerza `Silver Saint`.

---

## Inventario por familia (IDs actuales)

Rangos orientativos según scripts `c922100*.lua`:

| Familia | Rango / IDs | Notas |
|---------|-------------|--------|
| Bronze core + secundarios | `922100000`–`922100011` | Cinco bronce + soporte |
| Bronze Cloth | `922100041`–`922100050` | |
| Silver Cloth | `922100051`–`922100066` | Equip “solo a Silver Saint” (incluye Envoys Silver) |
| Gold Cloth | `922100067`–`922100078` | |
| Motor Santuario / spells | `922100079`–`922100086` | Campo, Raise Cosmos, Golden Inheritance, etc. |
| God Warrior (Asgard) | `922100172`–`922100189` (subset) | Incluye Palace of Valhalla, etc. |
| Envoy / Pope engine | `922100105`–`922100142` (subset) | Pope Ares, Mandates, Envoys |
| Specter | `922100195`–`922100204` | |
| Renegade | `922100205`–`922100210` | |
| Marine General | `922100223`–`922100229` | |
| Poseidón + Pilares | varios (`922100237`+, etc.) | |
| Meta | `922100268`–`922100302` | |

Para el siguiente bloque de cartas nuevas, reservar IDs consecutivos (p. ej. `922100303+`) y volver a ejecutar migración/upsert según tu flujo (`tools/migrate_saint_seiya_cdb.py`, insert scripts, etc.).

---

## Calendario sugerido (mes a mes)

Cada mes: **1 Structure Deck** (mazo listo para jugar) + **1 Booster** (pool de soporte / reprints / Meta).

### Mes 1 — SD01: **Sanctuary Awakening** (Bronze + Cloth)

| Producto | Contenido sugerido |
|----------|---------------------|
| **Structure Deck** | Bronze Saints (`922100000`–`922100005` + extensores), Bronze Cloth `922100041`–`922100050`, campo Reforged `922100080`, Inherited Cosmos `922100081`, Galactic Tournament `922100083`, Athena's Shield `922100086` |
| **Booster SAN-01** | Reprints motor: Sanctuary base `922100079`, Athena's Vanguard `922100082`, Sanctuary Assassination `922100084`; picks desde Meta `922100268`–`922100302` |

### Mes 2 — SD02: **Silver Crusade**

| Producto | Contenido sugerido |
|----------|---------------------|
| **Structure Deck** | Silver Saint monsters (Synchro + líneas de apoyo), Silver Cloth `922100051`–`922100066`, spells que enlazan Silver↔Bronze |
| **Booster SIL-01** | Más Silver + tech; Meta selective |

### Mes 3 — SD03: **Gold Zodiac Toolbox**

| Producto | Contenido sugerido |
|----------|---------------------|
| **Structure Deck** | Gold Saint Extra toolbox, Gold Cloth `922100067`–`922100078`, **Golden Inheritance** `922100085` |
| **Booster GOLD-01** | Soporte Rank 8 / materials / recuperación |

### Mes 4 — SD04: **Asgard (God Warrior)**

| Producto | Contenido sugerido |
|----------|---------------------|
| **Structure Deck** | Pool God Warrior (incl. **Palace of Valhalla** `922100172` y piezas del arco) |
| **Booster ASG-01** | Consistencia de campo + Zafiros / frost (según diseño) |

### Mes 5 — SD05: **Poseidon — Pillars**

| Producto | Contenido sugerido |
|----------|---------------------|
| **Structure Deck** | Marine Generals, Pilares, cartas de columna, boss Poseidón |
| **Booster SEA-01** | Turbo pillars / defensa de columnas |

### Mes 6 — SD06: **Hades — Threshold**

| Producto | Contenido sugerido |
|----------|---------------------|
| **Structure Deck** | Specter `922100195`–`922100204`, Renegade `922100205`–`922100210`, motor GY |
| **Booster HAD-01** | Soporte umbral / anti-banish + Meta |

---

## Listas de verificación antes de “lanzar”

1. **Lua**: `-- Archetypes:` correcto por carta (especialmente Silver vs Envoy).
2. **CDB**: ejecutar `python tools/normalize_saint_seiya_archetypes.py` tras cambios masivos en headers.
3. **Sets DB**: `sets.sqlite3` queda alineado por el mismo script (`archetypes_json`).
4. **Decklists**: exportar `.ydk` por producto (main 40, extra 15, side 15) cuando definas ratios finales.
5. **Lista de formato** (opcional): si usás whitelist, regenerar `lflist` con el rango completo del release (no solo `922100000`–`922100171`).

---

## Próximos IDs

Reservar explícitamente el siguiente bloque para no pisar cartas existentes, por ejemplo:

- **Wave 2**: `922100303`–`922100399` (ajustar al máximo real en repo cuando exista).

---

*Documento generado para planificación de productos; las listas exactas de cada Structure/Booster pueden refinarse según balance y disponibilidad de arte.*

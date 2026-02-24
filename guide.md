# Guía para Crear una Carta Nueva en Project Ignis (EDOPro)

Crear una carta personalizada en EDOPro requiere tres componentes: una entrada en la base de datos, un script Lua y opcionalmente una imagen. Esta guía detalla cada paso.

---

## Resumen de Archivos Necesarios

| Componente | Ubicación | Formato |
|---|---|---|
| Base de datos | `expansions/cards-unofficial.cdb` | SQLite (tablas `datas` y `texts`) |
| Script Lua | `script/unofficial/c{ID}.lua` | Lua |
| Imagen (opcional) | `pics/{ID}.jpg` | JPG 177x254 px (o proporcional) |

---

## Paso 1: Elegir un ID Único

Las cartas **unofficial** utilizan IDs a partir de `100000000`. Consulta el último ID usado para evitar colisiones:

```sql
SELECT MAX(id) FROM datas WHERE id >= 100000000;
```

Usa el siguiente número disponible como ID de tu carta. Ejemplo: `100006000`.

---

## Paso 2: Crear la Entrada en la Base de Datos

La base de datos SQLite tiene dos tablas que debes poblar.

### Tabla `datas` — Datos Numéricos de la Carta

```sql
INSERT INTO datas (id, ot, alias, setcode, type, atk, def, level, race, attribute, category)
VALUES (100006000, 1, 0, 0, 17, 2500, 2000, 4, 2, 32, 0);
```

#### Referencia de Columnas

| Columna | Descripción | Ejemplo |
|---|---|---|
| `id` | ID único de la carta | `100006000` |
| `ot` | Formato permitido: 1=OCG, 2=TCG, 3=OCG+TCG, 4=Custom | `1` |
| `alias` | ID de otra carta si es versión alternativa (0 si no aplica) | `0` |
| `setcode` | Código del arquetipo (0 si no pertenece a ninguno) | `0` |
| `type` | Tipo de carta (ver tabla de tipos abajo) | `17` |
| `atk` | ATK del monstruo (-2 = "?") | `2500` |
| `def` | DEF del monstruo (-2 = "?", 0 para Link) | `2000` |
| `level` | Nivel/Rango (para Pendulum/Link se codifica diferente) | `4` |
| `race` | Tipo de monstruo (ver tabla de razas) | `2` (Spellcaster) |
| `attribute` | Atributo (ver tabla de atributos) | `32` (DARK) |
| `category` | Categoría de efecto (bitmask, 0 si no aplica) | `0` |

#### Tipos de Carta (`type`) — Valores Comunes

Los valores son bitmasks que se combinan sumándolos:

| Valor | Tipo |
|---|---|
| `1` | Monster |
| `2` | Spell |
| `4` | Trap |
| `16` | Normal (Monster) |
| `32` | Effect |
| `64` | Fusion |
| `128` | Ritual |
| `8192` | Synchro |
| `16384` | Token |
| `32` | Effect |
| `2048` | Tuner |
| `8388608` | Xyz |
| `16777216` | Pendulum |
| `67108864` | Link |
| `65536` | Quick-Play (Spell) |
| `131072` | Continuous (Spell/Trap) |
| `524288` | Counter (Trap) |
| `262144` | Equip (Spell) |
| `1048576` | Field (Spell) |

**Ejemplos combinados:**
- Normal Monster: `1 + 16 = 17`
- Effect Monster: `1 + 32 = 33`
- Fusion Effect: `1 + 32 + 64 = 97`
- Synchro Tuner Effect: `1 + 32 + 2048 + 8192 = 10273`
- Link Effect: `1 + 32 + 67108864 = 67108897`
- Normal Spell: `2`
- Quick-Play Spell: `2 + 65536 = 65538`
- Continuous Trap: `4 + 131072 = 131076`

#### Atributos (`attribute`)

| Valor | Atributo |
|---|---|
| `1` | EARTH |
| `2` | WATER |
| `4` | FIRE |
| `8` | WIND |
| `16` | LIGHT |
| `32` | DARK |
| `64` | DIVINE |

#### Razas / Tipos de Monstruo (`race`)

| Valor | Race |
|---|---|
| `1` | Warrior |
| `2` | Spellcaster |
| `4` | Fairy |
| `8` | Fiend |
| `16` | Zombie |
| `32` | Machine |
| `64` | Aqua |
| `128` | Pyro |
| `256` | Rock |
| `512` | Winged Beast |
| `1024` | Plant |
| `2048` | Insect |
| `4096` | Thunder |
| `8192` | Dragon |
| `16384` | Beast |
| `32768` | Beast-Warrior |
| `65536` | Dinosaur |
| `131072` | Fish |
| `262144` | Sea Serpent |
| `524288` | Reptile |
| `1048576` | Psychic |
| `2097152` | Divine-Beast |
| `4194304` | Creator God |
| `8388608` | Wyrm |
| `16777216` | Cyberse |
| `33554432` | Illusion |

#### Codificación de `level` para Pendulum y Link

- **Monstruo normal:** Nivel directamente. Ej: Nivel 4 = `4`
- **Pendulum:** Combina nivel y escalas: `nivel + (escalaIzq << 24) + (escalaDer << 16)`
  - Ejemplo: Nivel 7, Escala 1/1 = `7 + (1 << 24) + (1 << 16) = 16842759`
- **Link:** El valor de `level` es el Link Rating. Los Link Markers van en `def`.

### Tabla `texts` — Textos de la Carta

```sql
INSERT INTO texts (id, name, desc, str1, str2, str3, str4, str5, str6, str7, str8, str9, str10, str11, str12, str13, str14, str15, str16)
VALUES (100006000, 'My Custom Card', 'This card''s effect description goes here.', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '');
```

| Columna | Descripción |
|---|---|
| `id` | Mismo ID que en `datas` |
| `name` | Nombre de la carta |
| `desc` | Texto de descripción / efecto |
| `str1`-`str16` | Textos auxiliares para prompts de activación (mensajes mostrados al jugador). Ej: `str1` = "Activate effect?" |

---

## Paso 3: Crear el Script Lua

Crear el archivo `script/unofficial/c{ID}.lua`. La estructura base es:

```lua
--Nombre de la carta
local s,id=GetID()
function s.initial_effect(c)
    -- Aquí se registran los efectos de la carta
end
```

### Ejemplo: Monstruo con Efecto Continuo de ATK Boost

```lua
--Mi Carta Custom
local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(500)
    c:RegisterEffect(e1)
end
```

### Ejemplo: Monstruo con Efecto Activado (Ignition)

```lua
--Mi Carta Custom
local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetTarget(s.destg)
    e1:SetOperation(s.desop)
    c:RegisterEffect(e1)
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_MZONE,1,nil) end
    local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
    if #g>0 then
        Duel.Destroy(g,REASON_EFFECT)
    end
end
```

### Funciones API Clave

| Función | Descripción |
|---|---|
| `Effect.CreateEffect(c)` | Crea un nuevo efecto asociado a la carta |
| `e:SetType(tipo)` | Tipo de efecto (IGNITION, TRIGGER, QUICK, CONTINUOUS, etc.) |
| `e:SetCode(codigo)` | Código del efecto (EFFECT_UPDATE_ATTACK, EFFECT_DESTROY, etc.) |
| `e:SetRange(ubicacion)` | Desde dónde se activa (LOCATION_MZONE, LOCATION_HAND, etc.) |
| `e:SetCategory(cat)` | Categoría (CATEGORY_DESTROY, CATEGORY_DRAW, CATEGORY_SPECIAL_SUMMON, etc.) |
| `e:SetCountLimit(n)` | Límite de activaciones por turno |
| `e:SetCondition(func)` | Función de condición |
| `e:SetCost(func)` | Función de costo |
| `e:SetTarget(func)` | Función de objetivo |
| `e:SetOperation(func)` | Función de resolución |
| `c:RegisterEffect(e)` | Registra el efecto en la carta |
| `c:EnableReviveLimit()` | Requiere invocación apropiada (Extra Deck monsters) |

### Constantes de Ubicación

| Constante | Ubicación |
|---|---|
| `LOCATION_HAND` | Mano |
| `LOCATION_MZONE` | Zona de Monstruos |
| `LOCATION_SZONE` | Zona de Magia/Trampa |
| `LOCATION_GRAVE` | Cementerio |
| `LOCATION_REMOVED` | Desterrado |
| `LOCATION_DECK` | Deck |
| `LOCATION_EXTRA` | Extra Deck |

---

## Paso 4: Agregar la Imagen (Opcional)

Coloca una imagen JPG del artwork en:

```
pics/{ID}.jpg
```

Ejemplo: `pics/100006000.jpg`

La resolución recomendada es **177x254 px** (o cualquier resolución proporcional). EDOPro redimensiona automáticamente.

Para imágenes de campo (Field Spells), también puedes agregar:

```
pics/field/{ID}.png
```

---

## Paso 5: Probar la Carta

1. **Reinicia EDOPro** para que cargue los cambios.
2. Ve al **Editor de Deck** y busca tu carta por nombre o ID.
3. Usa el modo **Test Hand** para verificar que la carta aparece correctamente.
4. Crea un duelo en **LAN Mode** contra ti mismo para probar los efectos.
5. Si el script tiene errores, revisa la consola del juego para mensajes de error Lua.

---

## Paso 6: Contribuir (Opcional)

Si deseas contribuir tu carta al repositorio oficial de scripts unofficial:

1. El PR debe contener **una sola carta** (salvo cartas muy acopladas).
2. El script va en `script/unofficial/`.
3. La entrada de base de datos se envía a [BabelCDB](https://github.com/ProjectIgnis/BabelCDB).
4. El título del PR debe ser: `Add "Card name"`.
5. Incluye un link a Yugipedia que confirme el comportamiento.
6. Solicita revisión de un miembro del staff.

---

## Referencia Rápida: Ejemplo Completo

### Carta: "Shadow Apprentice"
- Effect Monster, DARK, Spellcaster, Level 4, ATK 1800 / DEF 1200
- Efecto: Gana 400 ATK por cada carta en el Cementerio del oponente.

### SQL (en `cards-unofficial.cdb`):

```sql
INSERT INTO datas VALUES (100006000, 1, 0, 0, 33, 1800, 1200, 4, 2, 32, 0);
INSERT INTO texts VALUES (100006000, 'Shadow Apprentice',
    'Gains 400 ATK for each card in your opponent''s GY.',
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '');
```

### Script (`script/unofficial/c100006000.lua`):

```lua
--Shadow Apprentice
local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(s.val)
    c:RegisterEffect(e1)
end

function s.val(e,c)
    return Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_GRAVE)*400
end
```

### Imagen:

```
pics/100006000.jpg
```

---

## Arquetipos Personalizados (Setcodes)

Si tu carta pertenece a un arquetipo que **no existe** en el juego, debes crear un setcode nuevo.

### Paso a paso

1. **Abre** `script/archetype_setcode_constants.lua`.
2. **Busca el último valor hexadecimal** asignado. Los arquetipos custom se añaden al final del archivo bajo el comentario `--Custom archetypes`.
3. **Elige el siguiente valor disponible** (ej: si el último fue `0x1cf`, usa `0x1d0`).
4. **Agrega la constante** con el formato `SET_NOMBRE = 0xVALOR`.

```lua
--Custom archetypes
SET_GOKU                          = 0x1d0
```

5. En la columna `setcode` de la tabla `datas`, usa el valor decimal del setcode. Ejemplo: `0x1d0` = `464`.

### Cómo determinar el valor decimal

```python
print(0x1d0)  # Resultado: 464
```

---

## Cartas Nombradas y Placeholders

Cuando una carta hace referencia a otras cartas por nombre (ej: _"Special Summon 1 'Goku' from your Deck, except 'Goku Super Saiyan Mode'"_), **todas las cartas nombradas deben existir** en la base de datos para que el script funcione correctamente.

### Cuándo crear placeholders

- La carta principal referencia otra carta por nombre y esa carta **aún no existe**.
- Un efecto filtra por nombre (`IsCode`) o por arquetipo (`IsSetCard`) y necesita al menos una carta válida como objetivo.

### Cómo crear un placeholder

1. **Asigna un ID** consecutivo al de la carta principal (ej: principal `900000001`, placeholders `900000002`, `900000003`).
2. **Inserta en la base de datos** con stats razonables y el mismo `setcode` del arquetipo.
3. **Crea un script Lua mínimo** en `script/unofficial/c{ID}.lua`:

```lua
--Nombre del Placeholder
local s,id=GetID()
function s.initial_effect(c)
end
```

4. Si el placeholder **no debe ser invocable normalmente** (ej: _"Must be Special Summoned by a card effect"_), usa `c:EnableReviveLimit()` en su script para imponer esa restricción.

### Ejemplo: Placeholder con restricción de invocación

```lua
--Goku Super Saiyan Mode
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.spcon)
    c:RegisterEffect(e1)
end
function s.spcon(e,c)
    if c==nil then return true end
    return false
end
```

---

## Scripts de Inserción Replicables

Para mantener un registro de los inserts en la base de datos y poder replicarlos en otra instancia, se generan archivos Python con la convención:

```
{NRO}_{nombre_carta}_insert_card.py
```

### Convención de nombres

| Parte | Descripción | Ejemplo |
|---|---|---|
| `{NRO}` | Número secuencial con ceros a la izquierda (3 dígitos) | `001` |
| `{nombre_carta}` | Nombre de la carta en snake_case (minúsculas) | `kid_goku` |
| Sufijo fijo | Siempre `_insert_card.py` | `_insert_card.py` |

### Ejemplo de nombre

```
001_kid_goku_insert_card.py
```

### Contenido del archivo

El script debe usar `INSERT OR REPLACE` con parámetros para ser idempotente (se puede ejecutar múltiples veces sin duplicar datos):

```python
import sqlite3

conn = sqlite3.connect('expansions/cards-unofficial.cdb')
c = conn.cursor()

MY_SETCODE = 0x1d0  # 464

# Carta principal - ID
c.execute('INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)',
    (900000001, 4, 0, MY_SETCODE, 33, 650, 250, 3, 1, 1, 0))
c.execute('INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
    (900000001, 'Card Name', 'Effect description.', '', '', '', '', '',
     '', '', '', '', '', '', '', '', '', '', ''))

# Placeholders referenciados (si aplica)
# ...

conn.commit()
conn.close()
print('Cards inserted successfully!')
```

### Cómo replicar en otra instancia

Ejecuta todos los scripts en orden desde la raíz del proyecto:

```bash
python 001_kid_goku_insert_card.py
python 002_otra_carta_insert_card.py
# ...
```

O ejecuta todos de una vez:

```bash
# PowerShell
Get-ChildItem *_insert_card.py | Sort-Object Name | ForEach-Object { python $_.FullName }

# Bash
for f in $(ls *_insert_card.py | sort); do python "$f"; done
```

---

## Estructura de Archivos del Proyecto

```
ProjectIgnis/
├── expansions/
│   ├── cards.cdb              ← Base de datos principal (oficial)
│   ├── cards-unofficial.cdb   ← Base de datos para cartas custom
│   └── ...
├── script/
│   ├── official/              ← Scripts de cartas oficiales
│   │   └── c38033121.lua      ← Ejemplo: Dark Magician Girl
│   ├── unofficial/            ← Scripts de cartas custom
│   │   └── c900000001.lua     ← Tu carta nueva va aquí
│   └── archetype_setcode_constants.lua ← Definición de arquetipos
├── pics/
│   ├── {id}.jpg               ← Artwork de cartas
│   └── field/
│       └── {id}.png           ← Imágenes de campo
├── 001_kid_goku_insert_card.py ← Script de inserción replicable
└── guide.md                    ← Esta guía
```

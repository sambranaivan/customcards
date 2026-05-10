# Expansión Bronze Saint — Notas de Diseño
## Grupo Normal (sin armadura) + Grupo Fusión (armadura completa)

---

## 1. Análisis de la Idea

### Fortalezas

La propuesta introduce una jerarquía de poder en tres niveles que replica el arco narrativo de Saint Seiya con precisión:

```
Lv 2–3 Normal (sin armadura, candidatos)
   ↓  equipar Bronze Cloth correspondiente
Lv 4 Effect (armadura estándar, efecto activable)    ← ya existen
   ↓  cosmo máximo + Bronze Cloth
Lv 6 Fusion (armadura a pleno poder, efectos fuertes)
   ↓  unión de los cinco
Rank 4 Xyz Boss (Burning Five Stars)                 ← ya existe
```

Esto resuelve además dos problemas reales del arquetipo actual:

1. **Consistencia**: Los Normales son Level 2–3, permiten `Rescue Rabbit`, `Birthright` y cualquier soporte de vanilla. Son piezas de combo baratas que generan cuerpos en campo.
2. **Profundidad extra-deck**: Ahora el arquetipo tiene un plan B en el Extra Deck (Fusiones de Lv 6) además del boss Xyz. Los Lv 6 pueden usarse como material de tributo, como base para Synchro con un Tuner neutro, o como evolución standalone.

### Coherencia con las cartas existentes

- Los **Normales** son el material alternativo más barato para los Xyz del boss sin gastar una Normal Summon en un Level 4 Effect.
- Las **Fusiones** recuperadas del GY por el efecto ④ del boss pueden preparar el campo para un nuevo Xyz.
- `Legend of the Bronze Saints` (campo) y `Saintly Bond` apoyan a ambos grupos sin necesitar modificación.
- `Bronze Saint Oath` (Counter Trap) exige "Bronze Saint equipado con Cloth" — los Normales equipados con su Cloth antes de fusionar activan la condición.

### Consideraciones de balance

- Las Fusiones Level 6 no deberían exceder 2400 ATK de base para no eclipsar al boss (2800).
- Cada Fusión requiere su Cloth **específica**, no genérica. Esto evita que un solo Bronze Cloth acceda a todas las fusiones y mantiene la identidad de cada saint.
- El costo de la Fusión (enviar monstruo + equip al GY) ya es real; los efectos pueden ser moderadamente potentes.

---

## 2. Grupo A — Monstruos Normales (sin armadura)

### Concepto

Representan a los Caballeros de Bronce **antes de recibir su armadura**: jóvenes huérfanos en entrenamiento en distintos rincones del mundo. Son **Normal Monsters** puros — sin efectos, solo estadísticas y texto de lore.

**Nombre propuesto**: `Saint Candidate - [Name]`  
Contiene la palabra "Saint" → pertenecen a SET_SAINT (0x1D7) y SET_BRONZE_SAINT (0x1D9). Son distintos de sus versiones equipadas por la ausencia del subtítulo "of [Cloth]".

### Tabla de estadísticas

| ID propuesto | Nombre | Lv | ATK | DEF | Lore (flavor text) |
|---|---|---|---|---|---|
| 922100309 | Saint Candidate - Seiya | 3 | 1200 | 600 | *Trained beneath the harsh Greek cliffs under the watchful eye of Marin of Eagle. His spirit burns fiercer than any boy his age.* |
| 922100310 | Saint Candidate - Shiryu | 3 | 900 | 1400 | *Disciplined at the Lushan waterfall under the ancient master Dohko. His stance is as unyielding as the stone he practices on.* |
| 922100311 | Saint Candidate - Hyoga | 3 | 1000 | 1000 | *Raised in the Siberian tundra by the phantom of his mother, shaped by the ice itself. His heart holds both frost and grief.* |
| 922100312 | Saint Candidate - Shun | 2 | 700 | 1200 | *Gentle beyond measure, yet forged on the harshest training island. He holds back, waiting for the moment he must protect those he loves.* |
| 922100313 | Saint Candidate - Ikki | 3 | 1400 | 700 | *Exiled to Death Queen Island — a place no one survives. He returned, changed forever, carrying scars no armor can cover.* |

**Justificación de stats:**
- Siguen la misma distribución ATK/DEF que sus versiones Level 4 Effect, pero escaladas al rango Lv 2–3.
- Seiya: ofensivo (mismo perfil que su versión Lv 4, que tiene el ATK más alto del grupo principal).
- Shiryu: DEF alta, refleja el Dragon Shield.
- Shun: Level 2 porque en lore es el más joven del grupo central y el menos agresivo; Level 2 le da acceso a `Unexpected Dai`.
- Ikki: ATK más alto del grupo Normal porque entrenar en la isla de la muerte lo dejó más fuerte desde el inicio.

### Uso estratégico
- `Rescue Rabbit` → Special Summon 2 copias → overlay para Rank 3 extra o preparar tributo.
- `Unexpected Dai` → Special Summon 1 Normal de Level 4 o menor desde el Deck (Shun Level 2 es el objetivo primario).
- `Birthright` → Special Summon desde GY un Normal que murió en combate o fue enviado por costo.
- Objetivo principal: **estar equipado con su Bronze Cloth correspondiente para acceder a la Fusión**.

---

## 3. Grupo B — Monstruos de Fusión (armadura a pleno poder)

### Concepto

Representan a los Caballeros de Bronce en el momento de máxima tensión narrativa: armadura completa, Cosmo al límite, dispuestos a morir por su causa. Son **Fusion Effect Monsters Level 6**.

**Nombre propuesto**: `Armored Bronze Saint - [Name] of [Cloth]`  
El prefijo "Armored" los distingue claramente de los Effect Monsters existentes (`Bronze Saint - Seiya of Pegasus`) y los mantiene dentro del arquetipo por "Bronze Saint" y "of [Cloth]".

### Materiales de Fusión

Cada Fusión requiere:
- 1 monstruo "[Name]" de tipo Bronze Saint (Normal o Effect, según el campo)
- 1 `Bronze Cloth - [Cloth]` Equip Spell específica equipada a ese monstruo

La restricción de Cloth **específica** (no genérica) es intencionada — cada saint tiene su identidad.

### Fichas individuales

---

#### 922100314 · Armored Bronze Saint - Seiya of Pegasus
**Level 6 / LIGHT / Warrior / Fusion Effect**  
**ATK 2200 / DEF 1600**

Materiales: `Bronze Saint - Seiya` + `Bronze Cloth - Pegasus` (equipada)

> ① When this card attacks, it gains 300 ATK until the end of that attack for each "Bronze Saint" monster in your GY.  
> ② Once per turn, if this card destroys an opponent's monster by battle: This card can make 1 additional attack.  
> ③ (GY) Once per turn: You can banish 1 "Bronze Cloth" from your GY; add 1 "Bronze Saint" card from your Deck to your hand.

**Lore**: Meteoro de Pegaso — velocidad y furia que aumenta cuanto más caen sus compañeros. Efecto ① escala con el GY, ② premia la destrucción con un ataque adicional (espejo del efecto ② del boss). El efecto GY ③ le da utilidad como motor de búsqueda desde el cementerio.

---

#### 922100315 · Armored Bronze Saint - Shiryu of Dragon
**Level 6 / LIGHT / Warrior / Fusion Effect**  
**ATK 1800 / DEF 2500**

Materiales: `Bronze Saint - Shiryu` + `Bronze Cloth - Dragon` (equipada)

> ① This card can attack in face-down Defense Position. If it does, apply its DEF for damage calculation.  
> ② Once per turn: You can have this card gain ATK equal to its current DEF until the End Phase. If you do, it cannot change its battle position this turn.  
> ③ While this card is equipped with an Equip Spell, it cannot be destroyed by card effects.

**Lore**: Dragon Shield y Excalibur — Shiryu sacrifica su defensa (DEF → ATK) para el golpe definitivo. El efecto ① refleja el ataque a posición boca abajo del Dragon Shield. El efecto ③ es la protección pasiva del saint más defensivo.

---

#### 922100316 · Armored Bronze Saint - Hyoga of Cygnus
**Level 6 / LIGHT / Warrior / Fusion Effect**  
**ATK 2100 / DEF 1800**

Materiales: `Bronze Saint - Hyoga` + `Bronze Cloth - Cygnus` (equipada)

> ① When this card attacks an opponent's monster, that monster loses 500 ATK and DEF until the end of the Damage Step.  
> ② If this card battles a monster, negate that monster's effects until the end of the Damage Step.  
> ③ Once per turn, after damage calculation, if this card battled: Switch the battled monster to Defense Position; it cannot change its battle position while this card is face-up on the field.

**Lore**: Diamond Dust y Aurora Execution — el hielo paraliza y anula. Los tres efectos son progresivos: debilitar (①), negar efectos (②), inmovilizar (③). Juntos hacen que cualquier monstruo que enfrente a Hyoga quede desactivado y atrapado en defensa.

---

#### 922100317 · Armored Bronze Saint - Shun of Andromeda
**Level 6 / LIGHT / Warrior / Fusion Effect**  
**ATK 1900 / DEF 2200**

Materiales: `Bronze Saint - Shun` + `Bronze Cloth - Andromeda` (equipada)

> ① Once per turn: You can target 1 face-up monster your opponent controls; that target cannot attack or activate effects until your next End Phase (while this card is face-up).  
> ② While this card is on the field, your opponent cannot target other "Bronze Saint" monsters you control with card effects.  
> ③ When this card is destroyed and sent to the GY: You can Special Summon 1 "Saint Candidate" Normal Monster from your Deck.

**Lore**: Nebula Chain — encadenamiento, protección de los aliados, y cuando cae, asegura la continuidad. El efecto ② es una referencia directa a la naturaleza protectora de Shun con sus compañeros. El efecto ③ trae a un candidato desde el Deck, preparando la siguiente Fusión.

---

#### 922100318 · Armored Bronze Saint - Ikki of Phoenix
**Level 6 / LIGHT / Warrior / Fusion Effect**  
**ATK 2400 / DEF 1500**

Materiales: `Bronze Saint - Ikki` + `Bronze Cloth - Phoenix` (equipada)

> ① Once per turn: When this card would be destroyed by battle or card effect, it is not destroyed.  
> ② If this card is sent to the GY by an opponent's card: During the next Standby Phase, Special Summon this card from the GY.  
> ③ Once per turn: You can target 1 face-up monster your opponent controls; this turn, that target's ATK becomes 0 and its effects are negated (Illusion Demon Fist).

**Lore**: El fénix resurge siempre. Efecto ① es la primera vida (indestructible), efecto ② es la resurrección clásica del fénix. Ikki tiene el ATK más alto del grupo de Fusiones porque siempre fue el más poderoso de los Caballeros de Bronce individualmente.

---

### Tabla resumen

| ID | Nombre | ATK | DEF | Efecto signature |
|---|---|---|---|---|
| 922100314 | Armored Bronze Saint - Seiya | 2200 | 1600 | Doble ataque condicional + búsqueda desde GY |
| 922100315 | Armored Bronze Saint - Shiryu | 1800 | 2500 | DEF→ATK + ataque en defensa + protección |
| 922100316 | Armored Bronze Saint - Hyoga | 2100 | 1800 | Debilitar + negar + inmovilizar |
| 922100317 | Armored Bronze Saint - Shun | 1900 | 2200 | Encadenar + proteger aliados + recrutar candidato |
| 922100318 | Armored Bronze Saint - Ikki | 2400 | 1500 | Indestructible + resurrección + Illusion Fist |

---

## 4. Mecánica de Fusión

### Problema central

El usuario especificó "sin Polimerizacion". En EDOPro esto puede implementarse de tres formas:

| Opción | Dónde vive el efecto | Pros | Contras |
|---|---|---|---|
| A | Quick Effect en cada Normal Monster | Auto-contenido, temático (el armado es un momento del personaje) | Solo Normal Monsters pueden dispararlo; Effect Monsters no |
| B | Condición en el Fusion Monster (Contact Fusion) | Sin cartas adicionales | Requiere que EDOPro soporte la condición sin activación |
| C | Nueva Quick-Play Spell dedicada | Cubre ambos tipos (Normal y Effect), un solo punto de implementación | Una carta más de soporte |

### Recomendación: Opción A + C combinadas

**Los Normal Monsters tienen el Quick Effect** (Opción A):
> (Quick Effect): If "[Specific Cloth]" is equipped to this card: You can Fusion Summon 1 "[Specific Fusion]" from your Extra Deck, sending this card and the equipped Equip Spell to the GY.

Esto hace que el Normal Monster tenga un propósito único y potente: activar la Fusión sin necesidad de un Spell adicional. Es el momento dramático de "ponerse la armadura".

**Una nueva Quick-Play Spell cubre el Effect Monster** (Opción C):

---

### 922100319 · Bronze Armor Awakening
**Quick-Play Spell** | Archetypes: Bronze Saint, Bronze Cloth

> Fusion Summon 1 "Armored Bronze Saint" Fusion Monster from your Extra Deck, using 1 "Bronze Saint" monster you control equipped with its corresponding "Bronze Cloth" Equip Spell as the Fusion Material (this Fusion Summon does not require "Polymerization").  
> You can only activate 1 "Bronze Armor Awakening" per turn.

Esta carta funciona con **ambas** versiones del material (Normal o Effect), cubre el camino del Effect Monster sin modificar esas cartas existentes, y es temáticamente "ponerse la armadura de Bronce".

---

## 5. Líneas de Juego

### Línea A — Normal Monster path (sin gastar recursos)
```
1. Rescue Rabbit → Special Summon 2× "Saint Candidate - Seiya"
2. Equip "Bronze Cloth - Pegasus" a 1 de ellos (desde Deck con Bronze Cloth Awakening)
3. Quick Effect del Normal → Fusion Summon "Armored Bronze Saint - Seiya of Pegasus"
4. El otro Normal Monster queda en campo como material para el boss Xyz futuro
```

### Línea B — Effect Monster path (con Bronze Armor Awakening)
```
1. Normal Summon "Bronze Saint - Seiya of Pegasus" (Lv 4 Effect)
2. Bronze Cloth Awakening → equip "Bronze Cloth - Pegasus" + 1 más
3. Activar "Bronze Armor Awakening" → Fusion Summon Armored Seiya
4. En GY quedan: un Effect Monster + la Cloth (recuperables por Saintly Bond / boss ③)
```

### Línea C — Boss + Fusion en campo simultáneos
```
1. 3× Bronze Saint en campo → Xyz Summon boss (Burning Five Stars)
2. "Armored Bronze Saint - Shun" en campo → efecto ② protege al boss de targeting
3. Boss efecto ② → doble ataque con lock de activación
4. Si el boss es destruido → efecto ④ revive hasta 3 Bronze Saints → nueva Fusión posible
```

---

## 6. Extensión para los 5 Saints Secundarios

El diseño es escalable. Los 5 Bronze Saints secundarios (Jabu, Ichi, Geki, Ban, Nachi) pueden recibir el mismo tratamiento en una segunda ola, con Normal Monsters Level 2 y Fusion Monsters Level 5 (son saints menos poderosos en lore). Los Fusion Monsters secundarios serían más simples en efectos para reflejar su tier menor.

| Saint | Cloth | Fusión sugerida | ATK/DEF |
|---|---|---|---|
| Jabu | Unicorn | Armored Bronze Saint - Jabu of Unicorn | 2000/1500 |
| Ichi | Hydra | Armored Bronze Saint - Ichi of Hydra | 1800/1600 |
| Geki | Bear | Armored Bronze Saint - Geki of Bear | 2000/1800 |
| Ban | Lionet | Armored Bronze Saint - Ban of Lionet | 1900/1500 |
| Nachi | Wolf | Armored Bronze Saint - Nachi of Wolf | 1700/1400 |

---

## 7. Resumen de IDs Propuestos

| ID | Tipo | Nombre |
|---|---|---|
| 922100309 | Normal Monster Lv 3 | Saint Candidate - Seiya |
| 922100310 | Normal Monster Lv 3 | Saint Candidate - Shiryu |
| 922100311 | Normal Monster Lv 3 | Saint Candidate - Hyoga |
| 922100312 | Normal Monster Lv 2 | Saint Candidate - Shun |
| 922100313 | Normal Monster Lv 3 | Saint Candidate - Ikki |
| 922100314 | Fusion Effect Lv 6 | Armored Bronze Saint - Seiya of Pegasus |
| 922100315 | Fusion Effect Lv 6 | Armored Bronze Saint - Shiryu of Dragon |
| 922100316 | Fusion Effect Lv 6 | Armored Bronze Saint - Hyoga of Cygnus |
| 922100317 | Fusion Effect Lv 6 | Armored Bronze Saint - Shun of Andromeda |
| 922100318 | Fusion Effect Lv 6 | Armored Bronze Saint - Ikki of Phoenix |
| 922100319 | Quick-Play Spell | Bronze Armor Awakening |

---

## 8. Notas de Implementación Lua

### Normal Monsters
Script mínimo — solo `GetID()` y `listed_series`. Sin efectos registrados.
```lua
local s,id=GetID()
s.listed_series={SET_SAINT,SET_BRONZE_SAINT}
```

### Quick Effect de Fusión en cada Normal Monster
```lua
-- En el Normal Monster (e.g. c922100309 Seiya):
local e1=Effect.CreateEffect(c)
e1:SetType(EFFECT_TYPE_QUICK_O)
e1:SetCode(EVENT_FREE_CHAIN)
e1:SetRange(LOCATION_MZONE)
e1:SetCondition(s.fuscon)   -- si Bronze Cloth - Pegasus está equipada
e1:SetTarget(s.fustg)
e1:SetOperation(s.fusop)    -- Duel.Fusion usando materiales del campo
c:RegisterEffect(e1)
```

### Fusion Monsters
- `Fusion.AddProcedure` NO se usa (la fusión la ejecuta el Quick Effect del Normal o el Spell).
- En el script del Fusion Monster solo se registran sus efectos de campo/GY.
- Necesitan `c:EnableReviveLimit()` si van a impedir resurrección libre, o dejarlo sin limitación para que la carta de Ikki pueda resucitarse con su propio efecto ②.

### Bronze Armor Awakening (Spell)
Usa `Duel.SelectFusionMaterial` o equivalente para verificar que el monstruo en campo tenga su Cloth específica equipada antes de resolver la Fusión. La condición de "correspondiente" requiere un filtro por nombre cruzado (monstruo + cloth específica).

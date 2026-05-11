# Review de Balance: Envoy of the Pope

## Visión General

El arquetipo es temáticamente sólido y mecánicamente coherente. La estructura de 6 tiers está bien pensada y el lore fluye naturalmente (Voice → Usurper → Saga). Sin embargo, hay varias cartas que están sobre-diseñadas y generan una densidad de negaciones/inmunidades que puede hacer el deck extremadamente difícil de contrarrestar.

---

## Problemas Críticos (Necesitan cambios)

### 1. Gold Saint - Saga of Gemini, Envoy of the Pope — ROTO

```
Si es invocado: Niega los efectos de todas las cartas face-up del rival y las destruye.
Quick Effect: Envía 1 Envoy → niega una activación y banea esa carta.
Inmune a efectos de monstruos no-Envoy.
```

**Problemas:**
- **Board wipe total al invocar** (niega Y destruye todo lo del rival) sin costo adicional. No hay YGO estándar que dé board wipe + negate + destroy en invocación sin restricciones de material pesado.
- **El Quick Effect es omni-negate + banish** a costo de 1 carta de mano — este efecto solo en un Level 10 ya es poderoso, pero combinado con el board wipe de invocación es excesivo.
- **Inmunidad total a monstruos no-Envoy** hace que solo Spells/Traps puedan removerlo — junto con Absolute Verdict que es omni-negate, el rival casi no tiene outs.
- La cadena de triggers **Chain of Command destruida → Usurper → Usurper destruido → Saga** recompensa al rival por interactuar con el deck, lo cual es un diseño punitivo difícil de equilibrar.

**Sugerencias:**
- Invocación: cambiar a "niega los efectos" pero **sin destruir**, o limitar a "hasta 2 cartas objetivo".
- Quick Effect: añadir costo de LP (800-1000) además del descarte.
- Inmunidad: condicionar a "mientras controles otro monstruo Envoy" (ya así funciona Pope Ares Usurper).

---

### 2. Pope's Mandate - Absolute Verdict — FREE OMNI-NEGATE PERMANENTE

```
Cuando el rival activa una carta/efecto mientras controlas 1 Envoy: Niega y banea.
Con Pope Ares Usurper: el rival no puede activar cartas con ese nombre por el resto del Duelo.
```

**Problemas:**
- Es un **Counter Trap sin costo** — solo necesitas 1 Envoy en campo, que siempre vas a tener.
- Compara con Solemn Judgment (50% LP) o Solemn Strike (1500 LP).
- El bloqueo **permanente para todo el Duelo** del nombre de la carta baneada es game-breaking. Ninguna carta oficial hace esto sin condiciones extremas.

**Sugerencias:**
- Añadir costo: "Tribute 1 'Envoy of the Pope' monster, OR send 1 'Envoy of the Pope' card from your hand or face-up field to the GY."
- Cambiar el bloqueo de nombre a "until the end of your opponent's next turn" en lugar de "for the rest of this Duel".

---

### 3. Gold Saint - Aphrodite of Pisces, Envoy of the Pope — BOARD WIPE AUTOMÁTICO

```
Al ser invocado: 1 Royal Demon Rose Counter en cada monstruo rival (efecto negado, -500 ATK por counter).
Cada End Phase: +1 counter en cada monstruo rival, luego destruye todos los que tengan 2+ counters.
```

**Problemas:**
- Al ser invocada, inmediatamente niega todos los efectos de monstruos del rival.
- Al final del MISMO turno en que fue invocada, todos los monstruos del rival con 1 counter ya existente reciben otro → **destruidos automáticamente en el End Phase del rival**.
- Esto significa que cualquier monstruo del rival sobrevive máximo **1 turno** después de que Aphrodite llegue al campo.
- A 2700/2700 ATK/DEF, es también un beater sólido.

**Sugerencias:**
- Cambiar "During each End Phase" a "During your End Phase" (solo activa en tu turno).
- O añadir un costo por placement: "pay 300 LP for each counter placed".
- O cambiar "destroy all monsters with 2+ counters" a "destroy 1 monster with 2 or more Royal Demon Rose Counters" (limitado a 1 destrucción).

---

## Problemas Moderados (Tweaks recomendados)

### 4. Pope Ares - Usurper of the Sanctuary — Control-steal sin costo

El Quick Effect de negar efectos + robar control tiene 0 costo adicional al HOPT. Compara con Number 101 (detach 1 material) o Creature Swap (cede un monstruo propio). Siendo Level 10 a 3200 ATK ya es la amenaza principal; darle un robo gratuito cada turno es muy fuerte.

**Sugerencia:** Añadir costo: "Send 1 'Envoy of the Pope' card from your hand or face-up field to the GY."

---

### 5. Pope's Mandate - Chain of Command — Cadena triple de contragolpes

El deck genera una cascada de respuestas ante interacciones del rival:

```
[Rival destruye Chain of Command] → Invoca Pope Ares Usurper (ignorando condiciones)
[Rival destruye Pope Ares Usurper] → Invoca Saga de Geminis (Quick Effect)
[Saga se invoca] → Borra todo el campo del rival
```

El rival no puede "romper" la estructura sin desencadenar una avalancha de respuestas.

**Sugerencia:** Cambiar el trigger de Chain of Command de invocar "Pope Ares - Usurper of the Sanctuary" a invocar "Pope Ares - Voice of the Sanctuary" (el Level 4, no el Level 10), reduciendo el pico de poder de esta cadena.

---

### 6. Pope's Mandate - Silence the Rebels — Wording ambiguo

```
Your opponent cannot activate the effects of Level 4 or lower monsters on the field.
```

Dice "on the field" sin especificar "that your opponent controls" — técnicamente también bloquea los propios monstruos de Nivel 4 o menor del jugador activo.

**Sugerencia:** Clarificar: "Your opponent cannot activate the effects of Level 4 or lower monsters **they control**."

---

### 7. Jango of the Boomerang — El monstruo robado puede ser Tributado

```
Quick Effect: Toma control de 1 monstruo Nivel 4 o menor del rival hasta el End Phase.
El monstruo robado no puede atacar ni ser usado como material de Synchro/Xyz/Link.
```

La restricción no incluye "cannot be Tributed". Se puede robar un monstruo del rival y usarlo como tributo para invocar un Gold Saint Corrupto.

**Sugerencia:** Añadir "also it cannot be Tributed" a la lista de restricciones del monstruo robado.

---

## Observaciones Menores (Wording / Claridad)

| Carta | Observación |
|---|---|
| **Shaina, Envoy** | "If you control Pope Ares, this card can make a second attack" — vale aclarar si ambos ataques aplican contra monstruos Y jugador directo, o solo monstruos. |
| **Agora of Lotus** | El revival desde GY (enviar Pope's Mandate del Deck como costo) puede repetirse fácilmente cada turno. El HOPT general cubre esto, pero conviene verificar que el GY effect esté dentro del mismo bloque HOPT. |
| **Cepheus Daidalos** | El Quick Effect protege "1 face-up monster on the field" — incluyendo monstruos propios. Puede usarse para negar intencionalmente los propios efectos; verificar si es la intención. |
| **Pope's Mandate - Sanctuary Judgment** | El negate base es una Quick-Play Spell gratuita. Considera añadir costo de LP (500-800) para alinear con el poder del efecto opcional de destrucción. |
| **Algol, Envoy** | El column lock apilado con el effect-negate del turno puede silenciar una zona completa de forma muy opresiva. Temáticamente sólido; monitorear en juego. |

---

## Puntos Fuertes del Diseño

- La diferenciación mecánica entre versiones **Synchro** (Bronze+Silver deck) y **Effect** (Pope-only deck) de los mismos personajes está muy bien ejecutada.
- El **lore flow** Pope Voice → Usurper → Saga está reflejado de forma elegante en las condiciones de invocación.
- Los **Ghost Saints** como fodder de bajo costo son exactamente lo que el deck necesita para costear los Gold Corruptos sin romper el pacing.
- **Cassios** tributándose para proteger a Shaina es un guiño narrativo perfecto al anime.
- **Musca Dio** con los Fly Counters es un control de estado interesante y temáticamente apropiado.
- La restricción "cannot Special Summon from the Extra Deck, except 'Saint' monsters" en múltiples cartas de soporte mantiene coherencia con el sistema de arquetipo cerrado.

---

## Resumen de Prioridades

| Prioridad | Carta | Cambio necesario |
|---|---|---|
| 🔴 CRÍTICO | Gold Saint - Saga of Gemini, Envoy | Reducir board wipe de invocación; añadir costo al Quick Effect; condicionar inmunidad |
| 🔴 CRÍTICO | Pope's Mandate - Absolute Verdict | Añadir costo al Counter Trap; limitar bloqueo de nombre a 1 turno del rival |
| 🔴 CRÍTICO | Gold Saint - Aphrodite, Envoy | Cambiar "each End Phase" → "your End Phase" |
| 🟡 MODERADO | Pope Ares - Usurper of the Sanctuary | Añadir costo al control-steal Quick Effect |
| 🟡 MODERADO | Pope's Mandate - Chain of Command | Bajar el trigger de invocación a Pope Ares Voice (Level 4) |
| 🟡 MODERADO | Pope's Mandate - Silence the Rebels | Clarificar "that your opponent controls" |
| 🟡 MODERADO | Jango of the Boomerang | Añadir "cannot be Tributed" al monstruo robado |

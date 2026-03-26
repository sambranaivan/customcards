---
name: pokemon-yugioh-card-design
description: >
  Diseña cartas de Yu-Gi-Oh! basadas en Pokémon con fidelidad mecánica al videojuego.
  Usa esta skill siempre que el usuario quiera crear, revisar o refinar cartas YGO
  inspiradas en Pokémon — incluyendo líneas evolutivas, legendarios, movimientos como
  efectos, mapeo de tipos, o al mencionar términos como BST, STAB, arquetipo de tipo,
  estrategia macro, o cuando pida diseñar cualquier Pokémon específico como carta YGO.
  También aplica cuando el usuario quiera expandir o aplicar el sistema de diseño establecido.
---

# Skill: Diseño de Cartas Yu-Gi-Oh! basadas en Pokémon

## Pregunta central de diseño

> **"¿Se siente como ese Pokémon?"**

Cada decisión — ATK/DEF, tipo de efecto, condición de invocación — debe superar este test.
El objetivo no es traducir números, sino capturar la *identidad de combate* del Pokémon.

---

## 1. Mapeo de Estadísticas

### Tipo Pokémon → Atributo + Raza YGO

| Tipo Pokémon       | Atributo YGO | Raza YGO                  |
|--------------------|--------------|---------------------------|
| Fuego              | FIRE         | Pyro / Dragon             |
| Agua               | WATER        | Aqua / Sea Serpent / Fish |
| Planta             | EARTH        | Plant                     |
| Eléctrico          | LIGHT        | Thunder                   |
| Roca / Tierra      | EARTH        | Rock                      |
| Volador            | WIND         | Winged Beast / Fairy      |
| Hielo              | WATER        | Aqua                      |
| Lucha              | EARTH        | Warrior / Beast-Warrior   |
| Veneno / Siniestro | DARK         | Reptile / Insect / Fiend  |
| Psíquico           | LIGHT / DARK | Psychic                   |
| Fantasma           | DARK         | Zombie / Fiend            |
| Dragón             | WIND / DARK  | Dragon                    |
| Acero              | LIGHT        | Machine                   |
| Hada               | LIGHT        | Fairy                     |
| Bicho              | EARTH / WIND | Insect                    |
| Normal             | EARTH        | Beast                     |

### BST → ATK/DEF (suma total y distribución)

| BST            | Suma ATK+DEF  | Nivel YGO |
|----------------|---------------|-----------|
| < 300 (baby)   | 500–900       | 1–2       |
| 300–399        | 900–1400      | 2–3       |
| 400–499        | 1400–1900     | 3–4       |
| 500–549        | 1900–2200     | 4–5       |
| 550–599        | 2200–2600     | 5–6       |
| 600–649        | 2600–3000     | 6–7       |
| 650–699        | 3000–3400     | 7–8       |
| 700+           | 3400–4000     | 8–12      |

**Distribución según rol:**
- Atacante (Atk > Def): starters finales, legendarios ofensivos
- Tanque (Def > Atk): tipo Roca/Acero, evoluciones defensivas
- Equilibrado: Pokémon versátiles → reparto ~50/50

### Etapa Evolutiva → Nivel

| Etapa                       | Nivel         |
|-----------------------------|---------------|
| Básico (sin evolucionar)    | 2–4           |
| Fase 1 (primera evolución)  | 4–6           |
| Fase 2 (segunda evolución)  | 6–8           |
| Mega / Gigantamax           | Extra Deck    |
| Legendario / Mythical       | 8–12          |

---

## 2. Estrategias Macro por Tipo

Cada tipo comparte una *fantasía de juego* colectiva que permite sinergia entre familias distintas.
No todas las cartas del tipo deben implementarla a rajatabla — es el lenguaje compartido del tipo.

| Tipo          | Estrategia Macro            | Palabra Clave                  |
|---------------|-----------------------------|--------------------------------|
| 🔥 Fuego      | BURN / Agresión Directa     | Presión constante de LP        |
| 💧 Agua       | CONTROL / Manipulación      | Descarte y rebote de mano      |
| 🌿 Planta     | HEALING / Recuperación      | Resistencia y reciclado        |
| ⚡ Eléctrico  | TEMPO / Velocidad           | Invocaciones extra por turno   |
| 🪨 Roca       | DEFENSA ALTA / Attrition    | Inamovible, daño reflejado     |
| 🌬️ Volador   | EVASIÓN / Disruption        | Esquivo, cancela ataques       |
| 🧊 Hielo      | LOCK / Parálisis            | Congela opciones del oponente  |
| ☠️ Veneno     | DoT / Debilitamiento        | Veneno acumulativo por turno   |
| 🔮 Psíquico   | RECURSIÓN / Cementerio      | El GY es un recurso activo     |
| ⚔️ Lucha      | AGGRO Consistente           | Siempre hay monstruo en campo  |
| 🐉 Dragón     | BEATDOWN / Poder Bruto      | ATK máximo, daño bruto         |

### Detalle por tipo (mecánicas clave)

**🔥 FUEGO — BURN:**
- Daño al LP por destruir en batalla o al activar efectos
- Bonus de ATK temporal; daño escala si el oponente tiene pocos LP
- Debilidad: sin recuperación, pierde si el oponente aguanta

**💧 AGUA — CONTROL:**
- Rebote/descarte de cartas del oponente; negaciones suaves
- Draw adicional; Synchro Monsters de flujo
- Debilidad: daño lento, depende de ventaja incremental

**🌿 PLANTA — HEALING:**
- Recuperar LP al invocar/destruir/final de turno
- Reciclar cartas del GY; tokens defensivos
- Debilidad: ritmo lento, vulnerable a OTK temprano

**⚡ ELÉCTRICO — TEMPO:**
- Invocaciones especiales adicionales o en turno del oponente
- Atacar múltiples veces; Quick Effects de interrupción
- Debilidad: dependiente de combo, pierde contra hand traps

**🪨 ROCA — DEFENSA:**
- DEF alta; efectos al ser atacado en posición defensiva
- Daño reflejado; monstruos resistentes a destrucción por efecto
- Debilidad: ATK moderado, necesita soporte para cerrar el juego

**🌬️ VOLADOR — EVASIÓN:**
- Inmunidad temporal; regresar a mano antes de ser destruido
- Cancelar ataques/efectos como Quick Effect
- Debilidad: stats medias, pierde en combate directo

**🧊 HIELO — LOCK:**
- Cambiar monstruos del oponente a posición defensiva
- Negar Battle Phase o limitar invocaciones
- Debilidad: situacional, pierde contra remoción masiva

**☠️ VENENO — DoT:**
- Daño al final de cada turno que se acumula
- Reducir ATK/DEF permanentemente; "infectar" cartas
- Debilidad: muy lento, muere ante OTK

**🔮 PSÍQUICO/FANTASMA — GY:**
- Invocaciones desde el cementerio; triggers al ser mandado al GY
- Copiar efectos de cartas en el GY del oponente
- Debilidad: predecible, el banish lo neutraliza

**⚔️ LUCHA — AGGRO:**
- Dos invocaciones normales; búsqueda al invocar normalmente
- Auto-invocación si campo/mano vacíos
- Debilidad: efectos individuales débiles, pierde ante destrucción masiva

**🐉 DRAGÓN — BEATDOWN:**
- ATK base extrema; destrucción masiva al invocar
- Inmunidad a efectos durante la Battle Phase
- Debilidad: difícil de invocar, vulnerable a negaciones

---

## 3. Sistema de Evolución

Cada método de evolución Pokémon se mapea a un mecanismo YGO distinto:

| Método Pokémon            | Mecanismo YGO                                      |
|---------------------------|----------------------------------------------------|
| Por nivel (estándar)      | Tribute Summon o Special Summon por nombre         |
| Mega Evolución            | Equip Spell (Mega Stone) o Fusion desde Extra Deck |
| Por piedra                | Quick-Play Spell (actívable en turno del oponente) |
| Por felicidad/amistad     | Special Summon si controlas el anterior + ≥2000 LP |
| Por intercambio           | Special Summon enviando carta a oponente o banish  |
| Formas regionales/alternas| Mismo nombre, diferente Atributo/Raza/efectos      |
| Gigantamax / Dynamax      | Link o Xyz Monster de rango alto                   |

**Reglas de evolución:**
- La Mega Evolución siempre entra desde el Extra Deck
- Los monstruos de evolución comparten el setcode familiar del básico
- Las formas regionales comparten setcode base pero tienen efectos distintos

---

## 4. Movimientos → Efectos

### Tabla de traducción

| Categoría de Movimiento       | Tipo de Efecto YGO               | Plantilla Base                                          |
|-------------------------------|----------------------------------|---------------------------------------------------------|
| Físico ofensivo               | Efecto en batalla                | "Al destruir en batalla: [efecto adicional]"            |
| Especial ofensivo             | Efecto de coste                  | "Descarta/banish X: destruye o daña al adversario"      |
| Estado (status)               | Debilitamiento o lock            | "Reduce ATK/DEF en X o restringe una acción"            |
| Curación / soporte            | Recuperación o draw              | "Gana X LP / roba una carta / regresa carta"            |
| Habilidad pasiva (Ability)    | Efecto continuo o trigger pasivo | "Mientras esté boca arriba: [condición permanente]"     |
| Movimiento signature (STAB)   | Win condition / efecto poderoso  | "Una vez por duel; efecto devastador con coste alto"    |

### Reglas de asignación
- Máximo **3 efectos** por monstruo (incluyendo habilidad pasiva)
- El movimiento signature (STAB + mayor poder) es siempre el efecto más poderoso
- **Regla STAB:** si el movimiento es del mismo tipo que el Pokémon, el efecto recibe +500 de daño/burn o una condición adicional
- Máx. 1 efecto de negación por monstruo, y solo en niveles 8+

---

## 5. Legendarios — Restricciones de Invocación

| Categoría                          | Mecanismo YGO                                              |
|------------------------------------|------------------------------------------------------------|
| Dúos (Latios/Latias, etc.)         | El otro miembro debe estar en GY o banished               |
| Tríos (Beasts, Swords, etc.)       | Al menos 1 del trío en campo o GY                         |
| Creación (Arceus, Dialga…)         | Ritual Summon; no puede ser negado al invocar             |
| Mythicals (Mew, Celebi, Jirachi…) | Special Summon condicionado; máx. 1 en campo siempre      |
| Ultra Beasts                       | Requieren Field Spell 'Ultra Wormhole' activa             |

**Reglas generales de legendarios:**
- No pueden invocarse por tributo estándar
- Inmunes a efectos que cambien su nombre o tipo
- No pueden ser controlados por el oponente
- Máximo 1 copia en el deck

---

## 6. Arquetipos y Sinergia

- **Arquetipo familiar:** setcode único por línea evolutiva
- **Arquetipo de tipo:** setcode compartido por todos los del mismo tipo
- Un monstruo pertenece a **ambos** arquetipos simultáneamente

### Field Spells de tipo (referencia)
Cada tipo tiene una Field Spell que activa su estrategia macro:
- Fuego: bono de daño por batalla a todos los FIRE
- Agua: protección contra selección de objetivo
- Planta: recuperación de LP al final de turno
- Eléctrico: invocación especial adicional por turno
- Roca: negación de daño en posición defensiva

---

## 7. Límites de Balanceo

| Nivel           | ATK Máximo | Efectos Máximos               |
|-----------------|------------|-------------------------------|
| 1–3             | 1200       | 1 efecto simple               |
| 4               | 1900       | 1–2 efectos                   |
| 5–6             | 2400       | 2 efectos                     |
| 7–8             | 2800       | 2–3 efectos                   |
| 9–12 / Extra    | 3500       | 3 efectos (1 puede ser negación)|

---

## 8. Checklist de Diseño

Antes de entregar una carta, verificar:

- [ ] ¿El efecto evoca inmediatamente al Pokémon que representa?
- [ ] ¿ATK/DEF es consistente con la tabla de BST?
- [ ] ¿El nivel refleja la etapa evolutiva?
- [ ] ¿El monstruo pertenece al arquetipo familiar Y al de tipo?
- [ ] ¿La carta contribuye a la estrategia macro de su tipo?
- [ ] ¿El efecto más poderoso tiene un costo proporcional?
- [ ] ¿El monstruo es autosuficiente sin ser injugable en su familia?

---

## 9. Ejemplo de Referencia — Línea Bulbasaur

**Bulbasaur** | Nv.3 | EARTH | Plant | ATK 900 / DEF 700
> Una vez por turno, si ataca o es atacado: gana 300 LP al final del Damage Step.
> Si es enviado al GY para invocar 'Ivysaur' o 'Venusaur': recupera 500 LP.

**Ivysaur** | Nv.5 | EARTH | Plant | ATK 1500 / DEF 1300
> Puedes invocar de forma especial tributando 1 'Bulbasaur' de tu mano o campo.
> Al ser invocado: añade 1 Spell/Trap [Bulbasaur] desde tu deck a la mano.
> Una vez por turno: inflige 200 de daño al LP del oponente (Leech Seed).

**Venusaur** | Nv.7 | EARTH | Plant | ATK 2100 / DEF 2100
> Requiere 'Ivysaur' como tributo. Mientras esté boca arriba: ganas 300 LP al inicio de tus turnos.
> Una vez por turno (Quick Effect): reduce el ATK de un monstruo del oponente en 500.
> Al final del turno del oponente: si tiene 3000 LP menos que al inicio, inflige 500 de daño.

**Mega Venusaur** | Fusion Nv.9 | EARTH | Plant | ATK 2800 / DEF 2600
> Materiales: 'Venusaur' + 'Venusaurita'. No puede ser destruido por efectos ni seleccionado como objetivo.
> Una vez por turno: recupera 800 LP y reduce el ATK de todos los monstruos del oponente en 300.

---

## Flujo de trabajo al diseñar una carta

1. **Identificar el Pokémon** → consultar su tipo, BST, etapa evolutiva, movimientos signature y Ability
2. **Mapear estadísticas** → Atributo, Raza, Nivel, ATK/DEF usando las tablas de la Sección 1
3. **Asignar estrategia macro** → ¿qué tipo es? → revisar Sección 2 para orientar los efectos
4. **Traducir movimientos** → seleccionar los 2-3 más representativos + la Ability pasiva (Sección 4)
5. **Definir mecanismo de invocación** → si es evolución, ¿qué método usa? (Sección 3)
6. **Aplicar restricciones de legendario** si aplica (Sección 5)
7. **Pasar el checklist** (Sección 8)
8. **Presentar la carta** con: nombre, nivel, tipo, raza, atributo, ATK/DEF, arquetipos y texto de efecto

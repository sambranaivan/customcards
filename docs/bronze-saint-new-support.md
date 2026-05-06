# Bronze Saint / Bronze Cloth — Nuevo Soporte

Resumen de las 6 cartas añadidas al set `saint-seiya.cdb` en esta sesión, más notas de diseño y balance.

---

## Cartas de Soporte (IDs 922100303–922100307)

### 922100303 · Bronze Cloth Awakening
**Quick-Play Spell** | Archetypes: Bronze Saint, Bronze Cloth, saint-seiya

> Equip up to 2 "Bronze Cloth" Equip Spells with different names from your Deck to 1 "Bronze Saint" monster you control. You cannot Special Summon from the Extra Deck the turn you activate this card, except "Saint" monsters. You can only activate 1 "Bronze Cloth Awakening" per turn.

**Función en el arquetipo:** Tutoriza hasta 2 Bronze Cloths directamente desde el Deck, acelerando la preparación para el boss. La restricción de Extra Deck evita que la carta sea demasiado genérica como motor de equipo.

**Notas de diseño:** El filtro de "different names" está implementado con un argumento extra pasado al segundo `clothfilter`, evitando duplicados de nombre en la misma activación.

---

### 922100304 · Legend of the Bronze Saints
**Field Spell** | Archetypes: Bronze Saint, saint-seiya

> All "Bronze Saint" monsters gain 500 ATK/DEF.
> Once per turn: You can target 1 "Bronze Saint" monster you control equipped with a "Bronze Cloth" Equip Spell; until the End Phase, that target gains ATK equal to its current DEF.
> Once per turn, if a "Bronze Saint" monster you control would be destroyed by battle or card effect: You can send 1 "Bronze Cloth" Equip Spell equipped to it to the GY instead.
> You can only use each effect of "Legend of the Bronze Saints" once per turn.

**Función en el arquetipo:** Campo central del arquetipo. El efecto pasivo (+500) apoya tanto a los monstruos de mano como al boss. El efecto ② convierte DEF en ATK, recompensando tener Bronze Cloths equipadas. El efecto ③ actúa como escudo de destrucción sacrificando una Cloth (sin necesitar material separado), y lleva Cloths al GY para que el boss pueda recuperarlas después.

**Notas de diseño:** El efecto ③ usa `EFFECT_DESTROY_REPLACE` con condición que verifica si hay al menos una Cloth equipada al monstruo objetivo, evitando activaciones vacías.

---

### 922100305 · Saintly Bond
**Normal Spell** | Archetypes: Bronze Saint, Bronze Cloth, saint-seiya

> Target 1 "Bronze Saint" monster in your GY; Special Summon it, then you can equip 1 "Bronze Cloth" Equip Spell from your GY to it.
> If this card is in your GY: You can banish this card; add 1 "Bronze Saint" monster or 1 "Bronze Cloth" Equip Spell from your Deck to your hand.
> You can only use each effect of "Saintly Bond" once per turn.

**Función en el arquetipo:** Recuperación y búsqueda. El efecto principal devuelve un Bronze Saint y le reequipa una Cloth desde el GY en un solo movimiento. El efecto de GY es un searcher de coste mínimo que puede encontrar tanto monstruos como Cloths, dando consistencia.

**Notas de diseño:** El efecto de GY usa `aux.bfgcost` (banish self) como coste, limitando recursión excesiva. El `SelectYesNo` en la operación del efecto principal hace que equipar la Cloth sea opcional.

---

### 922100306 · Bronze Saint Oath
**Counter Trap** | Archetypes: Bronze Saint, saint-seiya

> When your opponent activates a card or effect while you control a "Bronze Saint" monster equipped with a "Cloth" card: Negate the activation, and if you do, destroy that card.
> You can only activate 1 "Bronze Saint Oath" per turn.

**Función en el arquetipo:** Respuesta reactiva. Requiere tener un Bronze Saint equipado con cualquier Cloth, incentivando mantener al menos una Cloth en campo. Al ser Counter Trap, funciona en Chain Link 1+ y no puede ser negada por Spell Speed 2.

**Notas de diseño:** La condición verifica `GetEquipGroup():IsExists(Card.IsSetCard,1,nil,SET_CLOTH)`, que cubre tanto Bronze Cloth (SET_BRONZE_CLOTH) como cualquier otra Cloth del arquetipo padre SET_CLOTH.

---

### 922100307 · Cosmo Surge
**Quick-Play Spell** | Archetypes: Bronze Saint, Cloth, saint-seiya

> Target 1 "Bronze Saint" monster you control; until the End Phase of this turn, it gains 500 ATK for each "Cloth" Equip Spell equipped to "Bronze Saint" monsters you control.
> You can only activate 1 "Cosmo Surge" per turn.

**Función en el arquetipo:** Bomba de ATK situacional. Con 2–3 Cloths en campo da entre +1000 y +1500 ATK, suficiente para voltear combates. Escala con Bronze Cloth Awakening (que puede poner 2 Cloths de golpe).

**Notas de diseño:** Itera todos los Bronze Saints con `GetMatchingGroup` y suma sus `GetEquipGroup():Filter()` contando solo Equip Spells de tipo Cloth. El boost es fijo hasta End Phase (`RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END`).

---

## Carta Boss (ID 922100308)

### 922100308 · Bronze Saints - Burning Five Stars
**Xyz Effect Monster** | Rank 4 | LIGHT | Warrior | ATK 2800 / DEF 2400  
Archetypes: Bronze Saint, saint

> 3 Level 4 "Bronze Saint" monsters
>
> ① While this card has 3 or more Xyz Materials, it cannot be destroyed by battle or card effects, and your opponent cannot target it with card effects.
>
> ② Once per turn: You can detach 1 "Bronze Cloth" Equip Spell Xyz Material from this card; this card can make 2 attacks on monsters this turn, also for each of its attacks this turn, your opponent cannot activate cards or effects until the end of the Damage Step.
> You can only use this effect of "Bronze Saints - Burning Five Stars" once per turn.
>
> ③ Once per turn: You can target 1 "Bronze Cloth" Equip Spell in your GY; attach it to this card as Xyz Material. If you activate this effect, you cannot activate the other effect of "Bronze Saints - Burning Five Stars" this turn.
> You can only use this effect of "Bronze Saints - Burning Five Stars" once per turn.
>
> ④ When this card is destroyed and sent to the GY: You can Special Summon up to 3 "Bronze Saint" monsters from your GY.

**Función en el arquetipo:** Boss definitivo. Requiere 3 Bronze Saints (los 5 Caballeros de Bronce clásicos reducidos a 3 para viabilidad competitiva), que son exactamente el objetivo de todo el soporte de nivel 4. Representa el momento en que los Caballeros combinan su Cosmo para superar al enemigo.

---

### Desglose de efectos

| # | Efecto | Condición | Mecánica clave |
|---|--------|-----------|----------------|
| ① | Indestructible + no-target | 3+ materiales | `EFFECT_INDESTRUCTABLE_BATTLE/EFFECT` + `EFFECT_CANNOT_BE_EFFECT_TARGET` |
| ② | Doble ataque + lock de activación | No haber usado ③ este turno | `EFFECT_EXTRA_ATTACK` + `EFFECT_CANNOT_ACTIVATE` hasta End of Damage Step |
| ③ | Recuperar Bronze Cloth desde GY como material | Bronze Cloth en GY | `Duel.Overlay` + `RegisterFlagEffect` |
| ④ | Revivir hasta 3 Bronze Saints desde GY | Destruido y enviado al GY | `EFFECT_TYPE_TRIGGER_O` + `EFFECT_FLAG_DELAY` |

---

### Fix de balance: combo ③ → ② (mismo turno)

**Problema detectado:** Activar ③ (adjuntar Bronze Cloth del GY) y luego ② (destacar Bronze Cloth → doble ataque) en el mismo turno resultaba en un combo de coste neto cero — la Cloth volvía del GY para ser inmediatamente destacada gratis.

**Solución implementada:**

```lua
-- En s.ovaop (efecto ③): marca el turno con un flag al resolver
c:RegisterFlagEffect(id, RESET_PHASE+PHASE_END, 0, 1)

-- En s.furcon (efecto ②): bloquea si el flag está activo
return c:GetOverlayGroup():IsExists(s.clothmatfilter,1,nil)
    and c:GetFlagEffect(id)==0
```

El flag se resetea al final del turno (`RESET_PHASE+PHASE_END`), por lo que en turnos siguientes ambos efectos pueden usarse con normalidad. El texto de la carta también fue actualizado para reflejar la restricción explícitamente.

---

## Sinergia entre cartas

```
Bronze Cloth Awakening
  → pone 2 Cloths al Bronze Saint
  → habilita Bronze Saint Oath (Cloth equipada)
  → escala Cosmo Surge (+1000 ATK mínimo)

Legend of the Bronze Saints (campo)
  → si esa Cloth muere, la manda al GY en lugar de destruir al monstruo
  → Bronze Saints - Burning Five Stars puede recuperarla con efecto ③

Saintly Bond (GY)
  → si el boss es destruido, ④ revive hasta 3 Bronze Saints
  → Saintly Bond los puede re-equipar con Cloths y buscar piezas para re-Xyz
```

---

## Archivos modificados

| Archivo | Descripción |
|---------|-------------|
| `script/unofficial/c922100303.lua` | Bronze Cloth Awakening |
| `script/unofficial/c922100304.lua` | Legend of the Bronze Saints |
| `script/unofficial/c922100305.lua` | Saintly Bond |
| `script/unofficial/c922100306.lua` | Bronze Saint Oath |
| `script/unofficial/c922100307.lua` | Cosmo Surge |
| `script/unofficial/c922100308.lua` | Bronze Saints - Burning Five Stars (boss) |
| `tools/insert_bronze_saint_support_v1.py` | Insert IDs 922100303–922100307 |
| `tools/insert_bronze_saint_boss_v1.py` | Insert ID 922100308 |
| `expansions/saint-seiya.cdb` | DB actualizada |

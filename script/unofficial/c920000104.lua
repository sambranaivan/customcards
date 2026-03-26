-- Magikarp
local s,id=GetID()
function s.initial_effect(c)
    -- TODO: Programar efecto
    -- **Ability — Swift Swim (pasivo):** Esta carta no puede ser seleccionada como objetivo de efectos del oponente durante el turno en que fue invocada. Mientras esté boca arriba: registra acumulativamente en un contador toda reducción de ATK que sufra por efectos del oponente *(el contador de Furia — Magikarp absorbe cada humillación)*. **Restricción — Splash:** Esta carta no puede declarar ataques ni activar efectos ofensivos. Solo puede cambiar de posición de batalla una vez por turno. **Trigger — Evolución por Ira:** Si esta carta es destruida por el oponente y enviada al GY: invoca de forma especial 1 "Gyarados" desde tu mano o deck. Esta invocación no puede ser negada ni respondida. Al ser invocado por este efecto, "Gyarados" gana ATK igual al total del contador de Furia de Magikarp + 300.
end

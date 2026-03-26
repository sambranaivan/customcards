-- Gastly
local s,id=GetID()
function s.initial_effect(c)
    -- TODO: Programar efecto
    -- **Ability — Levitate (pasivo):** Esta carta no puede ser seleccionada como objetivo de efectos de monstruos EARTH. Mientras esté en el campo, el oponente no puede activar efectos que la seleccionen como objetivo único a menos que controle un monstruo DARK. *(Gastly flota — los ataques físicos no lo alcanzan)* **Trigger — Gas Tóxico:** Si esta carta es enviada al GY por cualquier medio: el oponente descarta 1 carta al azar de su mano. Si esa carta es un monstruo, es enviada directamente al GY del oponente en lugar de la mano *(el gas de Gastly es inevitable al morir)*. **Trigger de Evolución:** Si esta carta es enviada al GY mientras controlas 0 monstruos en el campo: puedes invocar de forma especial 1 "Haunter" desde tu mano o deck en posición de ataque. Esta invocación no puede ser negada.
end

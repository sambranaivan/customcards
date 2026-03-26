-- Eevee
local s,id=GetID()
function s.initial_effect(c)
    -- TODO: Programar efecto
    -- **Ability — Run Away (pasivo):** Esta carta no puede ser destruida en batalla por monstruos de ATK 2000 o mayor. En su lugar, regresa a la mano de su dueño al final del Damage Step. **Efecto de Invocación:** Al ser invocado normalmente: puedes añadir 1 carta de evolución [Eevee] *(Piedra o Eeveelution de Nv. 5)* desde tu deck a la mano. **Trigger:** Si es enviada al GY o regresa a la mano para invocar una Eeveelution: roba 1 carta. **Regla común:** Todas son Nivel 5, no pueden ser invocadas normalmente, y pertenecen al setcode **[Eevee]** + el setcode de su tipo propio. Al ser invocadas usando a Eevee como material, el trigger de Eevee se activa y robás 1 carta.
end

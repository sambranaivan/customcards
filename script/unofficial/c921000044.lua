-- Altar de las Cenizas
local s,id=GetID()
function s.initial_effect(c)
    -- TODO: Programar efecto
    -- Al activar esta carta: puedes añadir 1 monstruo [Moltres] de Nivel 4 o inferior desde tu deck a la mano. **Efecto Continuo — Brasas del GY:** Al inicio de tu Standby Phase: por cada monstruo FIRE en tu GY (máx. 5), inflige 100 de daño al oponente. *(Las cenizas de los caídos siguen ardiendo)* **Efecto Continuo — Resurgimiento:** Cuando 1 monstruo [Moltres] tuyo es destruido y enviado al GY: puedes Invocar de Forma Especial 1 monstruo [Moltres] de Nivel 4 o inferior desde tu GY en posición de ataque. **Efecto de Campo — Brasa Activa:** Si hay 3 o más contadores de Brasa en el campo: los efectos de burn de los monstruos [Moltres] que controles infligen 200 de daño adicional.
end

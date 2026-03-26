-- Poliwag
local s,id=GetID()
function s.initial_effect(c)
    -- TODO: Programar efecto
    -- **Ability — Water Absorb (pasivo):** Si el oponente activa un efecto WATER que te causaría daño de LP: niega ese efecto y ganas 500 LP en su lugar. *(Poliwag absorbe el agua del rival y la convierte en vitalidad propia)* **Hypnosis:** Una vez por turno: selecciona 1 monstruo boca arriba que controle el oponente; ese monstruo cambia a posición de defensa boca abajo y no puede cambiar de posición hasta el próximo Standby Phase del oponente. *(Hipnosis pone a dormir — el monstruo queda indefenso y expuesto al turno siguiente)* **Trigger:** Si es enviado al GY por cualquier efecto: puedes añadir 1 carta [Agua] de nivel 3 o menor desde tu deck a la mano.
end

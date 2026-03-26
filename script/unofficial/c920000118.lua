-- Gigantamax Gengar
local s,id=GetID()
function s.initial_effect(c)
    -- TODO: Programar efecto
    -- **Materiales:** 3 monstruos DARK, incluyendo al menos 1 "Gengar" No puede ser destruido por efectos del oponente mientras haya 3 o más cartas en tu GY. **G-Max Terror:** Al final de cada turno del oponente: el oponente banishea 1 carta al azar de su GY. Si la carta banisheada es un monstruo, inflige 500 de daño al LP del oponente. Si es una Spell o Trap, el oponente descarta 1 carta de su mano. *(G-Max Terror vacía progresivamente el GY del rival — el cementerio del oponente desaparece pieza a pieza)* **Una vez por turno *(Quick Effect)*:** Cuando el oponente invoca un monstruo: ese monstruo pierde 600 ATK hasta el final del turno. Si ya hay un monstruo con ese nombre en el GY del oponente, es destruido en su lugar. *(Gigantamax Gengar castiga las repeticiones — el mismo monstruo dos veces es su perdición)*
end

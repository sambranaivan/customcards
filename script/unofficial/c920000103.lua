-- Parasect
local s,id=GetID()
function s.initial_effect(c)
    -- TODO: Programar efecto
    -- **Ability — Dry Skin (pasivo):** Durante la Standby Phase del oponente: si el oponente controla un monstruo WATER, ganas 400 LP. Si el oponente controla un monstruo con ATK/DEF reducidos por efectos de esta carta: inflige 200 de daño a su LP. *(Dry Skin absorbe la humedad — y convierte el veneno lento en daño constante)* **Spore (STAB):** Una vez por turno: selecciona 1 monstruo boca arriba del oponente; ese monstruo es enviado al GY al inicio del próximo Standby Phase del oponente si su ATK es 1500 o menos. El oponente puede descartar 1 carta para cancelar este efecto. *(Spore es el movimiento de precisión perfecta de Parasect — la espora del hongo que lo habita se planta en la víctima y la consume)* **Leech Life:** Una vez por turno: si un monstruo del oponente tiene ATK/DEF reducidos por efectos [Bicho]: ganas 300 LP por cada reducción activa. *(Las esporas drenan la vitalidad — Leech Life convierte el debuff del deck en LP)*
end

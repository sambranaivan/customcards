-- Gengar
local s,id=GetID()
function s.initial_effect(c)
    -- TODO: Programar efecto
    -- Puedes invocar de forma especial esta carta desde tu GY (además del método estándar) si hay 5 o más cartas en el GY del oponente. Esta invocación especial desde el GY no puede ser negada. **Ability — Cursed Body (pasivo):** Una vez por turno, cuando el oponente activa el efecto de un monstruo que está en el campo: ese monstruo pierde 300 ATK permanentemente (no se revierte al final del turno). Si tiene 0 ATK o menos por este efecto, es destruido. *(Cursed Body convierte cualquier efecto del rival en una maldición sobre su propio monstruo)* **Shadow Ball *(Signature — STAB)*:** Una vez por turno: inflige daño al LP del oponente igual al número de cartas en ambos GY × 100, hasta un máximo de 2000. Si el oponente tiene 5 o más monstruos en su GY: inflige 2500 en su lugar. *(Shadow Ball es más potente cuanto más lleno está el cementerio — STAB Fantasma en su máxima expresión)*
end

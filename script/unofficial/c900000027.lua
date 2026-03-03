--Genkidama
local s,id=GetID()
local COUNTER_GENKIDAMA=0x91
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_COUNTER_PERMIT+COUNTER_GENKIDAMA)
	c:RegisterEffect(e1)
end

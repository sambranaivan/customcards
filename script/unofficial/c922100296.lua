--Mist of Limbo
--[==[
-- ID: 922100296
-- Type: Trap / Continuous Trap
--
-- Archetypes:
-- - Meta
-- - saint-seiya
--
-- Effect (EN):
-- Activate this card by paying 1000 LP. Negate the effects of all face-up Effect Monsters on the field (but their effects can still be activated).
--]==]
--Mist of Limbo
local s,id=GetID()
function s.initial_effect(c)
	-- Activate by paying 1000 LP
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- Continuous negate of face-up effect monsters
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DISABLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(function(e,c) return c:IsFaceup() and c:IsType(TYPE_EFFECT) end)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_DISABLE_EFFECT)
	c:RegisterEffect(e3)
end
s.listed_series={SET_META, SET_SAINT}

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	Duel.PayLPCost(tp,1000)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- nothing else
end

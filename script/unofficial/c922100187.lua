--Glacial Winds of Asgard
--[==[
-- ID: 922100187
-- Type: Spell / Normal Spell
--
-- Archetypes:
-- - saint-seiya
--
-- Effect (EN):
-- Place 1 Frost Counter on all face-up monsters your opponent controls.
-- For the rest of this turn after this card resolves, your opponent cannot activate cards or effects in response to the Special Summon of a "God Warrior" monster(s).
-- You can only activate 1 "Glacial Winds of Asgard" per turn.
--]==]
--Glacial Winds of Asgard
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_SAINT}

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	for tc in aux.Next(g) do
		tc:AddCounter(0x10f8,1)
	end
	-- For rest of turn, opponent cannot respond to your God Warrior Special Summons (approx.)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetOperation(s.chainlimop)
	Duel.RegisterEffect(e1,tp)
end
function s.chainlimop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(function(c) return c:IsControler(tp) and c:IsSetCard(SET_GOD_WARRIOR) end,1,nil) then
		Duel.SetChainLimitTillChainEnd(aux.FALSE)
	end
end

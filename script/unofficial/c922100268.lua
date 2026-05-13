--Revelation of the Cosmos
--[==[
-- ID: 922100268
-- Type: Spell / Normal Spell
--
-- Archetypes:
-- - Meta
-- Effect (EN):
-- Pay 1000 LP; draw 2 cards, then, if you control no monsters, you cannot Special Summon monsters from the Extra Deck for the rest of this turn.
-- You can only activate 1 "Revelation of the Cosmos" per turn.
--]==]
--Revelation of the Cosmos
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_META, SET_SAINT}

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	Duel.PayLPCost(tp,1000)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Draw(tp,2,REASON_EFFECT)
	if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(function(e,c) return c:IsLocation(LOCATION_EXTRA) end)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end

--Mitsumasa Kido - Legacy of the Foundation
--[==[
-- ID: 922100098
-- Type: Monster / Effect Monster
-- Level: 1
-- Attribute: EARTH
-- Race: Warrior
-- ATK/DEF: 0/0
--
-- Archetypes:
-- (setcode 0 — not in a named ProjectIgnis archetype series)
-- Effect (EN):
-- (Quick Effect): You can discard this card; this turn, each time your opponent Special Summons a monster(s) from the Extra Deck, immediately draw 1 card (max. 2 draws).
-- You can only use this effect of "Mitsumasa Kido - Legacy of the Foundation" once per turn.
--]==]
--Mitsumasa Kido - Legacy of the Foundation
local s,id=GetID()
function s.initial_effect(c)
	--Discard; draw when opponent SS from Extra (max 2)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable(REASON_COST) end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetCountLimit(2)
	e1:SetOperation(s.drop)
	Duel.RegisterEffect(e1,tp)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp then return end
	local ct=eg:FilterCount(Card.IsSummonLocation,nil,LOCATION_EXTRA)
	if ct<=0 then return end
	Duel.Draw(tp,1,REASON_EFFECT)
end

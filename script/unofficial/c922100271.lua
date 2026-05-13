--Blessing of the Moirai
--[==[
-- ID: 922100271
-- Type: Spell / Normal Spell
--
-- Archetypes:
-- - Meta
-- Effect (EN):
-- Draw 3 cards, then discard 2 cards.
-- You can only activate 1 "Blessing of the Moirai" per turn.
--]==]
--Blessing of the Moirai
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_META, SET_SAINT}

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Draw(tp,3,REASON_EFFECT)==0 then return end
	Duel.DiscardHand(tp,nil,2,2,REASON_EFFECT+REASON_DISCARD)
end

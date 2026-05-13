--Divine Wave of the Main Breadwinner
--[==[
-- ID: 922100267
-- Type: Spell / Quick-Play Spell
--
-- Archetypes:
-- (setcode 0 — not in a named ProjectIgnis archetype series)
-- Effect (EN):
-- Choose 1 occupied column; return all cards in that column to the hand.
-- If you control "Poseidon, God of the Seas - Awakened", banish those cards instead.
-- You can only activate 1 "Divine Wave of the Main Breadwinner" per turn.
--]==]
--Divine Wave of the Main Breadwinner
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_SAINT}

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- choose column 0-4
	local col=Duel.AnnounceNumber(tp,0,1,2,3,4)
	local g=Duel.GetMatchingGroup(function(c)
		return c:GetSequence()==col and c:IsOnField()
	end,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if #g==0 then return end
	local rem=Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,922100245),tp,LOCATION_MZONE,0,1,nil)
	if rem then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	else
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end

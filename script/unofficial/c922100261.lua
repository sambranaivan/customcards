--Gemini's Secret - Saga and Kanon
--[==[
-- ID: 922100261
-- Type: Spell / Quick-Play Spell
--
-- Archetypes:
-- (setcode 0 — not in a named ProjectIgnis archetype series)
-- Effect (EN):
-- Reveal 1 "Marine General - Kanon of Sea Dragon" in your hand, or control 1 face-up "Gold Saint - Saga of Gemini"; apply 1 of these effects.
-- ● Add 1 "Pillar" card from your Deck to your hand, then discard 1 card.
-- ● Target 1 monster on the field; move it to an adjacent Main Monster Zone.
-- ● Banish 1 "Pillar" card from your GY; draw 1 card.
-- You can only activate 1 "Gemini's Secret - Saga and Kanon" per turn.
--]==]
--Gemini's Secret - Saga and Kanon
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_SAINT}

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	return true
end
function s.pilldeck(c)
	return c:IsSetCard(SET_PILLAR) and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))
	if op==0 then
		-- add pillar then discard 1
		if Duel.IsExistingMatchingCard(s.pilldeck,tp,LOCATION_DECK,0,1,nil) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g=Duel.SelectMatchingCard(tp,s.pilldeck,tp,LOCATION_DECK,0,1,1,nil)
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
			Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_EFFECT+REASON_DISCARD)
		end
	elseif op==1 then
		-- move monster adjacent
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		local tc=g:GetFirst()
		if not tc then return end
		local seq=tc:GetSequence()
		if seq>0 and Duel.CheckLocation(tc:GetControler(),LOCATION_MZONE,seq-1) then
			Duel.MoveSequence(tc,seq-1)
		elseif seq<4 and Duel.CheckLocation(tc:GetControler(),LOCATION_MZONE,seq+1) then
			Duel.MoveSequence(tc,seq+1)
		end
	else
		-- banish pillar from GY; draw 1
		local g=Duel.GetMatchingGroup(function(c) return c:IsSetCard(SET_PILLAR) and c:IsAbleToRemoveAsCost() end,tp,LOCATION_GRAVE,0,nil)
		if #g==0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local tc=g:Select(tp,1,1,nil):GetFirst()
		Duel.Remove(tc,POS_FACEUP,REASON_COST)
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end

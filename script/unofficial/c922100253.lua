--Call of the Depths
--[==[
-- ID: 922100253
-- Type: Spell / Normal Spell
--
-- Archetypes:
-- (setcode 0 — not in a named ProjectIgnis archetype series)
-- Effect (EN):
-- Add 1 "Marine General" monster or 1 "Pillar" card from your Deck to your hand.
-- If you control a "Marine General" monster, you can add 1 "Marine General" monster and 1 "Pillar" card instead.
-- You can only activate 1 "Call of the Depths" per turn.
--]==]
--Call of the Depths
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_SAINT}

function s.mgfilter(c)
	return c:IsSetCard(SET_MARINE_GENERAL) and c:IsMonster() and c:IsAbleToHand()
end
function s.pillfilter(c)
	return c:IsSetCard(SET_PILLAR) and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local hasmg=Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_MARINE_GENERAL),tp,LOCATION_MZONE,0,1,nil)
	if hasmg then
		if Duel.IsExistingMatchingCard(s.mgfilter,tp,LOCATION_DECK,0,1,nil) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g=Duel.SelectMatchingCard(tp,s.mgfilter,tp,LOCATION_DECK,0,1,1,nil)
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
		if Duel.IsExistingMatchingCard(s.pillfilter,tp,LOCATION_DECK,0,1,nil) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g2=Duel.SelectMatchingCard(tp,s.pillfilter,tp,LOCATION_DECK,0,1,1,nil)
			Duel.SendtoHand(g2,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g2)
		end
	else
		local opt=0
		if Duel.IsExistingMatchingCard(s.pillfilter,tp,LOCATION_DECK,0,1,nil) and Duel.IsExistingMatchingCard(s.mgfilter,tp,LOCATION_DECK,0,1,nil) then
			opt=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
		elseif Duel.IsExistingMatchingCard(s.mgfilter,tp,LOCATION_DECK,0,1,nil) then
			opt=0
		else
			opt=1
		end
		local filter=(opt==0) and s.mgfilter or s.pillfilter
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,filter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then Duel.SendtoHand(g,nil,REASON_EFFECT) Duel.ConfirmCards(1-tp,g) end
	end
end

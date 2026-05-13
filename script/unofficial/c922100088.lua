--Athena's Call
--[==[
-- ID: 922100088
-- Type: Spell / Normal Spell
--
-- Archetypes:
-- (setcode 0 — not in a named ProjectIgnis archetype series)
-- Effect (EN):
-- Add 1 Level 4 or lower "Saint" monster from your Deck to your hand, also, if you control no monsters, add 1 "Kiki - Messenger of the Cloth Sculptor" from your Deck to your hand.
-- You can only activate 1 "Athena's Call" per turn.
--]==]
--Athena's Call
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

s.listed_series={SET_SAINT}
s.listed_names={922100011}

function s.lowlevelsaintfilter(c)
	return c:IsSetCard(SET_SAINT) and c:IsMonster() and c:IsLevelBelow(4) and c:IsAbleToHand()
end
function s.kikifilter(c)
	return c:IsCode(922100011) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.lowlevelsaintfilter,tp,LOCATION_DECK,0,1,nil)
	end
	local ct=1
	if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 and Duel.IsExistingMatchingCard(s.kikifilter,tp,LOCATION_DECK,0,1,nil) then
		ct=2
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,ct,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local nomon=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.lowlevelsaintfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g==0 then return end
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,g)
	if nomon then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g2=Duel.SelectMatchingCard(tp,s.kikifilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g2>0 then
			Duel.SendtoHand(g2,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g2)
		end
	end
end

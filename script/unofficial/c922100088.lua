--Athena's Call
--[==[
-- ID: 922100088
-- Type: Spell / Normal Spell
--
-- Archetypes:
-- - saint-seiya
--
-- Effect (EN):
-- Add 1 Level 4 or lower "Saint" monster from your Deck to your hand, or if you control no monsters, you can add 1 "Kiki - Messenger of the Cloth Sculptor" instead.
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

function s.saintfilter(c)
	return c:IsSetCard(SET_SAINT) and c:IsMonster() and c:IsLevelBelow(4) and c:IsAbleToHand()
end
function s.kikifilter(c)
	return c:IsCode(922100011) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.saintfilter,tp,LOCATION_DECK,0,1,nil)
			or (Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 and Duel.IsExistingMatchingCard(s.kikifilter,tp,LOCATION_DECK,0,1,nil))
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local op=0
	local cankiki=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 and Duel.IsExistingMatchingCard(s.kikifilter,tp,LOCATION_DECK,0,1,nil)
	if cankiki then
		op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
	end
	if op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.kikifilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.saintfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end

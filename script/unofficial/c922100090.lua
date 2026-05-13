--Meditation at Star Hill
--[==[
-- ID: 922100090
-- Type: Spell / Normal Spell
--
-- Archetypes:
-- (setcode 0 — not in a named ProjectIgnis archetype series)
-- Effect (EN):
-- Excavate the top 3 cards of your Deck, add 1 excavated card to your hand, also shuffle the rest into the Deck.
-- If the added card is a "Cloth" card, you can reveal 1 "Saint" monster in your hand; Special Summon it.
-- You can only activate 1 "Meditation at Star Hill" per turn.
--]==]
--Meditation at Star Hill
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

s.listed_series={SET_SAINT,SET_CLOTH}

function s.saintinhand(c,e,tp)
	return c:IsSetCard(SET_SAINT) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<3 then return end
	Duel.ConfirmDecktop(tp,3)
	local g=Duel.GetDecktopGroup(tp,3)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sg=g:Select(tp,1,1,nil)
	local tc=sg:GetFirst()
	if tc and tc:IsAbleToHand() then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,Group.FromCards(tc))
		g:RemoveCard(tc)
	end
	Duel.ShuffleDeck(tp)
	if tc and tc:IsSetCard(SET_CLOTH) and Duel.IsExistingMatchingCard(s.saintinhand,tp,LOCATION_HAND,0,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
			local rg=Duel.SelectMatchingCard(tp,Card.IsSetCard,tp,LOCATION_HAND,0,1,1,nil,SET_SAINT)
			if #rg==0 then return end
			Duel.ConfirmCards(1-tp,rg)
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local spg=Duel.SelectMatchingCard(tp,s.saintinhand,tp,LOCATION_HAND,0,1,1,nil,e,tp)
			if #spg>0 then
				Duel.SpecialSummon(spg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end

--Pope's Mandate - Extermination Order
--[==[
-- ID: 922100139
-- Type: Spell / Normal Spell
--
-- Archetypes:
-- (setcode 0 — not in a named ProjectIgnis archetype series)
-- Effect (EN):
-- Send 1 "Envoy of the Pope" monster from your Deck to the GY; add 1 "Pope's Mandate" card from your Deck to your hand, except "Pope's Mandate - Extermination Order".
-- If your opponent controls a Level 4 or lower monster, you can apply this effect after this card resolves.
-- ● Special Summon 1 "Envoy of the Pope" monster from your hand.
-- You can only activate 1 "Pope's Mandate - Extermination Order" per turn.
--]==]
--Pope's Mandate - Extermination Order
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

s.listed_series={SET_POPES_MANDATE,SET_ENVOY_OF_THE_POPE}

function s.tgfilter(c)
	return c:IsSetCard(SET_ENVOY_OF_THE_POPE) and c:IsMonster() and c:IsAbleToGrave()
end
function s.thfilter(c)
	return c:IsSetCard(SET_POPES_MANDATE) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.envoyhand(c,e,tp)
	return c:IsSetCard(SET_ENVOY_OF_THE_POPE) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
			and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tg=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=tg:GetFirst()
	if not tc then return end
	if Duel.SendtoGrave(tc,REASON_EFFECT)==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
	--Optional SS from hand if opponent controls Level 4 or lower
	if Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and c:IsLevelBelow(4) end,tp,0,LOCATION_MZONE,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.envoyhand,tp,LOCATION_HAND,0,1,nil,e,tp)
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,s.envoyhand,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if #sg>0 then
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

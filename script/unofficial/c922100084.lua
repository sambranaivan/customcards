--Sanctuary Assassination Order (Normal Spell)
--[==[
-- ID: 922100084
-- Type: Spell / Normal Spell
--
-- Archetypes:
-- (setcode 0 — not in a named ProjectIgnis archetype series)
-- Effect (EN):
-- Target 1 "Silver Saint" monster you control and 1 monster your opponent controls; destroy them, and if you do, you can Special Summon 1 "Bronze Saint" monster from your Deck.
-- If this card is in your GY: You can banish this card; add 1 "Silver Cloth" card from your Deck to your hand.
-- You can only use this GY effect of "Sanctuary Assassination Order" once per turn.
--]==]
--Sanctuary Assassination Order (Normal Spell)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	--GY: banish; add 1 "Silver Cloth"
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end

s.listed_series={SET_SAINT,SET_SILVER_SAINT,SET_BRONZE_SAINT,SET_CLOTH}

function s.silverfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_SILVER_SAINT)
end
function s.oppfilter(c)
	return c:IsFaceup() and c:IsMonster()
end
function s.bronzefilter(c,e,tp)
	return c:IsSetCard(SET_BRONZE_SAINT) and c:IsLevelBelow(4)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then
		return Duel.IsExistingTarget(s.silverfilter,tp,LOCATION_MZONE,0,1,nil)
			and Duel.IsExistingTarget(s.oppfilter,tp,0,LOCATION_MZONE,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g1=Duel.SelectTarget(tp,s.silverfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g2=Duel.SelectTarget(tp,s.oppfilter,tp,0,LOCATION_MZONE,1,1,nil)
	g1:Merge(g2)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g<2 then return end
	if Duel.Destroy(g,REASON_EFFECT)==0 then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if Duel.IsExistingMatchingCard(s.bronzefilter,tp,LOCATION_DECK,0,1,nil,e,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,s.bronzefilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #sg>0 then
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

function s.silverclothfilter(c)
	return c:IsType(TYPE_EQUIP) and c:IsSetCard(SET_SILVER_CLOTH) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.silverclothfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.silverclothfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

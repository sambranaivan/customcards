--Saintly Bond
--[==[
-- ID: 922100305
-- Type: Spell / Normal Spell
--
-- Archetypes:
-- - saint-seiya
-- - saint
-- - Bronze Saint
-- - Bronze Cloth
--
-- Effect (EN):
-- Target 1 "Bronze Saint" monster in your GY; Special Summon it, then you can equip 1 "Bronze Cloth" Equip Spell from your GY to it.
-- If this card is in your GY: You can banish this card; add 1 "Bronze Saint" monster or 1 "Bronze Cloth" Equip Spell from your Deck to your hand.
-- You can only use each effect of "Saintly Bond" once per turn.
--]==]
--Saintly Bond
local s,id=GetID()
function s.initial_effect(c)
	--Activate: SP Summon Bronze Saint from GY, then optionally equip Bronze Cloth from GY
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	--GY: banish this card; add 1 Bronze Saint or Bronze Cloth from Deck to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.gyetg)
	e2:SetOperation(s.gyeop)
	c:RegisterEffect(e2)
end

s.listed_series={SET_SAINT,SET_BRONZE_SAINT,SET_CLOTH,SET_BRONZE_CLOTH}

-- SP Summon from GY
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_BRONZE_SAINT) and c:IsMonster()
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.clothgyfilter(c)
	return c:IsSetCard(SET_BRONZE_CLOTH) and c:IsType(TYPE_EQUIP)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp) end
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		if tc:IsFaceup()
			and Duel.IsExistingMatchingCard(s.clothgyfilter,tp,LOCATION_GRAVE,0,1,nil)
			and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
			local g=Duel.SelectMatchingCard(tp,s.clothgyfilter,tp,LOCATION_GRAVE,0,1,1,nil)
			local cloth=g:GetFirst()
			if cloth and tc:IsFaceup() then
				Duel.Equip(tp,cloth,tc,true)
			end
		end
	end
end

-- GY effect: add Bronze Saint or Bronze Cloth from Deck to hand
function s.gyefilter(c)
	return ((c:IsSetCard(SET_BRONZE_SAINT) and c:IsMonster())
		or (c:IsSetCard(SET_BRONZE_CLOTH) and c:IsType(TYPE_EQUIP)))
		and c:IsAbleToHand()
end
function s.gyetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.gyefilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.gyeop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.gyefilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

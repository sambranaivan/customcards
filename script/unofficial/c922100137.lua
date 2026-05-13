--Pope's Mandate - Chain of Command
--[==[
-- ID: 922100137
-- Type: Spell / Continuous Spell
--
-- Archetypes:
-- (setcode 0 — not in a named ProjectIgnis archetype series)
-- Effect (EN):
-- When this card is activated: You can add 1 "Envoy of the Pope" monster from your Deck to your hand.
-- Once per turn: You can reveal 1 "Envoy of the Pope" monster in your hand; Special Summon 1 "Envoy of the Pope" monster with a different name from your hand.
-- Also, for the rest of this turn after this effect resolves, you cannot Special Summon monsters from the Extra Deck, except "Saint" monsters.
-- If this face-up card leaves the field by an opponent's card effect: You can Special Summon 1 "Pope Ares - Voice of the Sanctuary" from your hand, Deck, or GY.
-- You can only activate 1 "Pope's Mandate - Chain of Command" per turn.
--]==]
--Pope's Mandate - Chain of Command
local s,id=GetID()
function s.initial_effect(c)
	--Activate + search Envoy
	local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e0:SetOperation(s.actop)
	c:RegisterEffect(e0)

	--Reveal 1 Envoy; Special Summon different Envoy from hand + ED lock
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,{id,1})
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	--If leaves field by opponent: SS Pope Ares Voice from hand/Deck/GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,{id,2})
	e2:SetCondition(s.lvcon)
	e2:SetTarget(s.lvtg)
	e2:SetOperation(s.lvop)
	c:RegisterEffect(e2)
end

s.listed_series={SET_POPES_MANDATE,SET_ENVOY_OF_THE_POPE,SET_SAINT}
s.listed_names={922100105}

function s.envoyfilter(c)
	return c:IsSetCard(SET_ENVOY_OF_THE_POPE) and c:IsMonster() and c:IsAbleToHand()
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsExistingMatchingCard(s.envoyfilter,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.envoyfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end

function s.revfilter(c)
	return c:IsSetCard(SET_ENVOY_OF_THE_POPE) and c:IsMonster() and not c:IsPublic()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.revfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.revfilter,tp,LOCATION_HAND,0,1,1,nil)
	Duel.ConfirmCards(1-tp,g)
	e:SetLabel(g:GetFirst():GetCode())
	Duel.ShuffleHand(tp)
end
function s.spfilter(c,e,tp,code)
	return c:IsSetCard(SET_ENVOY_OF_THE_POPE) and c:IsMonster() and not c:IsCode(code)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local code=e:GetLabel()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp,code) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local code=e:GetLabel()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,code)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
		--ED lock except Saint
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(function(e,c,sump,sumtype,sumpos,targetp,se)
			return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(SET_SAINT)
		end)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end

function s.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and e:GetHandler():IsPreviousPosition(POS_FACEUP)
end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(Card.IsCode),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,922100105) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(Card.IsCode),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,922100105)
	local tc=g:GetFirst()
	if tc then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

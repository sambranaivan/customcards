--Gold Saint - Deathmask of Cancer, Envoy of the Pope
--[==[
-- ID: 922100130
-- Type: Monster / Effect Monster
-- Level: 8
-- Attribute: DARK
-- Race: Warrior
-- ATK/DEF: 2900/2500
--
-- Archetypes:
-- - saint
-- - Gold Saint
-- - Envoy of the Pope
-- Effect (EN):
-- Cannot be Normal Summoned/Set. Must be Special Summoned (from your hand or GY) by Tributing 1 "Envoy of the Pope" monster (from your hand or field).
-- If this card is Special Summoned: You can banish up to 2 cards from your opponent's GY, and if you do, this card gains 300 ATK for each card banished by this effect (permanent).
-- Once per turn (Quick Effect): You can send 1 "Envoy of the Pope" card from your hand or Deck to the GY, then target 1 face-up monster your opponent controls; banish it.
-- You can only use each effect of "Gold Saint - Deathmask of Cancer, Envoy of the Pope" once per turn.
--]==]
--Gold Saint - Deathmask of Cancer, Envoy of the Pope
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Cannot be Normal Summoned/Set
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_SUMMON)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	local e0b=e0:Clone()
	e0b:SetCode(EFFECT_CANNOT_MSET)
	c:RegisterEffect(e0b)

	--Special Summon proc (hand/GY) by tributing 1 Envoy from hand/field
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	--If Special Summoned: banish up to 2 from opponent GY; gain 300 ATK each (permanent)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)

	--Quick: send 1 Envoy from hand or Deck; banish 1 face-up monster
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_REMOVE+CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e3:SetCountLimit(1,{id,1})
	e3:SetCost(s.cost)
	e3:SetTarget(s.bantg)
	e3:SetOperation(s.banop)
	c:RegisterEffect(e3)
end

s.listed_series={SET_ENVOY_OF_THE_POPE,SET_GOLD_SAINT,SET_SAINT,SET_POPES_MANDATE}

function s.trfilter(c,tp)
	return c:IsSetCard(SET_ENVOY_OF_THE_POPE) and c:IsReleasable()
		and (c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) or c:IsLocation(LOCATION_HAND))
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.trfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,tp)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectMatchingCard(tp,s.trfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,tp)
	local tc=g:GetFirst()
	if tc then
		Duel.Release(tc,REASON_COST)
	end
end

function s.rmfilter(c)
	return c:IsAbleToRemove()
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,0,LOCATION_GRAVE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_GRAVE)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,0,LOCATION_GRAVE,1,2,nil)
	local ct=Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	if ct>0 then
		local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(300*ct)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
	end
end

function s.costfilter(c)
	return c:IsSetCard(SET_ENVOY_OF_THE_POPE) and c:IsAbleToGraveAsCost()
		and (c:IsLocation(LOCATION_HAND) or c:IsLocation(LOCATION_DECK))
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.banfilter(c)
	return c:IsFaceup() and c:IsMonster() and c:IsAbleToRemove()
end
function s.bantg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.banfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.banfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	Duel.SelectTarget(tp,s.banfilter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,0)
end
function s.banop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end

--Gold Saint - Shura of Capricorn, Envoy of the Pope
--[==[
-- ID: 922100132
-- Type: Monster / Effect Monster
-- Level: 8
-- Attribute: EARTH
-- Race: Warrior
-- ATK/DEF: 2800/2100
--
-- Archetypes:
-- - saint
-- - Gold Saint
-- - Envoy of the Pope
-- Effect (EN):
-- Cannot be Normal Summoned/Set. Must be Special Summoned (from your hand or GY) by Tributing 1 "Envoy of the Pope" monster.
-- This card's attacks cannot be negated, also this card can attack all monsters your opponent controls once each.
-- Once per turn (Quick Effect): You can target 1 card on the field; banish it.
-- While you control "Pope Ares", this card is unaffected by your opponent's Trap Card effects.
-- You can only use the third effect of "Gold Saint - Shura of Capricorn, Envoy of the Pope" once per turn.
--]==]
--Gold Saint - Shura of Capricorn, Envoy of the Pope
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

	--Special Summon proc (hand/GY) by tributing 1 Envoy
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	--Unstoppable attack + attack all
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UNSTOPPABLE_ATTACK)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_ATTACK_ALL)
	e3:SetValue(1)
	c:RegisterEffect(e3)

	--Quick: target 1 card; banish it
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e4:SetCountLimit(1,id)
	e4:SetTarget(s.rmtg)
	e4:SetOperation(s.rmop)
	c:RegisterEffect(e4)

	--While you control Pope Ares: unaffected by opponent Trap effects
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_IMMUNE_EFFECT)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(s.popecon)
	e5:SetValue(s.efilter)
	c:RegisterEffect(e5)
end

s.listed_series={SET_ENVOY_OF_THE_POPE,SET_GOLD_SAINT,SET_SAINT}
s.listed_names={922100105,922100135}

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
	if tc then Duel.Release(tc,REASON_COST) end
end

function s.rmfilter(c)
	return c:IsAbleToRemove()
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.rmfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	Duel.SelectTarget(tp,s.rmfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end

function s.popecon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,922100105,922100135),tp,LOCATION_MZONE,0,1,nil)
end
function s.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:IsActiveType(TYPE_TRAP)
end

--Gold Saint - Camus of Aquarius, Envoy of the Pope
--[==[
-- ID: 922100133
-- Type: Monster / Effect Monster
-- Level: 8
-- Attribute: WATER
-- Race: Warrior
-- ATK/DEF: 2700/2600
--
-- Archetypes:
-- - saint
-- - Gold Saint
-- - Envoy of the Pope
-- Effect (EN):
-- Cannot be Normal Summoned/Set. Must be Special Summoned (from your hand or GY) by Tributing 1 "Envoy of the Pope" monster.
-- Once per turn (Quick Effect): You can target 1 face-up monster your opponent controls; until the end of your opponent's next turn, its effects are negated, it cannot attack, cannot change its battle position, and cannot be Tributed or used as material.
-- While you control "Pope Ares", your opponent's monsters cannot target this card for attacks, except this one.
-- You can only use each effect of "Gold Saint - Camus of Aquarius, Envoy of the Pope" once per turn.
--]==]
--Gold Saint - Camus of Aquarius, Envoy of the Pope
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

	--Quick: freeze 1 face-up monster until end of opponent next turn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.tg)
	e2:SetOperation(s.op)
	c:RegisterEffect(e2)

	--While control Pope Ares: opponent must attack this if able
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCondition(s.popecon)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetValue(s.atlimit)
	c:RegisterEffect(e3)
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

function s.ffilter(c)
	return c:IsFaceup() and c:IsMonster()
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.ffilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.ffilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.ffilter,tp,0,LOCATION_MZONE,1,1,nil)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or not tc:IsFaceup() then return end
	local reset=RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(reset)
	tc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	tc:RegisterEffect(e2)
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_ATTACK)
	e3:SetReset(reset)
	tc:RegisterEffect(e3)
	local e4=Effect.CreateEffect(e:GetHandler())
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e4:SetReset(reset)
	tc:RegisterEffect(e4)
	local e5=Effect.CreateEffect(e:GetHandler())
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_UNRELEASABLE_SUM)
	e5:SetValue(1)
	e5:SetReset(reset)
	tc:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	tc:RegisterEffect(e6)
	local e7=Effect.CreateEffect(e:GetHandler())
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e7:SetValue(1)
	e7:SetReset(reset)
	tc:RegisterEffect(e7)
	local e8=e7:Clone()
	e8:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	tc:RegisterEffect(e8)
	local e9=e7:Clone()
	e9:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	tc:RegisterEffect(e9)
end

function s.popecon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,922100105,922100135),tp,LOCATION_MZONE,0,1,nil)
end
function s.atlimit(e,c)
	local ec=e:GetHandler()
	return c~=ec and c:IsFaceup()
end

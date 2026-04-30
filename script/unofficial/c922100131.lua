--Gold Saint - Aphrodite of Pisces, Envoy of the Pope
--[==[
-- ID: 922100131
-- Type: Monster / Effect Monster
-- Level: 8
-- Attribute: DARK
-- Race: Warrior
-- ATK/DEF: 2700/2700
--
-- Archetypes:
-- - Envoy of the Pope
-- - Gold Saint
-- - saint
-- - saint-seiya
--
-- Effect (EN):
-- Cannot be Normal Summoned/Set. Must be Special Summoned (from your hand or GY) by Tributing 1 "Envoy of the Pope" monster.
-- If this card is Special Summoned: Place 1 Royal Demon Rose Counter on each monster your opponent controls.
-- Monsters with a Royal Demon Rose Counter have their effects negated, also they lose 500 ATK for each counter on them.
-- During each End Phase: Place 1 Royal Demon Rose Counter on each monster your opponent controls, then destroy all monsters with 2 or more Royal Demon Rose Counters.
-- You can only use each effect of "Gold Saint - Aphrodite of Pisces, Envoy of the Pope" once per turn.
--]==]
--Gold Saint - Aphrodite of Pisces, Envoy of the Pope
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

	--If Special Summoned: place 1 Royal Demon Rose Counter on each opponent monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetOperation(s.spsucop)
	c:RegisterEffect(e2)

	--Negate effects of monsters with counter
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DISABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetTarget(s.cttg)
	c:RegisterEffect(e3)
	local e3b=e3:Clone()
	e3b:SetCode(EFFECT_DISABLE_EFFECT)
	c:RegisterEffect(e3b)

	--ATK down 500 per counter
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetTarget(s.cttg)
	e4:SetValue(s.atkval)
	c:RegisterEffect(e4)

	--Each End Phase: add counters then destroy monsters with 2+ counters
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,{id,1})
	e5:SetOperation(s.endop)
	c:RegisterEffect(e5)
end

s.listed_series={SET_ENVOY_OF_THE_POPE,SET_GOLD_SAINT,SET_SAINT}
s.counter_place_list={0x10f7}

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

function s.cttg(e,c)
	return c:GetCounter(0x10f7)>0
end
function s.atkval(e,c)
	return -500*c:GetCounter(0x10f7)
end

function s.addcounters(tp)
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsCanAddCounter,0x10f7,1),tp,0,LOCATION_MZONE,nil)
	for tc in aux.Next(g) do
		tc:AddCounter(0x10f7,1)
	end
end
function s.spsucop(e,tp,eg,ep,ev,re,r,rp)
	s.addcounters(tp)
end
function s.endop(e,tp,eg,ep,ev,re,r,rp)
	s.addcounters(tp)
	local g=Duel.GetMatchingGroup(function(c) return c:IsFaceup() and c:GetCounter(0x10f7)>=2 end,tp,0,LOCATION_MZONE,nil)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end

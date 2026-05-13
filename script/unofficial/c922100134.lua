--Gold Saint - Aiolia of Leo, Envoy of the Pope
--[==[
-- ID: 922100134
-- Type: Monster / Effect Monster
-- Level: 8
-- Attribute: LIGHT
-- Race: Beast-Warrior
-- ATK/DEF: 2800/2000
--
-- Archetypes:
-- - saint
-- - Gold Saint
-- - Envoy of the Pope
-- Effect (EN):
-- Cannot be Normal Summoned/Set. Must be Special Summoned (from your hand or GY) by Tributing 1 "Envoy of the Pope" monster.
-- If this card is Special Summoned: You can destroy monsters your opponent controls, up to the number of "Envoy of the Pope" monsters you control.
-- This card can make a second attack on monsters during each Battle Phase.
-- If this card leaves the field by your opponent's card effect, during the next End Phase, inflict 2000 damage to your opponent.
-- You can only use each effect of "Gold Saint - Aiolia of Leo, Envoy of the Pope" once per turn.
--]==]
--Gold Saint - Aiolia of Leo, Envoy of the Pope
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

	--If Special Summoned: destroy monsters up to number of Envoys you control
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)

	--Second attack on monsters
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e3:SetValue(1)
	c:RegisterEffect(e3)

	--If leaves field by opponent: next End Phase burn 2000
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,{id,1})
	e4:SetCondition(s.burncon)
	e4:SetOperation(s.burnop)
	c:RegisterEffect(e4)
end

s.listed_series={SET_ENVOY_OF_THE_POPE,SET_GOLD_SAINT,SET_SAINT}

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

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,SET_ENVOY_OF_THE_POPE),tp,LOCATION_MZONE,0,nil)
	if chk==0 then return ct>0 and Duel.IsExistingMatchingCard(Card.IsDestructable,tp,0,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsDestructable,tp,0,LOCATION_MZONE,nil)
	if #g>ct then g=g:Select(tp,ct,ct,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,SET_ENVOY_OF_THE_POPE),tp,LOCATION_MZONE,0,nil)
	if ct<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,Card.IsDestructable,tp,0,LOCATION_MZONE,1,ct,nil)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end

function s.burncon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousPosition(POS_FACEUP)
end
function s.burnop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetOperation(function() Duel.Damage(1-tp,2000,REASON_EFFECT) end)
	Duel.RegisterEffect(e1,tp)
end

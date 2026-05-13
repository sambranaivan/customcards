--Marine General - Sorrento of Siren
--[==[
-- ID: 922100224
-- Type: Monster / Effect Monster
-- Level: 7
-- Attribute: WATER
-- Race: Warrior
-- ATK/DEF: 2300/2000
--
-- Archetypes:
-- - Marine General
-- Effect (EN):
-- If you control a "Pillar" card: You can Special Summon this card from your hand to your Main Monster Zone in the same column as that "Pillar" card.
-- Your opponent cannot target "Pillar" cards you control with card effects.
-- If "Pillar of the South Atlantic" is in your field or GY, opponent's monsters in this card's column have their original ATK halved, also their effects are negated.
-- You can only Special Summon "Marine General - Sorrento of Siren" once per turn this way.
--]==]
--Marine General - Sorrento of Siren
local s,id=GetID()
function s.initial_effect(c)
	-- Special Summon from hand if control Pillar
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_IGNITION)
	e0:SetRange(LOCATION_HAND)
	e0:SetCountLimit(1,id)
	e0:SetCondition(s.spcon)
	e0:SetTarget(s.sptg)
	e0:SetOperation(s.spop)
	c:RegisterEffect(e0)
	-- Pillars cannot be targeted by opponent effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_PILLAR))
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	-- Column debuff/negate (approx. if Pillar exists in field or GY)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SET_ATTACK_FINAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(s.colcon)
	e2:SetTarget(s.coltg)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DISABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCondition(s.colcon)
	e3:SetTarget(s.coltg)
	c:RegisterEffect(e3)
end
s.listed_series={SET_MARINE_GENERAL, SET_SAINT}

function s.pillfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_PILLAR)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.pillfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
end

function s.colcon(e)
	return Duel.IsExistingMatchingCard(aux.FilterBoolFunction(Card.IsSetCard,SET_PILLAR),e:GetHandlerPlayer(),LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil)
end
function s.coltg(e,c)
	return e:GetHandler():GetColumnGroup():IsContains(c)
end
function s.atkval(e,c)
	return math.floor(c:GetBaseAttack()/2)
end

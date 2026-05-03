--Marine General - Krishna of Chrysaor
--[==[
-- ID: 922100225
-- Type: Monster / Effect Monster
-- Level: 7
-- Attribute: WATER
-- Race: Warrior
-- ATK/DEF: 2600/2200
--
-- Archetypes:
-- - Marine General
-- - saint-seiya
--
-- Effect (EN):
-- If you control a "Pillar" card: You can Special Summon this card from your hand to your Main Monster Zone in the same column as that "Pillar" card.
-- If this card battles, your opponent cannot activate cards or effects until the end of the Damage Step.
-- If "Pillar of the Indian Ocean" is in your field, your opponent cannot Special Summon monsters to this card's column or adjacent columns.
-- You can only Special Summon "Marine General - Krishna of Chrysaor" once per turn this way.
--]==]
--Marine General - Krishna of Chrysaor
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
	-- Opponent cannot activate when this card battles
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetOperation(s.actop)
	c:RegisterEffect(e1)
	-- Summon restriction into this/adjacent columns if Pillar exists (approx.)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetCondition(s.rcon)
	e2:SetTarget(s.rtg)
	c:RegisterEffect(e2)
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

function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	Duel.RegisterEffect(e1,tp)
end

function s.rcon(e)
	return Duel.IsExistingMatchingCard(aux.FilterBoolFunction(Card.IsSetCard,SET_PILLAR),e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
function s.rtg(e,c,sump,sumtype,sumpos,targetp,se)
	local mc=e:GetHandler()
	if not c:IsLocation(LOCATION_MZONE) then return false end
	local seq=c:GetSummonLocation()==LOCATION_MZONE and c:GetSequence() or c:GetSequence()
	return (mc:GetColumnGroup():IsContains(c) or mc:GetAdjacentColumnGroup():IsContains(c))
end

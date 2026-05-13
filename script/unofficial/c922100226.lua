--Marine General - Isaac of Kraken
--[==[
-- ID: 922100226
-- Type: Monster / Effect Monster
-- Level: 7
-- Attribute: WATER
-- Race: Warrior
-- ATK/DEF: 2200/2100
--
-- Archetypes:
-- - Marine General
-- Effect (EN):
-- If you control a "Pillar" card: You can Special Summon this card from your hand to your Main Monster Zone in the same column as that "Pillar" card.
-- (Quick Effect): You can banish 1 "Pillar" card from your GY, then target 1 face-up monster your opponent controls; change it to face-down Defense Position.
-- If "Pillar of the Arctic Ocean" is in your field or is banished, this card gains 1000 ATK.
-- You can only use each effect of "Marine General - Isaac of Kraken" once per turn.
--]==]
--Marine General - Isaac of Kraken
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
	-- Quick: banish 1 Pillar; set monster facedown
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id+100)
	e1:SetCost(s.cost)
	e1:SetTarget(s.fdtg)
	e1:SetOperation(s.fdop)
	c:RegisterEffect(e1)
	-- Gain 1000 ATK if Pillar exists in field or banished
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.atkcon)
	e2:SetValue(1000)
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

function s.costfilter(c)
	return c:IsSetCard(SET_PILLAR) and c:IsAbleToRemoveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.fdfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
function s.fdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.fdfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.fdfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWN)
	local g=Duel.SelectTarget(tp,s.fdfilter,tp,0,LOCATION_MZONE,1,1,nil)
end
function s.fdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
function s.atkcon(e)
	return Duel.IsExistingMatchingCard(aux.FilterBoolFunction(Card.IsSetCard,SET_PILLAR),e:GetHandlerPlayer(),LOCATION_ONFIELD+LOCATION_REMOVED,0,1,nil)
end

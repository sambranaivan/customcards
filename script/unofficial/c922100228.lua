--Marine General - Baian of Sea Horse
--[==[
-- ID: 922100228
-- Type: Monster / Effect Monster
-- Level: 7
-- Attribute: WATER
-- Race: Warrior
-- ATK/DEF: 2400/2300
--
-- Archetypes:
-- - Marine General
-- Effect (EN):
-- If you control a "Pillar" card: You can Special Summon this card from your hand to your Main Monster Zone in the same column as that "Pillar" card.
-- (Quick Effect): You can target 1 card in this card's column; return it to the hand.
-- If "Pillar of the North Pacific" is in your field, "Marine General" monsters you control in this card's column cannot be destroyed by card effects.
-- You can only use each effect of "Marine General - Baian of Sea Horse" once per turn.
--]==]
--Marine General - Baian of Sea Horse
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
	-- Quick: bounce 1 card in this column
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id+100)
	e1:SetTarget(s.btg)
	e1:SetOperation(s.bop)
	c:RegisterEffect(e1)
	-- If Pillar exists, Marine Generals you control in this column indestructible by effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(s.indcon)
	e2:SetTarget(s.indtg)
	e2:SetValue(1)
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

function s.colfilter(c,mc)
	return c:IsAbleToHand() and mc:GetColumnGroup():IsContains(c)
end
function s.btg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.colfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,c) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,PLAYER_ALL,LOCATION_ONFIELD)
end
function s.bop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectMatchingCard(tp,s.colfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,c)
	if #g>0 then Duel.SendtoHand(g,nil,REASON_EFFECT) end
end
function s.indcon(e)
	return Duel.IsExistingMatchingCard(aux.FilterBoolFunction(Card.IsSetCard,SET_PILLAR),e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
function s.indtg(e,c)
	return c:IsSetCard(SET_MARINE_GENERAL) and e:GetHandler():GetColumnGroup():IsContains(c)
end

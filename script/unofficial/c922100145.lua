--Steel Saint - Ushio of Marine Armor
--[==[
-- ID: 922100145
-- Type: Monster / Effect Monster
-- Level: 4
-- Attribute: WATER
-- Race: Machine
-- ATK/DEF: 1300/1500
--
-- Archetypes:
-- - saint
-- - Steel Saint
-- Effect (EN):
-- When your opponent activates a card or effect that targets a "Saint" monster you control, or when your opponent declares an attack while you control a "Saint" monster (Quick Effect): You can discard this card; negate that activation or attack, and if you do, return 1 face-up card your opponent controls to the hand.
-- You can only use this effect of "Steel Saint - Ushio of Marine Armor" once per turn.
--]==]
--Steel Saint - Ushio of Marine Armor
local s,id=GetID()
function s.initial_effect(c)
	--Discard; negate activation/attack, then bounce 1 face-up card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.negcon)
	e1:SetCost(s.cost)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.atkcon)
	e2:SetCost(s.cost)
	e2:SetTarget(s.bouncetg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end

s.listed_series={SET_STEEL_SAINT,SET_SAINT}

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable(REASON_COST) end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function s.has_saint(tp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_SAINT),tp,LOCATION_MZONE,0,1,nil)
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or not Duel.IsChainNegatable(ev) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsExists(function(c) return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsSetCard(SET_SAINT) end,1,nil)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.bouncefilter(c)
	return c:IsFaceup() and c:IsAbleToHand()
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev)==0 then return end
	if not Duel.IsExistingMatchingCard(s.bouncefilter,tp,0,LOCATION_ONFIELD,1,nil) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectMatchingCard(tp,s.bouncefilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end

function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return s.has_saint(tp)
end
function s.bouncetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateAttack()==0 then return end
	if not Duel.IsExistingMatchingCard(s.bouncefilter,tp,0,LOCATION_ONFIELD,1,nil) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectMatchingCard(tp,s.bouncefilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end

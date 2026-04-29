--Crystal Wall
--[==[
-- ID: 922100101
-- Type: Trap / Counter Trap
--
-- Archetypes:
-- - saint-seiya
--
-- Effect (EN):
-- When your opponent activates a card or effect that targets 1 or more "Saint" monsters you control: Negate the activation, and if you do, return that card to the hand.
-- If you control "Gold Saint - Mu of Aries", you can activate this card from your hand by discarding 1 "Cloth" card.
-- You can only activate 1 "Crystal Wall" per turn.
--]==]
--Crystal Wall
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.negcon)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)

	--Activate from hand (Mu) by discarding 1 "Cloth"
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.handcon)
	e2:SetCost(s.handcost)
	c:RegisterEffect(e2)
end

s.listed_series={SET_SAINT,SET_CLOTH}
s.listed_names={922100029}

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or not Duel.IsChainNegatable(ev) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g then return false end
	return g:IsExists(function(c) return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsSetCard(SET_SAINT) end,1,nil)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if Duel.NegateActivation(ev)~=0 and rc and rc:IsRelateToEffect(re) then
		Duel.SendtoHand(rc,nil,REASON_EFFECT)
	end
end

function s.handcon(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,922100029),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function s.costfilter(c)
	return c:IsSetCard(SET_CLOTH) and c:IsDiscardable(REASON_COST)
end
function s.handcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,s.costfilter,1,1,REASON_COST+REASON_DISCARD,nil)
end

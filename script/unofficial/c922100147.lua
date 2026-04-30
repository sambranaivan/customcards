--Interception Protocol
--[==[
-- ID: 922100147
-- Type: Trap / Counter Trap
--
-- Archetypes:
-- - saint-seiya
--
-- Effect (EN):
-- When your opponent activates a card or effect that targets a "Saint" monster(s) you control: Negate the activation, and if you do, destroy that card.
-- Then, if you control a "Steel Saint" monster, you can draw 1 card.
-- You can only activate 1 "Interception Protocol" per turn.
--]==]
--Interception Protocol
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.negcon)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
end

s.listed_series={SET_STEEL_SAINT,SET_SAINT}

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or not Duel.IsChainNegatable(ev) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsExists(function(c) return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsSetCard(SET_SAINT) end,1,nil)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev)~=0 then
		Duel.Destroy(eg,REASON_EFFECT)
	end
	if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_STEEL_SAINT),tp,LOCATION_MZONE,0,1,nil) then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end

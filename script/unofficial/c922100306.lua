--Bronze Saint Oath
--[==[
-- ID: 922100306
-- Type: Trap / Counter Trap
--
-- Archetypes:
-- - saint-seiya
-- - saint
-- - Bronze Saint
--
-- Effect (EN):
-- When your opponent activates a card or effect while you control a "Bronze Saint" monster equipped with a "Cloth" card: Negate the activation, and if you do, destroy that card.
-- You can only activate 1 "Bronze Saint Oath" per turn.
--]==]
--Bronze Saint Oath
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.negcon)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
end

s.listed_series={SET_SAINT,SET_BRONZE_SAINT,SET_CLOTH}

function s.equippedfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_BRONZE_SAINT)
		and c:GetEquipGroup():IsExists(Card.IsSetCard,1,nil,SET_CLOTH)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or not Duel.IsChainNegatable(ev) then return false end
	return Duel.IsExistingMatchingCard(s.equippedfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev)~=0 then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end

--Desecrated Sagittarius - The Heist
--[==[
-- ID: 922100165
-- Type: Trap / Counter Trap
--
-- Archetypes:
-- (setcode 0 — not in a named ProjectIgnis archetype series)
-- Effect (EN):
-- When your opponent activates a card or effect, while you control a "Black Saint" monster equipped with a "Fragment of Sagittarius" card: Send 1 "Fragment of Sagittarius" Equip Spell you control to the GY; negate the activation, and if you do, destroy that card.
-- Then, if you control "Black Saint - Ikki, Leader of Death Queen Island", you can destroy 1 card your opponent controls.
-- You can only activate 1 "Desecrated Sagittarius - The Heist" per turn.
--]==]
--Desecrated Sagittarius - The Heist
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.negcon)
	e1:SetCost(s.cost)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
end

s.listed_series={SET_BLACK_SAINT,SET_FRAGMENT_OF_SAGITTARIUS}
s.listed_names={922100148}

function s.eqblackfrag(c)
	if not (c:IsFaceup() and c:IsSetCard(SET_BLACK_SAINT)) then return false end
	return c:GetEquipGroup():IsExists(Card.IsSetCard,1,nil,SET_FRAGMENT_OF_SAGITTARIUS)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and Duel.IsChainNegatable(ev)
		and Duel.IsExistingMatchingCard(s.eqblackfrag,tp,LOCATION_MZONE,0,1,nil)
end
function s.costfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EQUIP) and c:IsSetCard(SET_FRAGMENT_OF_SAGITTARIUS) and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_SZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_SZONE,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
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
	if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,922100148),tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(Card.IsDestructable,tp,0,LOCATION_ONFIELD,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,Card.IsDestructable,tp,0,LOCATION_ONFIELD,1,1,nil)
		if #g>0 then Duel.Destroy(g,REASON_EFFECT) end
	end
end

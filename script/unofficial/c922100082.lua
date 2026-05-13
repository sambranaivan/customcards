--Athena's Vanguard
--[==[
-- ID: 922100082
-- Type: Trap / Counter Trap
--
-- Archetypes:
-- (setcode 0 — not in a named ProjectIgnis archetype series)
-- Effect (EN):
-- If you control 3 or more "Saint" monsters with different names: When your opponent activates a card or effect: Negate the activation, and if you do, destroy that card.
--]==]
--Athena's Vanguard
local s,id=GetID()
function s.initial_effect(c)
	--Activate
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

s.listed_series={SET_SAINT}

function s.saintfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_SAINT)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or not Duel.IsChainNegatable(ev) then return false end
	local g=Duel.GetMatchingGroup(s.saintfilter,tp,LOCATION_MZONE,0,nil)
	if #g<3 then return false end
	local codes={}
	local ct=0
	for tc in aux.Next(g) do
		local cd=tc:GetCode()
		if not codes[cd] then
			codes[cd]=true
			ct=ct+1
			if ct>=3 then return true end
		end
	end
	return false
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

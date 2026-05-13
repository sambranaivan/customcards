--Verdict of the Gods
--[==[
-- ID: 922100282
-- Type: Trap / Counter Trap
--
-- Archetypes:
-- - Meta
-- Effect (EN):
-- When a monster effect is activated, or when a monster(s) would be Summoned: Pay 1500 LP; negate the activation or the Summon, and if you do, destroy that card.
--]==]
--Verdict of the Gods
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCost(s.cost)
	e1:SetCondition(s.negcon)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SUMMON)
	e2:SetCondition(s.sumcon)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON)
	e3:SetCondition(s.sumcon)
	c:RegisterEffect(e3)
end
s.listed_series={SET_META, SET_SAINT}

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1500) end
	Duel.PayLPCost(tp,1500)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetCode()==EVENT_CHAINING then
		if Duel.NegateActivation(ev)~=0 then
			Duel.Destroy(re:GetHandler(),REASON_EFFECT)
		end
	else
		local g=eg
		Duel.NegateSummon(g)
		Duel.Destroy(g,REASON_EFFECT)
	end
end

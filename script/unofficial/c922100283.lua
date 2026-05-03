--Judgment of Olympus
--[==[
-- ID: 922100283
-- Type: Trap / Counter Trap
--
-- Archetypes:
-- - Meta
-- - saint-seiya
--
-- Effect (EN):
-- When a monster would be Summoned, OR a Spell/Trap Card is activated: Pay half your LP; negate the Summon or activation, and if you do, destroy that card.
--]==]
--Judgment of Olympus
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
	if chk==0 then return Duel.GetLP(tp)>1 end
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
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

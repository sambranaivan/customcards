--Titan's Strike
--[==[
-- ID: 922100276
-- Type: Spell / Normal Spell
--
-- Archetypes:
-- - Meta
-- - saint-seiya
--
-- Effect (EN):
-- Destroy 1 face-up monster your opponent controls with the highest DEF (your choice, if tied).
--]==]
--Titan's Strike
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_META, SET_SAINT}

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if #g==0 then return end
	local maxdef=0
	for tc in aux.Next(g) do
		if tc:GetDefense()>maxdef then maxdef=tc:GetDefense() end
	end
	local hg=g:Filter(function(c) return c:GetDefense()==maxdef end,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local tc=hg:Select(tp,1,1,nil):GetFirst()
	if tc then Duel.Destroy(tc,REASON_EFFECT) end
end

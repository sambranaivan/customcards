--Starfall
--[==[
-- ID: 922100281
-- Type: Spell / Quick-Play Spell
--
-- Archetypes:
-- - Meta
-- Effect (EN):
-- Target 1 Spell/Trap on the field; destroy that target.
--]==]
--Starfall
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

function s.stfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsDestructable()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.stfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.stfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	Duel.SelectTarget(tp,s.stfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then Duel.Destroy(tc,REASON_EFFECT) end
end

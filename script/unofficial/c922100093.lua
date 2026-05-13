--Pegasus Comet
--[==[
-- ID: 922100093
-- Type: Spell / Normal Spell
--
-- Archetypes:
-- (setcode 0 — not in a named ProjectIgnis archetype series)
-- Effect (EN):
-- Destroy all Attack Position monsters your opponent controls.
-- If you control a "Saint" monster equipped with a "Cloth" card, your opponent cannot activate monster effects in response to this card's activation.
-- You can only activate 1 "Pegasus Comet" per turn.
--]==]
--Pegasus Comet
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.actcon)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
end

s.listed_series={SET_SAINT,SET_CLOTH}

function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_SAINT),tp,LOCATION_MZONE,0,1,nil) then return true end
	return true
end
function s.desfilter(c)
	return c:IsFaceup() and c:IsAttackPos()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.has_equipped_cloth(tp)
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSetCard,SET_SAINT),tp,LOCATION_MZONE,0,nil)
	for tc in aux.Next(g) do
		if tc:GetEquipGroup():IsExists(Card.IsSetCard,1,nil,SET_CLOTH) then
			return true
		end
	end
	return false
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	if s.has_equipped_cloth(tp) then
		Duel.SetChainLimitTillChainEnd(function(e,rp,tp) return not (rp==1-tp and e:IsActiveType(TYPE_MONSTER)) end)
	end
	local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end

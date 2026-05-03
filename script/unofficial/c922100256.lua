--Defense of the Seven Seas
--[==[
-- ID: 922100256
-- Type: Trap / Continuous Trap
--
-- Archetypes:
-- - saint-seiya
--
-- Effect (EN):
-- While you control a "Marine General" monster, "Pillar" cards you control cannot be destroyed by your opponent's card effects.
-- Once per turn, when your opponent activates a card or effect in a column where you control a "Pillar" card: You can negate that effect, and if you do, inflict 500 damage to your opponent for each "Marine General" monster you control.
--]==]
--Defense of the Seven Seas
local s,id=GetID()
function s.initial_effect(c)
	-- Pillars indestructible by opponent effects while you control Marine General
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_SZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_PILLAR))
	e1:SetCondition(s.indcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- Negate in column where you control Pillar
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.negcon)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_SAINT}

function s.indcon(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_MARINE_GENERAL),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp then return false end
	if not Duel.IsChainNegatable(ev) then return false end
	local rc=re:GetHandler()
	if not rc then return false end
	local pg=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSetCard,SET_PILLAR),tp,LOCATION_SZONE,0,nil)
	for pc in aux.Next(pg) do
		if pc:GetColumnGroup():IsContains(rc) then return true end
	end
	return false
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev)~=0 then
		local ct=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,SET_MARINE_GENERAL),tp,LOCATION_MZONE,0,nil)
		if ct>0 then Duel.Damage(1-tp,ct*500,REASON_EFFECT) end
	end
end

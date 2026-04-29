--Tatsumi - Guardian of the Mansion
--[==[
-- ID: 922100100
-- Type: Monster / Effect Monster
-- Level: 3
-- Attribute: EARTH
-- Race: Warrior
-- ATK/DEF: 1000/1000
--
-- Archetypes:
-- - saint-seiya
--
-- Effect (EN):
-- When your opponent activates a card or effect that would inflict damage to you (Quick Effect): You can discard this card; negate that activation, and if you do, inflict 1000 damage to your opponent.
-- You can only use this effect of "Tatsumi - Guardian of the Mansion" once per turn.
--]==]
--Tatsumi - Guardian of the Mansion
local s,id=GetID()
function s.initial_effect(c)
	--Discard; negate damage effect, then burn 1000
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.negcon)
	e1:SetCost(s.cost)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp then return false end
	if not Duel.IsChainNegatable(ev) then return false end
	return (re:GetCategory()&CATEGORY_DAMAGE)~=0 and Duel.GetChainInfo(ev,CHAININFO_TARGET_PLAYER)==tp
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable(REASON_COST) end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev)~=0 then
		Duel.Damage(1-tp,1000,REASON_EFFECT)
	end
end

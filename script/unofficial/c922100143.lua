--Steel Saint - Sho of Sky Armor
--[==[
-- ID: 922100143
-- Type: Monster / Effect Monster
-- Level: 4
-- Attribute: WIND
-- Race: Machine
-- ATK/DEF: 1200/1200
--
-- Archetypes:
-- - Steel Saint
-- - saint
-- - saint-seiya
--
-- Effect (EN):
-- When your opponent activates a monster effect on the field, or when your opponent activates a face-up Spell/Trap Card or effect on the field (Quick Effect): You can discard this card; negate that effect, and if you do, destroy that card.
-- If you control a "Saint" monster, you can activate this effect from your hand during either player's turn.
-- You can only use this effect of "Steel Saint - Sho of Sky Armor" once per turn.
--]==]
--Steel Saint - Sho of Sky Armor
local s,id=GetID()
function s.initial_effect(c)
	--Discard; negate + destroy (monster on field or face-up S/T on field)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
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

s.listed_series={SET_STEEL_SAINT,SET_SAINT}

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or not Duel.IsChainNegatable(ev) then return false end
	local rc=re:GetHandler()
	if not rc:IsOnField() then return false end
	if re:IsActiveType(TYPE_MONSTER) then
		return rc:IsLocation(LOCATION_MZONE) and (Duel.IsTurnPlayer(tp) or Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_SAINT),tp,LOCATION_MZONE,0,1,nil))
	end
	if re:IsActiveType(TYPE_SPELL+TYPE_TRAP) then
		return rc:IsLocation(LOCATION_SZONE) and rc:IsFaceup() and (Duel.IsTurnPlayer(tp) or Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_SAINT),tp,LOCATION_MZONE,0,1,nil))
	end
	return false
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable(REASON_COST) end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev)~=0 then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end

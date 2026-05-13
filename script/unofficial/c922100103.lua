--The Pope's Verdict
--[==[
-- ID: 922100103
-- Type: Trap / Counter Trap
--
-- Archetypes:
-- (setcode 0 — not in a named ProjectIgnis archetype series)
-- Effect (EN):
-- When your opponent activates a Spell/Trap Card or effect, while you control a "Saint" monster equipped with a "Cloth" card: Negate the activation, and if you do, Set that card in your opponent's Spell & Trap Zone, and it cannot be activated until the end of the next turn.
-- You can only activate 1 "The Pope's Verdict" per turn.
--]==]
--The Pope's Verdict
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.negcon)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
end

s.listed_series={SET_SAINT,SET_CLOTH}

function s.equipped_filter(c)
	if not (c:IsFaceup() and c:IsSetCard(SET_SAINT)) then return false end
	return c:GetEquipGroup():IsExists(Card.IsSetCard,1,nil,SET_CLOTH)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or not Duel.IsChainNegatable(ev) then return false end
	if not re:IsActiveType(TYPE_SPELL+TYPE_TRAP) then return false end
	return Duel.IsExistingMatchingCard(s.equipped_filter,tp,LOCATION_MZONE,0,1,nil)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if Duel.NegateActivation(ev)==0 or not rc then return end
	if not rc:IsRelateToEffect(re) or not rc:IsSSetable() then return end
	Duel.BreakEffect()
	Duel.SSet(1-tp,rc)

	--Prevent that Set card from being activated until the end of the next turn
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_TRIGGER)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
	rc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	rc:RegisterEffect(e2)
end

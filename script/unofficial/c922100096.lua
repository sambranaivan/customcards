--Marin - Guide of the Apprentice
--[==[
-- ID: 922100096
-- Type: Monster / Effect Monster
-- Level: 4
-- Attribute: WIND
-- Race: Warrior
-- ATK/DEF: 1400/1600
--
-- Archetypes:
-- - saint-seiya
--
-- Effect (EN):
-- When your opponent activates a card or effect that includes any of these effects (Quick Effect): You can discard this card; negate that effect.
-- ● Add a card from the Deck to the hand.
-- ● Special Summon from the Deck.
-- ● Send a card from the Deck to the GY.
-- You can only use this effect of "Marin - Guide of the Apprentice" once per turn.
--]==]
--Marin - Guide of the Apprentice
local s,id=GetID()
function s.initial_effect(c)
	--Discard; negate specific categories
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE)
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

s.listed_series={SET_SAINT}

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp then return false end
	if not Duel.IsChainNegatable(ev) then return false end
	local cat=re:GetCategory()
	return (cat&CATEGORY_TOHAND)~=0 or (cat&CATEGORY_SPECIAL_SUMMON)~=0 or (cat&CATEGORY_TOGRAVE)~=0
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable(REASON_COST) end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateActivation(ev)
end

--Cosmic Intervention
--[==[
-- ID: 922100299
-- Type: Monster / Effect Monster
-- Level: 3
-- Attribute: LIGHT
-- Race: Fairy
-- ATK/DEF: 0/1800
--
-- Archetypes:
-- - Meta
-- - saint-seiya
--
-- Effect (EN):
-- When a card or effect is activated that includes any of these effects (Quick Effect): You can discard this card; negate that effect.
-- - Add a card from the Deck to the hand.
-- - Special Summon from the Deck.
-- - Send a card from the Deck to the GY.
-- You can only use this effect of "Cosmic Intervention" once per turn.
--]==]
--Cosmic Intervention
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_series={SET_META, SET_SAINT}

function s.deckeffect(re)
	local cat=re:GetCategory()
	return (cat&CATEGORY_TOHAND)~=0 or (cat&CATEGORY_SPECIAL_SUMMON)~=0 or (cat&CATEGORY_TOGRAVE)~=0
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and Duel.IsChainNegatable(ev) and s.deckeffect(re)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateActivation(ev)
end

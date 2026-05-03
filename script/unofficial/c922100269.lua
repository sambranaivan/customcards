--Omen of the Stars
--[==[
-- ID: 922100269
-- Type: Spell / Normal Spell
--
-- Archetypes:
-- - Meta
-- - saint-seiya
--
-- Effect (EN):
-- At the start of your Main Phase 1, banish 3 or 6 random cards from your Extra Deck, face-down; draw 1 card for every 3 cards banished. For the rest of this turn after this card resolves, you cannot activate other "Pot" cards, also negate any other effects of cards drawn by this effect.
-- You can only activate 1 "Omen of the Stars" per turn.
--]==]
--Omen of the Stars
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_META, SET_SAINT}

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- banish 3 random from Extra facedown
	local g=Duel.GetFieldGroup(tp,LOCATION_EXTRA,0)
	if #g<3 then return end
	local rg=g:RandomSelect(tp,3)
	Duel.Remove(rg,POS_FACEDOWN,REASON_EFFECT)
	Duel.Draw(tp,1,REASON_EFFECT)
end

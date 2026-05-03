--Pact with the Foundation
--[==[
-- ID: 922100272
-- Type: Spell / Normal Spell
--
-- Archetypes:
-- - Meta
-- - saint-seiya
--
-- Effect (EN):
-- Draw 1 card. Your opponent gains 1000 LP.
-- You can only activate 1 "Pact with the Foundation" per turn.
--]==]
--Pact with the Foundation
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_META, SET_SAINT}

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Draw(tp,1,REASON_EFFECT)
	Duel.Recover(1-tp,1000,REASON_EFFECT)
end

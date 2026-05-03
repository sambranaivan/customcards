--Kasa - Reflection of the Beloved
--[==[
-- ID: 922100248
-- Type: Monster / Effect Monster
-- Level: 3
-- Attribute: WATER
-- Race: Warrior
-- ATK/DEF: 1200/1200
--
-- Archetypes:
-- - saint-seiya
--
-- Effect (EN):
-- When your opponent activates a monster effect (Quick Effect): You can discard this card, then target 1 "Marine General" monster you control; that activated effect becomes "Your opponent chooses 1 card in their hand and sends it to the GY".
-- You can only use this effect of "Kasa - Reflection of the Beloved" once per turn.
--]==]
--Kasa - Reflection of the Beloved
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.chcon)
	e1:SetCost(s.cost)
	e1:SetOperation(s.chop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_SAINT}

function s.chcon(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and re:IsActiveType(TYPE_MONSTER)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeChainOperation(ev,s.disop)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
	if #g==0 then return end
	-- opponent chooses 1 to send (approx: random)
	local sg=g:RandomSelect(tp,1)
	Duel.SendtoGrave(sg,REASON_EFFECT+REASON_DISCARD)
end

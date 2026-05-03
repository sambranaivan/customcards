--Cosmo Intrusion
--[==[
-- ID: 922100295
-- Type: Trap / Normal Trap
--
-- Archetypes:
-- - Meta
-- - saint-seiya
--
-- Effect (EN):
-- Declare 1 card name; your opponent reveals their hand, and if the declared card is there, they discard all copies. Otherwise, you discard 1 random card from your hand.
--]==]
--Cosmo Intrusion
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_META, SET_SAINT}

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	return true
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local code=Duel.AnnounceCard(tp)
	local hg=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
	Duel.ConfirmCards(tp,hg)
	local matches=hg:Filter(aux.FilterBoolFunction(Card.IsCode,code),nil)
	if #matches>0 then
		Duel.SendtoGrave(matches,REASON_EFFECT+REASON_DISCARD)
	else
		local my=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
		if #my>0 then
			local rc=my:RandomSelect(tp,1)
			Duel.SendtoGrave(rc,REASON_EFFECT+REASON_DISCARD)
		end
	end
	Duel.ShuffleHand(1-tp)
end

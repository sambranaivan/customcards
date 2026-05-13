--Cycle of Eternal Reincarnation
--[==[
-- ID: 922100219
-- Type: Spell / Normal Spell
--
-- Archetypes:
-- (setcode 0 — not in a named ProjectIgnis archetype series)
-- Effect (EN):
-- Shuffle all your banished "Specter" monsters into the Deck, and if you do, draw 1 card for every 3 cards shuffled.
-- Then, if you have 12 or more "Specter" monsters in your GY, you can add 1 "Hades, Emperor of the Eternal Underworld" from your Extra Deck to your hand.
-- You can only activate 1 "Cycle of Eternal Reincarnation" per turn.
--]==]
--Cycle of Eternal Reincarnation
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_SAINT}

function s.tdfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_SPECTER) and c:IsMonster() and c:IsAbleToDeck()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_REMOVED,0,1,nil) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_REMOVED,0,nil)
	local ct=#g
	if ct==0 then return end
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	Duel.ShuffleDeck(tp)
	local dc=ct//3
	if dc>0 then Duel.Draw(tp,dc,REASON_EFFECT) end
	-- If 12+ Specters in GY, add Hades fusion from Extra to hand
	if Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,SET_SPECTER),tp,LOCATION_GRAVE,0,nil)>=12 then
		local ex=Duel.GetMatchingGroup(aux.FilterBoolFunction(Card.IsCode,922100214),tp,LOCATION_EXTRA,0,nil)
		if #ex>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			local tc=ex:GetFirst()
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,Group.FromCards(tc))
		end
	end
end

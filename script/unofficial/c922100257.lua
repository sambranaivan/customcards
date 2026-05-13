--The Broken Amphora
--[==[
-- ID: 922100257
-- Type: Trap / Normal Trap
--
-- Archetypes:
-- (setcode 0 — not in a named ProjectIgnis archetype series)
-- Effect (EN):
-- Send 1 "Marine General" monster you control to the GY; send 1 "Pillar" card from your Deck to the GY, or if you control a "Pillar" card, you can send up to 2 "Pillar" cards with different names instead.
-- If this card is in your GY: You can banish this card; add 1 "Poseidon, God of the Seas" monster from your Deck or GY to your hand.
-- You can only use this effect of "The Broken Amphora" once per turn.
--]==]
--The Broken Amphora
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- GY: banish; add Poseidon
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_SAINT}

function s.mgface(c)
	return c:IsFaceup() and c:IsSetCard(SET_MARINE_GENERAL) and c:IsAbleToGrave()
end
function s.pilldeck(c)
	return c:IsSetCard(SET_PILLAR) and c:IsAbleToGrave()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.mgface,tp,LOCATION_MZONE,0,1,nil) and Duel.IsExistingMatchingCard(s.pilldeck,tp,LOCATION_DECK,0,1,nil) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local mg=Duel.SelectMatchingCard(tp,s.mgface,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if not mg then return end
	Duel.SendtoGrave(mg,REASON_EFFECT)
	local ct=1
	if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_PILLAR),tp,LOCATION_ONFIELD,0,1,nil) then ct=2 end
	local g=Duel.GetMatchingGroup(s.pilldeck,tp,LOCATION_DECK,0,nil)
	if #g<ct then ct=#g end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sg=Duel.SelectMatchingCard(tp,s.pilldeck,tp,LOCATION_DECK,0,ct,ct,nil)
	Duel.SendtoGrave(sg,REASON_EFFECT)
end

function s.posfilter(c)
	return c:IsCode(922100244,922100245) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.posfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.posfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then Duel.SendtoHand(g,nil,REASON_EFFECT) Duel.ConfirmCards(1-tp,g) end
end

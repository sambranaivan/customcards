--Kanon's Ambition
--[==[
-- ID: 922100251
-- Type: Spell / Normal Spell
--
-- Archetypes:
-- (setcode 0 — not in a named ProjectIgnis archetype series)
-- Effect (EN):
-- Send 1 "Pillar" card from your Deck to the GY, or if you control a "Marine General" monster, you can send up to 2 "Pillar" cards with different names instead, also for the rest of this turn after this card resolves, you cannot Special Summon monsters, except WATER monsters.
-- If this card is in your GY: You can banish this card; add 1 "Marine General" monster from your Deck to your hand.
-- You can only activate 1 "Kanon's Ambition" per turn.
-- You can only use this effect of "Kanon's Ambition" once per turn.
--]==]
--Kanon's Ambition
local s,id=GetID()
function s.initial_effect(c)
	-- Activate: send Pillar(s) then WATER-only SS
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- GY: banish; add Marine General
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+100)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_SAINT}

function s.pilldeck(c)
	return c:IsSetCard(SET_PILLAR) and c:IsAbleToGrave()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ct=1
	if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_MARINE_GENERAL),tp,LOCATION_MZONE,0,1,nil) then
		ct=2
	end
	local g=Duel.GetMatchingGroup(s.pilldeck,tp,LOCATION_DECK,0,nil)
	if #g==0 then return end
	if #g<ct then ct=#g end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sg=Duel.SelectMatchingCard(tp,s.pilldeck,tp,LOCATION_DECK,0,ct,ct,nil)
	Duel.SendtoGrave(sg,REASON_EFFECT)
	-- WATER-only special summons rest of turn
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return not c:IsAttribute(ATTRIBUTE_WATER) end)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

function s.mgfilter(c)
	return c:IsSetCard(SET_MARINE_GENERAL) and c:IsMonster() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.mgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.mgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then Duel.SendtoHand(g,nil,REASON_EFFECT) Duel.ConfirmCards(1-tp,g) end
end

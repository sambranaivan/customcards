--Pillar of the North Atlantic
--[==[
-- ID: 922100239
-- Type: Spell / Continuous Spell
--
-- Archetypes:
-- - Pillar
-- - saint-seiya
--
-- Effect (EN):
-- When this card is activated: You can add 1 "Marine General" monster or 1 "Scale" card from your Deck to your hand.
-- Once per turn, the first time a card in this card's column would be destroyed by battle or card effect each turn, it is not destroyed.
-- You can only control 1 "Pillar of the North Atlantic".
-- You can only activate 1 "Pillar of the North Atlantic" per turn.
--]==]
--Pillar of the North Atlantic
local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	-- Activate search
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- Prevent destruction once per turn for cards in column
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
	e2:SetTarget(s.coltg)
	e2:SetValue(s.indct)
	c:RegisterEffect(e2)
end
s.listed_series={SET_PILLAR, SET_SAINT}

function s.thfilter(c)
	return (c:IsSetCard(SET_MARINE_GENERAL) and c:IsMonster() or (c:IsCode(922100230,922100231,922100232,922100233,922100234,922100235,922100236)))
		and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then Duel.SendtoHand(g,nil,REASON_EFFECT) Duel.ConfirmCards(1-tp,g) end
end
function s.coltg(e,c)
	return e:GetHandler():GetColumnGroup():IsContains(c)
end
function s.indct(e,re,r,rp)
	return (r&REASON_BATTLE+REASON_EFFECT)~=0
end

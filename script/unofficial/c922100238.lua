--Pillar of the South Pacific
--[==[
-- ID: 922100238
-- Type: Spell / Continuous Spell
--
-- Archetypes:
-- - Pillar
-- Effect (EN):
-- When this card is activated: You can add 1 "Marine General" monster or 1 "Scale" card from your Deck to your hand.
-- Your opponent cannot activate cards or effects in the GY while they have a card in this card's column.
-- You can only control 1 "Pillar of the South Pacific".
-- You can only activate 1 "Pillar of the South Pacific" per turn.
--]==]
--Pillar of the South Pacific
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
	-- Opponent cannot activate effects in GY while they have a card in this column
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,1)
	e2:SetCondition(s.lockcon)
	e2:SetValue(s.aclimit)
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
function s.lockcon(e)
	return Duel.IsExistingMatchingCard(function(c) return e:GetHandler():GetColumnGroup():IsContains(c) end,1-e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
function s.aclimit(e,re,tp)
	return re:GetHandler():IsLocation(LOCATION_GRAVE)
end

--Pillar of the Antarctic Ocean
--[==[
-- ID: 922100243
-- Type: Spell / Continuous Spell
--
-- Archetypes:
-- - Pillar
-- - saint-seiya
--
-- Effect (EN):
-- When this card is activated: You can add 1 "Marine General" monster or 1 "Scale" card from your Deck to your hand.
-- Spells/Traps in this card's column cannot be targeted by your opponent's card effects.
-- You can only control 1 "Pillar of the Antarctic Ocean".
-- You can only activate 1 "Pillar of the Antarctic Ocean" per turn.
--]==]
--Pillar of the Antarctic Ocean
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
	-- S/T in this column cannot be targeted by opponent effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e2:SetTarget(s.colst)
	e2:SetValue(aux.tgoval)
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
function s.colst(e,c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and e:GetHandler():GetColumnGroup():IsContains(c)
end

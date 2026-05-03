--Call of the Polar Star
--[==[
-- ID: 922100185
-- Type: Spell / Normal Spell
--
-- Archetypes:
-- - saint-seiya
--
-- Effect (EN):
-- Add 1 "God Warrior" monster or 1 "Hilda of Polaris - Odin's Representative" from your Deck to your hand.
-- If you control "Palace of Valhalla - Throne of Hilda", you can add 1 "Nibelungen Ring" from your Deck to your hand instead.
-- You can only activate 1 "Call of the Polar Star" per turn.
--]==]
--Call of the Polar Star
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_SAINT}

function s.thfilter(c)
	return (c:IsSetCard(SET_GOD_WARRIOR) and c:IsMonster() or c:IsCode(922100181,922100188)) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local palace=Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,922100172),tp,LOCATION_FZONE,0,1,nil)
	-- If you control Palace, you can choose to search Ring instead of the usual search
	local selring=false
	if palace and Duel.IsExistingMatchingCard(aux.FilterBoolFunction(Card.IsCode,922100188),tp,LOCATION_DECK,0,1,nil) then
		selring=Duel.SelectYesNo(tp,aux.Stringid(id,0))
	end
	local filter=s.thfilter
	if selring then
		filter=function(c) return c:IsCode(922100188) and c:IsAbleToHand() end
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

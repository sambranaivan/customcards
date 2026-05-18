--Mu - The Cloth Repairer
--[==[
-- ID: 922100010
-- Type: Monster / Effect Monster
-- Level: 4
-- Attribute: LIGHT
-- Race: Warrior
-- ATK/DEF: 1200/2000
--
-- Archetypes:
-- (no archetype setcode — not treated as a "Saint" / "Bronze Saint" series monster; effects reference "Cloth" / Field by name.)
--
-- Effect (EN):
-- If this card is Normal or Special Summoned: You can target up to 2 "Cloth" Equip Spells in your GY; add them to your hand.
-- You can discard this card; add 1 "Athena's Sanctuary" from your Deck to your hand.
-- You can only use each effect of "Mu - The Cloth Repairer" once per turn.
--]==]
--Mu - The Cloth Repairer
local s,id=GetID()
function s.initial_effect(c)
	--If Normal or Special Summoned: add up to 2 "Cloth" Equip Spells from GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e1b=e1:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)

	--Discard this card; add "Athena's Sanctuary"
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.cost)
	e2:SetTarget(s.fdtg)
	e2:SetOperation(s.fdop)
	c:RegisterEffect(e2)
end

s.listed_series={SET_CLOTH}
s.listed_names={922100079}

function s.clotheqgyfilter(c)
	return c:IsSetCard(SET_CLOTH) and c:IsType(TYPE_EQUIP) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.clotheqgyfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.clotheqgyfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.clotheqgyfilter,tp,LOCATION_GRAVE,0,1,2,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g==0 then return end
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,g)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function s.fdfilter(c)
	return c:IsCode(922100079) and c:IsAbleToHand()
end
function s.fdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.fdfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.fdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.fdfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

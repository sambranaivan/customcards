--Vegeta (Majin Buu Saga)
local s,id=GetID()
function s.initial_effect(c)
	--If sent from hand to GY: add 1 "Goku" monster + 1 "Potara Earrings" from Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
end
s.listed_names={900000017}
s.listed_series={0x1d0,0x1d1,0x1d2,0x1d3}

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
function s.gokufilter(c)
	return c:IsSetCard(0x1d0) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.potfilter(c)
	return c:IsCode(900000017) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.gokufilter,tp,LOCATION_DECK,0,1,nil)
			and Duel.IsExistingMatchingCard(s.potfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local vg=Duel.GetMatchingGroup(s.gokufilter,tp,LOCATION_DECK,0,nil)
	local pg=Duel.GetMatchingGroup(s.potfilter,tp,LOCATION_DECK,0,nil)
	if #vg<1 or #pg<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g1=vg:Select(tp,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g2=pg:Select(tp,1,1,nil)
	g1:Merge(g2)
	Duel.SendtoHand(g1,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,g1)
end

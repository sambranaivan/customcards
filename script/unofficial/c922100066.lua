--Silver Cloth - Cepheus
--[==[
-- ID: 922100066
-- Type: Spell / Equip Spell
--
-- Archetypes:
-- - cloth
-- - Silver Cloth
-- Effect (EN):
-- Equip only to a "Silver Saint" monster.
-- Once per turn: You can target 1 "Saint" monster in your GY; add it to your hand, then discard 1 card.
-- If this card is equipped to "Silver Saint - Cepheus Daidalos", once per turn, when a "Saint" monster is Special Summoned to your field: You can target 1 card your opponent controls; return it to the hand.
--]==]
--Silver Cloth - Cepheus
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	--Equip limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(s.eqlimit)
	c:RegisterEffect(e1)

	--Once per turn: target 1 "Saint" in GY; add, then discard 1
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_DISCARD)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.eqcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)

	--If equipped to Daidalos: when a "Saint" is SS to your field, bounce 1 card
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.dai_con)
	e3:SetTarget(s.bouncetg)
	e3:SetOperation(s.bounceop)
	c:RegisterEffect(e3)
end

s.listed_series={SET_CLOTH,SET_SILVER_CLOTH,SET_SAINT}
s.listed_names={922100018}

function s.eqlimit(e,c)
	return c:IsSetCard(SET_SILVER_SAINT)
end
function s.eqcon(e)
	return e:GetHandler():GetEquipTarget()~=nil
end
function s.thfilter(c)
	return c:IsSetCard(SET_SAINT) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil,REASON_EFFECT) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DISCARD,nil,0,tp,1)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	if Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 then
		Duel.ConfirmCards(1-tp,Group.FromCards(tc))
		Duel.BreakEffect()
		Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_EFFECT+REASON_DISCARD,nil,REASON_EFFECT)
	end
end

function s.dai_con(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if not (ec and ec:IsCode(922100018)) then return false end
	return eg:IsExists(s.saintss,1,nil,tp)
end
function s.saintss(c,tp)
	return c:IsFaceup() and c:IsSetCard(SET_SAINT) and c:IsControler(tp)
end
function s.bouncefilter(c)
	return c:IsAbleToHand()
end
function s.bouncetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and s.bouncefilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.bouncefilter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,s.bouncefilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.bounceop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end

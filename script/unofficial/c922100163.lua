--Death Queen Island
--[==[
-- ID: 922100163
-- Type: Spell / Field Spell
--
-- Archetypes:
-- (setcode 0 — not in a named ProjectIgnis archetype series)
-- Effect (EN):
-- All "Black Saint" monsters you control gain 300 ATK/DEF.
-- When this card is activated: You can send 1 "Fragment of Sagittarius" card from your Deck to the GY.
-- Once per turn: You can target 1 "Black Saint" monster you control; equip 1 "Fragment of Sagittarius" Equip Spell from your GY to that target.
-- If a face-up "Fragment of Sagittarius" Equip Spell(s) you control is sent to the GY by card effect: You can add 1 "Black Saint" monster from your Deck to your hand, except "Black Saint - Ikki, Leader of Death Queen Island".
-- You can only use this effect of "Death Queen Island" once per turn.
--]==]
--Death Queen Island
local s,id=GetID()
function s.initial_effect(c)
	--Activate + send 1 Fragment from Deck
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e0:SetOperation(s.actop)
	c:RegisterEffect(e0)

	--ATK/DEF +300 to your Black Saints
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_BLACK_SAINT))
	e1:SetValue(300)
	c:RegisterEffect(e1)
	local e1b=e1:Clone()
	e1b:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1b)

	--Once per turn: target 1 Black Saint; equip 1 Fragment Equip from GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)

	--If face-up Fragment Equip you control sent to GY by effect: add 1 Black Saint except Ikki
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end

s.listed_series={SET_BLACK_SAINT,SET_FRAGMENT_OF_SAGITTARIUS}
s.listed_names={922100148}

function s.fragdeck(c)
	return c:IsSetCard(SET_FRAGMENT_OF_SAGITTARIUS) and c:IsAbleToGrave()
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsExistingMatchingCard(s.fragdeck,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,s.fragdeck,tp,LOCATION_DECK,0,1,1,nil)
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end

function s.bsfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_BLACK_SAINT)
end
function s.fraggy(c)
	return c:IsSetCard(SET_FRAGMENT_OF_SAGITTARIUS) and c:IsType(TYPE_EQUIP) and c:IsAbleToChangeControler()
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.bsfilter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(s.bsfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.fraggy),tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.bsfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not (tc and tc:IsRelateToEffect(e) and tc:IsFaceup()) then return end
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.fraggy),tp,LOCATION_GRAVE,0,1,1,nil)
	local ec=g:GetFirst()
	if ec then Duel.Equip(tp,ec,tc) end
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(function(c)
		return c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousPosition(POS_FACEUP)
			and c:IsSetCard(SET_FRAGMENT_OF_SAGITTARIUS) and (r&REASON_EFFECT)~=0 and c:IsControler(tp)
	end,1,nil)
end
function s.thfilter(c)
	return c:IsSetCard(SET_BLACK_SAINT) and c:IsMonster() and c:IsAbleToHand() and not c:IsCode(922100148)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

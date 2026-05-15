--Guilty's Cruel Trial
--[==[
-- ID: 922100171
-- Type: Spell / Continuous Spell
--
-- Archetypes:
-- (setcode 0 — not in a named ProjectIgnis archetype series)
-- Effect (EN):
-- When this card is activated: You can add 1 "Esmeralda, Light of Death Queen Island" or 1 "Guilty, Master of Hell" from your Deck to your hand.
-- Once per turn, if a "Fragment of Sagittarius" Equip Spell you control is sent to the GY: You can draw 1 card, then discard 1 card.
-- If you control "Black Saint - Ikki, Leader of Death Queen Island", your opponent cannot target "Esmeralda, Light of Death Queen Island" with card effects.
-- You can only activate 1 "Guilty's Cruel Trial" per turn.
--]==]
--Guilty's Cruel Trial
local s,id=GetID()
function s.initial_effect(c)
	--Activate + search Esmeralda or Guilty
	local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e0:SetOperation(s.actop)
	c:RegisterEffect(e0)

	--If Fragment Equip you control sent to GY: draw 1 then discard 1
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,{id,1})
	e1:SetCondition(s.drcon)
	e1:SetTarget(s.drtg)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)

	--If control Ikki: opponent cannot target Esmeralda with effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(s.protcon)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsCode,922100168))
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
end

s.listed_series={SET_FRAGMENT_OF_SAGITTARIUS,SET_BLACK_SAINT}
s.listed_names={922100168,922100169,922100148}

function s.thfilter(c)
	return (c:IsCode(922100168) or c:IsCode(922100169)) and c:IsAbleToHand()
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end

function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(function(c)
		return c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousPosition(POS_FACEUP)
			and c:IsSetCard(SET_FRAGMENT_OF_SAGITTARIUS) and c:IsControler(tp)
	end,1,nil)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil,REASON_EFFECT) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Draw(tp,1,REASON_EFFECT)==0 then return end
	Duel.BreakEffect()
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_EFFECT+REASON_DISCARD,nil,REASON_EFFECT)
end

function s.protcon(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,922100148),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end

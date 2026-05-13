--Bond of Brotherhood
--[==[
-- ID: 922100092
-- Type: Spell / Quick-Play Spell
--
-- Archetypes:
-- (setcode 0 — not in a named ProjectIgnis archetype series)
-- Effect (EN):
-- Target 1 "Saint" monster you control; it cannot be destroyed by your opponent's card effects this turn, also it cannot be banished by your opponent's card effects this turn.
-- If this card is activated in response to your opponent's monster effect activation, draw 1 card.
-- You can only activate 1 "Bond of Brotherhood" per turn.
--]==]
--Bond of Brotherhood
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

s.listed_series={SET_SAINT}

function s.saintfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_SAINT)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.saintfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.saintfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.saintfilter,tp,LOCATION_MZONE,0,1,1,nil)
	if re and re:IsActiveType(TYPE_MONSTER) and rp==1-tp then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or not tc:IsFaceup() then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetValue(s.indval)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e1)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.remval)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e2)
	if e:GetLabel()==1 then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
function s.indval(e,re,r,rp)
	return rp==1-e:GetHandlerPlayer()
end
function s.remval(e,re,r,rp)
	return rp==1-e:GetHandlerPlayer()
end

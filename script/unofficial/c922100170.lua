--Esmeralda's Last Will
--[==[
-- ID: 922100170
-- Type: Spell / Quick-Play Spell
--
-- Archetypes:
-- (setcode 0 — not in a named ProjectIgnis archetype series)
-- Effect (EN):
-- Target 1 "Black Saint" monster you control; this turn, it gains 800 ATK, also it cannot be destroyed by battle.
-- Then, if you control "Black Saint - Ikki, Leader of Death Queen Island", you can send 1 "Fragment of Sagittarius" card from your Deck to the GY.
-- You can only activate 1 "Esmeralda's Last Will" per turn.
--]==]
--Esmeralda's Last Will
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

s.listed_series={SET_BLACK_SAINT,SET_FRAGMENT_OF_SAGITTARIUS}
s.listed_names={922100148}

function s.bsfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_BLACK_SAINT)
end
function s.fragdeck(c)
	return c:IsSetCard(SET_FRAGMENT_OF_SAGITTARIUS) and c:IsAbleToGrave()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.bsfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.bsfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.bsfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or not tc:IsFaceup() then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(800)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e1)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e2)
	--If control Ikki: send 1 Fragment from Deck
	if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,922100148),tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.fragdeck,tp,LOCATION_DECK,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,s.fragdeck,tp,LOCATION_DECK,0,1,1,nil)
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end

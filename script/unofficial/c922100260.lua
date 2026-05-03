--The Will of Poseidon
--[==[
-- ID: 922100260
-- Type: Spell / Quick-Play Spell
--
-- Archetypes:
-- - Poseidon
-- - saint-seiya
--
-- Effect (EN):
-- Target 1 face-up "Marine General" monster you control; until the end of this turn, it is unaffected by your opponent's activated monster effects, also cards your opponent controls cannot be moved to a different column than that target's column.
-- If you control "Julian Solo, Chosen Vessel", you can activate this card from your hand during your opponent's turn.
-- You can only activate 1 "The Will of Poseidon" per turn.
--]==]
--The Will of Poseidon
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_POSEIDON, SET_SAINT}

function s.mgfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_MARINE_GENERAL)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.mgfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.mgfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.mgfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(function(e,re) return re:IsActivated() and re:IsActiveType(TYPE_MONSTER) and re:GetOwnerPlayer()~=e:GetHandlerPlayer() end)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e1)
end

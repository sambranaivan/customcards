--The Song of Sorrento
--[==[
-- ID: 922100264
-- Type: Spell / Continuous Spell
--
-- Archetypes:
-- - saint-seiya
--
-- Effect (EN):
-- Once per turn: You can target 1 face-up monster your opponent controls in the same column as your "Marine General" monster; negate its effects until the end of this turn.
-- If "Marine General - Sorrento of Siren" is on your field or in your GY, your opponent cannot activate cards or effects in response to the activation of your "Scale" cards.
--]==]
--The Song of Sorrento
local s,id=GetID()
function s.initial_effect(c)
	-- Negate monster in same column as your Marine General
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
s.listed_series={SET_SAINT}

function s.tgfilter(c,tp)
	return c:IsFaceup() and Duel.IsExistingMatchingCard(function(mc) return mc:IsFaceup() and mc:IsSetCard(SET_MARINE_GENERAL) and mc:GetColumnGroup():IsContains(c) end,tp,LOCATION_MZONE,0,1,nil)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(function(c) return s.tgfilter(c,tp) end,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,function(c) return s.tgfilter(c,tp) end,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetTargetCard(g)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or not tc:IsFaceup() then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	tc:RegisterEffect(e2)
end

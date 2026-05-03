--Cocytus - Prison of Ice
--[==[
-- ID: 922100217
-- Type: Spell / Normal Spell
--
-- Archetypes:
-- - saint-seiya
--
-- Effect (EN):
-- Target 1 monster your opponent controls; send it to the GY, and if you do, your opponent cannot Special Summon monsters with that original name during their next 2 turns.
-- If you control a "Renegade Saint" monster, you can activate this card from your hand during your opponent's turn.
-- You can only activate 1 "Cocytus - Prison of Ice" per turn.
--]==]
--Cocytus - Prison of Ice
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_SAINT}

function s.tgfilter(c)
	return c:IsFaceup() and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.tgfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	local code=tc:GetOriginalCode()
	if Duel.SendtoGrave(tc,REASON_EFFECT)~=0 then
		-- For opponent's next 2 turns, cannot Special Summon monsters with that name
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(0,1)
		e1:SetLabel(code)
		e1:SetTarget(function(e,c) return c:IsCode(e:GetLabel()) end)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		Duel.RegisterEffect(e1,tp)
	end
end

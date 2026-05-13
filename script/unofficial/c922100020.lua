--Silver Saint - Crow Jamian
--[==[
-- ID: 922100020
-- Type: Monster / Synchro Monster
-- Level: 8
-- Attribute: DARK
-- Race: Warrior
-- ATK/DEF: 2400/1800
--
-- Archetypes:
-- - saint
-- - Silver Saint
-- Effect (EN):
-- 1 Tuner + 1+ non-Tuner "Saint" monsters
-- For the Synchro Summon of this card, you can treat 1 "Bronze Saint" monster you control as a Tuner.
-- Once per turn: You can target 1 monster your opponent controls; it loses 800 ATK, also it cannot attack or activate its effects this turn.
-- If that monster leaves the field this turn, inflict 400 damage to your opponent.
--]==]
--Silver Saint - Crow Jamian
local s,id=GetID()
function s.initial_effect(c)
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(aux.FilterBoolFunction(Card.IsSetCard,SET_SAINT)),1,99,s.subtuner)
	c:EnableReviveLimit()

	--Target 1 opponent monster; -800 ATK, cannot attack/activate effects; if it leaves field this turn, inflict 400
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end

s.listed_series={SET_SAINT,SET_SILVER_SAINT}

function s.subtuner(c,sc,sumtype,tp)
	return c:IsSetCard(SET_BRONZE_SAINT) and c:IsControler(tp)
end

function s.tgfilter(c)
	return c:IsFaceup()
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.tgfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,1,0,0)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or not tc:IsFaceup() then return end
	--ATK down
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(-800)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e1)
	--Cannot attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e2)
	--Cannot activate effects
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_TRIGGER)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e3)
	--Track leaving field
	tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetReset(RESET_PHASE+PHASE_END)
	e4:SetLabelObject(tc)
	e4:SetOperation(s.damop)
	Duel.RegisterEffect(e4,tp)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if not tc then return end
	if eg:IsContains(tc) and tc:GetFlagEffect(id)~=0 then
		Duel.Damage(1-tp,400,REASON_EFFECT)
		e:Reset()
	end
end

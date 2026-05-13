--Silver Saint - Heracles Algethi
--[==[
-- ID: 922100025
-- Type: Monster / Synchro Monster
-- Level: 8
-- Attribute: EARTH
-- Race: Warrior
-- ATK/DEF: 2700/2000
--
-- Archetypes:
-- - saint
-- - Silver Saint
-- Effect (EN):
-- 1 Tuner + 1+ non-Tuner "Saint" monsters
-- For the Synchro Summon of this card, you can treat 1 "Bronze Saint" monster you control as a Tuner.
-- Once per turn (Quick Effect): You can target 1 face-up monster your opponent controls; its ATK becomes 0 until the end of this turn, also this card can make a second attack during each Battle Phase this turn.
--]==]
--Silver Saint - Heracles Algethi
local s,id=GetID()
function s.initial_effect(c)
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(aux.FilterBoolFunction(Card.IsSetCard,SET_SAINT)),1,99,s.subtuner)
	c:EnableReviveLimit()

	--Quick: target 1 face-up monster; its ATK becomes 0, and this card can make a second attack this turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
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
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.tgfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.tgfilter,tp,0,LOCATION_MZONE,1,1,nil)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or not tc:IsFaceup() then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetValue(0)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e1)
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_EXTRA_ATTACK)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
	end
end

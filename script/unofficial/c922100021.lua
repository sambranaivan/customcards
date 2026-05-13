--Silver Saint - Cerberus Dante
--[==[
-- ID: 922100021
-- Type: Monster / Synchro Monster
-- Level: 8
-- Attribute: DARK
-- Race: Warrior
-- ATK/DEF: 2500/2300
--
-- Archetypes:
-- - saint
-- - Silver Saint
-- Effect (EN):
-- 1 Tuner + 1+ non-Tuner "Saint" monsters
-- For the Synchro Summon of this card, you can treat 1 "Bronze Saint" monster you control as a Tuner.
-- Once per turn: You can target up to 2 cards in either GY; banish them.
-- If a card(s) is banished by this effect, your opponent cannot activate cards or effects with the same original name as those banished cards for the rest of this turn.
--]==]
--Silver Saint - Cerberus Dante
local s,id=GetID()
function s.initial_effect(c)
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(aux.FilterBoolFunction(Card.IsSetCard,SET_SAINT)),1,99,s.subtuner)
	c:EnableReviveLimit()

	--Banish up to 2 cards in either GY; lock activations of same original names
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
end

s.listed_series={SET_SAINT,SET_SILVER_SAINT}

function s.subtuner(c,sc,sumtype,tp)
	return c:IsSetCard(SET_BRONZE_SAINT) and c:IsControler(tp)
end
function s.rmfilter(c)
	return c:IsAbleToRemove()
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.rmfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,2,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg==0 then return end
	local codes={}
	for tc in tg:Iter() do
		codes[#codes+1]=tc:GetOriginalCodeRule()
	end
	if Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)>0 then
		--Opponent cannot activate cards/effects with those original names this turn
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(0,1)
		e1:SetLabelObject(codes)
		e1:SetValue(s.actlimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.actlimit(e,re,tp)
	local codes=e:GetLabelObject()
	local ac=re:GetHandler()
	local code=ac:GetOriginalCodeRule()
	for _,v in ipairs(codes) do
		if v==code then return true end
	end
	return false
end

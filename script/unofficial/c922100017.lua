--Silver Saint - Hound Asterion
--[==[
-- ID: 922100017
-- Type: Monster / Synchro Monster
-- Level: 8
-- Attribute: LIGHT
-- Race: Warrior
-- ATK/DEF: 2400/2000
--
-- Archetypes:
-- - saint
-- - saint-seiya
-- - Silver Saint
--
-- Effect (EN):
-- 1 Tuner + 1+ non-Tuner "Saint" monsters
-- For the Synchro Summon of this card, you can treat 1 "Bronze Saint" monster you control as a Tuner.
-- Once per turn: You can reveal 1 random card in your opponent's hand, then apply this effect based on its type.
-- ● Monster: Negate the effects of 1 face-up monster your opponent controls until the end of this turn.
-- ● Spell/Trap: Set 1 Spell/Trap your opponent controls face-down.
--]==]
--Silver Saint - Hound Asterion
local s,id=GetID()
function s.initial_effect(c)
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(aux.FilterBoolFunction(Card.IsSetCard,SET_SAINT)),1,99,s.subtuner)
	c:EnableReviveLimit()

	--Reveal 1 random card in opponent's hand; apply effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.rdtg)
	e1:SetOperation(s.rdop)
	c:RegisterEffect(e1)
end

s.listed_series={SET_SAINT,SET_SILVER_SAINT}

function s.subtuner(c,sc,sumtype,tp)
	return c:IsSetCard(SET_BRONZE_SAINT) and c:IsControler(tp)
end

function s.rdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
end
function s.negfilter(c)
	return c:IsFaceup() and c:IsNegatableMonster()
end
function s.setstfilter(c)
	return c:IsSpellTrap() and c:IsFaceup() and c:IsCanTurnSet()
end
function s.rdop(e,tp,eg,ep,ev,re,r,rp)
	local hg=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if #hg==0 then return end
	local rc=hg:RandomSelect(tp,1):GetFirst()
	if not rc then return end
	Duel.ConfirmCards(tp,rc)
	Duel.ConfirmCards(1-tp,rc)
	Duel.ShuffleHand(1-tp)
	if rc:IsType(TYPE_MONSTER) then
		if not Duel.IsExistingMatchingCard(s.negfilter,tp,0,LOCATION_MZONE,1,nil) then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
		local g=Duel.SelectMatchingCard(tp,s.negfilter,tp,0,LOCATION_MZONE,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			tc:RegisterEffect(e2)
		end
	else
		if not Duel.IsExistingMatchingCard(s.setstfilter,tp,0,LOCATION_ONFIELD,1,nil) then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local g=Duel.SelectMatchingCard(tp,s.setstfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			Duel.ChangePosition(tc,POS_FACEDOWN)
		end
	end
end

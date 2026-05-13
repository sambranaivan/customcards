--Silver Saint - Hound Asterion, Envoy of the Pope
--[==[
-- ID: 922100111
-- Type: Monster / Effect Monster
-- Level: 6
-- Attribute: LIGHT
-- Race: Warrior
-- ATK/DEF: 2400/2000
--
-- Archetypes:
-- - saint
-- - Silver Saint
-- - Envoy of the Pope
-- Effect (EN):
-- If you control "Pope Ares" or a "Pope's Mandate" card, you can Special Summon this card from your hand.
-- Once per turn: You can reveal 1 random card in your opponent's hand, then apply this effect based on its type.
-- ● Monster: Negate the effects of 1 face-up monster your opponent controls until the end of this turn.
-- ● Spell/Trap: Set 1 Spell/Trap your opponent controls face-down.
-- If you control "Pope Ares", your opponent cannot activate cards or effects with the same original name as the revealed card until the end of this turn.
--]==]
--Silver Saint - Hound Asterion, Envoy of the Pope
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon from hand
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_HAND)
	e0:SetCondition(s.spcon)
	c:RegisterEffect(e0)

	--Reveal 1 random card; apply
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end

s.listed_series={SET_ENVOY_OF_THE_POPE,SET_SILVER_SAINT,SET_SAINT,SET_POPES_MANDATE}
s.listed_names={922100105}

function s.pm_onfield(tp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_POPES_MANDATE),tp,LOCATION_ONFIELD,0,1,nil)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and (Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,922100105),tp,LOCATION_MZONE,0,1,nil) or s.pm_onfield(tp))
end

function s.op(e,tp,eg,ep,ev,re,r,rp)
	local og=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if #og==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local rg=og:RandomSelect(tp,1)
	local rc=rg:GetFirst()
	if not rc then return end
	Duel.ConfirmCards(tp,rg)
	Duel.ShuffleHand(1-tp)

	if rc:IsMonster() then
		if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsType,TYPE_MONSTER),tp,0,LOCATION_MZONE,1,nil) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
			local tg=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsType,TYPE_MONSTER),tp,0,LOCATION_MZONE,1,1,nil)
			local tc=tg:GetFirst()
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
		end
	else
		local g=Duel.GetMatchingGroup(function(c) return c:IsFaceup() and c:IsSpellTrap() and c:IsCanTurnSet() end,tp,0,LOCATION_ONFIELD,nil)
		if #g>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
			local sg=g:Select(tp,1,1,nil)
			local sc=sg:GetFirst()
			if sc then
				Duel.ChangePosition(sc,POS_FACEDOWN)
			end
		end
	end

	--If control Pope Ares: opponent cannot activate cards/effects with same original name this turn
	if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,922100105),tp,LOCATION_MZONE,0,1,nil) then
		local code=rc:GetOriginalCode()
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e3:SetCode(EFFECT_CANNOT_ACTIVATE)
		e3:SetTargetRange(0,1)
		e3:SetValue(function(e,re,tp) return re:GetHandler():GetOriginalCode()==e:GetLabel() end)
		e3:SetLabel(code)
		e3:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e3,tp)
	end
end

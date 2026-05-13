--Cassios' Intervention
--[==[
-- ID: 922100095
-- Type: Monster / Effect Monster
-- Level: 4
-- Attribute: EARTH
-- Race: Warrior
-- ATK/DEF: 1800/2500
--
-- Archetypes:
-- (setcode 0 — not in a named ProjectIgnis archetype series)
-- Effect (EN):
-- (Quick Effect): You can discard this card, then target 1 "Saint" monster you control; it cannot be destroyed by battle or card effects this turn, also any battle damage you take from battles involving that target this turn becomes 0.
-- You can only use this effect of "Cassios' Intervention" once per turn.
--]==]
--Cassios' Intervention
local s,id=GetID()
function s.initial_effect(c)
	--Discard; protect + damage 0
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end

s.listed_series={SET_SAINT}

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable(REASON_COST) end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(SET_SAINT)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or not tc:IsFaceup() then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	tc:RegisterEffect(e2)
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CHANGE_DAMAGE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetReset(RESET_PHASE+PHASE_END)
	e3:SetValue(s.damval)
	e3:SetLabelObject(tc)
	Duel.RegisterEffect(e3,tp)
end
function s.damval(e,re,val,r,rp,rc)
	if r&REASON_BATTLE~=0 then
		local tc=e:GetLabelObject()
		local bc=Duel.GetAttacker()
		local dc=Duel.GetAttackTarget()
		if tc and bc and dc and (bc==tc or dc==tc) then
			return 0
		end
	end
	return val
end

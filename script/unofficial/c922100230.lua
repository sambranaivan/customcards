--Scale - Sea Dragon
--[==[
-- ID: 922100230
-- Type: Spell / Equip Spell
--
-- Archetypes:
-- - saint-seiya
--
-- Effect (EN):
-- Equip only to a "Marine General" monster.
-- The equipped monster gains 500 ATK.
-- Once per turn, when your opponent would activate a card or effect in the equipped monster's column: They must pay 1000 LP to activate it.
-- Once per turn (Quick Effect): You can send this face-up Equip Card to the GY; this turn, cards and effects activated in the equipped monster's column are negated.
--]==]
--Scale - Sea Dragon
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c,nil,s.eqfilter)
	-- ATK +500
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(500)
	c:RegisterEffect(e1)
	-- Pay 1000 to activate in equipped column
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.paycon)
	e2:SetOperation(s.payop)
	c:RegisterEffect(e2)
	-- Quick: send equip to GY; negate activations in column this turn
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id+100)
	e3:SetCost(s.negcost)
	e3:SetOperation(s.negop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_SAINT}

function s.eqfilter(c)
	return c:IsSetCard(SET_MARINE_GENERAL)
end

function s.paycon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp then return false end
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if not ec then return false end
	local rc=re:GetHandler()
	return rc and ec:GetColumnGroup():IsContains(rc) and Duel.GetLP(rp)>=1000
end
function s.payop(e,tp,eg,ep,ev,re,r,rp)
	-- Opponent must pay 1000 or negate
	if Duel.CheckLPCost(rp,1000) and Duel.SelectYesNo(rp,aux.Stringid(id,0)) then
		Duel.PayLPCost(rp,1000)
	else
		Duel.NegateActivation(ev)
	end
end

function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	if not ec then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local rc=re:GetHandler()
		if rc and ec:GetColumnGroup():IsContains(rc) and Duel.IsChainNegatable(ev) then
			Duel.NegateActivation(ev)
		end
	end)
	Duel.RegisterEffect(e1,tp)
end

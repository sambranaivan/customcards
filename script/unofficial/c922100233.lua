--Scale - Kraken
--[==[
-- ID: 922100233
-- Type: Spell / Equip Spell
--
-- Archetypes:
-- (setcode 0 — not in a named ProjectIgnis archetype series)
-- Effect (EN):
-- Equip only to a "Marine General" monster.
-- Once per turn (Quick Effect): You can target 1 face-up monster in the equipped monster's column; change it to face-down Defense Position.
-- Once per turn (Quick Effect): You can send this face-up Equip Card to the GY; this turn, when your opponent activates a monster effect in the equipped monster's column, negate that effect.
--]==]
--Scale - Kraken
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c,nil,s.eqfilter)
	-- Quick: set a face-up monster in column facedown
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.fdtg)
	e1:SetOperation(s.fdop)
	c:RegisterEffect(e1)
	-- Quick: send to GY; negate monster effects in column this turn
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id+100)
	e2:SetCost(s.cost)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_SAINT}

function s.eqfilter(c)
	return c:IsSetCard(SET_MARINE_GENERAL)
end
function s.fdfilter(c,ec)
	return c:IsFaceup() and c:IsCanTurnSet() and ec:GetColumnGroup():IsContains(c)
end
function s.fdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=e:GetHandler():GetEquipTarget()
	if chk==0 then return ec and Duel.IsExistingTarget(function(c) return s.fdfilter(c,ec) end,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWN)
	local g=Duel.SelectTarget(tp,function(c) return s.fdfilter(c,ec) end,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
function s.fdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
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
		if rc and re:IsActiveType(TYPE_MONSTER) and ec:GetColumnGroup():IsContains(rc) and Duel.IsChainNegatable(ev) then
			Duel.NegateActivation(ev)
		end
	end)
	Duel.RegisterEffect(e1,tp)
end

--Scale - Siren
--[==[
-- ID: 922100231
-- Type: Spell / Equip Spell
--
-- Archetypes:
-- (setcode 0 — not in a named ProjectIgnis archetype series)
-- Effect (EN):
-- Equip only to a "Marine General" monster.
-- If the equipped monster is a "Marine General", your opponent cannot Set cards in the equipped monster's column.
-- Once per turn (Quick Effect): You can send this face-up Equip Card to the GY; this turn, your opponent cannot Set cards in the equipped monster's column, also cards in that column cannot be targeted by your opponent's card effects.
--]==]
--Scale - Siren
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c,nil,s.eqfilter)
	-- Opponent cannot Set cards in equipped column
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SSET)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(0,1)
	e1:SetCondition(s.colcon)
	e1:SetTarget(s.coltg)
	c:RegisterEffect(e1)
	local e1b=e1:Clone()
	e1b:SetCode(EFFECT_CANNOT_MSET)
	c:RegisterEffect(e1b)
	-- Quick: send to GY; lock sets + cannot target cards in column
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.cost)
	e2:SetOperation(s.op)
	c:RegisterEffect(e2)
end
s.listed_series={SET_SAINT}

function s.eqfilter(c)
	return c:IsSetCard(SET_MARINE_GENERAL)
end
function s.colcon(e)
	return e:GetHandler():GetEquipTarget()~=nil
end
function s.coltg(e,c)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:GetColumnGroup():IsContains(c)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	-- Column effects expire end phase
	local ec=e:GetHandler():GetEquipTarget()
	if not ec then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SSET)
	e1:SetTargetRange(0,1)
	e1:SetTarget(function(e,c) return ec:GetColumnGroup():IsContains(c) end)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e1b=e1:Clone()
	e1b:SetCode(EFFECT_CANNOT_MSET)
	Duel.RegisterEffect(e1b,tp)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
	e2:SetTarget(function(e,c) return ec:GetColumnGroup():IsContains(c) end)
	e2:SetValue(aux.tgoval)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
end

--Scale - Chrysaor
--[==[
-- ID: 922100232
-- Type: Spell / Equip Spell
--
-- Archetypes:
-- - saint-seiya
--
-- Effect (EN):
-- Equip only to a "Marine General" monster.
-- The equipped monster can inflict piercing battle damage.
-- If the equipped monster inflicts battle damage to your opponent: Destroy all Spells/Traps in that monster's column.
-- Once per turn (Quick Effect): You can send this face-up Equip Card to the GY; this turn, the equipped monster gains 800 ATK, also if it inflicts battle damage to your opponent this turn, destroy all Spells/Traps your opponent controls in its column.
--]==]
--Scale - Chrysaor
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c,nil,s.eqfilter)
	-- Pierce
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e1)
	-- If battle damage: destroy S/T in column
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.damcon)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	-- Quick: send to GY; +800 and column wipe this turn
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.cost)
	e3:SetOperation(s.boostop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_SAINT}

function s.eqfilter(c)
	return c:IsSetCard(SET_MARINE_GENERAL)
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and Duel.GetAttacker()==ec and ep~=tp
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	if not ec then return end
	local g=Duel.GetMatchingGroup(function(c) return c:IsType(TYPE_SPELL+TYPE_TRAP) and ec:GetColumnGroup():IsContains(c) end,tp,0,LOCATION_SZONE,nil)
	if #g>0 then Duel.Destroy(g,REASON_EFFECT) end
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.boostop(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	if not ec or not ec:IsFaceup() then return end
	local e1=Effect.CreateEffect(ec)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(800)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	ec:RegisterEffect(e1)
	-- register column wipe on battle damage
	local e2=Effect.CreateEffect(ec)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return Duel.GetAttacker()==ec and ep~=tp end)
	e2:SetOperation(function(e,tp) 
		local g=Duel.GetMatchingGroup(function(c) return c:IsType(TYPE_SPELL+TYPE_TRAP) and ec:GetColumnGroup():IsContains(c) end,tp,0,LOCATION_SZONE,nil)
		if #g>0 then Duel.Destroy(g,REASON_EFFECT) end
	end)
	Duel.RegisterEffect(e2,tp)
end

--Scale - Sea Horse
--[==[
-- ID: 922100235
-- Type: Spell / Equip Spell
--
-- Archetypes:
-- - saint-seiya
--
-- Effect (EN):
-- Equip only to a "Marine General" monster.
-- Once per turn (Quick Effect): You can target 1 card in the equipped monster's column; return it to the hand.
-- Once per turn (Quick Effect): You can send this face-up Equip Card to the GY; this turn, cards in the equipped monster's column cannot be destroyed by card effects.
--]==]
--Scale - Sea Horse
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c,nil,s.eqfilter)
	-- Quick: bounce a card in equipped column
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.btg)
	e1:SetOperation(s.bop)
	c:RegisterEffect(e1)
	-- Quick: send to GY; protect column from effect destruction this turn
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id+100)
	e2:SetCost(s.cost)
	e2:SetOperation(s.protop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_SAINT}

function s.eqfilter(c)
	return c:IsSetCard(SET_MARINE_GENERAL)
end
function s.bfilter(c,ec)
	return c:IsAbleToHand() and ec:GetColumnGroup():IsContains(c)
end
function s.btg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=e:GetHandler():GetEquipTarget()
	if chk==0 then return ec and Duel.IsExistingMatchingCard(function(c) return s.bfilter(c,ec) end,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
end
function s.bop(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	if not ec then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectMatchingCard(tp,function(c) return s.bfilter(c,ec) end,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then Duel.SendtoHand(g,nil,REASON_EFFECT) end
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.protop(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	if not ec then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
	e1:SetTarget(function(e,c) return ec:GetColumnGroup():IsContains(c) end)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

--Flare (Freya) - Hope of Asgard
--[==[
-- ID: 922100182
-- Type: Monster / Effect Monster
-- Level: 3
-- Attribute: LIGHT
-- Race: Spellcaster
-- ATK/DEF: 0/2000
--
-- Archetypes:
-- (setcode 0 — not in a named ProjectIgnis archetype series)
-- Effect (EN):
-- You can Tribute this card; remove all Frost Counters from the field, then draw 1 card for every 2 counters removed (max. 3).
-- You can only use this effect of "Flare (Freya) - Hope of Asgard" once per turn.
--]==]
--Flare (Freya) - Hope of Asgard
local s,id=GetID()
function s.initial_effect(c)
	-- Tribute to remove Frost Counters and draw
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.drcost)
	e1:SetTarget(s.drtg)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_SAINT}

function s.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ct=Duel.GetCounter(tp,LOCATION_ONFIELD,LOCATION_ONFIELD,0x10f8)
	local dc=math.min(ct//2,3)
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(dc)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,dc)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetCounter(tp,LOCATION_ONFIELD,LOCATION_ONFIELD,0x10f8)
	if ct>0 then
		Duel.RemoveCounter(tp,LOCATION_ONFIELD,LOCATION_ONFIELD,0x10f8,ct,REASON_EFFECT)
	end
	local dc=math.min(ct//2,3)
	if dc>0 then
		Duel.Draw(tp,dc,REASON_EFFECT)
	end
end

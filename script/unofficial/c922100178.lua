--God Warrior - Mime of Benetnasch
--[==[
-- ID: 922100178
-- Type: Monster / Effect Monster
-- Level: 7
-- Attribute: WATER
-- Race: Warrior
-- ATK/DEF: 2200/2500
--
-- Archetypes:
-- - God Warrior
-- Effect (EN):
-- Your opponent cannot Tribute face-up monsters with Frost Counters.
-- Face-up monsters with Frost Counters cannot be used as material for a Special Summon from the Extra Deck.
--]==]
--God Warrior - Mime of Benetnasch
local s,id=GetID()
function s.initial_effect(c)
	-- Opponent cannot Tribute Frosted monsters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UNRELEASABLE_SUM)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetTarget(s.frztg)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e1b=e1:Clone()
	e1b:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e1b)
	-- Frosted monsters cannot be used as Extra Deck material
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.frztg)
	e2:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e2b=e2:Clone()
	e2b:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	c:RegisterEffect(e2b)
	local e2c=e2:Clone()
	e2c:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	c:RegisterEffect(e2c)
	local e2d=e2:Clone()
	e2d:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	c:RegisterEffect(e2d)
end
s.listed_series={SET_GOD_WARRIOR, SET_SAINT}

function s.frztg(e,c)
	return c:GetCounter(0x10f8)>0
end

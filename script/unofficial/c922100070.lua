--Gold Cloth - Cancer
--[==[
-- ID: 922100070
-- Type: Spell / Equip Spell
--
-- Archetypes:
-- - cloth
-- - Gold Saint
-- - saint-seiya
--
-- Effect (EN):
-- Equip only to a "Gold Saint" monster.
-- The equipped monster is also treated as a Zombie monster.
-- If a monster(s) would be sent to your opponent's GY, banish it instead.
--]==]
--Gold Cloth - Cancer
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	--Equip limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(s.eqlimit)
	c:RegisterEffect(e1)

	--Equipped monster is also Zombie
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_CHANGE_RACE)
	e2:SetValue(RACE_ZOMBIE)
	c:RegisterEffect(e2)

	--If a monster(s) would be sent to opponent's GY, banish it instead
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetValue(LOCATION_REMOVED)
	e3:SetTarget(s.redirtg)
	c:RegisterEffect(e3)
end

s.listed_series={SET_CLOTH,SET_GOLD_CLOTH,SET_GOLD_SAINT,SET_SAINT}

function s.eqlimit(e,c)
	return c:IsSetCard(SET_GOLD_SAINT)
end
function s.redirtg(e,c)
	return c:IsMonster()
end

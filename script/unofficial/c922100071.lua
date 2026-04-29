--Gold Cloth - Libra
--[==[
-- ID: 922100071
-- Type: Spell / Equip Spell
--
-- Archetypes:
-- - cloth
-- - Gold Saint
-- - saint-seiya
--
-- Effect (EN):
-- Equip only to a "Gold Saint" monster.
-- The equipped monster gains 500 ATK.
-- It can attack while in Defense Position. Apply its ATK for damage calculation.
--]==]
--Gold Cloth - Libra
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

	--ATK +500
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(500)
	c:RegisterEffect(e2)

	--Can attack while in DEF (use ATK)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_DEFENSE_ATTACK)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end

s.listed_series={SET_CLOTH,SET_GOLD_CLOTH,SET_GOLD_SAINT}

function s.eqlimit(e,c)
	return c:IsSetCard(SET_GOLD_SAINT)
end

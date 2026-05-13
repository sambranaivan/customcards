--Gold Cloth - Taurus
--[==[
-- ID: 922100069
-- Type: Spell / Equip Spell
--
-- Archetypes:
-- - cloth
-- - Gold Cloth
-- Effect (EN):
-- Equip only to a "Gold Saint" monster.
-- The equipped monster gains 1000 ATK/DEF.
-- Your opponent cannot target other "Saint" monsters you control for attacks.
--]==]
--Gold Cloth - Taurus
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

	--ATK/DEF +1000
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(1000)
	c:RegisterEffect(e2)
	local e2b=e2:Clone()
	e2b:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2b)

	--Opponent cannot target other "Saint" monsters for attacks
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetValue(s.atlimit)
	c:RegisterEffect(e3)
end

s.listed_series={SET_CLOTH,SET_GOLD_CLOTH,SET_GOLD_SAINT,SET_SAINT}
function s.eqlimit(e,c)
	return c:IsSetCard(SET_GOLD_SAINT)
end
function s.atlimit(e,c)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and c~=ec and c:IsFaceup() and c:IsSetCard(SET_SAINT)
end

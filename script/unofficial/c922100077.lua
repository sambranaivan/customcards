--Gold Cloth - Virgo
--[==[
-- ID: 922100077
-- Type: Spell / Equip Spell
--
-- Archetypes:
-- - cloth
-- - Gold Cloth
--
-- Effect (EN):
-- Equip only to a "Gold Saint" monster.
-- The equipped monster is unaffected by your opponent's activated monster effects.
--]==]
--Gold Cloth - Virgo
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

	--Unaffected by opponent's activated monster effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)
end

s.listed_series={SET_CLOTH,SET_GOLD_CLOTH,SET_GOLD_SAINT,SET_SAINT}
function s.eqlimit(e,c)
	return c:IsSetCard(SET_GOLD_SAINT)
end
function s.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
		and te:IsActivated() and te:IsActiveType(TYPE_MONSTER)
end

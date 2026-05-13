--Seal of the Ancient Sanctuary
--[==[
-- ID: 922100286
-- Type: Trap / Continuous Trap
--
-- Archetypes:
-- - Meta
-- Effect (EN):
-- Both players must Set Spell Cards before activating them, and cannot activate them until their next turn.
--]==]
--Seal of the Ancient Sanctuary
local s,id=GetID()
function s.initial_effect(c)
	-- Simple implementation: cannot activate Spell Cards from hand
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(1,1)
	e1:SetValue(s.aclimit)
	c:RegisterEffect(e1)
end
s.listed_series={SET_META, SET_SAINT}

function s.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_SPELL) and re:GetHandler():IsLocation(LOCATION_HAND)
end

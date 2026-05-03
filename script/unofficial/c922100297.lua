--Stellar Prison
--[==[
-- ID: 922100297
-- Type: Trap / Continuous Trap
--
-- Archetypes:
-- - Meta
-- - saint-seiya
--
-- Effect (EN):
-- Any card sent to the GY is banished instead.
--]==]
--Stellar Prison
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_ALL,LOCATION_ALL)
	e1:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e1)
end
s.listed_series={SET_META, SET_SAINT}

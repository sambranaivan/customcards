--Gold Cloth - Aries
--[==[
-- ID: 922100068
-- Type: Spell / Equip Spell
--
-- Archetypes:
-- - cloth
-- - Gold Saint
-- - saint-seiya
--
-- Effect (EN):
-- Equip only to a "Gold Saint" monster.
-- The equipped monster gains 1000 DEF.
-- Once per turn, if a face-up "Saint" card(s) you control would be destroyed by battle or card effect, it is not destroyed.
--]==]
--Gold Cloth - Aries
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

	--DEF +1000
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetValue(1000)
	c:RegisterEffect(e2)

	--Once per turn: "Saint" card(s) you control would be destroyed -> not destroyed
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_ONFIELD,0)
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_SAINT))
	e3:SetValue(s.indct)
	c:RegisterEffect(e3)
end

s.listed_series={SET_CLOTH,SET_GOLD_CLOTH,SET_GOLD_SAINT,SET_SAINT}

function s.eqlimit(e,c)
	return c:IsSetCard(SET_GOLD_SAINT)
end
function s.indct(e,re,r,rp)
	if (r&REASON_BATTLE)~=0 or (r&REASON_EFFECT)~=0 then
		return 1
	end
	return 0
end

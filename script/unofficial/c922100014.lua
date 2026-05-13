--Silver Saint - Algol of Perseus
--[==[
-- ID: 922100014
-- Type: Monster / Synchro Monster
-- Level: 8
-- Attribute: EARTH
-- Race: Warrior
-- ATK/DEF: 2300/1800
--
-- Archetypes:
-- - saint
-- - Silver Saint
-- Effect (EN):
-- 1 Tuner + 1+ non-Tuner "Saint" monsters
-- For the Synchro Summon of this card, you can treat 1 "Bronze Saint" monster you control as a Tuner.
-- Opponent's monsters in this card's column are changed to Defense Position, also their effects are negated, and they cannot change their battle positions.
--]==]
--Silver Saint - Algol of Perseus
local s,id=GetID()
function s.initial_effect(c)
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(aux.FilterBoolFunction(Card.IsSetCard,SET_SAINT)),1,99,s.subtuner)
	c:EnableReviveLimit()

	--Column lock for opponent's monsters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SET_POSITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetTarget(s.coltg)
	e1:SetValue(POS_FACEUP_DEFENSE)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetTarget(s.coltg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DISABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetTarget(s.coltg)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_DISABLE_EFFECT)
	c:RegisterEffect(e4)
end

s.listed_series={SET_SAINT,SET_SILVER_SAINT}

function s.subtuner(c,sc,sumtype,tp)
	return c:IsSetCard(SET_BRONZE_SAINT) and c:IsControler(tp)
end

function s.coltg(e,c)
	local hc=e:GetHandler()
	if not hc:IsOnField() then return false end
	return hc:GetColumnGroup():IsContains(c)
end

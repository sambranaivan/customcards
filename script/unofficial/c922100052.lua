--Silver Cloth - Ophiuchus
--[==[
-- ID: 922100052
-- Type: Spell / Equip Spell
--
-- Archetypes:
-- - cloth
-- - saint-seiya
-- - Silver Saint
--
-- Effect (EN):
-- Equip only to a "Silver Saint" monster.
-- The equipped monster gains 800 ATK.
-- If the equipped monster destroys an opponent's monster by battle, your opponent cannot activate effects in their GY this turn.
-- If the equipped monster is "Silver Saint - Shaina of Ophiuchus", it can attack all monsters your opponent controls, once each.
--]==]
--Silver Cloth - Ophiuchus
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

	--ATK +800
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(800)
	c:RegisterEffect(e2)

	--If equipped monster destroys by battle: opponent cannot activate GY effects this turn
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.gycon)
	e3:SetOperation(s.gyop)
	c:RegisterEffect(e3)

	--If equipped to Shaina: can attack all monsters once each
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_ATTACK_ALL)
	e4:SetCondition(s.shainacon)
	e4:SetValue(1)
	c:RegisterEffect(e4)
end

s.listed_series={SET_CLOTH,SET_SILVER_SAINT}
s.listed_names={922100013}

function s.eqlimit(e,c)
	return c:IsSetCard(SET_SILVER_SAINT)
end
function s.gycon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and eg:IsContains(ec) and ec:IsRelateToBattle()
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetValue(function(_,re2) return re2:GetHandler():IsLocation(LOCATION_GRAVE) end)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.shainacon(e)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:IsCode(922100013)
end

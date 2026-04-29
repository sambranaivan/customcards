--Gold Cloth - Capricorn
--[==[
-- ID: 922100073
-- Type: Spell / Equip Spell
--
-- Archetypes:
-- - cloth
-- - Gold Saint
-- - saint-seiya
--
-- Effect (EN):
-- Equip only to a "Gold Saint" monster.
-- The equipped monster's attacks cannot be negated.
-- If the equipped monster destroys an opponent's monster by battle, it can make a second attack in a row.
--]==]
--Gold Cloth - Capricorn
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

	--Attacks cannot be negated
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UNSTOPPABLE_ATTACK)
	e2:SetValue(1)
	c:RegisterEffect(e2)

	--If equipped monster destroys by battle: it can make a second attack in a row
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.excon)
	e3:SetOperation(s.exop)
	c:RegisterEffect(e3)
end

s.listed_series={SET_CLOTH,SET_GOLD_CLOTH,SET_GOLD_SAINT}

function s.eqlimit(e,c)
	return c:IsSetCard(SET_GOLD_SAINT)
end

function s.excon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	local bc=Duel.GetAttacker()
	return ec~=nil and bc==ec and bc:IsRelateToBattle()
end
function s.exop(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	if not ec or not ec:IsFaceup() then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	ec:RegisterEffect(e1)
end

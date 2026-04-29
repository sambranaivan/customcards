--Gold Cloth - Pisces
--[==[
-- ID: 922100074
-- Type: Spell / Equip Spell
--
-- Archetypes:
-- - cloth
-- - Gold Saint
-- - saint-seiya
--
-- Effect (EN):
-- Equip only to a "Gold Saint" monster.
-- If the equipped monster is destroyed by battle, destroy the monster that destroyed it during the End Phase.
-- While this card is equipped to "Gold Saint - Aphrodite of Pisces", your opponent must keep their hand revealed.
--]==]
--Gold Cloth - Pisces
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

	--If equipped monster destroyed by battle: destroy the monster that destroyed it during the End Phase
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.repcon)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)

	--If equipped to Aphrodite: opponent must keep their hand revealed
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_PUBLIC)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(0,LOCATION_HAND)
	e3:SetCondition(s.aphcon)
	c:RegisterEffect(e3)
end

s.listed_series={SET_CLOTH,SET_GOLD_CLOTH,SET_GOLD_SAINT}
s.listed_names={922100038}

function s.eqlimit(e,c)
	return c:IsSetCard(SET_GOLD_SAINT)
end

function s.repcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	if not ec then return false end
	return eg:IsContains(ec) and ec:IsReason(REASON_BATTLE)
		and ec:GetBattleTarget()~=nil and ec:GetBattleTarget():IsRelateToBattle()
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	if not ec then return end
	local bc=ec:GetBattleTarget()
	if not bc then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1,{id,1})
	e1:SetLabelObject(bc)
	e1:SetOperation(s.endop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.endop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetLabelObject()
	if bc and bc:IsOnField() and bc:IsDestructable() then
		Duel.Destroy(bc,REASON_EFFECT)
	end
end

function s.aphcon(e)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:IsCode(922100038)
end

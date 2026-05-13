--Gold Cloth - Scorpio
--[==[
-- ID: 922100072
-- Type: Spell / Equip Spell
--
-- Archetypes:
-- - cloth
-- - Gold Cloth
-- Effect (EN):
-- Equip only to a "Gold Saint" monster.
-- If the equipped monster battles an opponent's monster, before damage calculation: Destroy that opponent's monster.
-- If the equipped monster destroys a monster by battle: Inflict 1500 damage to your opponent.
--]==]
--Gold Cloth - Scorpio
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

	--Before damage calculation: destroy opponent's monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)

	--If equipped monster destroys by battle: inflict 1500
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.damcon)
	e3:SetTarget(s.damtg)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
end

s.listed_series={SET_CLOTH,SET_GOLD_CLOTH,SET_GOLD_SAINT,SET_SAINT}
function s.eqlimit(e,c)
	return c:IsSetCard(SET_GOLD_SAINT)
end

function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	return ec~=nil and a and d and (a==ec or d==ec) and d:IsControler(1-tp) and d:IsRelateToBattle()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetAttackTarget()~=nil end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,Duel.GetAttackTarget(),1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local dc=Duel.GetAttackTarget()
	if dc and dc:IsRelateToBattle() then
		Duel.Destroy(dc,REASON_EFFECT)
	end
end

function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	local bc=Duel.GetAttacker()
	return ec~=nil and bc==ec and bc:IsRelateToBattle()
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(1500)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1500)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end

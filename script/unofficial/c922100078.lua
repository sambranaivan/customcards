--Gold Cloth - Aquarius
--[==[
-- ID: 922100078
-- Type: Spell / Equip Spell
--
-- Archetypes:
-- - cloth
-- - Gold Cloth
--
-- Effect (EN):
-- Equip only to a "Gold Saint" monster.
-- Monsters your opponent controls lose 500 ATK.
-- If a monster battles the equipped monster, at the end of the Damage Step: Change that monster to face-down Defense Position.
--]==]
--Gold Cloth - Aquarius
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

	--Opponent monsters lose 500 ATK
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(-500)
	c:RegisterEffect(e2)

	--If a monster battles the equipped monster: at end of Damage Step, set it face-down DEF
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DAMAGE_STEP_END)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.poscon)
	e3:SetOperation(s.posop)
	c:RegisterEffect(e3)
end

s.listed_series={SET_CLOTH,SET_GOLD_CLOTH,SET_GOLD_SAINT,SET_SAINT}
function s.eqlimit(e,c)
	return c:IsSetCard(SET_GOLD_SAINT)
end
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	return ec~=nil and a and d and (a==ec or d==ec)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if not ec or not a or not d then return end
	local tc=(a==ec) and d or a
	if tc and tc:IsFaceup() and tc:IsCanTurnSet() then
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end

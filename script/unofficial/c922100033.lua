--Gold Saint - Dohko of Libra - Master of the Five Ancient Peaks
--[==[
-- ID: 922100033
-- Type: Monster / Xyz Monster
-- Rank: 4
-- Attribute: EARTH
-- Race: Warrior
-- ATK/DEF: 2400/2400
--
-- Archetypes:
-- - saint
-- - Gold Saint
-- Effect (EN):
-- 3 Level 4 "Saint" monsters
-- This card gains these effects based on the number of materials attached to it.
-- ● 1+: Cannot be destroyed by battle.
-- ● 2+: Once per turn: You can detach 1 material from this card; destroy 1 Spell/Trap on the field.
-- ● 3+: (Quick Effect): You can detach 1 material from this card; "Saint" monsters you control gain 1000 ATK and cannot be targeted by your opponent's card effects, until the end of this turn.
-- Once per turn: You can target 1 "Cloth" card in your GY; attach it to this card as material.
-- You can only use each effect of "Gold Saint - Dohko of Libra - Master of the Five Ancient Peaks" once per turn.
--]==]
--Gold Saint - Dohko of Libra - Master of the Five Ancient Peaks
local s,id=GetID()
function s.initial_effect(c)
	Xyz.AddProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,SET_SAINT),4,3)
	c:EnableReviveLimit()

	--1+: Cannot be destroyed by battle
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	e1:SetCondition(s.indcon)
	c:RegisterEffect(e1)

	--2+: Detach 1; destroy 1 Spell/Trap
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.descon)
	e2:SetCost(aux.dxmcostgen(1,1,nil))
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)

	--3+: Detach 1; your "Saint" gain 1000 ATK and cannot be targeted
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.buffcon)
	e3:SetCost(aux.dxmcostgen(1,1,nil))
	e3:SetOperation(s.buffop)
	c:RegisterEffect(e3)

	--Attach 1 "Cloth" in GY as material
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_LEAVE_GRAVE)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,{id,2})
	e4:SetTarget(s.ovatg)
	e4:SetOperation(s.ovaop)
	c:RegisterEffect(e4)
end

s.listed_series={SET_SAINT,SET_GOLD_SAINT,SET_CLOTH}

function s.indcon(e)
	return e:GetHandler():GetOverlayCount()>=1
end
function s.descon(e)
	return e:GetHandler():GetOverlayCount()>=2
end
function s.buffcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayCount()>=3
end

function s.stfilter(c)
	return c:IsSpellTrap() and c:IsDestructable()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.stfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.stfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.stfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

function s.saintfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_SAINT)
end
function s.buffop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.saintfilter)
	e1:SetValue(1000)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.saintfilter)
	e2:SetValue(aux.tgoval)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
end

function s.ovafilter(c)
	return c:IsSetCard(SET_CLOTH) and c:IsAbleToRemove()
end
function s.ovatg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.ovafilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.ovafilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	Duel.SelectTarget(tp,s.ovafilter,tp,LOCATION_GRAVE,0,1,1,nil)
end
function s.ovaop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or not c:IsFaceup() then return end
	if tc and tc:IsRelateToEffect(e) then
		Duel.Overlay(c,Group.FromCards(tc))
	end
end

--Gold Saint - Aphrodite of Pisces
--[==[
-- ID: 922100038
-- Type: Monster / Xyz Monster
-- Rank: 4
-- Attribute: WATER
-- Race: Warrior
-- ATK/DEF: 2200/2600
--
-- Archetypes:
-- - saint
-- - Gold Saint
-- Effect (EN):
-- 3 Level 4 "Saint" monsters
-- Once per turn: You can detach 1 material from this card; your opponent cannot declare attacks during their next Battle Phase.
-- Once per turn: You can target 1 "Cloth" card in your GY; attach it to this card as material.
-- You can only use each effect of "Gold Saint - Aphrodite of Pisces" once per turn.
--]==]
--Gold Saint - Aphrodite of Pisces
local s,id=GetID()
function s.initial_effect(c)
	Xyz.AddProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,SET_SAINT),4,3)
	c:EnableReviveLimit()

	--Detach 1; opponent cannot declare attacks during their next Battle Phase
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(aux.dxmcostgen(1,1,nil))
	e1:SetOperation(s.atklimop)
	c:RegisterEffect(e1)

	--Attach 1 "Cloth" in GY as material
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_LEAVE_GRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.ovatg)
	e2:SetOperation(s.ovaop)
	c:RegisterEffect(e2)
end

s.listed_series={SET_SAINT,SET_GOLD_SAINT,SET_CLOTH}

function s.atklimop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetReset(RESET_PHASE+PHASE_BATTLE_START+RESET_OPPO_TURN)
	Duel.RegisterEffect(e1,tp)
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

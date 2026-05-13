--Gold Saint - Camus of Aquarius
--[==[
-- ID: 922100040
-- Type: Monster / Xyz Monster
-- Rank: 8
-- Attribute: WATER
-- Race: Warrior
-- ATK/DEF: 2700/2600
--
-- Archetypes:
-- - saint
-- - Gold Saint
-- Effect (EN):
-- 2 Level 8 "Saint" monsters
-- Once per turn: You can detach 1 material from this card, then target 2 cards your opponent controls; while this card is face-up on the field, those cards cannot be activated, cannot change their battle positions, and cannot attack.
-- Once per turn: You can target 1 "Cloth" card in your GY; attach it to this card as material.
-- You can only use each effect of "Gold Saint - Camus of Aquarius" once per turn.
--]==]
--Gold Saint - Camus of Aquarius
local s,id=GetID()
function s.initial_effect(c)
	Xyz.AddProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,SET_SAINT),8,2)
	c:EnableReviveLimit()

	--Detach 1; target 2 opponent cards; while this remains face-up, those cards cannot be activated, cannot change battle position, and cannot attack
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(aux.dxmcostgen(1,1,nil))
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
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

function s.tgfilter(c)
	return c:IsOnField() and c:IsFaceup()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_ONFIELD) and s.tgfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,0,LOCATION_ONFIELD,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,0,LOCATION_ONFIELD,2,2,nil)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsFaceup() or not c:IsRelateToEffect(e) then return end
	local g=Duel.GetTargetCards(e)
	for tc in g:Iter() do
		if tc:IsFaceup() and tc:IsRelateToEffect(e) then
			--Cannot activate
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_TRIGGER)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			--Cannot change position
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
			--Cannot attack (monsters only)
			if tc:IsType(TYPE_MONSTER) then
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(EFFECT_CANNOT_ATTACK)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e3)
			end
		end
	end
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

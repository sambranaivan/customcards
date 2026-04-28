--Gold Saint - Mu of Aries
--[==[
-- ID: 922100029
-- Type: Monster / Xyz Monster
-- Rank: 8
-- Attribute: LIGHT
-- Race: Warrior
-- ATK/DEF: 2100/2600
--
-- Archetypes:
-- - Gold Saint
-- - saint
-- - saint-seiya
--
-- Effect (EN):
-- 2 Level 8 "Saint" monsters
-- You can detach 1 material; add 1 "Cloth" card from your GY to your hand, or if that card was a "Gold Cloth", you can equip it to a monster you control instead.
-- Once per turn: You can target 1 "Cloth" card in your GY; attach it to this card as material.
-- You can only use each effect of "Gold Saint - Mu of Aries" once per turn.
--]==]
--Gold Saint - Mu of Aries
local s,id=GetID()
function s.initial_effect(c)
	Xyz.AddProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,SET_SAINT),8,2)
	c:EnableReviveLimit()

	--Detach 1; add 1 "Cloth" from GY, or equip it instead if it's a "Gold Cloth"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(aux.dxmcostgen(1,1,nil))
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
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

s.listed_series={SET_SAINT,SET_GOLD_SAINT,SET_CLOTH,SET_GOLD_CLOTH}

function s.clothgyfilter(c)
	return c:IsSetCard(SET_CLOTH) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.clothgyfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsFaceup() then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.clothgyfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if not tc then return end
	if tc:IsSetCard(SET_GOLD_CLOTH) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) and not tc:IsForbidden() then
		local op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
		if op==1 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
			local mg=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
			local mc=mg:GetFirst()
			if mc and Duel.Equip(tp,tc,mc,true) then return end
		end
	end
	Duel.SendtoHand(tc,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,tc)
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

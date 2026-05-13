--Gold Saint - Aiolia of Leo
--[==[
-- ID: 922100030
-- Type: Monster / Xyz Monster
-- Rank: 8
-- Attribute: LIGHT
-- Race: Warrior
-- ATK/DEF: 2800/2000
--
-- Archetypes:
-- - saint
-- - Gold Saint
-- Effect (EN):
-- 2 Level 8 "Saint" monsters
-- Once per turn: You can detach any number of materials from this card; destroy up to that many monsters your opponent controls.
-- Once per turn: You can target 1 "Cloth" card in your GY; attach it to this card as material.
-- You can only use each effect of "Gold Saint - Aiolia of Leo" once per turn.
--]==]
--Gold Saint - Aiolia of Leo
local s,id=GetID()
function s.initial_effect(c)
	Xyz.AddProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,SET_SAINT),8,2)
	c:EnableReviveLimit()

	--Detach any number; destroy up to that many monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.descost)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
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

function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetOverlayCount()>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVEXYZ)
	local ct=Duel.RemoveOverlayCard(tp,1,1,1,REASON_COST)
	e:SetLabel(ct)
end
function s.desfilter(c)
	return c:IsMonster() and c:IsDestructable()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.desfilter(chkc) end
	local ct=e:GetLabel()
	if chk==0 then return ct>0 and Duel.IsExistingTarget(s.desfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.desfilter,tp,0,LOCATION_MZONE,1,ct,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
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

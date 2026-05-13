--Saint - Ban of Lionet
--[==[
-- ID: 922100008
-- Type: Monster / Effect Monster
-- Level: 4
-- Attribute: FIRE
-- Race: Warrior
-- ATK/DEF: 1500/1300
--
-- Archetypes:
-- - saint
-- - Bronze Saint
-- Effect (EN):
-- If a "Saint" monster(s) you control is destroyed by battle: You can Special Summon this card from your hand.
-- If this card is Special Summoned: You can target 1 "Saint" monster in your GY; add it to your hand.
-- If this card is sent to the GY as material for the Summon of a "Saint" monster: You can either equip 1 face-up "Cloth" Equip Spell you control to that monster, or attach it to it as material (if it is an Xyz Monster).
-- You can only use each effect of "Bronze Saint - Ban of Lionet" once per turn.
--]==]
--Saint - Ban of Lionet
local s,id=GetID()
function s.initial_effect(c)
	--If a "Saint" you control is destroyed by battle: Special Summon this card from hand or GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	--If Special Summoned: add 1 "Saint" monster from GY to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)

	--If sent to GY as material for a "Saint" monster
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.matcon)
	e3:SetTarget(s.mattg)
	e3:SetOperation(s.matop)
	c:RegisterEffect(e3)
end

s.listed_series={SET_SAINT,SET_BRONZE_SAINT,SET_CLOTH}

function s.spconfilter(c,tp)
	return c:IsReason(REASON_BATTLE) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsSetCard(SET_SAINT)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spconfilter,1,nil,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,c:GetLocation())
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.saintgyfilter(c)
	return c:IsSetCard(SET_SAINT) and c:IsMonster() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.saintgyfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.saintgyfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.saintgyfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
end

function s.matcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	return c:IsLocation(LOCATION_GRAVE) and (r&REASON_MATERIAL)~=0 and rc and rc:IsSetCard(SET_SAINT) and rc:IsMonster()
end
function s.matclothfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_CLOTH) and c:IsType(TYPE_EQUIP)
end
function s.mattg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=e:GetHandler():GetReasonCard()
	if chk==0 then
		return rc and rc:IsFaceup() and Duel.IsExistingMatchingCard(s.matclothfilter,tp,LOCATION_ONFIELD,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_ONFIELD)
end
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	if not rc or not rc:IsFaceup() then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectMatchingCard(tp,s.matclothfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	local tc=g:GetFirst()
	if not tc then return end
	if rc:IsType(TYPE_XYZ) then
		Duel.Overlay(rc,Group.FromCards(tc))
	else
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
		Duel.Equip(tp,tc,rc,true)
	end
end

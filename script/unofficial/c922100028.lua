--Gold Saint - Flash of Hope of the Five (Link-4)
--[==[
-- ID: 922100028
-- Type: Monster / Link Monster
-- Link: 4
-- Attribute: LIGHT
-- Race: Warrior
-- ATK/DEF: 2500/-
--
-- Archetypes:
-- - saint
-- - Gold Saint
-- Effect (EN):
-- 2+ "Saint" monsters
-- This card gains 500 ATK for each Equip Card on the field.
-- Once per turn (Quick Effect): You can target 1 "Cloth" Equip Spell in your GY; equip it to this card.
-- This card gains the effects of "Saint" monsters currently equipped with their corresponding "Cloth" cards.
--]==]
--Gold Saint - Flash of Hope of the Five (Link-4)
local s,id=GetID()
function s.initial_effect(c)
	Link.AddProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,SET_SAINT),2,nil)
	c:EnableReviveLimit()

	--Gains 500 ATK for each Equip Card on the field
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)

	--Equip 1 "Cloth" Equip Spell from GY to this card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)

	--Copy effect of a "Saint" monster you control equipped with a "Cloth" Equip Spell
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.cptg)
	e3:SetOperation(s.cpop)
	c:RegisterEffect(e3)
end

s.listed_series={SET_SAINT,SET_GOLD_SAINT,SET_CLOTH}

function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(Card.IsType,c:GetControler(),LOCATION_ONFIELD,LOCATION_ONFIELD,nil,TYPE_EQUIP)*500
end

function s.clotheqgy(c)
	return c:IsSetCard(SET_CLOTH) and c:IsType(TYPE_EQUIP) and c:IsAbleToEquip()
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.clotheqgy(chkc) end
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			and Duel.IsExistingTarget(s.clotheqgy,tp,LOCATION_GRAVE,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,s.clotheqgy,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_GRAVE)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or not c:IsFaceup() or not c:IsRelateToEffect(e) then return end
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Equip(tp,tc,c,true)
end

function s.copyfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_SAINT)
		and c:GetEquipGroup():IsExists(function(ec) return ec:IsSetCard(SET_CLOTH) and ec:IsType(TYPE_EQUIP) end,1,nil)
end
function s.cptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.copyfilter,tp,LOCATION_MZONE,0,1,nil) end
end
function s.cpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,s.copyfilter,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if not tc then return end
	local code=tc:GetOriginalCodeRule()
	c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)
end

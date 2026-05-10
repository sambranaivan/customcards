--Cosmo Surge
--[==[
-- ID: 922100307
-- Type: Spell / Quick-Play Spell
--
-- Archetypes:
-- - saint-seiya
-- - saint
-- - Bronze Saint
-- - cloth
--
-- Effect (EN):
-- Target 1 "Bronze Saint" monster you control; until the End Phase of this turn, it gains 500 ATK for each "Cloth" Equip Spell equipped to "Bronze Saint" monsters you control.
-- You can only activate 1 "Cosmo Surge" per turn.
--]==]
--Cosmo Surge
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKDEF_CHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

s.listed_series={SET_SAINT,SET_BRONZE_SAINT,SET_CLOTH}

function s.saintfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_BRONZE_SAINT)
end
function s.clotheqfilter(c)
	return c:IsSetCard(SET_CLOTH) and c:IsType(TYPE_EQUIP)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.saintfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.saintfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.saintfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_ATKDEF_CHANGE,nil,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or not tc:IsFaceup() then return end
	local count=0
	local saints=Duel.GetMatchingGroup(s.saintfilter,tp,LOCATION_MZONE,0,nil)
	for saint in aux.Next(saints) do
		count=count+saint:GetEquipGroup():Filter(s.clotheqfilter,nil):GetCount()
	end
	if count>0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(count*500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end

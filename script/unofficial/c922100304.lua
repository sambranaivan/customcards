--Legend of the Bronze Saints
--[==[
-- ID: 922100304
-- Type: Spell / Field Spell
--
-- Archetypes:
-- - saint-seiya
-- - saint
-- - Bronze Saint
--
-- Effect (EN):
-- All "Bronze Saint" monsters gain 500 ATK/DEF.
-- Once per turn: You can target 1 "Bronze Saint" monster you control equipped with a "Bronze Cloth" Equip Spell; until the End Phase, that target gains ATK equal to its current DEF.
-- Once per turn, if a "Bronze Saint" monster you control would be destroyed by battle or card effect: You can send 1 "Bronze Cloth" Equip Spell equipped to it to the GY instead.
-- You can only use each effect of "Legend of the Bronze Saints" once per turn.
--]==]
--Legend of the Bronze Saints
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	--All "Bronze Saint" monsters gain 500 ATK/DEF
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_BRONZE_SAINT))
	e1:SetValue(500)
	c:RegisterEffect(e1)
	local e1b=e1:Clone()
	e1b:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1b)

	--Once per turn IGNITION: target Bronze Saint with Bronze Cloth; gains ATK equal to current DEF
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_ATKDEF_CHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.boosttg)
	e2:SetOperation(s.boostop)
	c:RegisterEffect(e2)

	--Destruction replacement: if Bronze Saint would be destroyed, send Bronze Cloth equipped to it to GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,{id,2})
	e3:SetTarget(s.reptg)
	e3:SetOperation(s.repop)
	c:RegisterEffect(e3)
end

s.listed_series={SET_SAINT,SET_BRONZE_SAINT,SET_CLOTH,SET_BRONZE_CLOTH}

-- ATK boost effect
function s.boostfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_BRONZE_SAINT)
		and c:GetEquipGroup():IsExists(Card.IsSetCard,1,nil,SET_BRONZE_CLOTH)
end
function s.boosttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.boostfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.boostfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.boostfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_ATKDEF_CHANGE,nil,1,0,0)
end
function s.boostop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or not tc:IsFaceup() then return end
	local boost=tc:GetDefense()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(boost)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e1)
end

-- Destruction replacement effect
function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(SET_BRONZE_SAINT) and c:IsControler(tp)
		and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT))
		and c:GetEquipGroup():IsExists(Card.IsSetCard,1,nil,SET_BRONZE_CLOTH)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp) end
	return Duel.SelectYesNo(tp,aux.Stringid(id,1))
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.repfilter,nil,tp)
	local tc=g:Select(tp,1,1,nil):GetFirst()
	if not tc then return end
	local eqg=tc:GetEquipGroup():Filter(Card.IsSetCard,nil,SET_BRONZE_CLOTH)
	if eqg:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local sg=eqg:Select(tp,1,1,nil)
		Duel.SendtoGrave(sg,REASON_EFFECT+REASON_REPLACE)
	end
end

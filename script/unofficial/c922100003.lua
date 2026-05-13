--Saint - Shun of Andromeda
--[==[
-- ID: 922100003
-- Type: Monster / Effect Monster
-- Level: 4
-- Attribute: WIND
-- Race: Warrior
-- ATK/DEF: 1300/1900
--
-- Archetypes:
-- - saint
-- - Bronze Saint
-- Effect (EN):
-- Your opponent cannot target other "Saint" monsters you control for attacks.
-- If this card is equipped with a "Cloth" Equip Spell, it can attack while in Defense Position. Use its DEF for damage calculation.
-- You can pay 500 LP; equip 1 "Cloth" Equip Spell from your GY to this card, also, for the rest of this turn after this effect resolves, you cannot Special Summon from the Extra Deck, except "Saint" monsters.
-- If this card is sent to the GY as material for the Summon of a "Saint" monster: You can either equip 1 face-up "Cloth" Equip Spell you control to that monster, or attach it to it as material (if it is an Xyz Monster).
-- You can only use each effect of "Bronze Saint - Shun of Andromeda" once per turn.
--]==]
--Saint - Shun of Andromeda
local s,id=GetID()
function s.initial_effect(c)
	--Opponent cannot target other "Saint" monsters you control for attacks
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(s.atlimit)
	c:RegisterEffect(e1)

	--Can attack while in Defense Position if equipped with a "Cloth" card
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DEFENSE_ATTACK)
	e2:SetCondition(s.defatkcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)

	--Equip 1 "Cloth" Equip Spell + Extra Deck lock
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.eqcost)
	e3:SetTarget(s.eqtg)
	e3:SetOperation(s.eqop)
	c:RegisterEffect(e3)

	--If sent to GY as material for a "Saint" monster
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_EQUIP)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_BE_MATERIAL)
	e4:SetCountLimit(1,{id,1})
	e4:SetCondition(s.matcon)
	e4:SetTarget(s.mattg)
	e4:SetOperation(s.matop)
	c:RegisterEffect(e4)
end

s.listed_series={SET_SAINT,SET_BRONZE_SAINT,SET_CLOTH}

function s.atlimit(e,c)
	local tc=e:GetHandler()
	return c:IsSetCard(SET_SAINT) and c~=tc
end
function s.clotheqfilter(c)
	return c:IsSetCard(SET_CLOTH) and c:IsType(TYPE_EQUIP)
end
function s.defatkcon(e)
	local eg=e:GetHandler():GetEquipGroup()
	return eg and eg:IsExists(s.clotheqfilter,1,nil)
end

function s.eqcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	Duel.PayLPCost(tp,500)
end
function s.eqfilter(c)
	return c:IsSetCard(SET_CLOTH) and c:IsType(TYPE_EQUIP) and not c:IsForbidden()
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsFaceup()
			and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_GRAVE,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_GRAVE)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not c:IsFaceup() then return end
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if not tc then return end
	if Duel.Equip(tp,tc,c,true) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(SET_SAINT)
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

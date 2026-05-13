--Saint - Hyoga of Cygnus
--[==[
-- ID: 922100002
-- Type: Monster / Effect Monster
-- Level: 4
-- Attribute: WATER
-- Race: Warrior
-- ATK/DEF: 1600/1400
--
-- Archetypes:
-- - saint
-- - Bronze Saint
-- Effect (EN):
-- If this card attacks an opponent's monster, before damage calculation: Change that opponent's monster to Defense Position, and if you do, negate its effects until the end of your opponent's next turn.
-- You can pay 500 LP; equip 1 "Cloth" Equip Spell from your GY to this card, also, for the rest of this turn after this effect resolves, you cannot Special Summon from the Extra Deck, except "Saint" monsters.
-- If this card is sent to the GY as material for the Summon of a "Saint" monster: You can either equip 1 face-up "Cloth" Equip Spell you control to that monster, or attach it to it as material (if it is an Xyz Monster).
-- You can only use each effect of "Bronze Saint - Hyoga of Cygnus" once per turn.
--]==]
--Saint - Hyoga of Cygnus
local s,id=GetID()
function s.initial_effect(c)
	--When Hyoga attacks only — before damage calculation: change to DEF, negate effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.poscon)
	e1:SetTarget(s.postg)
	e1:SetOperation(s.posop)
	c:RegisterEffect(e1)

	--Equip 1 "Cloth" Equip Spell + Extra Deck lock
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.eqcost)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
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

function s.battleopp(e)
	local c=e:GetHandler()
	if Duel.GetAttacker()~=c then return nil end
	return Duel.GetAttackTarget()
end
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
	local bc=s.battleopp(e)
	return bc~=nil and bc:IsControler(1-tp) and bc:IsFaceup() and bc:IsRelateToBattle()
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=s.battleopp(e)
	if chk==0 then return bc and bc:IsCanChangePosition() end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,bc,1,0,0)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local bc=s.battleopp(e)
	if not bc or not bc:IsRelateToBattle() then return end
	if Duel.ChangePosition(bc,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE)~=0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		bc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		bc:RegisterEffect(e2)
	end
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

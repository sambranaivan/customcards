--Black Saint - Dark Andromeda
--[==[
-- ID: 922100153
-- Type: Monster / Effect Monster
-- Level: 4
-- Attribute: DARK
-- Race: Warrior
-- ATK/DEF: 1400/1900
--
-- Archetypes:
-- - saint
-- - Black Saint
-- Effect (EN):
-- Your opponent cannot target other "Black Saint" monsters you control for attacks.
-- Once per turn: You can equip 1 "Fragment of Sagittarius" Equip Spell from your hand or GY to this card.
-- If this card is equipped with 2 or more Equip Cards, your opponent cannot target this card with card effects.
-- If a face-up "Fragment of Sagittarius" Equip Spell(s) you control is sent to the GY by card effect: Draw 1 card.
-- You can only use this effect of "Black Saint - Dark Andromeda" once per turn.
--]==]
--Black Saint - Dark Andromeda
local s,id=GetID()
function s.initial_effect(c)
	--Opponent cannot target other Black Saints for attacks
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(s.atlimit)
	c:RegisterEffect(e1)

	--Equip 1 Fragment from hand or GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)

	--If equipped with 2+ equips: cannot be targeted by effects
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.tgcon)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)

	--If face-up Fragment Equip you control sent to GY by effect: draw 1
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,{id,1})
	e4:SetCondition(s.drcon)
	e4:SetTarget(s.drtg)
	e4:SetOperation(s.drop)
	c:RegisterEffect(e4)
end

s.listed_series={SET_BLACK_SAINT,SET_FRAGMENT_OF_SAGITTARIUS,SET_SAINT}

function s.atlimit(e,c)
	local tc=e:GetHandler()
	return c~=tc and c:IsFaceup() and c:IsSetCard(SET_BLACK_SAINT)
end

function s.eqfilter(c)
	return c:IsType(TYPE_EQUIP) and c:IsSetCard(SET_FRAGMENT_OF_SAGITTARIUS) and c:IsAbleToChangeControler()
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or not c:IsFaceup() then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then Duel.Equip(tp,tc,c) end
end

function s.tgcon(e)
	local c=e:GetHandler()
	return c:IsFaceup() and c:GetEquipCount()>=2
end

function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(function(c)
		return c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousPosition(POS_FACEUP)
			and c:IsSetCard(SET_FRAGMENT_OF_SAGITTARIUS) and (r&REASON_EFFECT)~=0 and c:IsControler(tp)
	end,1,nil)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Draw(tp,1,REASON_EFFECT)
end

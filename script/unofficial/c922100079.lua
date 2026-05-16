--Athena's Sanctuary
--[==[
-- ID: 922100079
-- Type: Spell / Field Spell
--
-- Archetypes:
-- (setcode 0 — not in a named ProjectIgnis archetype series)
-- Effect (EN):
-- All "Saint" monsters on the field gain 300 ATK/DEF.
-- The first time a "Bronze Saint" monster you control would be destroyed by battle, while this card is in the Field Zone, it is not destroyed.
-- Once per turn: You can target 1 "Cloth" card in your Spell & Trap Zone; return it to the hand.
--]==]
--Athena's Sanctuary
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	--ATK/DEF +300 for all "Saint" monsters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_SAINT))
	e1:SetValue(300)
	c:RegisterEffect(e1)
	local e1b=e1:Clone()
	e1b:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1b)

	--First time a "Bronze Saint" you control would be destroyed by battle (while this card is in the Field Zone)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTarget(s.reptg)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)

	--Reset battle protection when this card leaves the Field Zone
	local e2r=Effect.CreateEffect(c)
	e2r:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2r:SetCode(EVENT_LEAVE_FIELD)
	e2r:SetOperation(s.resetop)
	c:RegisterEffect(e2r)

	--Once per turn: return 1 "Cloth" in your Spell & Trap Zone to hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.clothtg)
	e3:SetOperation(s.clothop)
	c:RegisterEffect(e3)
end

s.listed_series={SET_SAINT,SET_CLOTH,SET_BRONZE_SAINT}

function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(SET_BRONZE_SAINT) and c:IsControler(tp)
		and c:IsReason(REASON_BATTLE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(id+10)==0 and eg:IsExists(s.repfilter,1,nil,tp) end
	return true
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id+10,RESET_EVENT+RESETS_STANDARD,0,0)
end
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():ResetFlagEffect(id+10)
end

function s.clothfilter(c,tp)
	return c:IsControler(tp) and c:IsFaceup() and c:IsSetCard(SET_CLOTH)
		and c:IsLocation(LOCATION_SZONE) and c:IsAbleToHand()
end
function s.clothtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_SZONE) and s.clothfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.clothfilter,tp,LOCATION_SZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	Duel.SelectTarget(tp,s.clothfilter,tp,LOCATION_SZONE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_SZONE)
end
function s.clothop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,Group.FromCards(tc))
	end
end

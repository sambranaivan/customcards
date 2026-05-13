--Renegade Saint - Aphrodite of Pisces
--[==[
-- ID: 922100210
-- Type: Monster / Effect Monster
-- Level: 4
-- Attribute: DARK
-- Race: Zombie
-- ATK/DEF: 1600/1800
--
-- Archetypes:
-- - saint
-- - Renegade Saint
-- Effect (EN):
-- This card is also treated as a "Saint" monster while on the field and in the GY.
-- If this card is Special Summoned by a "Renegade Saint" monster's effect: You can draw 1 card, then your opponent sends 1 card from their hand or field to the GY.
-- While you have 3 or more "Specter" monsters in your GY, your opponent cannot target Level 8 "Renegade Saint" monsters you control for attacks.
-- You can only use this effect of "Renegade Saint - Aphrodite of Pisces" once per turn.
--]==]
--Renegade Saint - Aphrodite of Pisces
local s,id=GetID()
function s.initial_effect(c)
	-- If SS by Renegade Saint effect: draw 1 then opponent sends 1 from hand/field
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.drcon)
	e1:SetTarget(s.drtg)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)
	-- Attack target protection for your Level 8 Renegade Saints
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(s.btcon)
	e2:SetValue(s.btval)
	c:RegisterEffect(e2)
end
s.listed_series={SET_RENEGADE_SAINT, SET_SAINT}

function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:GetHandler():IsSetCard(SET_RENEGADE_SAINT)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Draw(tp,1,REASON_EFFECT)==0 then return end
	local g=Duel.GetMatchingGroup(aux.TRUE,1-tp,LOCATION_HAND+LOCATION_ONFIELD,0,nil)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)
	local sg=g:Select(1-tp,1,1,nil)
	Duel.SendtoGrave(sg,REASON_EFFECT)
end

function s.btcon(e)
	return Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,SET_SPECTER),e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil)>=3
end
function s.btval(e,c)
	return c:IsFaceup() and c:IsSetCard(SET_RENEGADE_SAINT) and c:IsLevel(8)
end

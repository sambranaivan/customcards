--Specter Judge - Aiacos of Garuda
--[==[
-- ID: 922100204
-- Type: Monster / Effect Monster
-- Level: 8
-- Attribute: DARK
-- Race: Warrior
-- ATK/DEF: 2800/2200
--
-- Archetypes:
-- - Specter
-- - saint-seiya
--
-- Effect (EN):
-- Cannot be Normal Summoned/Set.
-- Must be Special Summoned (from your hand or GY) while you have 6 or more "Specter" monsters in your GY.
-- Your opponent cannot activate cards or effects in response to the activation of your "Specter" monster effects in the GY.
-- If this card is Special Summoned from the GY: Your opponent discards 1 random card.
-- Once per turn, if you have 8 or more "Specter" monsters in your GY: You can return all Spells/Traps your opponent controls in this card's column and adjacent columns to the hand.
-- You can only use each effect of "Specter Judge - Aiacos of Garuda" once per turn.
--]==]
--Specter Judge - Aiacos of Garuda
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- Special Summon proc with 6+ Specters in GY
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e0:SetCondition(s.spcon)
	c:RegisterEffect(e0)
	-- Opponent cannot respond to your Specter GY monster effects (approx global chainlimit)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetCondition(s.clcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- If SS from GY: opponent discards random
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_HANDES)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.hdcon)
	e2:SetTarget(s.hdtg)
	e2:SetOperation(s.hdop)
	c:RegisterEffect(e2)
	-- Once per turn if 8+ Specters in GY: bounce S/T in column and adjacent
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+100)
	e3:SetCondition(s.bcon)
	e3:SetTarget(s.btg)
	e3:SetOperation(s.bop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_SPECTER, SET_SAINT}

function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,SET_SPECTER),tp,LOCATION_GRAVE,0,nil)>=6
end
function s.clcon(e)
	return true
end
function s.hdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
end
function s.hdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)>0 end
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,1)
end
function s.hdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
	if #g==0 then return end
	local sg=g:RandomSelect(tp,1)
	Duel.SendtoGrave(sg,REASON_EFFECT+REASON_DISCARD)
end
function s.bcon(e)
	return Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,SET_SPECTER),e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil)>=8
end
function s.stfilter(c,mc)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand() and c:IsFaceup()
		and (mc:GetColumnGroup():IsContains(c) or mc:GetAdjacentColumnGroup():IsContains(c))
end
function s.btg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.stfilter,tp,0,LOCATION_SZONE,1,nil,c) end
	local g=Duel.GetMatchingGroup(s.stfilter,tp,0,LOCATION_SZONE,nil,c)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
function s.bop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.stfilter,tp,0,LOCATION_SZONE,nil,c)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end

--Specter - Pharaoh of Sphinx
--[==[
-- ID: 922100198
-- Type: Monster / Effect Monster
-- Level: 4
-- Attribute: DARK
-- Race: Zombie
-- ATK/DEF: 1500/1500
--
-- Archetypes:
-- - Specter
-- - saint-seiya
--
-- Effect (EN):
-- While you have 3 or more "Specter" monsters in your GY, your opponent cannot activate card effects in the GY.
-- If this card is sent to the GY: You can send 1 "Specter" monster from your Deck to the GY.
-- You can only use this effect of "Specter - Pharaoh of Sphinx" once per turn.
--]==]
--Specter - Pharaoh of Sphinx
local s,id=GetID()
function s.initial_effect(c)
	-- Lock GY activations while 3+ Specters in your GY
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetCondition(s.lockcon)
	e1:SetValue(s.aclimit)
	c:RegisterEffect(e1)
	-- If sent to GY: send 1 Specter from Deck
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_SPECTER, SET_SAINT}

function s.lockcon(e)
	return Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,SET_SPECTER),e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil)>=3
end
function s.aclimit(e,re,tp)
	return re:GetHandler():IsLocation(LOCATION_GRAVE)
end
function s.tgfilter(c)
	return c:IsSetCard(SET_SPECTER) and c:IsMonster() and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end

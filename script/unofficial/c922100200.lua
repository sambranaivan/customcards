--Specter - Raimi of Worm
--[==[
-- ID: 922100200
-- Type: Monster / Effect Monster
-- Level: 4
-- Attribute: DARK
-- Race: Zombie
-- ATK/DEF: 1400/1400
--
-- Archetypes:
-- - Specter
-- - saint-seiya
--
-- Effect (EN):
-- While this card is in your GY, your opponent cannot activate cards or effects in response to the Special Summon of your "Specter" monster(s).
-- If this card is sent to the GY: You can target 1 "Specter" monster in your GY, except "Specter - Raimi of Worm"; add it to your hand.
-- You can only use this effect of "Specter - Raimi of Worm" once per turn.
--]==]
--Specter - Raimi of Worm
local s,id=GetID()
function s.initial_effect(c)
	-- While in GY, opponent cannot respond to your Specter summons
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_CANNOT_ACTIVATE)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e0:SetRange(LOCATION_GRAVE)
	e0:SetTargetRange(0,1)
	e0:SetCondition(s.clcon)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	-- If sent to GY: add 1 Specter (except itself)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_SPECTER, SET_SAINT}

function s.clcon(e)
	return true
end

function s.thfilter(c)
	return c:IsSetCard(SET_SPECTER) and c:IsMonster() and not c:IsCode(922100200) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

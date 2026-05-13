--Specter - Valentine of Harpy
--[==[
-- ID: 922100201
-- Type: Monster / Effect Monster
-- Level: 4
-- Attribute: DARK
-- Race: Zombie
-- ATK/DEF: 1700/1000
--
-- Archetypes:
-- - Specter
-- Effect (EN):
-- You can discard this card; add 1 Level 8 "Specter" monster or 1 "Renegade Saint" monster from your Deck to your hand.
-- If this card is sent to the GY: You can pay 500 LP; during the next Standby Phase, Special Summon this card.
-- You can only use each effect of "Specter - Valentine of Harpy" once per turn.
--]==]
--Specter - Valentine of Harpy
local s,id=GetID()
function s.initial_effect(c)
	-- Discard; search Level 8 Specter or Renegade Saint
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- If sent to GY: pay 500; SS next Standby
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+100)
	e2:SetCost(s.spcost)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_SPECTER, SET_SAINT}

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function s.thfilter(c)
	return c:IsAbleToHand() and ((c:IsSetCard(SET_SPECTER) and c:IsLevel(8) and c:IsMonster()) or c:IsSetCard(SET_RENEGADE_SAINT))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	Duel.PayLPCost(tp,500)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,0,1)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetReset(RESET_PHASE+PHASE_STANDBY)
	e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp and c:GetFlagEffect(id)>0 end)
	e1:SetOperation(function(e,tp)
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		if c:IsLocation(LOCATION_GRAVE) then
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end)
	Duel.RegisterEffect(e1,tp)
end

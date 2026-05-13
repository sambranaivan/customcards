--Specter - Niobe of Deep
--[==[
-- ID: 922100199
-- Type: Monster / Effect Monster
-- Level: 4
-- Attribute: DARK
-- Race: Zombie
-- ATK/DEF: 1300/1700
--
-- Archetypes:
-- - Specter
-- Effect (EN):
-- If this card is Special Summoned from the GY: You can negate the effects of all face-up monsters your opponent currently controls, until the end of this turn.
-- If this card is sent to the GY: You can pay 500 LP; during the next Standby Phase, Special Summon this card.
-- You can only use each effect of "Specter - Niobe of Deep" once per turn.
--]==]
--Specter - Niobe of Deep
local s,id=GetID()
function s.initial_effect(c)
	-- If SS from GY: negate all face-up opponent monsters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.negcon)
	e1:SetOperation(s.negop)
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

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		tc:RegisterEffect(e2)
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

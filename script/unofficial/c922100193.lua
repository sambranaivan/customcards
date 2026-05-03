--The Great Eclipse - World of Silence
--[==[
-- ID: 922100193
-- Type: Spell / Field Spell
--
-- Archetypes:
-- - saint-seiya
--
-- Effect (EN):
-- "Specter" monsters in your GY cannot be banished by your opponent's card effects.
-- Each time a "Specter" monster is Special Summoned from your GY: Inflict 500 damage to your opponent, and if you do, gain 500 LP.
-- Once per turn, during your Standby Phase: Place 1 Eclipse Counter on this card.
-- During your Standby Phase, if this card has 5 or more Eclipse Counters: You win the Duel.
-- You can only activate 1 "The Great Eclipse - World of Silence" per turn.
--]==]
--The Great Eclipse - World of Silence
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(0x10fa) -- Eclipse Counter
	-- Specters in your GY cannot be banished by opponent effects (approx.)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_REMOVE)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_GRAVE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_SPECTER))
	e1:SetCondition(function(e) return Duel.GetTurnPlayer()~=e:GetHandlerPlayer() end)
	c:RegisterEffect(e1)
	-- Damage + recover when Specter SS from GY
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(s.damcon)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
	-- Standby: add Eclipse counter
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp end)
	e3:SetOperation(s.ctop)
	c:RegisterEffect(e3)
	-- Win condition
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.wincon)
	e4:SetOperation(s.winop)
	c:RegisterEffect(e4)
end
s.listed_series={SET_SAINT}

function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spfromgy,1,nil,tp)
end
function s.spfromgy(c,tp)
	return c:IsSetCard(SET_SPECTER) and c:IsControler(tp) and c:IsPreviousLocation(LOCATION_GRAVE)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Damage(1-tp,500,REASON_EFFECT)
	Duel.Recover(tp,500,REASON_EFFECT)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() then c:AddCounter(0x10fa,1) end
end
function s.wincon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.GetTurnPlayer()==tp and c:IsFaceup() and c:GetCounter(0x10fa)>=5
end
function s.winop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Win(tp,WIN_REASON_EFFECT)
end

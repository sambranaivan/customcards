--Decree of Chronos
--[==[
-- ID: 922100285
-- Type: Spell / Quick-Play Spell
--
-- Archetypes:
-- - Meta
-- Effect (EN):
-- Declare 1 card name; banish 1 card with that name from your Deck, and if you do, for the rest of this turn, negate all activated effects and effects on the field of monsters with that original name, also negate the effects of Spells/Traps with that name.
--]==]
--Decree of Chronos
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_META, SET_SAINT}

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	return true
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local code=Duel.AnnounceCard(tp)
	-- banish 1 copy from deck if exists
	local g=Duel.GetMatchingGroup(aux.FilterBoolFunction(Card.IsCode,code),tp,LOCATION_DECK,0,nil)
	if #g>0 then
		local tc=g:Select(tp,1,1,nil):GetFirst()
		Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)
	end
	-- negate monsters with that name this turn
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(function(e,c) return c:IsFaceup() and c:IsCode(code) end)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	Duel.RegisterEffect(e2,tp)
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetTargetRange(1,1)
	e3:SetValue(function(e,re,tp) return re:GetHandler():IsCode(code) end)
	e3:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e3,tp)
end

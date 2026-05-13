--Gale of Tartarus
--[==[
-- ID: 922100279
-- Type: Spell / Normal Spell
--
-- Archetypes:
-- - Meta
-- Effect (EN):
-- Destroy all Spells and Traps your opponent controls. You cannot activate other Spell/Trap Cards the turn you activate this card, except Normal Spells.
-- You can only activate 1 "Gale of Tartarus" per turn.
--]==]
--Gale of Tartarus
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_META, SET_SAINT}

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_SZONE,nil)
	if #g>0 then Duel.Destroy(g,REASON_EFFECT) end
	-- restrict S/T activations except Normal Spells (approx)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(function(e,re,tp) return re:IsActiveType(TYPE_TRAP) or (re:IsActiveType(TYPE_SPELL) and not re:GetHandler():IsType(TYPE_NORMAL)) end)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

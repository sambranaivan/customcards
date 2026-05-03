--Cosmic Singularity
--[==[
-- ID: 922100274
-- Type: Spell / Normal Spell
--
-- Archetypes:
-- - Meta
-- - saint-seiya
--
-- Effect (EN):
-- Destroy all monsters on the field. Monsters destroyed by this effect cannot be Special Summoned from the GY for the rest of this turn.
-- You can only activate 1 "Cosmic Singularity" per turn.
--]==]
--Cosmic Singularity
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
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g==0 then return end
	local destroyed=g:Clone()
	if Duel.Destroy(g,REASON_EFFECT)>0 then
		-- cannot SS destroyed monsters from GY this turn (approx: prevent SS of their codes from GY)
		local codes={}
		for tc in aux.Next(destroyed) do
			codes[tc:GetOriginalCode()]=true
		end
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,1)
		e1:SetTarget(function(e,c) return c:IsLocation(LOCATION_GRAVE) and codes[c:GetOriginalCode()] end)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end

--Poseidon, God of the Seas - Awakened
--[==[
-- ID: 922100245
-- Type: Monster / Fusion Monster
-- Level: 10
-- Attribute: WATER
-- Race: Warrior
-- ATK/DEF: 4000/4000
--
-- Archetypes:
-- - Poseidon
-- Effect (EN):
-- Cannot be Normal Summoned/Set.
-- Must first be Special Summoned (from your hand or GY) by banishing 7 "Pillar" cards with different names from your hand, field, and/or GY. (This is treated as a Fusion Summon.)
-- Its Special Summon cannot be negated.
-- Unaffected by other cards' effects.
-- At the end of each Battle Phase, your opponent sends cards they control to the GY equal to the number of columns occupied by your "Marine General" cards.
-- If this face-up card would be Tributed or change control, you can send 1 of your banished "Pillar" cards to the GY instead.
--]==]
--Poseidon, God of the Seas - Awakened
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- Special Summon procedure by banishing 7 Pillars (treated as Fusion)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e0:SetCondition(s.spcon)
	e0:SetOperation(s.spop)
	e0:SetValue(SUMMON_TYPE_FUSION)
	c:RegisterEffect(e0)
	-- Cannot disable summon
	local e0b=Effect.CreateEffect(c)
	e0b:SetType(EFFECT_TYPE_SINGLE)
	e0b:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	c:RegisterEffect(e0b)
	-- Unaffected by other effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(function(e,re) return re:GetOwnerPlayer()~=e:GetHandlerPlayer() end)
	c:RegisterEffect(e1)
	-- End of Battle Phase: opponent sends cards equal to columns occupied by your Marine Generals
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetOperation(s.bpdrop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_POSEIDON, SET_SAINT}

function s.pillmat(c)
	return c:IsSetCard(SET_PILLAR) and c:IsAbleToRemoveAsCost()
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.pillmat,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,7,nil)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.pillmat,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,7,7,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function s.bpdrop(e,tp,eg,ep,ev,re,r,rp)
	local seen={}
	local ct=0
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSetCard,SET_MARINE_GENERAL),tp,LOCATION_MZONE,0,nil)
	for tc in aux.Next(g) do
		local seq=tc:GetSequence()
		if not seen[seq] then seen[seq]=true ct=ct+1 end
	end
	if ct<=0 then return end
	local og=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	if #og==0 then return end
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)
	local sg=og:Select(1-tp,math.min(ct,#og),math.min(ct,#og),nil)
	Duel.SendtoGrave(sg,REASON_EFFECT)
end

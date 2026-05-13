--Flood of the Sanctuary
--[==[
-- ID: 922100252
-- Type: Spell / Quick-Play Spell
--
-- Archetypes:
-- (setcode 0 — not in a named ProjectIgnis archetype series)
-- Effect (EN):
-- Target 1 "Marine General" monster you control; move it to another of your Main Monster Zones, and if you do, you can activate 1 "Pillar" card directly from your Deck in that monster's new column.
-- You can only activate 1 "Flood of the Sanctuary" per turn.
--]==]
--Flood of the Sanctuary
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_SAINT}

function s.mgfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_MARINE_GENERAL)
end
function s.pillfilter(c)
	return c:IsSetCard(SET_PILLAR) and c:IsSSetable()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.mgfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.mgfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
	Duel.SelectTarget(tp,s.mgfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	local zone=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
	local nseq=math.floor(math.log(zone,2))
	Duel.MoveSequence(tc,nseq)
	-- Activate a Pillar from Deck in that column (approx: move to field face-up)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local g=Duel.GetMatchingGroup(s.pillfilter,tp,LOCATION_DECK,0,nil)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local pc=g:Select(tp,1,1,nil):GetFirst()
	if pc then
		Duel.MoveToField(pc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end

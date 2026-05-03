--Blood Offering of the Renegades
--[==[
-- ID: 922100218
-- Type: Spell / Quick-Play Spell
--
-- Archetypes:
-- - saint-seiya
--
-- Effect (EN):
-- Target 1 "Renegade Saint" monster you control that was Special Summoned this turn; return it to the hand, and if you do, Special Summon "Specter" monsters from your GY, up to the number of "Specter" monsters banished for that monster's Summon.
-- You can only activate 1 "Blood Offering of the Renegades" per turn.
--]==]
--Blood Offering of the Renegades
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_SAINT}

function s.rsfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_RENEGADE_SAINT) and c:GetFlagEffect(922100205)>0 and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.rsfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.rsfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,s.rsfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_SPECTER) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	if Duel.SendtoHand(tc,nil,REASON_EFFECT)==0 then return end
	-- Approximate summon count: 2
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	local ct=math.min(2,ft)
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if #g==0 then return end
	if #g>ct then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		g=g:Select(tp,ct,ct,nil)
	end
	for sc in aux.Next(g) do
		Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP)
	end
	Duel.SpecialSummonComplete()
end

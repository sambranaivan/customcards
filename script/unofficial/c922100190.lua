--Bifrost Descent
--[==[
-- ID: 922100190
-- Type: Spell / Quick-Play Spell
--
-- Archetypes:
-- (setcode 0 — not in a named ProjectIgnis archetype series)
-- Effect (EN):
-- Special Summon 1 "God Warrior" monster from your hand or GY, then you can move that monster to another of your Main Monster Zones.
-- If this card is activated while your opponent controls an Extra Deck monster, you can place 1 Frost Counter on 1 face-up monster your opponent controls.
-- For the rest of this turn after this card resolves, you cannot Special Summon monsters from the Extra Deck, except "God Warrior" monsters.
-- You can only activate 1 "Bifrost Descent" per turn.
--]==]
--Bifrost Descent
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_SAINT}

function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_GOD_WARRIOR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then return end
	if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	-- Move to another MZ (optional)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
		local zone=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
		Duel.MoveSequence(tc,math.floor(math.log(zone,2)))
	end
	-- If opponent controls Extra Deck monster, place Frost Counter
	if Duel.IsExistingMatchingCard(Card.IsType,tp,0,LOCATION_MZONE,1,nil,TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local og=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
		local oc=og:GetFirst()
		if oc then oc:AddCounter(0x10f8,1) end
	end
	-- Restrict Extra Deck summons
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(SET_GOD_WARRIOR)
end

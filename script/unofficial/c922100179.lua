--God Warrior - Syd of Mizar
--[==[
-- ID: 922100179
-- Type: Monster / Effect Monster
-- Level: 7
-- Attribute: WATER
-- Race: Warrior
-- ATK/DEF: 2600/2300
--
-- Archetypes:
-- - God Warrior
-- Effect (EN):
-- If this card is Normal or Special Summoned: You can Special Summon 1 "Bud of Alcor" from your hand or Deck.
-- You can only use this effect of "God Warrior - Syd of Mizar" once per turn.
--]==]
--God Warrior - Syd of Mizar
local s,id=GetID()
function s.initial_effect(c)
	-- Special Summon "Bud of Alcor"
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e1b=e1:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)
end
s.listed_series={SET_GOD_WARRIOR, SET_SAINT}

function s.spfilter(c,e,tp)
	return c:IsCode(922100180) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

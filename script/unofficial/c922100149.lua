--Black Saint - Jango, Commander of the Shadow
--[==[
-- ID: 922100149
-- Type: Monster / Effect Monster
-- Level: 4
-- Attribute: DARK
-- Race: Warrior
-- ATK/DEF: 1700/1000
--
-- Archetypes:
-- - saint
-- - Black Saint
-- Effect (EN):
-- If this card is Normal or Special Summoned: You can send 1 "Fragment of Sagittarius" card from your Deck to the GY.
-- If a face-up "Fragment of Sagittarius" Equip Spell(s) you control is sent to the GY by card effect: You can Special Summon 1 Level 4 or lower "Black Saint" monster from your hand or GY, except "Black Saint - Jango, Commander of the Shadow".
-- You can only use each effect of "Black Saint - Jango, Commander of the Shadow" once per turn.
--]==]
--Black Saint - Jango, Commander of the Shadow
local s,id=GetID()
function s.initial_effect(c)
	--On summon: send 1 Fragment of Sagittarius from Deck to GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	local e1b=e1:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)

	--If a face-up Fragment Equip you control is sent to GY by card effect: SS 1 Level4 or lower Black Saint from hand/GY except itself
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end

s.listed_series={SET_BLACK_SAINT,SET_FRAGMENT_OF_SAGITTARIUS,SET_SAINT}

function s.fragfilter(c)
	return c:IsSetCard(SET_FRAGMENT_OF_SAGITTARIUS) and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.fragfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.fragfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then Duel.SendtoGrave(g,REASON_EFFECT) end
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(function(c) return c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsSetCard(SET_FRAGMENT_OF_SAGITTARIUS) and (r&REASON_EFFECT)~=0 and c:IsControler(tp) end,1,nil)
end
function s.bsfilter(c,e,tp)
	return c:IsSetCard(SET_BLACK_SAINT) and c:IsLevelBelow(4) and c:IsMonster()
		and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.bsfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.bsfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

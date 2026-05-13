--Renegade Saint - Deathmask of Cancer
--[==[
-- ID: 922100209
-- Type: Monster / Effect Monster
-- Level: 4
-- Attribute: DARK
-- Race: Zombie
-- ATK/DEF: 1800/1500
--
-- Archetypes:
-- - saint
-- - Renegade Saint
-- Effect (EN):
-- This card is also treated as a "Saint" monster while on the field and in the GY.
-- If you control "Renegade Saint - Shion of Aries" or "Renegade Saint - Saga of Gemini", you can Special Summon this card (from your hand).
-- If this card is Normal or Special Summoned: You can send 2 "Specter" monsters from your Deck to the GY.
-- You can Tribute this card while you have 3 or more "Specter" monsters in your GY; Special Summon 1 "Renegade Saint - Aphrodite of Pisces" from your hand or Deck.
-- You can only use each effect of "Renegade Saint - Deathmask of Cancer" once per turn.
--]==]
--Renegade Saint - Deathmask of Cancer
local s,id=GetID()
function s.initial_effect(c)
	-- SS proc from hand if you control Shion or Saga
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_HAND)
	e0:SetCondition(s.spcon)
	c:RegisterEffect(e0)
	-- On Summon: send 2 Specters from Deck
	local e1=Effect.CreateEffect(c)
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
	-- Tribute self w/ 3+ Specters in GY; SS Aphrodite from hand or Deck
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+100)
	e2:SetCondition(s.spcon2)
	e2:SetCost(s.spcost2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
s.listed_series={SET_RENEGADE_SAINT, SET_SAINT}

function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,922100205,922100206),tp,LOCATION_MZONE,0,1,nil)
end

function s.tgfilter(c)
	return c:IsSetCard(SET_SPECTER) and c:IsMonster() and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,2,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,2,2,nil)
	if #g>0 then Duel.SendtoGrave(g,REASON_EFFECT) end
end

function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,SET_SPECTER),tp,LOCATION_GRAVE,0,nil)>=3
end
function s.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end
function s.spfilter(c,e,tp)
	return c:IsCode(922100210) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end
end

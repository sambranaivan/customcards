--Tide of Rebellion
--[==[
-- ID: 922100266
-- Type: Trap / Normal Trap
--
-- Archetypes:
-- - saint-seiya
--
-- Effect (EN):
-- If your opponent controls more cards than you do: Special Summon 1 "Marine General" monster from your hand or GY, then you can equip 1 "Scale" card from your GY to that monster.
-- For the rest of this turn after this card resolves, you cannot Special Summon monsters from the Extra Deck, except WATER monsters.
-- You can only activate 1 "Tide of Rebellion" per turn.
--]==]
--Tide of Rebellion
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_SAINT}

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)<Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
end
function s.mgfilter(c,e,tp)
	return c:IsSetCard(SET_MARINE_GENERAL) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.scalefilter(c)
	return c:IsCode(922100230,922100231,922100232,922100233,922100234,922100235,922100236) and c:IsType(TYPE_EQUIP)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.mgfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local mg=Duel.SelectMatchingCard(tp,s.mgfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	if not mg then return end
	Duel.SpecialSummon(mg,0,tp,tp,false,false,POS_FACEUP)
	-- equip scale from GY if any
	local g=Duel.GetMatchingGroup(function(c) return s.scalefilter(c) and c:IsAbleToGrave() end,tp,LOCATION_GRAVE,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local sc=g:Select(tp,1,1,nil):GetFirst()
		if sc then Duel.Equip(tp,sc,mg) end
	end
	-- Extra Deck restriction
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsAttribute(ATTRIBUTE_WATER) end)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

--Oath of the Shadow
--[==[
-- ID: 922100166
-- Type: Spell / Continuous Spell
--
-- Archetypes:
-- (setcode 0 — not in a named ProjectIgnis archetype series)
-- Effect (EN):
-- Once per turn: You can send 1 "Fragment of Sagittarius" card from your hand or face-up field to the GY; Special Summon 1 "Black Saint" monster from your GY.
-- While you control "Black Saint - Ikki, Leader of Death Queen Island", you can equip 1 "Fragment of Sagittarius" card from your GY to the monster Special Summoned by this effect.
--]==]
--Oath of the Shadow
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	--SS 1 Black Saint from GY by sending 1 Fragment from hand/face-up field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE+CATEGORY_LEAVE_GRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end

s.listed_series={SET_BLACK_SAINT,SET_FRAGMENT_OF_SAGITTARIUS}
s.listed_names={922100148}

function s.costfilter(c)
	return c:IsSetCard(SET_FRAGMENT_OF_SAGITTARIUS) and c:IsAbleToGraveAsCost()
		and (c:IsLocation(LOCATION_HAND) or (c:IsLocation(LOCATION_ONFIELD) and c:IsFaceup()))
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_BLACK_SAINT) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.eqgyfilter(c,ec,tp)
	if not ec or not ec:IsFaceup() or not ec:IsControler(tp) or not ec:IsSetCard(SET_BLACK_SAINT) then return false end
	if not c:IsSetCard(SET_FRAGMENT_OF_SAGITTARIUS) or not c:IsEquipSpell() then return false end
	if c:IsForbidden() then return false end
	return c:CheckEquipTarget(ec)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then return end
	if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	if not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,922100148),tp,LOCATION_MZONE,0,1,nil) then return end
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local eg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.eqgyfilter),tp,LOCATION_GRAVE,0,nil,tc,tp)
	if #eg==0 then return end
	if not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local ec=eg:Select(tp,1,1,nil):GetFirst()
	if not ec then return end
	if tc:IsFaceup() and tc:IsControler(tp) and tc:IsLocation(LOCATION_MZONE) and not tc:IsImmuneToEffect(e) then
		Duel.Equip(tp,ec,tc,true)
	end
end

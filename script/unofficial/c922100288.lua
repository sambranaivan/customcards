--Echo of the Cosmos
--[==[
-- ID: 922100288
-- Type: Trap / Continuous Trap
--
-- Archetypes:
-- - Meta
-- Effect (EN):
-- Activate this card by targeting 1 monster in your GY; Special Summon it. When this card leaves the field, destroy that monster. When that monster is destroyed, destroy this card.
--]==]
--Echo of the Cosmos
local s,id=GetID()
function s.initial_effect(c)
	-- Activate by targeting 1 monster in your GY; Special Summon it
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_META, SET_SAINT}

function s.spfilter(c,e,tp)
	return c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	c:SetLabelObject(tc)
	-- when this leaves, destroy that monster
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_LEAVE_FIELD)
	e1:SetOperation(function(e,tp) 
		local mc=e:GetHandler():GetLabelObject()
		if mc and mc:IsOnField() then Duel.Destroy(mc,REASON_EFFECT) end
	end)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	-- when monster destroyed, destroy this
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(function(e,tp,eg)
		local mc=e:GetHandler():GetLabelObject()
		if mc and eg:IsContains(mc) and e:GetHandler():IsOnField() then
			Duel.Destroy(e:GetHandler(),REASON_EFFECT)
		end
	end)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
end

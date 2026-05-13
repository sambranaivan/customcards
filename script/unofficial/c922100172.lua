--Palace of Valhalla - Throne of Hilda
--[==[
-- ID: 922100172
-- Type: Spell / Field Spell
--
-- Archetypes:
-- - God Warrior
-- Effect (EN):
-- All "God Warrior" monsters on the field gain 500 ATK/DEF.
-- Each time a "God Warrior" monster you control leaves the field, place 1 Odin Sapphire Counter on this card (max. 7).
-- Once per turn: You can remove 2 Odin Sapphire Counters from your field; Special Summon 1 "God Warrior" monster from your hand or GY.
-- You can only use this effect of "Palace of Valhalla - Throne of Hilda" once per turn.
--]==]
--Palace of Valhalla - Throne of Hilda
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(0x10f9) -- Odin Sapphire Counter
	-- ATK/DEF +500
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_GOD_WARRIOR))
	e1:SetValue(500)
	c:RegisterEffect(e1)
	local e1b=e1:Clone()
	e1b:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1b)
	-- Place counter when a God Warrior you control leaves field
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(s.ctcon)
	e2:SetOperation(s.ctop)
	c:RegisterEffect(e2)
	-- Special Summon from hand/GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_GOD_WARRIOR, SET_SAINT}

function s.ctfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsSetCard(SET_GOD_WARRIOR)
end
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.ctfilter,1,nil,tp)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsFaceup() then return end
	if c:GetCounter(0x10f9)>=7 then return end
	c:AddCounter(0x10f9,1)
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanRemoveCounter(tp,LOCATION_ONFIELD,0,0x10f9,2,REASON_COST) end
	Duel.RemoveCounter(tp,LOCATION_ONFIELD,0,0x10f9,2,REASON_COST)
end
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
	if tc then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

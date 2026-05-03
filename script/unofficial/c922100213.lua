--Hypnos, God of Sleep
--[==[
-- ID: 922100213
-- Type: Monster / Fusion Monster
-- Level: 10
-- Attribute: DARK
-- Race: Fiend
-- ATK/DEF: 2500/3500
--
-- Archetypes:
-- - saint-seiya
--
-- Effect (EN):
-- 1 Level 8 "Specter" monster + 1 Level 8 "Renegade Saint" monster
-- Cannot be Normal Summoned/Set.
-- Must be Special Summoned from your Extra Deck (this is treated as a Fusion Summon) while you have 9 or more "Specter" monsters in your GY. (You do not use "Fusion" as an activation procedure.)
-- Once per turn (Quick Effect): You can target up to 2 Effect Monsters your opponent controls; change them to face-down Defense Position.
-- Cards your opponent controls that are face-down cannot be activated in response to the activation of your "Specter" or "Renegade Saint" monster effects.
-- While this card is face-up on the field, "Specter" monsters you control cannot be destroyed by card effects.
--]==]
--Hypnos, God of Sleep
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- Special Summon from Extra with 9+ Specters in GY (treated as Fusion)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(s.spcon)
	e0:SetOperation(s.spop)
	e0:SetValue(SUMMON_TYPE_FUSION)
	c:RegisterEffect(e0)
	-- Quick: set up to 2 opponent effect monsters facedown
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.fdtg)
	e1:SetOperation(s.fdop)
	c:RegisterEffect(e1)
	-- Specters you control indestructible by effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_SPECTER))
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
s.listed_series={SET_SAINT}

function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,SET_SPECTER),tp,LOCATION_GRAVE,0,nil)>=9
		and Duel.IsExistingMatchingCard(s.matfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,tp)
		and Duel.IsExistingMatchingCard(s.matfilter2,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,tp)
end
function s.matfilter(c,tp)
	return c:IsSetCard(SET_SPECTER) and c:IsLevel(8) and c:IsMonster() and c:IsAbleToGraveAsCost()
end
function s.matfilter2(c,tp)
	return c:IsSetCard(SET_RENEGADE_SAINT) and c:IsLevel(8) and c:IsMonster() and c:IsAbleToGraveAsCost()
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g1=Duel.SelectMatchingCard(tp,s.matfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g2=Duel.SelectMatchingCard(tp,s.matfilter2,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,tp)
	g1:Merge(g2)
	Duel.SendtoGrave(g1,REASON_COST)
end

function s.fdfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:IsCanTurnSet()
end
function s.fdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.fdfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWN)
	local g=Duel.SelectMatchingCard(tp,s.fdfilter,tp,0,LOCATION_MZONE,1,2,nil)
	Duel.SetTargetCard(g)
end
function s.fdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>0 then
		Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
	end
end

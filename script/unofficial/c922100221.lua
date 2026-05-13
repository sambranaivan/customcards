--Hades Castle - Barrier of Loss
--[==[
-- ID: 922100221
-- Type: Spell / Continuous Spell
--
-- Archetypes:
-- - Hades
-- Effect (EN):
-- All monsters your opponent controls that are not "Specter" or "Renegade Saint" monsters lose ATK/DEF equal to the number of monsters in your GY x 100.
-- During your End Phase: Send the top 2 cards of your Deck to the GY.
-- If this face-up card is sent from the Spell & Trap Zone to the GY: You can Special Summon 1 Level 4 or lower "Specter" monster from your GY.
-- You can only use this effect of "Hades Castle - Barrier of Loss" once per turn.
--]==]
--Hades Castle - Barrier of Loss
local s,id=GetID()
function s.initial_effect(c)
	-- Opponent non Specter/Renegade loses ATK/DEF
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetTarget(s.tg)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
	local e1b=e1:Clone()
	e1b:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1b)
	-- End Phase mill 2
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp end)
	e2:SetOperation(s.millop)
	c:RegisterEffect(e2)
	-- If sent from SZONE to GY: SS Level 4 or lower Specter
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_HADES, SET_SAINT}

function s.tg(e,c)
	return not (c:IsSetCard(SET_SPECTER) or c:IsSetCard(SET_RENEGADE_SAINT))
end
function s.val(e,c)
	local tp=e:GetHandlerPlayer()
	local ct=Duel.GetMatchingGroupCount(Card.IsMonster,tp,LOCATION_GRAVE,0,nil)
	return -ct*100
end
function s.millop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetDecktopGroup(tp,2)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_SZONE)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_SPECTER) and c:IsLevelBelow(4) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end
end

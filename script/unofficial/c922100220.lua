--Judgment of Souls
--[==[
-- ID: 922100220
-- Type: Spell / Normal Spell
--
-- Archetypes:
-- (setcode 0 — not in a named ProjectIgnis archetype series)
-- Effect (EN):
-- Send "Specter" monsters from your Deck to the GY until you have exactly 12 "Specter" monsters in your GY.
-- For the rest of this turn after this card resolves, you cannot Special Summon from the hand or Extra Deck, except "Specter", "Renegade Saint", or "Hades" monsters.
-- You can only activate 1 "Judgment of Souls" once per Duel.
--]==]
--Judgment of Souls
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_SAINT}

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	return true
end
function s.tgfilter(c)
	return c:IsSetCard(SET_SPECTER) and c:IsMonster() and c:IsAbleToGrave()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local need=12-Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,SET_SPECTER),tp,LOCATION_GRAVE,0,nil)
	if need<=0 then return end
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_DECK,0,nil)
	if #g==0 then return end
	if #g<need then need=#g end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sg=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,need,need,nil)
	Duel.SendtoGrave(sg,REASON_EFFECT)
	-- Restrict Special Summons from hand or Extra
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
	if not (c:IsSetCard(SET_SPECTER) or c:IsSetCard(SET_RENEGADE_SAINT) or c:IsSetCard(SET_HADES)) then return true end
	if c:IsLocation(LOCATION_EXTRA) then return false end
	return c:IsLocation(LOCATION_HAND)
end

--Master's Legacy (Normal Spell)
--[==[
-- ID: 922100087
-- Type: Spell / Normal Spell
--
-- Archetypes:
-- (setcode 0 — not in a named ProjectIgnis archetype series)
-- Effect (EN):
-- Reveal up to 3 "Cloth" cards in your hand, shuffle them into the Deck, then draw the same number of cards.
-- If you control no "Saint" monsters, while this card is in your GY: You can banish this card; Special Summon 1 "Bronze Saint" monster from your Deck, but negate its effects, also for the rest of this turn, you cannot Special Summon from the Extra Deck, except "Saint" monsters.
-- You can only use this effect of "Master's Legacy" once per turn.
--]==]
--Master's Legacy (Normal Spell)
local s,id=GetID()
function s.initial_effect(c)
	--Activate: recycle up to 3 Cloth; draw same
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	--GY: if you control no "Saint" monsters, banish; SS 1 Bronze Saint (negate), ED lock
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.gycon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end

s.listed_series={SET_SAINT,SET_BRONZE_SAINT,SET_CLOTH}

function s.clothfilter(c)
	return c:IsSetCard(SET_CLOTH) and c:IsAbleToDeck() and not c:IsPublic()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsExistingMatchingCard(s.clothfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.clothfilter,tp,LOCATION_HAND,0,1,3,nil)
	if #g==0 then return end
	local ct=#g
	Duel.ConfirmCards(1-tp,g)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	Duel.ShuffleDeck(tp)
	Duel.Draw(tp,ct,REASON_EFFECT)
end

function s.gycon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,SET_SAINT),tp,LOCATION_MZONE,0,nil)==0
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_BRONZE_SAINT) and c:IsLevelBelow(4)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then return end
	if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		tc:RegisterEffect(e2)
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
		e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e3:SetTargetRange(1,0)
		e3:SetTarget(s.splimit)
		e3:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e3,tp)
	end
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(SET_SAINT)
end

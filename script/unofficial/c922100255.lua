--Golden Marine Scales
--[==[
-- ID: 922100255
-- Type: Spell / Normal Spell
--
-- Archetypes:
-- - saint-seiya
--
-- Effect (EN):
-- Target 2 "Pillar" cards in your GY; shuffle them into the Deck, and if you do, draw 2 cards.
-- If this card is in your GY: You can banish this card, then target 1 "Marine General" monster you control; equip 1 "Scale" card from your GY to that target.
-- You can only activate 1 "Golden Marine Scales" per turn.
-- You can only use this effect of "Golden Marine Scales" once per turn.
--]==]
--Golden Marine Scales
local s,id=GetID()
function s.initial_effect(c)
	-- Target 2 Pillars in GY, shuffle, draw 2
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	-- GY: banish; equip a Scale from GY to a Marine General
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+100)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_SAINT}

function s.pillgy(c)
	return c:IsSetCard(SET_PILLAR) and c:IsAbleToDeck()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingTarget(s.pillgy,tp,LOCATION_GRAVE,0,2,nil) and Duel.IsPlayerCanDraw(tp,2) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.pillgy,tp,LOCATION_GRAVE,0,2,2,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g==2 then
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		Duel.ShuffleDeck(tp)
		Duel.Draw(tp,2,REASON_EFFECT)
	end
end

function s.mgfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_MARINE_GENERAL)
end
function s.scalefilter(c)
	return c:IsCode(922100230,922100231,922100232,922100233,922100234,922100235,922100236) and c:IsType(TYPE_EQUIP) and c:IsAbleToGrave()
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.mgfilter,tp,LOCATION_MZONE,0,1,nil)
			and Duel.IsExistingMatchingCard(s.scalefilter,tp,LOCATION_GRAVE,0,1,nil)
	end
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local mg=Duel.SelectMatchingCard(tp,s.mgfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if not mg then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local sc=Duel.SelectMatchingCard(tp,s.scalefilter,tp,LOCATION_GRAVE,0,1,1,nil):GetFirst()
	if not sc then return end
	Duel.Equip(tp,sc,mg)
end

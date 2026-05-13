--Three Paths of Destiny
--[==[
-- ID: 922100270
-- Type: Spell / Normal Spell
--
-- Archetypes:
-- - Meta
-- Effect (EN):
-- Excavate the top 3 cards of your Deck, add 1 of them to your hand, then place the rest on the bottom of your Deck in any order. You cannot Special Summon monsters during the turn you activate this card.
-- You can only activate 1 "Three Paths of Destiny" per turn.
--]==]
--Three Paths of Destiny
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_META, SET_SAINT}

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetDecktopGroup(tp,3)
	if #g==0 then return end
	Duel.ConfirmCards(tp,g)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sg=g:Select(tp,1,1,nil)
	local tc=sg:GetFirst()
	g:RemoveCard(tc)
	Duel.SendtoHand(tc,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,sg)
	Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	-- no Special Summon this turn
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return true end)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

--Ghost Saint - Geist, Envoy of the Pope
--[==[
-- ID: 922100122
-- Type: Monster / Effect Monster
-- Level: 4
-- Attribute: DARK
-- Race: Warrior
-- ATK/DEF: 1400/1400
--
-- Archetypes:
-- - saint
-- - Envoy of the Pope
-- Effect (EN):
-- If you control "Pope Ares" or a "Pope's Mandate" card, you can Special Summon this card from your hand.
-- If this card is Normal or Special Summoned: You can add 1 "Ghost Saint" monster from your Deck to your hand, except "Ghost Saint - Geist, Envoy of the Pope".
-- Once per turn, if a "Ghost Saint" monster(s) you control would be destroyed by battle or card effect, you can discard 1 "Envoy of the Pope" monster instead.
-- You can only use each effect of "Ghost Saint - Geist, Envoy of the Pope" once per turn.
--]==]
--Ghost Saint - Geist, Envoy of the Pope
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon from hand
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_HAND)
	e0:SetCondition(s.spcon)
	c:RegisterEffect(e0)

	--On summon: add 1 "Ghost Saint" except itself
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e1b=e1:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)

	--Destruction replacement (discard 1 Envoy)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.reptg)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
end

s.listed_series={SET_GHOST_SAINT,SET_ENVOY_OF_THE_POPE,SET_SAINT,SET_POPES_MANDATE}
s.listed_names={922100105}

function s.pm_onfield(tp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_POPES_MANDATE),tp,LOCATION_ONFIELD,0,1,nil)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and (Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,922100105),tp,LOCATION_MZONE,0,1,nil) or s.pm_onfield(tp))
end

function s.ghfilter(c)
	return c:IsSetCard(SET_GHOST_SAINT) and c:IsMonster() and c:IsAbleToHand() and not c:IsCode(id)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.ghfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.ghfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(SET_GHOST_SAINT) and c:IsControler(tp)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
end
function s.costfilter(c)
	return c:IsSetCard(SET_ENVOY_OF_THE_POPE) and c:IsMonster() and c:IsDiscardable(REASON_COST)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return eg:IsExists(s.repfilter,1,nil,tp) and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil)
	end
	return Duel.SelectYesNo(tp,aux.Stringid(id,2))
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.DiscardHand(tp,s.costfilter,1,1,REASON_COST+REASON_DISCARD,nil)
end

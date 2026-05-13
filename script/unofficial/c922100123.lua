--Ghost Saint - Astaroth, Envoy of the Pope
--[==[
-- ID: 922100123
-- Type: Monster / Effect Monster
-- Level: 3
-- Attribute: DARK
-- Race: Fiend
-- ATK/DEF: 1200/800
--
-- Archetypes:
-- - saint
-- - Envoy of the Pope
-- Effect (EN):
-- If you control "Pope Ares" or a "Pope's Mandate" card, you can Special Summon this card from your hand.
-- If this card is Normal or Special Summoned: You can send 1 "Envoy of the Pope" card from your Deck to the GY.
-- (Quick Effect): You can banish this card from your GY, then target 1 Set card your opponent controls; your opponent reveals that card, and if it is a Spell/Trap, destroy it.
-- You can only use each effect of "Ghost Saint - Astaroth, Envoy of the Pope" once per turn.
--]==]
--Ghost Saint - Astaroth, Envoy of the Pope
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

	--On summon: send 1 Envoy card from Deck to GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	local e1b=e1:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)

	--GY Quick: banish; reveal 1 Set card, destroy if S/T
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.rvtg)
	e2:SetOperation(s.rvop)
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

function s.tgfilter(c)
	return c:IsSetCard(SET_ENVOY_OF_THE_POPE) and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then Duel.SendtoGrave(g,REASON_EFFECT) end
end

function s.setfilter(c)
	return c:IsFacedown() and c:IsOnField()
end
function s.rvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_ONFIELD) and s.setfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.setfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	Duel.SelectTarget(tp,s.setfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
end
function s.rvop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	Duel.ConfirmCards(tp,Group.FromCards(tc))
	if tc:IsSpellTrap() and tc:IsDestructable() then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

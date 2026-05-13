--Echoes of Sounion
--[==[
-- ID: 922100262
-- Type: Trap / Normal Trap
--
-- Archetypes:
-- (setcode 0 — not in a named ProjectIgnis archetype series)
-- Effect (EN):
-- When your opponent activates a card or effect while you control "Marine General - Kanon of Sea Dragon": Negate that activation, and if you do, move 1 monster your opponent controls to an adjacent Main Monster Zone.
-- If this Set card is destroyed by your opponent's card effect: You can send 1 "Pillar" card from your Deck to the GY.
-- You can only activate 1 "Echoes of Sounion" per turn.
--]==]
--Echoes of Sounion
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- If set card destroyed by opponent: send pillar
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.dcon)
	e2:SetOperation(s.dop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_SAINT}

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and Duel.IsChainNegatable(ev)
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,922100223),tp,LOCATION_MZONE,0,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev)==0 then return end
	-- move opponent monster adjacent
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if #g==0 then return end
	local tc=g:Select(tp,1,1,nil):GetFirst()
	if not tc then return end
	local seq=tc:GetSequence()
	if seq>0 and Duel.CheckLocation(1-tp,LOCATION_MZONE,seq-1) then Duel.MoveSequence(tc,seq-1)
	elseif seq<4 and Duel.CheckLocation(1-tp,LOCATION_MZONE,seq+1) then Duel.MoveSequence(tc,seq+1) end
end
function s.dcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_SZONE) and e:GetHandler():IsReason(REASON_EFFECT) and rp~=tp
end
function s.pilldeck(c)
	return c:IsSetCard(SET_PILLAR) and c:IsAbleToGrave()
end
function s.dop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsExistingMatchingCard(s.pilldeck,tp,LOCATION_DECK,0,1,nil) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,s.pilldeck,tp,LOCATION_DECK,0,1,1,nil)
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end

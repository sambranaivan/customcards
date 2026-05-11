--Pope's Mandate - Absolute Verdict
--[==[
-- ID: 922100142
-- Type: Trap / Counter Trap
--
-- Archetypes:
-- - saint-seiya
--
-- Effect (EN):
-- When your opponent activates a card or effect, while you control an "Envoy of the Pope" monster: Send 1 "Envoy of the Pope" card from your hand or face-up field to the GY; negate the activation, and if you do, banish that card.
-- If you control "Pope Ares - Usurper of the Sanctuary", your opponent cannot activate cards or effects with that banished card's original name until the end of your opponent's next turn.
-- You can only activate 1 "Pope's Mandate - Absolute Verdict" per turn.
--]==]
--Pope's Mandate - Absolute Verdict
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.negcon)
	e1:SetCost(s.negcost)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
end

s.listed_series={SET_POPES_MANDATE,SET_ENVOY_OF_THE_POPE}
s.listed_names={922100135}

function s.costfilter(c)
	return c:IsSetCard(SET_ENVOY_OF_THE_POPE) and c:IsAbleToGraveAsCost()
		and (c:IsLocation(LOCATION_HAND) or (c:IsLocation(LOCATION_ONFIELD) and c:IsFaceup()))
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and Duel.IsChainNegatable(ev)
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_ENVOY_OF_THE_POPE),tp,LOCATION_MZONE,0,1,nil)
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,e:GetHandler())
	Duel.SendtoGrave(g,REASON_COST)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if Duel.NegateActivation(ev)==0 or not rc or not rc:IsRelateToEffect(re) then return end
	local code=rc:GetOriginalCode()
	if Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)==0 then return end
	--If control Usurper: lock that name until end of opponent's next turn
	if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,922100135),tp,LOCATION_MZONE,0,1,nil) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(0,1)
		e1:SetLabel(code)
		e1:SetValue(function(e,re,tp) return re:GetHandler():GetOriginalCode()==e:GetLabel() end)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		Duel.RegisterEffect(e1,tp)
	end
end

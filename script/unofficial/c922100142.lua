--Pope's Mandate - Absolute Verdict
--[==[
-- ID: 922100142
-- Type: Trap / Counter Trap
--
-- Archetypes:
-- - saint-seiya
--
-- Effect (EN):
-- When your opponent activates a card or effect, while you control a "Envoy of the Pope" monster: Negate the activation, and if you do, banish that card.
-- If you control "Pope Ares - Usurper of the Sanctuary", your opponent cannot activate cards or effects with that banished card's original name for the rest of this Duel.
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
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
end

s.listed_series={SET_POPES_MANDATE,SET_ENVOY_OF_THE_POPE}
s.listed_names={922100135}

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and Duel.IsChainNegatable(ev)
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_ENVOY_OF_THE_POPE),tp,LOCATION_MZONE,0,1,nil)
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
	--If control Usurper: permanent lock on that original name
	if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,922100135),tp,LOCATION_MZONE,0,1,nil) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(0,1)
		e1:SetLabel(code)
		e1:SetValue(function(e,re,tp) return re:GetHandler():GetOriginalCode()==e:GetLabel() end)
		--No reset (rest of Duel)
		Duel.RegisterEffect(e1,tp)
	end
end

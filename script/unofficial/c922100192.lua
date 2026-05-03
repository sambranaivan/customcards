--Rune of Fimbulwinter
--[==[
-- ID: 922100192
-- Type: Trap / Counter Trap
--
-- Archetypes:
-- - saint-seiya
--
-- Effect (EN):
-- When your opponent activates a card or effect, while you control a "God Warrior" monster or "Palace of Valhalla - Throne of Hilda": Negate the activation, and if you do, banish that card.
-- Then, you can remove 1 Odin Sapphire Counter from your field, and if you do, place 1 Frost Counter on 1 face-up monster your opponent controls.
-- You can only activate 1 "Rune of Fimbulwinter" per turn.
--]==]
--Rune of Fimbulwinter
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE+CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_SAINT}

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp then return false end
	return Duel.IsChainNegatable(ev)
		and (Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_GOD_WARRIOR),tp,LOCATION_MZONE,0,1,nil)
			or Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,922100172),tp,LOCATION_FZONE,0,1,nil))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev)~=0 then
		local rc=re:GetHandler()
		if rc:IsRelateToEffect(re) then
			Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)
		end
		if Duel.IsCanRemoveCounter(tp,LOCATION_ONFIELD,0,0x10f9,1,REASON_EFFECT)
			and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.RemoveCounter(tp,LOCATION_ONFIELD,0,0x10f9,1,REASON_EFFECT)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
			local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
			local tc=g:GetFirst()
			if tc then tc:AddCounter(0x10f8,1) end
		end
	end
end

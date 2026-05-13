--North Star Punishment
--[==[
-- ID: 922100191
-- Type: Spell / Normal Spell
--
-- Archetypes:
-- (setcode 0 — not in a named ProjectIgnis archetype series)
-- Effect (EN):
-- If your opponent controls more monsters than you do: Target up to 2 face-up monsters your opponent controls; place 1 Frost Counter on each target, also they cannot be used as material for a Special Summon from the Extra Deck this turn.
-- If you control "Palace of Valhalla - Throne of Hilda", you can remove 1 Odin Sapphire Counter from your field; draw 1 card.
-- You can only activate 1 "North Star Punishment" per turn.
--]==]
--North Star Punishment
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_SAINT}

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
end
function s.tgfilter(c)
	return c:IsFaceup() and c:IsCanAddCounter(0x10f8,1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.tgfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,0,LOCATION_MZONE,1,2,nil)
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,#g,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	for tc in aux.Next(g) do
		if tc:IsFaceup() and tc:IsRelateToEffect(e) then
			tc:AddCounter(0x10f8,1)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
			tc:RegisterEffect(e2)
			local e3=e1:Clone()
			e3:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
			tc:RegisterEffect(e3)
			local e4=e1:Clone()
			e4:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
			tc:RegisterEffect(e4)
		end
	end
	if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,922100172),tp,LOCATION_FZONE,0,1,nil)
		and Duel.IsCanRemoveCounter(tp,LOCATION_ONFIELD,0,0x10f9,1,REASON_EFFECT)
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.RemoveCounter(tp,LOCATION_ONFIELD,0,0x10f9,1,REASON_EFFECT)
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end

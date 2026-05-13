--Steel Assistance System
--[==[
-- ID: 922100146
-- Type: Spell / Quick-Play Spell
--
-- Archetypes:
-- (setcode 0 — not in a named ProjectIgnis archetype series)
-- Effect (EN):
-- Target 1 "Saint" monster you control; this turn, it cannot be destroyed by battle or card effects.
-- Then, if you have a "Steel Saint" monster in your GY, you can Special Summon 1 "Steel Saint" monster with a different name from your hand.
-- You can only activate 1 "Steel Assistance System" per turn.
--]==]
--Steel Assistance System
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

s.listed_series={SET_STEEL_SAINT,SET_SAINT}

function s.saintfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_SAINT)
end
function s.steelgy(c)
	return c:IsSetCard(SET_STEEL_SAINT) and c:IsMonster()
end
function s.steelhand(c,e,tp,code)
	return c:IsSetCard(SET_STEEL_SAINT) and c:IsMonster() and not c:IsCode(code)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.saintfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.saintfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.saintfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or not tc:IsFaceup() then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	tc:RegisterEffect(e2)
	--If you have Steel Saint in GY, you can SS a different Steel Saint from hand
	if Duel.IsExistingMatchingCard(s.steelgy,tp,LOCATION_GRAVE,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.steelhand,tp,LOCATION_HAND,0,1,nil,e,tp,0)
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.steelhand,tp,LOCATION_HAND,0,1,1,nil,e,tp,0)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

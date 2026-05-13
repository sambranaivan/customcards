--Whisper from the Beyond
--[==[
-- ID: 922100284
-- Type: Spell / Quick-Play Spell
--
-- Archetypes:
-- - Meta
-- Effect (EN):
-- Target 1 monster in your opponent's GY; banish it, and if you do, until the end of the next turn, its effects are negated, as well as the activated effects and effects on the field of monsters with the same name.
--]==]
--Whisper from the Beyond
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_META, SET_SAINT}

function s.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE) and s.tgfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,0,LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	Duel.SelectTarget(tp,s.tgfilter,tp,0,LOCATION_GRAVE,1,1,nil)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	local code=tc:GetOriginalCode()
	if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)==0 then return end
	-- until end of next turn, negate monsters with same name (approx)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetLabel(code)
	e1:SetTarget(function(e,c) return c:IsFaceup() and c:IsCode(e:GetLabel()) end)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	Duel.RegisterEffect(e2,tp)
end

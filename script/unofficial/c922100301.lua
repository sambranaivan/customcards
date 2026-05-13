--Petrifying Gaze
--[==[
-- ID: 922100301
-- Type: Trap / Normal Trap
--
-- Archetypes:
-- - Meta
-- Effect (EN):
-- Target 1 Effect Monster your opponent controls; negate its effects (until the end of this turn), then, if this card was activated from your hand, for the rest of this turn after this card resolves, other Spell/Trap effects in this column cannot be activated.
-- If you control no cards, you can activate this card from your hand.
--]==]
--Petrifying Gaze
local s,id=GetID()
function s.initial_effect(c)
	-- allow activation from hand if you control no cards
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e0:SetCondition(function(e) return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_ONFIELD,0)==0 end)
	c:RegisterEffect(e0)
	-- negate target
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_META, SET_SAINT}

function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or not tc:IsFaceup() then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	tc:RegisterEffect(e2)
	-- if activated from hand, lock other S/T effects in that column this turn (approx by target column)
	if c:IsPreviousLocation(LOCATION_HAND) then
		local colg=tc:GetColumnGroup()
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
		e3:SetCode(EFFECT_CANNOT_ACTIVATE)
		e3:SetTargetRange(1,1)
		e3:SetTarget(function(e,re,tp) return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and colg:IsContains(re:GetHandler()) end)
		e3:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e3,tp)
	end
end

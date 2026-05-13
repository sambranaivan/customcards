--Renegade Saint - Camus of Aquarius
--[==[
-- ID: 922100207
-- Type: Monster / Effect Monster
-- Level: 8
-- Attribute: DARK
-- Race: Zombie
-- ATK/DEF: 2300/2300
--
-- Archetypes:
-- - saint
-- - Renegade Saint
-- Effect (EN):
-- This card is also treated as a "Saint" monster while on the field and in the GY.
-- Cannot be Normal Summoned/Set.
-- Must be Special Summoned (from your hand or GY) by banishing 2 "Specter" monsters from your GY, while you have 6 or more "Specter" monsters in your GY.
-- If this card is Special Summoned: You can target up to 2 face-up monsters your opponent controls; while this card is face-up on the field, those monsters cannot change their battle positions, also they cannot activate their effects.
-- Once per turn (Quick Effect): You can banish 1 "Specter" monster from your GY; change 1 face-up card on the field to face-down Defense Position.
-- During the End Phase, if this card was Special Summoned this turn: Destroy this card, and if you do, inflict 1000 damage to your opponent.
-- You can only use each effect of "Renegade Saint - Camus of Aquarius" once per turn.
--]==]
--Renegade Saint - Camus of Aquarius
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- SS proc: banish 2 Specters while 6+ in GY
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e0:SetCondition(s.spcon)
	e0:SetOperation(s.spop)
	c:RegisterEffect(e0)
	-- On SS: lock up to 2 monsters (no pos change, cannot activate)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.lktg)
	e1:SetOperation(s.lkop)
	c:RegisterEffect(e1)
	-- Quick: banish 1 Specter; set 1 face-up card face-down DEF
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+100)
	e2:SetCondition(function(e) return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_SPECTER),e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil) end)
	e2:SetCost(s.fdcost)
	e2:SetTarget(s.fdtg)
	e2:SetOperation(s.fdop)
	c:RegisterEffect(e2)
	-- End Phase self-destroy + burn if SS this turn
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+200)
	e3:SetCondition(s.endcon)
	e3:SetOperation(s.endop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_RENEGADE_SAINT, SET_SAINT}

function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,SET_SPECTER),tp,LOCATION_GRAVE,0,nil)>=6
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_SPECTER),tp,LOCATION_GRAVE,0,2,nil)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsSetCard,SET_SPECTER),tp,LOCATION_GRAVE,0,2,2,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end

function s.lkfilter(c)
	return c:IsFaceup()
end
function s.lktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.lkfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,s.lkfilter,tp,0,LOCATION_MZONE,1,2,nil)
	e:SetLabel(#g)
	Duel.SetTargetCard(g)
end
function s.lkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetTargetCards(e)
	for tc in aux.Next(g) do
		if tc:IsFaceup() and tc:IsRelateToEffect(e) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_CANNOT_TRIGGER)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
	end
end

function s.costfilter(c)
	return c:IsSetCard(SET_SPECTER) and c:IsAbleToRemoveAsCost()
end
function s.fdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.fdfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
function s.fdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.fdfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.fdfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWN)
	local g=Duel.SelectTarget(tp,s.fdfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
function s.fdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end

function s.endcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
end
function s.endop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		if Duel.Destroy(c,REASON_EFFECT)>0 then
			Duel.Damage(1-tp,1000,REASON_EFFECT)
		end
	end
end

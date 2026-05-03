--Hades, Emperor of the Eternal Underworld
--[==[
-- ID: 922100214
-- Type: Monster / Fusion Monster
-- Level: 12
-- Attribute: DARK
-- Race: Fiend
-- ATK/DEF: 4000/4000
--
-- Archetypes:
-- - Hades
-- - saint-seiya
--
-- Effect (EN):
-- 1 Level 8 "Specter" monster + 1 Level 8 "Renegade Saint" monster
-- Cannot be Normal Summoned/Set.
-- Must be Special Summoned from your Extra Deck (this is treated as a Fusion Summon) while you have 12 or more "Specter" monsters in your GY. (You do not use "Fusion" as an activation procedure.)
-- Its Special Summon cannot be negated.
-- While you have 8 or more "Specter" monsters in your GY, this card is unaffected by your opponent's activated effects.
-- Once per turn (Quick Effect): You can return 2 of your banished "Specter" monsters to the GY, then target 1 card on the field; banish it face-down, and if you do, your opponent cannot Special Summon monsters with that original name for the rest of this Duel.
-- If this face-up card would leave the field by an opponent's card effect, you can send 1 Level 8 "Specter" or "Renegade Saint" monster from your Extra Deck or GY to the GY instead.
-- You can only control 1 "Hades, Emperor of the Eternal Underworld".
--]==]
--Hades, Emperor of the Eternal Underworld
local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	c:EnableReviveLimit()
	-- Special Summon from Extra with 12+ Specters in GY (treated as Fusion)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(s.spcon)
	e0:SetOperation(s.spop)
	e0:SetValue(SUMMON_TYPE_FUSION)
	c:RegisterEffect(e0)
	-- Cannot negate its summon (approx.)
	local e0b=Effect.CreateEffect(c)
	e0b:SetType(EFFECT_TYPE_SINGLE)
	e0b:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	c:RegisterEffect(e0b)
	-- Unaffected by opponent activated effects if 8+ Specters in GY
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetCondition(s.immcon)
	e1:SetValue(s.immval)
	c:RegisterEffect(e1)
	-- Quick: return 2 banished Specters; banish 1 card facedown and lock SS of that name
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.cost)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
	-- Replacement if would leave field by opponent effect
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetTarget(s.reptg)
	e3:SetOperation(s.repop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_HADES, SET_SAINT}

function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,SET_SPECTER),tp,LOCATION_GRAVE,0,nil)>=12
		and Duel.IsExistingMatchingCard(s.matfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,tp)
		and Duel.IsExistingMatchingCard(s.matfilter2,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,tp)
end
function s.matfilter(c,tp)
	return c:IsSetCard(SET_SPECTER) and c:IsLevel(8) and c:IsMonster() and c:IsAbleToGraveAsCost()
end
function s.matfilter2(c,tp)
	return c:IsSetCard(SET_RENEGADE_SAINT) and c:IsLevel(8) and c:IsMonster() and c:IsAbleToGraveAsCost()
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g1=Duel.SelectMatchingCard(tp,s.matfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g2=Duel.SelectMatchingCard(tp,s.matfilter2,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,tp)
	g1:Merge(g2)
	Duel.SendtoGrave(g1,REASON_COST)
end

function s.immcon(e)
	return Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,SET_SPECTER),e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil)>=8
end
function s.immval(e,re)
	return re:IsActivated() and re:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

function s.costfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_SPECTER) and c:IsMonster() and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_REMOVED,0,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_REMOVED,0,2,2,nil)
	Duel.SendtoGrave(g,REASON_COST+REASON_RETURN)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToRemove() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	local code=tc:GetOriginalCode()
	if Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)~=0 then
		-- For rest of duel, opponent cannot Special Summon monsters with that original name (approx.)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(0,1)
		e1:SetLabel(code)
		e1:SetTarget(function(e,c) return c:IsCode(e:GetLabel()) end)
		e1:SetReset(0)
		Duel.RegisterEffect(e1,tp)
	end
end

function s.repfilter(c)
	return (c:IsSetCard(SET_SPECTER) or c:IsSetCard(SET_RENEGADE_SAINT)) and c:IsLevel(8) and c:IsMonster() and c:IsAbleToGraveAsCost()
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()~=tp
			and Duel.IsExistingMatchingCard(s.repfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil)
	end
	return Duel.SelectEffectYesNo(tp,c,96)
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.repfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_EFFECT)
end

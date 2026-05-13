--Agora of Lotus, Envoy of the Pope
--[==[
-- ID: 922100127
-- Type: Monster / Effect Monster
-- Level: 5
-- Attribute: DARK
-- Race: Spellcaster
-- ATK/DEF: 1800/1500
--
-- Archetypes:
-- - Envoy of the Pope
-- Effect (EN):
-- If you control "Pope Ares" or a "Pope's Mandate" card, you can Special Summon this card from your hand.
-- Once per turn (Quick Effect): You can discard 1 "Envoy of the Pope" card, then target 1 face-up monster your opponent controls; that monster's effects are negated until your next Standby Phase.
-- While you control "Pope Ares", this card and other "Envoy of the Pope" monsters you control cannot be targeted by your opponent's Spellcaster-Type monster effects.
-- If this card is in your GY: You can send 1 "Pope's Mandate" Spell/Trap from your Deck to the GY; Special Summon this card.
-- You can only use each effect of "Agora of Lotus, Envoy of the Pope" once per turn.
--]==]
--Agora of Lotus, Envoy of the Pope
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon from hand
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_HAND)
	e0:SetCondition(s.spcon)
	c:RegisterEffect(e0)

	--Quick: discard 1 Envoy; negate 1 face-up monster until your next Standby Phase
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)

	--While you control Pope Ares: this and other Envoys cannot be targeted by opponent's Spellcaster monster effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(s.popecon)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_ENVOY_OF_THE_POPE))
	e2:SetValue(s.tgval)
	c:RegisterEffect(e2)

	--GY: send 1 "Pope's Mandate" S/T from Deck to GY; Special Summon this
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCost(s.gycost)
	e3:SetTarget(s.gytg)
	e3:SetOperation(s.gyop)
	c:RegisterEffect(e3)
end

s.listed_series={SET_ENVOY_OF_THE_POPE,SET_POPES_MANDATE}
s.listed_names={922100105}

function s.pm_onfield(tp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_POPES_MANDATE),tp,LOCATION_ONFIELD,0,1,nil)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and (Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,922100105),tp,LOCATION_MZONE,0,1,nil) or s.pm_onfield(tp))
end

function s.costfilter(c)
	return c:IsSetCard(SET_ENVOY_OF_THE_POPE) and c:IsAbleToGraveAsCost() and c:IsDiscardable(REASON_COST)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,s.costfilter,1,1,REASON_COST+REASON_DISCARD,nil)
end
function s.filter(c)
	return c:IsFaceup() and c:IsMonster()
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or not tc:IsFaceup() then return end
	local reset=RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(reset)
	tc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	tc:RegisterEffect(e2)
end

function s.popecon(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,922100105),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function s.tgval(e,re,rp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsRace(RACE_SPELLCASTER) and rp==1-e:GetHandlerPlayer()
end

function s.pmdeckfilter(c)
	return c:IsSetCard(SET_POPES_MANDATE) and c:IsSpellTrap() and c:IsAbleToGraveAsCost()
end
function s.gycost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.pmdeckfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.pmdeckfilter,tp,LOCATION_DECK,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

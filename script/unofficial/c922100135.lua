--Pope Ares - Usurper of the Sanctuary
--[==[
-- ID: 922100135
-- Type: Monster / Effect Monster
-- Level: 10
-- Attribute: DARK
-- Race: Spellcaster
-- ATK/DEF: 3200/2800
--
-- Archetypes:
-- (setcode 0 — not in a named ProjectIgnis archetype series)
-- Effect (EN):
-- Cannot be Normal Summoned/Set.
-- Must be Special Summoned (from your hand or GY) by sending 2 "Envoy of the Pope" monsters you control to the GY.
-- If this card is Special Summoned: You can Set 1 "Pope's Mandate" Spell/Trap directly from your Deck.
-- Once per turn (Quick Effect): You can send 1 "Envoy of the Pope" card from your hand or face-up field to the GY, then target 1 face-up monster your opponent controls; negate its effects, and if you do, take control of it until the End Phase, but it cannot attack directly.
-- While you control another "Envoy of the Pope" monster, your opponent cannot target this card with card effects.
-- You can only use each effect of "Pope Ares - Usurper of the Sanctuary" once per turn.
--]==]
--Pope Ares - Usurper of the Sanctuary
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Cannot be Normal Summoned/Set
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_SUMMON)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	local e0b=e0:Clone()
	e0b:SetCode(EFFECT_CANNOT_MSET)
	c:RegisterEffect(e0b)

	--Special Summon proc (hand/GY) by sending 2 Envoys you control to GY
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	--If Special Summoned: Set 1 "Pope's Mandate" S/T from Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)

	--Quick: send 1 Envoy to GY, then negate + take control until End Phase
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e3:SetCountLimit(1,{id,1})
	e3:SetCost(s.ctcost)
	e3:SetTarget(s.cttg)
	e3:SetOperation(s.ctop)
	c:RegisterEffect(e3)

	--While you control another Envoy, cannot be targeted
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.protcon)
	e4:SetValue(aux.tgoval)
	c:RegisterEffect(e4)
end

s.listed_series={SET_POPES_MANDATE,SET_ENVOY_OF_THE_POPE,SET_SAINT}

function s.spfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_ENVOY_OF_THE_POPE) and c:IsAbleToGraveAsCost()
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.GetMatchingGroupCount(s.spfilter,tp,LOCATION_MZONE,0,nil)>=2
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_MZONE,0,2,2,nil)
	Duel.SendtoGrave(g,REASON_COST)
end

function s.pmsetfilter(c)
	return c:IsSetCard(SET_POPES_MANDATE) and c:IsSpellTrap() and c:IsSSetable()
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if not Duel.IsExistingMatchingCard(s.pmsetfilter,tp,LOCATION_DECK,0,1,nil) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.pmsetfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then Duel.SSet(tp,tc) end
end

function s.ctcostfilter(c)
	return c:IsSetCard(SET_ENVOY_OF_THE_POPE) and c:IsAbleToGraveAsCost()
		and (c:IsLocation(LOCATION_HAND) or (c:IsLocation(LOCATION_ONFIELD) and c:IsFaceup()))
end
function s.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.ctcostfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.ctcostfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,e:GetHandler())
	Duel.SendtoGrave(g,REASON_COST)
end
function s.ctfilter(c)
	return c:IsFaceup() and c:IsMonster() and c:IsAbleToChangeControler()
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.ctfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.ctfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	Duel.SelectTarget(tp,s.ctfilter,tp,0,LOCATION_MZONE,1,1,nil)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) then return end
	--negate
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	tc:RegisterEffect(e2)
	--take control
	if Duel.GetControl(tc,tp,PHASE_END,1)~=0 then
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
	end
end

function s.protcon(e)
	local c=e:GetHandler()
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_ENVOY_OF_THE_POPE),c:GetControler(),LOCATION_MZONE,0,1,c)
end

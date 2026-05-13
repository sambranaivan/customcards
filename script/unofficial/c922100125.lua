--Cassios, Envoy of the Pope
--[==[
-- ID: 922100125
-- Type: Monster / Effect Monster
-- Level: 4
-- Attribute: EARTH
-- Race: Warrior
-- ATK/DEF: 1800/1400
--
-- Archetypes:
-- - Envoy of the Pope
-- Effect (EN):
-- If you control "Pope Ares", a "Pope's Mandate" card, or a "Silver Saint" Envoy monster, you can Special Summon this card from your hand.
-- (Quick Effect): You can Tribute this card, then target 1 "Envoy of the Pope" monster you control; that monster cannot be destroyed by battle or card effect until the end of the next turn, also your opponent cannot target it with card effects during that period.
-- If this card is sent from the field to the GY as a cost or by an opponent's card: You can add 1 "Silver Saint - Shaina of Ophiuchus, Envoy of the Pope" or 1 "Pope's Mandate" card from your Deck or GY to your hand.
-- You can only use each effect of "Cassios, Envoy of the Pope" once per turn.
--]==]
--Cassios, Envoy of the Pope
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

	--Quick: Tribute; protect 1 Envoy until end of next turn + cannot be targeted
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.trcost)
	e1:SetTarget(s.trtg)
	e1:SetOperation(s.trop)
	c:RegisterEffect(e1)

	--If sent from field to GY as cost or by opponent: add Shaina Envoy or Pope's Mandate from Deck/GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end

s.listed_series={SET_ENVOY_OF_THE_POPE,SET_POPES_MANDATE,SET_SILVER_SAINT}
s.listed_names={922100105,922100107}

function s.pm_onfield(tp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_POPES_MANDATE),tp,LOCATION_ONFIELD,0,1,nil)
end
function s.has_silver_envoy(tp)
	return Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and c:IsSetCard(SET_ENVOY_OF_THE_POPE) and c:IsSetCard(SET_SILVER_SAINT) end,tp,LOCATION_MZONE,0,1,nil)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and (
		Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,922100105),tp,LOCATION_MZONE,0,1,nil)
		or s.pm_onfield(tp)
		or s.has_silver_envoy(tp)
	)
end

function s.trcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end
function s.envfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_ENVOY_OF_THE_POPE)
end
function s.trtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.envfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.envfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.envfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.trop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or not tc:IsFaceup() then return end
	local reset=RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	e1:SetReset(reset)
	tc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	tc:RegisterEffect(e2)
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(aux.tgoval)
	e3:SetReset(reset)
	tc:RegisterEffect(e3)
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and ((r&REASON_COST)~=0 or rp==1-tp)
end
function s.thfilter(c)
	return (c:IsCode(922100107) or c:IsSetCard(SET_POPES_MANDATE)) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

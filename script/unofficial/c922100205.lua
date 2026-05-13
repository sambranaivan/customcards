--Renegade Saint - Shion of Aries
--[==[
-- ID: 922100205
-- Type: Monster / Effect Monster
-- Level: 8
-- Attribute: DARK
-- Race: Zombie
-- ATK/DEF: 2100/2600
--
-- Archetypes:
-- - saint
-- - Renegade Saint
-- Effect (EN):
-- This card is also treated as a "Saint" monster while on the field and in the GY.
-- Cannot be Normal Summoned/Set.
-- Must be Special Summoned (from your hand or GY) by banishing 2 "Specter" monsters from your GY, while you have 6 or more "Specter" monsters in your GY.
-- If this card is Special Summoned: You can add 1 "Hades" Spell/Trap or 1 "The Great Eclipse - World of Silence" from your Deck to your hand.
-- While you have 5 or more "Specter" monsters in your GY (Quick Effect): You can banish 1 "Specter" monster from your GY; negate the activation of a Spell/Trap Card, and if you do, destroy that card.
-- During the End Phase, if this card was Special Summoned this turn: Destroy this card, and if you do, inflict 1000 damage to your opponent.
-- You can only use each effect of "Renegade Saint - Shion of Aries" once per turn.
--]==]
--Renegade Saint - Shion of Aries
local s,id=GetID()
function s.initial_effect(c)
	-- Treated as Saint already via setcode usage in archetype; no extra needed for engine.
	c:EnableReviveLimit()
	-- SS proc (hand/GY): banish 2 Specters while 6+ Specters in GY
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e0:SetCondition(s.spcon)
	e0:SetOperation(s.spop)
	c:RegisterEffect(e0)
	-- On SS: search Hades S/T or Great Eclipse
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- Quick: banish 1 Specter; negate Spell/Trap activation and destroy
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+100)
	e2:SetCondition(s.negcon)
	e2:SetCost(s.negcost)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
	-- End Phase: if SS this turn, destroy self and burn
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
	-- mark summoned this turn
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end

function s.thfilter(c)
	return (c:IsSetCard(SET_HADES) and c:IsType(TYPE_SPELL+TYPE_TRAP) or c:IsCode(922100193)) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp then return false end
	return Duel.IsChainNegatable(ev)
		and Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,SET_SPECTER),tp,LOCATION_GRAVE,0,nil)>=5
		and re:IsHasType(EFFECT_TYPE_ACTIVATE)
		and re:GetHandler():IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.costfilter(c)
	return c:IsSetCard(SET_SPECTER) and c:IsAbleToRemoveAsCost()
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev)~=0 then
		local rc=re:GetHandler()
		if rc:IsRelateToEffect(re) then
			Duel.Destroy(rc,REASON_EFFECT)
		end
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

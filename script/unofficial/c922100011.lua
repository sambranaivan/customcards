--Kiki - Messenger of the Cloth Sculptor
--[==[
-- ID: 922100011
-- Type: Monster / Effect Monster
-- Level: 2
-- Attribute: LIGHT
-- Race: Psychic
-- ATK/DEF: 500/500
--
-- Archetypes:
-- (no archetype setcode — not a "Saint" or "Bronze Saint" monster; supports allies via card text.)
--
-- Effect (EN):
-- (Quick Effect): You can discard this card, then target 1 "Saint" monster you control; equip 1 "Cloth" Equip Spell from your Deck or GY to that target.
-- During the Standby Phase of the next turn after this card was sent to the GY: You can banish this card; add up to 2 "Cloth" cards with different names from your GY to your hand.
-- You can only use each effect of "Kiki - Messenger of the Cloth Sculptor" once per turn.
--]==]
--Kiki - Messenger of the Cloth Sculptor
local s,id=GetID()
function s.initial_effect(c)
	--Track when sent to GY
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_TO_GRAVE)
	e0:SetOperation(s.regop)
	c:RegisterEffect(e0)

	--Discard; equip 1 "Cloth" Equip Spell from Deck or GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.eqcost)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)

	--Next turn Standby Phase: banish; add up to 2 "Cloth" with different names
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.thcon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end

s.listed_series={SET_SAINT, SET_CLOTH}

function s.eqcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function s.saintmon(c)
	return c:IsFaceup() and c:IsSetCard(SET_SAINT)
end
function s.clotheq(c)
	return c:IsSetCard(SET_CLOTH) and c:IsType(TYPE_EQUIP) and not c:IsForbidden()
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.saintmon(chkc) end
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			and Duel.IsExistingTarget(s.saintmon,tp,LOCATION_MZONE,0,1,nil)
			and Duel.IsExistingMatchingCard(s.clotheq,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.saintmon,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or not tc:IsFaceup() then return end
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectMatchingCard(tp,s.clotheq,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	local ec=g:GetFirst()
	if not ec then return end
	Duel.Equip(tp,ec,tc,true)
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.GetTurnPlayer()==tp and c:GetFlagEffect(id)~=0 and Duel.GetTurnCount()>c:GetFlagEffectLabel(id)
end
function s.thfilter(c)
	return c:IsSetCard(SET_CLOTH) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_GRAVE,0,nil)
		return g:GetClassCount(Card.GetCode)>=2 or g:GetClassCount(Card.GetCode)>=1
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_GRAVE,0,nil)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,2)
	if not sg or #sg==0 then return end
	if sg:GetClassCount(Card.GetCode)~=#sg then return end
	Duel.SendtoHand(sg,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,sg)
end

function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_COST) or c:IsReason(REASON_DISCARD) or c:IsReason(REASON_EFFECT) then
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,0,1,Duel.GetTurnCount())
	end
end

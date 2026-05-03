--Nibelungen Ring
--[==[
-- ID: 922100188
-- Type: Spell / Continuous Spell
--
-- Archetypes:
-- - saint-seiya
--
-- Effect (EN):
-- The activation and effects of your "Hilda of Polaris - Odin's Representative" cannot be negated.
-- Once per turn, when your opponent activates the effect of a monster with a Frost Counter: That effect becomes "Return 1 card you control to the hand".
-- If this face-up card is destroyed by a card effect and sent to the GY: You can remove 1 Odin Sapphire Counter from your field; Set this card.
--]==]
--Nibelungen Ring
local s,id=GetID()
function s.initial_effect(c)
	-- Your Hilda cannot be negated
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_INACTIVATE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetValue(s.chainfilter)
	c:RegisterEffect(e1)
	local e1b=e1:Clone()
	e1b:SetCode(EFFECT_CANNOT_DISEFFECT)
	c:RegisterEffect(e1b)
	-- Once per turn, change effect of Frosted monster
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.chcon)
	e2:SetOperation(s.chop)
	c:RegisterEffect(e2)
	-- If destroyed by effect, Set itself
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(s.setcon)
	e3:SetCost(s.setcost)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_SAINT}

function s.chainfilter(e,ct)
	local te,tp=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	if not te then return false end
	local tc=te:GetHandler()
	return tp==e:GetHandlerPlayer() and tc and tc:IsCode(922100181)
end

function s.chcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return rp~=tp and re:IsActiveType(TYPE_MONSTER) and rc:IsFaceup() and rc:GetCounter(0x10f8)>0
end
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeChainOperation(ev,s.repop)
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetHandlerPlayer()
	if Duel.IsExistingMatchingCard(aux.TRUE,p,LOCATION_ONFIELD,0,1,nil) then
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_RTOHAND)
		local g=Duel.SelectMatchingCard(p,aux.TRUE,p,LOCATION_ONFIELD,0,1,1,nil)
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end

function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and c:IsPreviousPosition(POS_FACEUP)
end
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanRemoveCounter(tp,LOCATION_ONFIELD,0,0x10f9,1,REASON_COST) end
	Duel.RemoveCounter(tp,LOCATION_ONFIELD,0,0x10f9,1,REASON_COST)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SSet(tp,c)
	end
end

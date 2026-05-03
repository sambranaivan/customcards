--Poseidon, God of the Seas
--[==[
-- ID: 922100244
-- Type: Monster / Effect Monster
-- Level: 10
-- Attribute: WATER
-- Race: Warrior
-- ATK/DEF: 3500/3500
--
-- Archetypes:
-- - Poseidon
-- - saint-seiya
--
-- Effect (EN):
-- Requires 3 Tributes to Normal Summon (cannot be Normal Set).
-- If this card is Tribute Summoned: You can target up to 2 "Pillar" cards in your GY; add them to your hand.
-- Once per turn: You can target 1 "Pillar" card in your GY; place it face-up in your Spell & Trap Zone.
-- While this card is face-up on the field, negate your opponent's card effects activated in the same column as your "Pillar" cards.
--]==]
--Poseidon, God of the Seas
local s,id=GetID()
function s.initial_effect(c)
	-- Tribute summon requires 3 tributes, cannot set (approx.)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CANNOT_MSET)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	-- On Tribute Summon: add up to 2 Pillars from GY
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.trcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- Once per turn: place a Pillar from GY face-up in S/T zone
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_LEAVE_GRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+100)
	e2:SetTarget(s.placetg)
	e2:SetOperation(s.placeop)
	c:RegisterEffect(e2)
	-- Negate opponent effects activated in same column as your Pillars
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.negcon)
	e3:SetOperation(s.negop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_POSEIDON, SET_SAINT}

function s.trcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_TRIBUTE)
end
function s.pillgy(c)
	return c:IsSetCard(SET_PILLAR) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.pillgy,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.pillgy,tp,LOCATION_GRAVE,0,1,2,nil)
	if #g>0 then Duel.SendtoHand(g,nil,REASON_EFFECT) Duel.ConfirmCards(1-tp,g) end
end

function s.placefilter(c)
	return c:IsSetCard(SET_PILLAR) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
function s.placetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingMatchingCard(s.placefilter,tp,LOCATION_GRAVE,0,1,nil) end
end
function s.placeop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.placefilter,tp,LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp then return false end
	if not Duel.IsChainNegatable(ev) then return false end
	local rc=re:GetHandler()
	if not rc then return false end
	-- check if activation in same column as any pillar you control
	local pg=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSetCard,SET_PILLAR),tp,LOCATION_SZONE,0,nil)
	for pc in aux.Next(pg) do
		if pc:GetColumnGroup():IsContains(rc) then return true end
	end
	return false
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateActivation(ev)
end

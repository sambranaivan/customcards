--The Great Central Pillar
--[==[
-- ID: 922100250
-- Type: Spell / Continuous Spell
--
-- Archetypes:
-- - Pillar
-- Effect (EN):
-- When this card is activated: you can place 1 "Pillar" card from your Deck or GY face-up in your Spell & Trap Zone.
-- Once per turn: You can move 1 other face-up "Pillar" card you control to another Spell & Trap Zone.
-- "Pillar" cards you control cannot be targeted by your opponent's card effects.
-- If this face-up card would be destroyed by a card effect, you can send 1 other face-up "Pillar" card you control to the GY instead.
-- You can only activate 1 "The Great Central Pillar" per turn.
--]==]
--The Great Central Pillar
local s,id=GetID()
function s.initial_effect(c)
	-- Activate: place a Pillar from Deck/GY
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_LEAVE_GRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.pltg)
	e1:SetOperation(s.plop)
	c:RegisterEffect(e1)
	-- Move 1 other Pillar
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id+100)
	e2:SetTarget(s.movtg)
	e2:SetOperation(s.movop)
	c:RegisterEffect(e2)
	-- Pillars cannot be targeted by opponent effects
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_SZONE,0)
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_PILLAR))
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	-- Destruction replacement: send other Pillar
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetTarget(s.reptg)
	e4:SetOperation(s.repop)
	c:RegisterEffect(e4)
end
s.listed_series={SET_PILLAR, SET_SAINT}

function s.plfilter(c)
	return c:IsSetCard(SET_PILLAR) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			and Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
	end
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.plfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) end
end

function s.pillmove(c)
	return c:IsFaceup() and c:IsSetCard(SET_PILLAR) and c:IsLocation(LOCATION_SZONE)
end
function s.movtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_SZONE) and s.pillmove(chkc) and chkc~=e:GetHandler() end
	if chk==0 then return Duel.IsExistingTarget(s.pillmove,tp,LOCATION_SZONE,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
	local g=Duel.SelectTarget(tp,s.pillmove,tp,LOCATION_SZONE,0,1,1,e:GetHandler())
end
function s.movop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
	local zone=Duel.SelectDisableField(tp,1,LOCATION_SZONE,0,0)
	Duel.MoveSequence(tc,math.floor(math.log(zone,2)))
end

function s.repother(c)
	return c:IsFaceup() and c:IsSetCard(SET_PILLAR) and c:IsLocation(LOCATION_SZONE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsReason(REASON_EFFECT) and Duel.IsExistingMatchingCard(s.repother,tp,LOCATION_SZONE,0,1,c)
	end
	return Duel.SelectEffectYesNo(tp,c,96)
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.repother,tp,LOCATION_SZONE,0,1,1,c)
	Duel.SendtoGrave(g,REASON_EFFECT)
end

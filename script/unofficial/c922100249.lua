--Submarine Sanctuary
--[==[
-- ID: 922100249
-- Type: Spell / Field Spell
--
-- Archetypes:
-- (setcode 0 — not in a named ProjectIgnis archetype series)
-- Effect (EN):
-- All "Marine General" monsters you control gain 300 ATK/DEF.
-- Once per turn: You can move 1 face-up "Marine General" monster you control to another of your Main Monster Zones.
-- If a "Pillar" card(s) you control would be destroyed by your opponent's card effect, you can send 1 "Scale" card from your hand or face-up field to the GY instead.
--]==]
--Submarine Sanctuary
local s,id=GetID()
function s.initial_effect(c)
	-- ATK/DEF +300
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_MARINE_GENERAL))
	e1:SetValue(300)
	c:RegisterEffect(e1)
	local e1b=e1:Clone()
	e1b:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1b)
	-- Move 1 Marine General
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.movtg)
	e2:SetOperation(s.movop)
	c:RegisterEffect(e2)
	-- Destruction replace for your Pillars by sending a Scale
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTarget(s.reptg)
	e3:SetValue(s.repval)
	e3:SetOperation(s.repop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_SAINT}

function s.mgfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_MARINE_GENERAL)
end
function s.movtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.mgfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.mgfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
	local g=Duel.SelectTarget(tp,s.mgfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.movop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
	local zone=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
	Duel.MoveSequence(tc,math.floor(math.log(zone,2)))
end

function s.pillar_dest(c,tp)
	return c:IsControler(tp) and c:IsSetCard(SET_PILLAR) and c:IsLocation(LOCATION_SZONE)
end
function s.scalecost(c)
	return c:IsCode(922100230,922100231,922100232,922100233,922100234,922100235,922100236)
		and (c:IsLocation(LOCATION_HAND) or (c:IsLocation(LOCATION_ONFIELD) and c:IsFaceup()))
		and c:IsAbleToGraveAsCost()
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.pillar_dest,1,nil,tp) and Duel.IsExistingMatchingCard(s.scalecost,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil) end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function s.repval(e,c)
	return s.pillar_dest(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.scalecost,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end

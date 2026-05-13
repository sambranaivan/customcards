--Silver Cloth - Cerberus
--[==[
-- ID: 922100060
-- Type: Spell / Equip Spell
--
-- Archetypes:
-- - cloth
-- - Silver Cloth
-- Effect (EN):
-- Equip only to a "Silver Saint" monster.
-- Once per turn: You can target 1 card in either GY; banish it.
-- If this card is equipped to "Silver Saint - Cerberus Dante", while you control this equipped card, cards in your opponent's GY cannot be banished except by card effects.
--]==]
--Silver Cloth - Cerberus
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	--Equip limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(s.eqlimit)
	c:RegisterEffect(e1)

	--Banish 1 card in either GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.rmcon)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)

	--If equipped to Dante: opponent's GY cards cannot be banished except by card effects
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_REMOVE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(0,1)
	e3:SetCondition(s.lockcon)
	e3:SetValue(s.rmlimit)
	c:RegisterEffect(e3)
end

s.listed_series={SET_CLOTH,SET_SILVER_CLOTH,SET_SAINT}
s.listed_names={922100021}

function s.eqlimit(e,c)
	return c:IsSetCard(SET_SILVER_SAINT)
end

function s.rmcon(e)
	return e:GetHandler():GetEquipTarget()~=nil
end
function s.rmfilter(c)
	return c:IsAbleToRemove()
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.rmfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end

function s.lockcon(e)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:IsCode(922100021)
end
function s.rmlimit(e,c,tp,r)
	return c:IsLocation(LOCATION_GRAVE) and (r&REASON_EFFECT)==0
end

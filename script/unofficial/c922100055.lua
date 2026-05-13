--Silver Cloth - Lacerta
--[==[
-- ID: 922100055
-- Type: Spell / Equip Spell
--
-- Archetypes:
-- - cloth
-- - Silver Cloth
-- Effect (EN):
-- Equip only to a "Silver Saint" monster.
-- The equipped monster cannot be targeted by your opponent's card effects.
-- If the equipped monster is "Silver Saint - Misty of Lacerta", once per turn, if it would be destroyed by battle or card effect, you can send 1 "Cloth" card from your hand or field to the GY instead.
--]==]
--Silver Cloth - Lacerta
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

	--Equipped monster cannot be targeted
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)

	--If equipped to Misty: destruction substitute by sending 1 "Cloth" from hand/field to GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.mistycon)
	e3:SetTarget(s.reptg)
	e3:SetOperation(s.repop)
	c:RegisterEffect(e3)
end

s.listed_series={SET_CLOTH,SET_SILVER_CLOTH,SET_SAINT}
s.listed_names={922100015}

function s.eqlimit(e,c)
	return c:IsSetCard(SET_SILVER_SAINT)
end

function s.mistycon(e)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:IsCode(922100015)
end
function s.costfilter(c)
	return c:IsSetCard(SET_CLOTH) and c:IsAbleToGraveAsCost() and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return (r&REASON_BATTLE+REASON_EFFECT)~=0 and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil)
	end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_COST)
	end
end

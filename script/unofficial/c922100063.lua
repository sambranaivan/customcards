--Silver Cloth - Musca
--[==[
-- ID: 922100063
-- Type: Spell / Equip Spell
--
-- Archetypes:
-- - cloth
-- - Silver Cloth
-- Effect (EN):
-- Equip only to a "Silver Saint" monster.
-- Once per turn: You can place 1 Fly Counter on 1 face-up monster on the field.
-- Monsters with Fly Counters lose 500 ATK/DEF.
-- If this card is equipped to "Silver Saint - Musca Dio", monsters with Fly Counters also cannot activate their effects.
--]==]
--Silver Cloth - Musca
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

	--Place 1 Fly Counter
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.ctcon)
	e2:SetTarget(s.cttg)
	e2:SetOperation(s.ctop)
	c:RegisterEffect(e2)

	--ATK/DEF -500 for monsters with Fly Counters
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(s.flytg)
	e3:SetValue(-500)
	c:RegisterEffect(e3)
	local e3b=e3:Clone()
	e3b:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3b)

	--If equipped to Dio: monsters with Fly Counters cannot activate effects
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_ACTIVATE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(0,1)
	e4:SetCondition(s.diocon)
	e4:SetValue(s.actlimit)
	c:RegisterEffect(e4)
end

s.listed_series={SET_CLOTH,SET_SILVER_CLOTH,SET_SAINT}
s.listed_names={922100024}
s.counter_place_list={0x10f5}

function s.eqlimit(e,c)
	return c:IsSetCard(SET_SILVER_SAINT)
end

function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipTarget()~=nil
end
function s.ctfilter(c)
	return c:IsFaceup() and c:IsCanAddCounter(0x10f5,1)
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.ctfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.ctfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.ctfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		tc:AddCounter(0x10f5,1)
	end
end
function s.flytg(e,c)
	return c:GetCounter(0x10f5)>0
end

function s.diocon(e)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:IsCode(922100024)
end
function s.actlimit(e,re,tp)
	local rc=re:GetHandler()
	return rc:IsLocation(LOCATION_MZONE) and rc:GetCounter(0x10f5)>0
end

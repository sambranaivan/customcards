--Gold Cloth - Sagittarius
--[==[
-- ID: 922100067
-- Type: Spell / Equip Spell
--
-- Archetypes:
-- - cloth
-- - Gold Cloth
--
-- Effect (EN):
-- Equip only to a "Saint" monster.
-- The equipped monster gains 1200 ATK.
-- Once per turn, if the equipped "Gold Saint" monster would activate an effect that requires detaching material, you can banish 1 "Cloth" card from your GY instead of detaching 1 material.
-- If the equipped monster is "Bronze Saint - Seiya of Pegasus" or "Gold Saint - Aiolos of Sagittarius", when it declares an attack, your opponent cannot activate cards or effects until the end of the Battle Phase.
-- If this card is in your GY: You can target 1 "Bronze Saint" monster you control; equip this card to it, and if you do, it becomes Level 8. You can only use this effect of "Gold Cloth - Sagittarius" once per turn.
--]==]
--Gold Cloth - Sagittarius
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

	--ATK +1200
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(1200)
	c:RegisterEffect(e2)

	--Detach replacement: banish 1 "Cloth" from GY instead
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_OVERLAY_REMOVE_REPLACE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.repcon)
	e3:SetOperation(s.repop)
	c:RegisterEffect(e3)

	--Attack declaration lock (Seiya or Aiolos): opponent cannot activate until end of BP
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(s.atkcon)
	e4:SetOperation(s.atkop)
	c:RegisterEffect(e4)

	--GY: equip to Bronze Saint; it becomes Level 8
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCategory(CATEGORY_EQUIP)
	e5:SetRange(LOCATION_GRAVE)
	e5:SetCountLimit(1,id)
	e5:SetTarget(s.eqtg)
	e5:SetOperation(s.eqop)
	c:RegisterEffect(e5)
end

s.listed_series={SET_CLOTH,SET_GOLD_CLOTH,SET_GOLD_SAINT,SET_SAINT}
s.listed_names={922100000,922100029}

function s.eqlimit(e,c)
	return c:IsSetCard(SET_SAINT)
end

function s.repcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if not ec then return false end
	return (r&REASON_COST)~=0 and re:IsActivated()
		and re:GetHandler()==ec and ec:IsFaceup() and ec:IsSetCard(SET_GOLD_SAINT)
		and Duel.IsExistingMatchingCard(s.banfilter,tp,LOCATION_GRAVE,0,1,nil)
		and ep==e:GetOwnerPlayer() and ev==1
end
function s.banfilter(c)
	return c:IsSetCard(SET_CLOTH) and c:IsAbleToRemoveAsCost()
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.banfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g==0 then return false end
	return Duel.Remove(g,POS_FACEUP,REASON_COST)~=0
end

function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if not ec then return false end
	return Duel.GetAttacker()==ec and (ec:IsCode(922100000) or ec:IsCode(922100029))
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_BATTLE)
	Duel.RegisterEffect(e1,tp)
end

function s.eqfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(SET_BRONZE_SAINT) and c:IsControler(tp)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.eqfilter(chkc,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,0,1,nil,tp)
		and e:GetHandler():IsAbleToChangeControler() end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not (tc and tc:IsRelateToEffect(e) and tc:IsFaceup()) then return end
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if not c:IsRelateToEffect(e) then return end
	if Duel.Equip(tp,c,tc) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(8)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end

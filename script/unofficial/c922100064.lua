--Silver Cloth - Heracles
--[==[
-- ID: 922100064
-- Type: Spell / Equip Spell
--
-- Archetypes:
-- - cloth
-- - Silver Cloth
-- Effect (EN):
-- Equip only to a "Silver Saint" monster.
-- The equipped monster gains 700 ATK.
-- If this card is equipped to "Silver Saint - Heracles Algethi", once per turn: You can target 1 face-up monster your opponent controls; change it to Defense Position, and if you do, it cannot change its battle position this turn.
--]==]
--Silver Cloth - Heracles
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

	--ATK +700
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(700)
	c:RegisterEffect(e2)

	--If equipped to Algethi: change 1 opponent monster to DEF and lock position
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.algcon)
	e3:SetTarget(s.postg)
	e3:SetOperation(s.posop)
	c:RegisterEffect(e3)
end

s.listed_series={SET_CLOTH,SET_SILVER_CLOTH,SET_SAINT}
s.listed_names={922100025}

function s.eqlimit(e,c)
	return c:IsSetCard(SET_SILVER_SAINT)
end
function s.algcon(e)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:IsCode(922100025)
end
function s.posfilter(c)
	return c:IsFaceup() and c:IsMonster() and c:IsCanChangePosition()
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.posfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSITION)
	Duel.SelectTarget(tp,s.posfilter,tp,0,LOCATION_MZONE,1,1,nil)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or not tc:IsFaceup() then return end
	if Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE)~=0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end

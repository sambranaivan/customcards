--Docrates, Envoy of the Pope
--[==[
-- ID: 922100128
-- Type: Monster / Effect Monster
-- Level: 6
-- Attribute: EARTH
-- Race: Warrior
-- ATK/DEF: 2400/1600
--
-- Archetypes:
-- - Silver Saint
-- - Envoy of the Pope
-- Effect (EN):
-- If you control "Pope Ares" or a "Pope's Mandate" card, you can Normal Summon this card without Tributing, but its ATK becomes 1800 until the End Phase.
-- If this card is Normal or Special Summoned: You can destroy 1 Spell/Trap your opponent controls, then this card gains 300 ATK until the end of this turn.
-- Once per turn, if this card would be destroyed by an opponent's card effect, you can banish 1 "Envoy of the Pope" monster from your GY instead.
-- You can only use each effect of "Docrates, Envoy of the Pope" once per turn.
--]==]
--Docrates, Envoy of the Pope
local s,id=GetID()
function s.initial_effect(c)
	--Normal Summon without tribute (but ATK becomes 1800)
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SUMMON_PROC)
	e0:SetCondition(s.ntcon)
	e0:SetOperation(s.ntop)
	c:RegisterEffect(e0)

	--On summon: destroy 1 opponent S/T; then gain 300 ATK
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	local e1b=e1:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)

	--Destruction replacement: banish 1 Envoy from GY instead
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.reptg)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
end

s.listed_series={SET_ENVOY_OF_THE_POPE,SET_POPES_MANDATE,SET_SILVER_SAINT}
s.listed_names={922100105}

function s.pm_onfield(tp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_POPES_MANDATE),tp,LOCATION_ONFIELD,0,1,nil)
end
function s.ntcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	return minc==0 and c:GetLevel()>4 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and (Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,922100105),tp,LOCATION_MZONE,0,1,nil) or s.pm_onfield(tp))
end
function s.ntop(e,tp,eg,ep,ev,re,r,rp,c)
	--Mark that this Normal Summon used the no-tribute procedure
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetValue(1800)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end

function s.stfilter(c)
	return c:IsSpellTrap() and c:IsOnField() and c:IsDestructable()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_ONFIELD) and s.stfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.stfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.stfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end

function s.repfilter(c)
	return c:IsSetCard(SET_ENVOY_OF_THE_POPE) and c:IsAbleToRemoveAsCost()
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsFaceup() and c:IsOnField() and c:IsReason(REASON_EFFECT) and rp==1-tp
			and Duel.IsExistingMatchingCard(s.repfilter,tp,LOCATION_GRAVE,0,1,nil)
	end
	return Duel.SelectYesNo(tp,aux.Stringid(id,2))
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.repfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

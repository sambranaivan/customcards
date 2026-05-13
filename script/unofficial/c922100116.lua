--Silver Saint - Auriga Capella, Envoy of the Pope
--[==[
-- ID: 922100116
-- Type: Monster / Effect Monster
-- Level: 6
-- Attribute: LIGHT
-- Race: Warrior
-- ATK/DEF: 2600/1900
--
-- Archetypes:
-- - saint
-- - Silver Saint
-- - Envoy of the Pope
-- Effect (EN):
-- If you control "Pope Ares" or a "Pope's Mandate" card, you can Special Summon this card from your hand.
-- Once per turn (Quick Effect): You can target 1 face-up Spell/Trap your opponent controls; destroy it, then if you control another "Envoy of the Pope" monster, this card gains 400 ATK until the end of this turn.
--]==]
--Silver Saint - Auriga Capella, Envoy of the Pope
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon from hand
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_HAND)
	e0:SetCondition(s.spcon)
	c:RegisterEffect(e0)

	--Quick: destroy 1 face-up S/T; then if you control another Envoy, gain 400 ATK
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end

s.listed_series={SET_ENVOY_OF_THE_POPE,SET_SILVER_SAINT,SET_SAINT,SET_POPES_MANDATE}
s.listed_names={922100105}

function s.pm_onfield(tp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_POPES_MANDATE),tp,LOCATION_ONFIELD,0,1,nil)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and (Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,922100105),tp,LOCATION_MZONE,0,1,nil) or s.pm_onfield(tp))
end

function s.stfilter(c)
	return c:IsFaceup() and c:IsSpellTrap() and c:IsDestructable()
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_ONFIELD) and s.stfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.stfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.stfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		if Duel.Destroy(tc,REASON_EFFECT)~=0 then
			if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_ENVOY_OF_THE_POPE),tp,LOCATION_MZONE,0,1,c) then
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetValue(400)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				c:RegisterEffect(e1)
			end
		end
	end
end

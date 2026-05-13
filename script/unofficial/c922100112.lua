--Silver Saint - Whale Moses, Envoy of the Pope
--[==[
-- ID: 922100112
-- Type: Monster / Effect Monster
-- Level: 6
-- Attribute: WATER
-- Race: Warrior
-- ATK/DEF: 2500/2200
--
-- Archetypes:
-- - saint
-- - Silver Saint
-- - Envoy of the Pope
-- Effect (EN):
-- If you control "Pope Ares" or a "Pope's Mandate" card, you can Special Summon this card from your hand.
-- (Quick Effect): You can target 1 face-up monster your opponent controls; return it to the hand, also your opponent cannot Special Summon monsters with that card's original name from the Extra Deck until the end of their next turn.
-- You can only use each effect of "Silver Saint - Whale Moses, Envoy of the Pope" once per turn.
--]==]
--Silver Saint - Whale Moses, Envoy of the Pope
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

	--Quick: bounce 1 face-up monster; lock ED summon of that original name until end of opponent next turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,{id,1})
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

function s.filter(c)
	return c:IsFaceup() and c:IsMonster() and c:IsAbleToHand()
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,0)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	local code=tc:GetOriginalCode()
	if Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 then
		local reset=RESET_PHASE+PHASE_END+RESET_OPPO_TURN
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(0,1)
		e1:SetLabel(code)
		e1:SetTarget(function(e,c,sump,sumtype,sumpos,targetp,se)
			return c:IsLocation(LOCATION_EXTRA) and c:GetOriginalCode()==e:GetLabel()
		end)
		e1:SetReset(reset)
		Duel.RegisterEffect(e1,tp)
	end
end

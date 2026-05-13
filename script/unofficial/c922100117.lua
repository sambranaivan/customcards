--Silver Saint - Canis Major Sirius, Envoy of the Pope
--[==[
-- ID: 922100117
-- Type: Monster / Effect Monster
-- Level: 6
-- Attribute: EARTH
-- Race: Warrior
-- ATK/DEF: 2500/2100
--
-- Archetypes:
-- - saint
-- - Silver Saint
-- - Envoy of the Pope
-- Effect (EN):
-- If you control "Pope Ares" or a "Pope's Mandate" card, you can Special Summon this card from your hand.
-- When this card battles an opponent's monster, at the start of the Damage Step: You can make that opponent's monster lose 1000 ATK/DEF until the end of this turn.
-- Once per turn, when your opponent activates a monster effect in the Battle Phase (Quick Effect): You can negate that effect.
--]==]
--Silver Saint - Canis Major Sirius, Envoy of the Pope
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

	--Battle: start of Damage Step, opponent monster loses 1000 ATK/DEF
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.bdcon)
	e1:SetOperation(s.bdop)
	c:RegisterEffect(e1)

	--Battle Phase monster effect: negate
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.negcon)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
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

function s.bdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	local tc=(a==c) and d or a
	return tc~=nil and (a==c or d==c) and tc:IsFaceup() and tc:IsRelateToBattle()
end
function s.bdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	local tc=(a==c) and d or a
	if not tc or not tc:IsRelateToBattle() then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(-1000)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	tc:RegisterEffect(e2)
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE
		and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateActivation(ev)
end

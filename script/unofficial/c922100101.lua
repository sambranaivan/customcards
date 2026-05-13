--Crystal Wall
--[==[
-- ID: 922100101
-- Type: Trap / Counter Trap
--
-- Archetypes:
-- (setcode 0 — not in a named ProjectIgnis archetype series)
-- Effect (EN):
-- When an opponent's monster declares an attack on a "Saint" monster you control: Negate that attack, and if you do, end the Battle Phase, then if you control "Gold Saint - Mu of Aries", destroy all Attack Position monsters your opponent controls.
-- If you control "Gold Saint - Mu of Aries", you can activate this card from your hand.
-- You can only activate 1 "Crystal Wall" per turn.
--]==]
--Crystal Wall
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.negcon)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)

	--Activate from hand (Mu)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.handcon)
	c:RegisterEffect(e2)
end

s.listed_series={SET_SAINT,SET_CLOTH}
s.listed_names={922100029}

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	return a and a:IsControler(1-tp) and d and d:IsControler(tp) and d:IsSetCard(SET_SAINT)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,nil,0,0,0)
	if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,922100029),tp,LOCATION_MZONE,0,1,nil) then
		local g=Duel.GetMatchingGroup(Card.IsAttackPos,1-tp,LOCATION_MZONE,0,nil)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateAttack()==0 then return end
	-- End the Battle Phase after negating (turn player is the one conducting battle).
	Duel.SkipPhase(Duel.GetTurnPlayer(),PHASE_BATTLE,RESET_PHASE|PHASE_BATTLE_STEP,1)
	if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,922100029),tp,LOCATION_MZONE,0,1,nil) then
		local g=Duel.GetMatchingGroup(Card.IsAttackPos,1-tp,LOCATION_MZONE,0,nil)
		if #g>0 then
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end

function s.handcon(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,922100029),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end

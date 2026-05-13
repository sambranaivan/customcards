--Court of Silent Judgment
--[==[
-- ID: 922100216
-- Type: Spell / Continuous Spell
--
-- Archetypes:
-- (setcode 0 — not in a named ProjectIgnis archetype series)
-- Effect (EN):
-- Once per turn, if the number of "Specter" monsters in your GY changed this turn: You can draw 1 card.
-- While you have 10 or more "Specter" monsters in your GY, your opponent cannot activate monster effects in the hand.
--]==]
--Court of Silent Judgment
local s,id=GetID()
function s.initial_effect(c)
	-- Track Specter count in GY each turn
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_PHASE+PHASE_DRAW)
	e0:SetRange(LOCATION_SZONE)
	e0:SetOperation(s.regop)
	c:RegisterEffect(e0)
	-- Draw if Specter count changed this turn
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.drcon)
	e1:SetTarget(s.drtg)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)
	-- Opponent cannot activate monster effects in hand if 10+ Specters in your GY
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,1)
	e2:SetCondition(s.lockcon)
	e2:SetValue(s.aclimit)
	c:RegisterEffect(e2)
end
s.listed_series={SET_SAINT}

function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:SetTurnCounter((c:GetTurnCounter() or 0)+1)
	c:SetHint(CHINT_TURN,c:GetTurnCounter())
	c:SetFlagEffectLabel(id,Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,SET_SPECTER),tp,LOCATION_GRAVE,0,nil))
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local prev=c:GetFlagEffectLabel(id)
	local now=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,SET_SPECTER),tp,LOCATION_GRAVE,0,nil)
	return prev~=now
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Draw(tp,1,REASON_EFFECT)
end
function s.lockcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,SET_SPECTER),tp,LOCATION_GRAVE,0,nil)>=10
end
function s.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsLocation(LOCATION_HAND)
end

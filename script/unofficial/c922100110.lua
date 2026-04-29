--Silver Saint - Orphee of Lyra, Envoy of the Pope
--[==[
-- ID: 922100110
-- Type: Monster / Effect Monster
-- Level: 7
-- Attribute: LIGHT
-- Race: Warrior
-- ATK/DEF: 2700/2000
--
-- Archetypes:
-- - Envoy of the Pope
-- - Silver Saint
-- - saint
-- - saint-seiya
--
-- Effect (EN):
-- Cannot be Normal Summoned/Set.
-- Must be Special Summoned (from your hand) by controlling 2 or more "Envoy of the Pope" monsters.
-- Once per turn (Quick Effect): You can send 1 card from your hand or face-up field to the GY; negate the effects of all face-up monsters your opponent currently controls, until the end of this turn.
-- If you control "Pope Ares", your opponent cannot activate monster effects in response to this effect's activation.
--]==]
--Silver Saint - Orphee of Lyra, Envoy of the Pope
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Cannot be Normal Summoned/Set
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_SUMMON)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	local e0b=e0:Clone()
	e0b:SetCode(EFFECT_CANNOT_MSET)
	c:RegisterEffect(e0b)

	--Special Summon from hand by controlling 2+ Envoys
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)

	--Quick: send 1 from hand or face-up field; negate all face-up opponent monsters
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.cost)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end

s.listed_series={SET_ENVOY_OF_THE_POPE,SET_SILVER_SAINT,SET_SAINT,SET_POPES_MANDATE}
s.listed_names={922100105}

function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,SET_ENVOY_OF_THE_POPE),tp,LOCATION_MZONE,0,nil)>=2
end

function s.costfilter(c)
	return (c:IsLocation(LOCATION_HAND) and c:IsAbleToGraveAsCost())
		or (c:IsLocation(LOCATION_ONFIELD) and c:IsFaceup() and c:IsAbleToGraveAsCost())
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsMonster),tp,0,LOCATION_MZONE,nil)
	if #g==0 then return end
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		tc:RegisterEffect(e2)
	end
	if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,922100105),tp,LOCATION_MZONE,0,1,nil) then
		Duel.SetChainLimitTillChainEnd(function(e,rp,tp) return not (rp==1-tp and e:IsActiveType(TYPE_MONSTER)) end)
	end
end

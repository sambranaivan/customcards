--Thanatos, God of Death
--[==[
-- ID: 922100212
-- Type: Monster / Fusion Monster
-- Level: 10
-- Attribute: DARK
-- Race: Fiend
-- ATK/DEF: 3500/2500
--
-- Archetypes:
-- (setcode 0 — not in a named ProjectIgnis archetype series)
-- Effect (EN):
-- 1 Level 8 "Specter" monster + 1 Level 8 "Renegade Saint" monster
-- Cannot be Normal Summoned/Set.
-- Must be Special Summoned from your Extra Deck (this is treated as a Fusion Summon) while you have 9 or more "Specter" monsters in your GY. (You do not use "Fusion" as an activation procedure.)
-- Once per turn (Quick Effect): You can return 1 of your banished "Specter" monsters to the GY, then target 1 card on the field; destroy it, and if you destroyed a monster, inflict 1000 damage to your opponent.
-- If this card destroys an opponent's monster by battle: Your opponent banishes 2 random cards from their hand.
-- While this card is face-up on the field, negate your opponent's card effects activated in the GY.
--]==]
--Thanatos, God of Death
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- Special Summon from Extra with 9+ Specters in GY (treated as Fusion)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(s.spcon)
	e0:SetOperation(s.spop)
	e0:SetValue(SUMMON_TYPE_FUSION)
	c:RegisterEffect(e0)
	-- Quick: return banished Specter; destroy card and burn if monster destroyed
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	-- If destroys by battle: opponent banishes 2 random from hand
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(aux.bdocon)
	e2:SetOperation(s.banop)
	c:RegisterEffect(e2)
	-- Negate opponent effects activated in GY
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,1)
	e3:SetValue(s.aclimit)
	c:RegisterEffect(e3)
end
s.listed_series={SET_SAINT}

function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,SET_SPECTER),tp,LOCATION_GRAVE,0,nil)>=9
		and Duel.IsExistingMatchingCard(s.matfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,tp)
		and Duel.IsExistingMatchingCard(s.matfilter2,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,tp)
end
function s.matfilter(c,tp)
	return c:IsSetCard(SET_SPECTER) and c:IsLevel(8) and c:IsMonster() and c:IsAbleToGraveAsCost()
end
function s.matfilter2(c,tp)
	return c:IsSetCard(SET_RENEGADE_SAINT) and c:IsLevel(8) and c:IsMonster() and c:IsAbleToGraveAsCost()
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g1=Duel.SelectMatchingCard(tp,s.matfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g2=Duel.SelectMatchingCard(tp,s.matfilter2,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,tp)
	g1:Merge(g2)
	Duel.SendtoGrave(g1,REASON_COST)
end

function s.costfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_SPECTER) and c:IsMonster() and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST+REASON_RETURN)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsDestructable() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsDestructable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,Card.IsDestructable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	local wasMonster=tc:IsType(TYPE_MONSTER)
	if Duel.Destroy(tc,REASON_EFFECT)>0 and wasMonster then
		Duel.Damage(1-tp,1000,REASON_EFFECT)
	end
end

function s.banop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
	if #g==0 then return end
	local ct=math.min(2,#g)
	local rg=g:RandomSelect(tp,ct)
	Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
end

function s.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsLocation(LOCATION_GRAVE)
end

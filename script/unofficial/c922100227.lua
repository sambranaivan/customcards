--Marine General - Io of Scylla
--[==[
-- ID: 922100227
-- Type: Monster / Effect Monster
-- Level: 7
-- Attribute: WATER
-- Race: Warrior
-- ATK/DEF: 2500/1700
--
-- Archetypes:
-- - Marine General
-- Effect (EN):
-- If you control a "Pillar" card: You can Special Summon this card from your hand to your Main Monster Zone in the same column as that "Pillar" card.
-- This card can make a second attack during each Battle Phase.
-- If "Pillar of the South Pacific" is in your field, this card gains these effects based on the number of "Marine General" monsters with different names in your GY.
-- ● 2+: This card can attack directly.
-- ● 4+: If this card attacks, after damage calculation: Destroy all Spells/Traps your opponent controls.
-- You can only Special Summon "Marine General - Io of Scylla" once per turn this way.
--]==]
--Marine General - Io of Scylla
local s,id=GetID()
function s.initial_effect(c)
	-- Special Summon from hand if control Pillar
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_IGNITION)
	e0:SetRange(LOCATION_HAND)
	e0:SetCountLimit(1,id)
	e0:SetCondition(s.spcon)
	e0:SetTarget(s.sptg)
	e0:SetOperation(s.spop)
	c:RegisterEffect(e0)
	-- Second attack each BP
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- Direct attack if 2+ different Marine Generals in GY
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	e2:SetCondition(s.dircon)
	c:RegisterEffect(e2)
	-- If attacks and 4+ different names in GY: destroy all opponent S/T after damage calc
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DAMAGE_STEP_END)
	e3:SetCountLimit(1,id+100)
	e3:SetCondition(s.descon)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_MARINE_GENERAL, SET_SAINT}

function s.pillfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_PILLAR)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.pillfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
end

function s.diffnames(tp)
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSetCard,SET_MARINE_GENERAL),tp,LOCATION_GRAVE,0,nil)
	local seen={}
	local ct=0
	for tc in aux.Next(g) do
		local code=tc:GetCode()
		if not seen[code] then
			seen[code]=true
			ct=ct+1
		end
	end
	return ct
end
function s.dircon(e)
	return s.diffnames(e:GetHandlerPlayer())>=2
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsAttackPos() and Duel.GetAttacker()==e:GetHandler() and s.diffnames(tp)>=4
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_SZONE,1,nil) end
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_SZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_SZONE,nil)
	if #g>0 then Duel.Destroy(g,REASON_EFFECT) end
end

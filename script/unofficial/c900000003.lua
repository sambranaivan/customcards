--Goku Super Saiyan
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon when a monster is destroyed (from hand/GY/Deck if Krillin)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_HAND|LOCATION_GRAVE|LOCATION_DECK)
	e1:SetCountLimit(1)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Double ATK while Krillin is in your GY
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SET_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.atkcon)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	--Once per turn: destroy all opponent's Spells/Traps
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
	--Cannot be destroyed by battle or card effects
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e5:SetValue(1)
	c:RegisterEffect(e5)
	--Gains ATK equal to Frieza's ATK +1000 when battling Frieza - Namek Ultimate Form
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_UPDATE_ATTACK)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCondition(s.frcon)
	e6:SetValue(s.frval)
	c:RegisterEffect(e6)
	--Cannot attack directly
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	c:RegisterEffect(e7)
end
s.listed_names={900000011,900000012}
s.listed_series={0x1d0}
--Special Summon condition: a monster was destroyed
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local dominated=eg:Filter(Card.IsMonster,nil)
	if #dominated==0 then return false end
	local c=e:GetHandler()
	if c:IsLocation(LOCATION_DECK) then
		return dominated:IsExists(Card.IsCode,1,nil,900000011)
	end
	return true
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
--ATK double condition: Krillin in your GY
function s.atkcon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(s.krillinfilter,tp,LOCATION_GRAVE,0,1,nil)
end
function s.krillinfilter(c)
	return c:IsCode(900000011)
end
function s.atkval(e,c)
	return c:GetBaseAttack()*2
end
--Destroy opponent's Spells/Traps
function s.stfilter(c)
	return c:IsType(TYPE_SPELL|TYPE_TRAP)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.stfilter,tp,0,LOCATION_SZONE,1,nil) end
	local g=Duel.GetMatchingGroup(s.stfilter,tp,0,LOCATION_SZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.stfilter,tp,0,LOCATION_SZONE,nil)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end
--Frieza battle ATK boost condition
function s.frcon(e)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsCode(900000012)
end
function s.frval(e,c)
	local bc=c:GetBattleTarget()
	if bc then
		return bc:GetAttack()+1000
	end
	return 0
end

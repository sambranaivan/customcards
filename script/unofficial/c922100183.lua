--Odin, God of Asgard
--[==[
-- ID: 922100183
-- Type: Monster / Fusion Monster
-- Level: 12
-- Attribute: LIGHT
-- Race: Warrior
-- ATK/DEF: 4500/4500
--
-- Archetypes:
-- - God Warrior
-- - saint-seiya
--
-- Effect (EN):
-- 1 "God Warrior" monster
-- Cannot be Normal Summoned/Set.
-- Must be Special Summoned from your Extra Deck by sending 1 "Palace of Valhalla - Throne of Hilda" you control with 7 Odin Sapphire Counters to the GY, and banishing 1 "God Warrior" monster from your field or GY. (This is treated as a Fusion Summon.)
-- When this card declares an attack: Negate the effects of all face-up cards your opponent currently controls until the end of this turn.
-- Once per turn (Quick Effect): You can remove all Frost Counters from the field; destroy all cards that had a Frost Counter removed by this effect, and if you do, gain 1000 LP for each card destroyed.
-- If this face-up card is destroyed or banished by an opponent's card effect: You can Special Summon 1 "God Warrior - Siegfried of Dubhe" from your GY.
-- You can only control 1 "Odin, God of Asgard".
--]==]
--Odin, God of Asgard
local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	c:EnableReviveLimit()
	-- Contact Fusion Summon procedure
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(s.spcon)
	e0:SetOperation(s.spop)
	e0:SetValue(SUMMON_TYPE_FUSION)
	c:RegisterEffect(e0)
	-- Negate all face-up opponent cards when declaring attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCountLimit(1,id)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
	-- Remove Frost Counters, destroy those cards, gain LP
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+100)
	e2:SetTarget(s.dstg)
	e2:SetOperation(s.dsop)
	c:RegisterEffect(e2)
	-- If destroyed/banished by opponent effect, SS Siegfried
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(s.spcon2)
	e3:SetTarget(s.sptg2)
	e3:SetOperation(s.spop2)
	c:RegisterEffect(e3)
	local e3b=e3:Clone()
	e3b:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e3b)
end
s.listed_series={SET_GOD_WARRIOR, SET_SAINT}

function s.fzfilter(c,tp)
	return c:IsFaceup() and c:IsCode(922100172) and c:GetCounter(0x10f9)>=7 and c:IsControler(tp)
end
function s.banfilter(c)
	return c:IsSetCard(SET_GOD_WARRIOR) and c:IsMonster() and c:IsAbleToRemoveAsCost()
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.fzfilter,tp,LOCATION_FZONE,0,1,nil,tp)
		and Duel.IsExistingMatchingCard(s.banfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local fz=Duel.SelectMatchingCard(tp,s.fzfilter,tp,LOCATION_FZONE,0,1,1,nil,tp):GetFirst()
	if not fz then return end
	Duel.SendtoGrave(fz,REASON_COST)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local rg=Duel.SelectMatchingCard(tp,s.banfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
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
end

function s.frzfilter(c)
	return c:GetCounter(0x10f8)>0
end
function s.dstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCounter(tp,LOCATION_ONFIELD,LOCATION_ONFIELD,0x10f8)>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,0,PLAYER_ALL,LOCATION_ONFIELD)
end
function s.dsop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.frzfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	local ct=Duel.GetCounter(tp,LOCATION_ONFIELD,LOCATION_ONFIELD,0x10f8)
	if ct>0 then
		Duel.RemoveCounter(tp,LOCATION_ONFIELD,LOCATION_ONFIELD,0x10f8,ct,REASON_EFFECT)
	end
	if #g>0 then
		local destroyed=Duel.Destroy(g,REASON_EFFECT)
		if destroyed>0 then
			Duel.Recover(tp,1000*destroyed,REASON_EFFECT)
		end
	end
end

function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_EFFECT)) and c:GetReasonPlayer()~=tp
end
function s.spfilter2(c,e,tp)
	return c:IsCode(922100173) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

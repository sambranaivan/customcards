--Seiya of Pegasus - Bearer of the Odin Robe
--[==[
-- ID: 922100184
-- Type: Monster / Effect Monster
-- Level: 12
-- Attribute: LIGHT
-- Race: Warrior
-- ATK/DEF: 4000/3000
--
-- Archetypes:
-- - saint
-- - God Warrior
-- Effect (EN):
-- (This card is always treated as a "Saint" card.)
-- Cannot be Normal Summoned/Set.
-- Must be Special Summoned (from your hand or GY) by removing 7 Odin Sapphire Counters from your field.
-- When this card declares an attack: You can remove all Frost Counters from the field; this card gains 500 ATK for each counter removed, until the end of the Damage Step.
-- If this card destroys an opponent's monster by battle: Destroy all Spells/Traps your opponent controls.
-- If this face-up card would be destroyed or banished by an opponent's card effect: You can Special Summon 1 "God Warrior - Siegfried of Dubhe" from your GY, and if you do, this card is not destroyed or banished.
-- You can only Special Summon "Seiya of Pegasus - Bearer of the Odin Robe" once per turn this way.
-- You can only use each effect of "Seiya of Pegasus - Bearer of the Odin Robe" once per turn.
--]==]
--Seiya of Pegasus - Bearer of the Odin Robe
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- Special Summon procedure by removing 7 Odin Sapphire Counters
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e0:SetCondition(s.spcon)
	e0:SetOperation(s.spop)
	c:RegisterEffect(e0)
	-- Remove Frost Counters on attack, gain ATK
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCountLimit(1,id)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	-- Destroy all opponent S/T if destroys by battle
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+100)
	e2:SetCondition(aux.bdocon)
	e2:SetTarget(s.dstg)
	e2:SetOperation(s.dsop)
	c:RegisterEffect(e2)
	-- Destroy replacement (approx. for destroyed by opponent effect)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetCountLimit(1,id+200)
	e3:SetTarget(s.reptg)
	e3:SetOperation(s.repop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_GOD_WARRIOR, SET_SAINT}

function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsCanRemoveCounter(tp,LOCATION_ONFIELD,0,0x10f9,7,REASON_COST)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.RemoveCounter(tp,LOCATION_ONFIELD,0,0x10f9,7,REASON_COST)
end

function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=Duel.GetCounter(tp,LOCATION_ONFIELD,LOCATION_ONFIELD,0x10f8)
	if ct<=0 then return end
	if Duel.RemoveCounter(tp,LOCATION_ONFIELD,LOCATION_ONFIELD,0x10f8,ct,REASON_EFFECT) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		c:RegisterEffect(e1)
	end
end

function s.dstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_SZONE,1,nil) end
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_SZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.dsop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_SZONE,nil)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end

function s.ssfilter(c,e,tp)
	return c:IsCode(922100173) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()~=tp
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.ssfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	end
	return Duel.SelectEffectYesNo(tp,c,96)
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.ssfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

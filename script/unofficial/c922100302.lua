--Big Bang Collapse
--[==[
-- ID: 922100302
-- Type: Monster / Effect Monster
-- Level: 11
-- Attribute: LIGHT
-- Race: Rock
-- ATK/DEF: 3000/600
--
-- Archetypes:
-- - Meta
-- Effect (EN):
-- During your opponent's Main Phase, if your opponent Normal or Special Summoned 5 or more monsters this turn (Quick Effect): You can Tribute as many monsters on the field as possible, and if you do, Special Summon this card from your hand, then Special Summon 1 "Primordial Cosmos Token" (Rock/LIGHT/Level 11/ATK ?/DEF ?) to your opponent's field, whose original ATK/DEF become the combined original ATK/DEF of the monsters Tributed by this effect.
-- You can only use this effect of "Big Bang Collapse" once per turn.
--]==]
--Big Bang Collapse
local s,id=GetID()
function s.initial_effect(c)
	-- Track summon count per player each turn
	if not s.global_check then
		s.global_check=true
		local ge=Effect.CreateEffect(c)
		ge:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge:SetCode(EVENT_SUMMON_SUCCESS)
		ge:SetOperation(s.sumreg)
		Duel.RegisterEffect(ge,0)
		local ge2=ge:Clone()
		ge2:SetCode(EVENT_SPSUMMON_SUCCESS)
		Duel.RegisterEffect(ge2,0)
	end
	-- Quick: if opponent summoned 5+ this turn, tribute as many as possible; SS self; summon token with sum ATK/DEF
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_series={SET_META, SET_SAINT}

function s.sumreg(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(ep,id,RESET_PHASE+PHASE_END,0,1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return Duel.GetTurnPlayer()~=tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and Duel.GetFlagEffect(1-tp,id)>=5
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
function s.relfilter(c)
	return c:IsOnField() and c:IsReleasable()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.relfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local sumatk=0
	local sumdef=0
	for tc in aux.Next(g) do
		sumatk=sumatk+math.max(0,tc:GetBaseAttack())
		sumdef=sumdef+math.max(0,tc:GetBaseDefense())
	end
	if #g>0 then Duel.Release(g,REASON_EFFECT) end
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=0 then return end
	-- token to opponent with summed ATK/DEF
	if not Duel.IsPlayerCanSpecialSummonMonster(1-tp,0,0,TYPES_TOKEN,sumatk,sumdef,11,RACE_ROCK,ATTRIBUTE_LIGHT,POS_FACEUP_DEFENSE) then return end
	local token=Duel.CreateToken(tp,id+2,TYPES_TOKEN,sumatk,sumdef,11,RACE_ROCK,ATTRIBUTE_LIGHT)
	if Duel.SpecialSummon(token,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)~=0 then
		-- set its base ATK/DEF (visual)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK)
		e1:SetValue(sumatk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_BASE_DEFENSE)
		e2:SetValue(sumdef)
		token:RegisterEffect(e2)
	end
end

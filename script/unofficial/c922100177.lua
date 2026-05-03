--God Warrior - Fenrir of Alioth
--[==[
-- ID: 922100177
-- Type: Monster / Effect Monster
-- Level: 7
-- Attribute: WATER
-- Race: Warrior
-- ATK/DEF: 2400/2100
--
-- Archetypes:
-- - God Warrior
-- - saint-seiya
--
-- Effect (EN):
-- If this card is Normal or Special Summoned: You can Special Summon 2 "Wolf Token" (Beast/WATER/Level 4/ATK 500/DEF 500).
-- You cannot Special Summon monsters from the Extra Deck the turn you activate this effect, except "God Warrior" monsters.
-- While you control a "Wolf Token", this card can attack directly.
-- You can only use this effect of "God Warrior - Fenrir of Alioth" once per turn.
--]==]
--God Warrior - Fenrir of Alioth
local s,id=GetID()
function s.initial_effect(c)
	-- Summon 2 Wolf Tokens
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tktg)
	e1:SetOperation(s.tkop)
	c:RegisterEffect(e1)
	local e1b=e1:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)
end
s.listed_series={SET_GOD_WARRIOR, SET_SAINT}

function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>1
			and Duel.IsPlayerCanSpecialSummonMonster(tp,0,0,TYPES_TOKEN,500,500,4,RACE_BEAST,ATTRIBUTE_WATER)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,0)
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=1 then return end
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,0,0,TYPES_TOKEN,500,500,4,RACE_BEAST,ATTRIBUTE_WATER) then return end
	for i=1,2 do
		local token=Duel.CreateToken(tp,id+1000,TYPES_TOKEN,500,500,4,RACE_BEAST,ATTRIBUTE_WATER)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
	end
	Duel.SpecialSummonComplete()
	-- Restrict Extra Deck summons
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(SET_GOD_WARRIOR)
end

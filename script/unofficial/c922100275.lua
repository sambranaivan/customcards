--Meteor of Judgment
--[==[
-- ID: 922100275
-- Type: Spell / Normal Spell
--
-- Archetypes:
-- - Meta
-- - saint-seiya
--
-- Effect (EN):
-- Tribute 1 monster your opponent controls; Special Summon 1 "Divine Meteor Token" (Rock/EARTH/Level 8/ATK 2500/DEF 2500) to your opponent's field in Defense Position. That Token cannot be Tributed, also its effects cannot be activated or applied. While that Token is on the field, neither player can activate the effects of monsters with the same Type as the Tributed monster.
-- You can only activate 1 "Meteor of Judgment" per turn.
--]==]
--Meteor of Judgment
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_META, SET_SAINT}

function s.relfilter(c)
	return c:IsFaceup() and c:IsReleasable()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.relfilter,tp,0,LOCATION_MZONE,1,nil)
			and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
			and Duel.IsPlayerCanSpecialSummonMonster(1-tp,0,0,TYPES_TOKEN,2500,2500,8,RACE_ROCK,ATTRIBUTE_EARTH,POS_FACEUP_DEFENSE)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local tg=Duel.SelectMatchingCard(tp,s.relfilter,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
	if not tg then return end
	local ttype=tg:GetOriginalType()
	Duel.Release(tg,REASON_EFFECT)
	-- summon token to opponent
	local token=Duel.CreateToken(tp,id+1,TYPES_TOKEN,2500,2500,8,RACE_ROCK,ATTRIBUTE_EARTH)
	if Duel.SpecialSummonStep(token,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE) then
		-- cannot be tributed
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UNRELEASABLE_SUM)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1)
		local e1b=e1:Clone()
		e1b:SetCode(EFFECT_UNRELEASABLE_NONSUM)
		token:RegisterEffect(e1b)
		-- cannot activate/apply effects
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_TRIGGER)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e2)
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e3)
		local e4=e3:Clone()
		e4:SetCode(EFFECT_DISABLE_EFFECT)
		token:RegisterEffect(e4)
	end
	Duel.SpecialSummonComplete()
	-- lock monster effects by type while token on field (approx.)
	local e5=Effect.CreateEffect(e:GetHandler())
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetCode(EFFECT_CANNOT_ACTIVATE)
	e5:SetTargetRange(1,1)
	e5:SetLabel(ttype)
	e5:SetCondition(function(e) return token and token:IsOnField() end)
	e5:SetValue(function(e,re,tp) return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsType(e:GetLabel()) end)
	e5:SetReset(RESET_EVENT+RESETS_STANDARD)
	Duel.RegisterEffect(e5,tp)
end

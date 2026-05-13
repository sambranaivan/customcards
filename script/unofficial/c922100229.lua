--Marine General - Kasa of Lymnades
--[==[
-- ID: 922100229
-- Type: Monster / Effect Monster
-- Level: 7
-- Attribute: WATER
-- Race: Warrior
-- ATK/DEF: 2100/1900
--
-- Archetypes:
-- - Marine General
-- Effect (EN):
-- If you control a "Pillar" card: You can Special Summon this card from your hand to your Main Monster Zone in the same column as that "Pillar" card.
-- If this card is Summoned: You can target 1 face-up monster your opponent controls; until the end of this turn, this card's name becomes that target's name, also it gains that target's original effects.
-- If "Pillar of the Antarctic Ocean" is in your field, the activation and effect of this card's previous effect cannot be negated.
-- You can only use each effect of "Marine General - Kasa of Lymnades" once per turn.
--]==]
--Marine General - Kasa of Lymnades
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
	-- On Summon: copy name/effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id+100)
	e1:SetTarget(s.cptg)
	e1:SetOperation(s.cpop)
	c:RegisterEffect(e1)
	local e1b=e1:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)
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

function s.cpfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
function s.cptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.cpfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.cpfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.cpfilter,tp,0,LOCATION_MZONE,1,1,nil)
end
function s.cpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or not c:IsFaceup() then return end
	local code=tc:GetOriginalCode()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetValue(code)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
	c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)
end

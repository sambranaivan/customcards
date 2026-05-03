--God Warrior - Thor of Phecda
--[==[
-- ID: 922100175
-- Type: Monster / Effect Monster
-- Level: 7
-- Attribute: WATER
-- Race: Warrior
-- ATK/DEF: 2900/2000
--
-- Archetypes:
-- - God Warrior
-- - saint-seiya
--
-- Effect (EN):
-- If this card attacks, your opponent cannot activate cards or effects until the end of the Damage Step.
-- At the start of the Damage Step, if this card battles: You can target 1 face-up Spell/Trap in this card's column; place 1 Frost Counter on it.
-- You can only use this effect of "God Warrior - Thor of Phecda" once per turn.
--]==]
--God Warrior - Thor of Phecda
local s,id=GetID()
function s.initial_effect(c)
	-- Opponent cannot activate when this card attacks
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetOperation(s.actop)
	c:RegisterEffect(e1)
	-- Place Frost Counter on S/T in this card's column and negate it
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.cttg)
	e2:SetOperation(s.ctop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_GOD_WARRIOR, SET_SAINT}

function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	Duel.RegisterEffect(e1,tp)
end

function s.stfilter(c,mc)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP) and mc:GetColumnGroup():IsContains(c)
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.stfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,c) end
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,s.stfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,c)
	local tc=g:GetFirst()
	if tc and tc:IsFaceup() then
		tc:AddCounter(0x10f8,1)
		-- Negate its effects until end of turn
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		tc:RegisterEffect(e2)
	end
end

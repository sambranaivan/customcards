--God Warrior - Hagen of Merak
--[==[
-- ID: 922100174
-- Type: Monster / Effect Monster
-- Level: 7
-- Attribute: WATER
-- Race: Warrior
-- ATK/DEF: 2500/2200
--
-- Archetypes:
-- - God Warrior
-- Effect (EN):
-- Once per turn: You can make this card become FIRE until the end of this turn.
-- If this card becomes FIRE: You can target up to 2 face-up monsters on the field with Frost Counters; destroy them.
-- You can only use this effect of "God Warrior - Hagen of Merak" once per turn.
--]==]
--God Warrior - Hagen of Merak
local s,id=GetID()
function s.initial_effect(c)
	-- Become FIRE, then destroy up to 2 monsters with Frost Counters
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_GOD_WARRIOR, SET_SAINT}

function s.desfilter(c)
	return c:IsFaceup() and c:GetCounter(0x10f8)>0
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,PLAYER_ALL,LOCATION_MZONE)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not c:IsFaceup() then return end
	-- change attribute to FIRE
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e1:SetValue(ATTRIBUTE_FIRE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
	-- if became FIRE, destroy
	if c:IsAttribute(ATTRIBUTE_FIRE) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,2,nil)
		if #g>0 then
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end

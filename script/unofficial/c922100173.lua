--God Warrior - Siegfried of Dubhe
--[==[
-- ID: 922100173
-- Type: Monster / Effect Monster
-- Level: 7
-- Attribute: WATER
-- Race: Warrior
-- ATK/DEF: 2800/2600
--
-- Archetypes:
-- - God Warrior
-- Effect (EN):
-- Once per turn, if this card would be destroyed by battle or card effect, it is not destroyed.
-- At the start of the Damage Step, if this card battles: You can place 1 Frost Counter on the opponent's monster.
-- While this card is in Defense Position, "Palace of Valhalla - Throne of Hilda" you control cannot be destroyed by card effects.
-- You can only use this effect of "God Warrior - Siegfried of Dubhe" once per turn.
--]==]
--God Warrior - Siegfried of Dubhe
local s,id=GetID()
function s.initial_effect(c)
	-- Indestructible once per turn
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetCountLimit(1)
	e1:SetValue(s.indct)
	c:RegisterEffect(e1)
	-- Place Frost Counter on battle start
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.cttg)
	e2:SetOperation(s.ctop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_GOD_WARRIOR, SET_SAINT}

function s.indct(e,re,r,rp)
	return (r&REASON_BATTLE+REASON_EFFECT)~=0
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	if chk==0 then return bc~=nil and bc:IsFaceup() and bc:IsRelateToBattle() end
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	if bc and bc:IsFaceup() and bc:IsRelateToBattle() then
		bc:AddCounter(0x10f8,1) -- Frost Counter
	end
end

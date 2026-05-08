--Bronze Cloth - Chameleon
--[==[
-- ID: 922100321
-- Type: Spell / Equip Spell
--
-- Archetypes:
-- - cloth
-- - Bronze Cloth
--
-- Effect (EN):
-- Equip only to a "Saint" monster.
-- The equipped monster cannot be targeted by the opponent's card effects.
-- Once per turn: You can change the battle position of the equipped monster.
-- You can only use this effect of "Bronze Cloth - Chameleon" once per turn.
-- If the equipped monster would be destroyed by a card effect: You can send this card
-- from the field to the GY instead; the equipped monster is not destroyed.
-- You can only use this effect of "Bronze Cloth - Chameleon" once per turn.
--]==]
--Bronze Cloth - Chameleon
local s,id=GetID()
function s.initial_effect(c)
	-- Equip procedure: equip to any Saint monster
	aux.AddEquipProcedure(c,0,aux.FilterBoolFunction(Card.IsSetCard,SET_SAINT))

	-- Effect 1: Equipped monster cannot be targeted by opponent's card effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)

	-- Effect 2: Once per turn – change battle position of equipped monster (HOPT)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.bpcon)
	e2:SetTarget(s.bptg)
	e2:SetOperation(s.bpop)
	c:RegisterEffect(e2)

	-- Effect 3: If equipped monster would be destroyed by card effect → send this card instead (HOPT)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.repcon)
	e3:SetValue(s.repval)
	c:RegisterEffect(e3)
end

s.listed_series={SET_SAINT,SET_CLOTH,SET_BRONZE_CLOTH}

-- Effect 2: change battle position
function s.bpcon(e)
	local ec=e:GetHandler():GetEquipTarget()
	return ec~=nil and ec:IsFaceup()
end
function s.bptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=e:GetHandler():GetEquipTarget()
	if chk==0 then return ec~=nil and ec:IsFaceup() end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,ec,1,0,0)
end
function s.bpop(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	if not ec or not ec:IsFaceup() then return end
	local newpos=ec:IsAttackPos() and POS_FACEUP_DEFENSE or POS_FACEUP_ATTACK
	Duel.ChangePosition(ec,newpos)
end

-- Effect 3: destroy replace – equip sends itself to GY
function s.repcon(e,r)
	return (r&REASON_EFFECT)~=0
end
function s.repval(e,re,r)
	Duel.SendtoGrave(Group.FromCards(e:GetHandler()),REASON_EFFECT)
	return true
end

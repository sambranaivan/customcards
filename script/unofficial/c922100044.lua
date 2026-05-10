--Bronze Cloth - Andromeda
--[==[
-- ID: 922100044
-- Type: Spell / Equip Spell
--
-- Archetypes:
-- - cloth
-- - Bronze Cloth
--
-- Effect (EN):
-- Equip only to a "Saint" monster.
-- While the equipped monster is in Defense Position, your opponent cannot declare attacks on other monsters you control, also they cannot activate the effects of monsters that were Special Summoned this turn.
-- If this card is equipped to "Saint - Shun of Andromeda", the equipped monster can attack directly.
-- When this card is sent from the field to the GY: You can add 1 "Bronze Saint" monster or 1 "Bronze Cloth" Equip Spell from your Deck to your hand.
-- You can only use 1 effect of "Bronze Cloth - Andromeda" per turn, and only once that turn.
--]==]
--Bronze Cloth - Andromeda
local s,id=GetID()
function s.initial_effect(c)
	--Activate: select target then Duel.Equip (must use aux.AddEquipProcedure)
	local e0=aux.AddEquipProcedure(c,0,aux.FilterBoolFunction(Card.IsSetCard,SET_SAINT),nil,nil,nil,nil,s.actcon)
	e0:SetDescription(aux.Stringid(id,1))

	-- When sent from field to GY: add 1 Bronze Saint or Bronze Cloth from Deck to hand (HOPT)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)

	--Equipped monster can attack directly
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_DIRECT_ATTACK)
	e3:SetValue(1)
	e3:SetCondition(s.dircon)
	c:RegisterEffect(e3)

	--DEF Position (any equipped Saint): opponent cannot attack other monsters; cannot activate effects of monsters Special Summoned this turn
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetCondition(s.defcon)
	e4:SetValue(s.atlimit)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetCode(EFFECT_CANNOT_ACTIVATE)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTargetRange(0,1)
	e5:SetCondition(s.defcon)
	e5:SetValue(s.actlimit)
	c:RegisterEffect(e5)

end

s.listed_series={SET_SAINT,SET_CLOTH,SET_BRONZE_CLOTH}
s.listed_names={922100003}

function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(function(tc)
			return tc:IsFaceup() and tc:IsSetCard(SET_SAINT) and tc:IsControler(tp)
		end,tp,LOCATION_MZONE,0,1,nil)
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_SZONE)
end
function s.thfilter(c)
	return ((c:IsSetCard(SET_BRONZE_SAINT) and c:IsMonster())
		or (c:IsSetCard(SET_BRONZE_CLOTH) and c:IsType(TYPE_EQUIP)))
		and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function s.dircon(e)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:IsCode(922100003)
end

function s.defcon(e)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:IsFaceup() and ec:IsDefensePos()
end
function s.atlimit(e,c)
	return c:IsSetCard(SET_SAINT) and c~=e:GetHandler():GetEquipTarget()
end
function s.actlimit(e,re,tp)
	local rc=re:GetHandler()
	return rc:IsLocation(LOCATION_MZONE) and rc:IsType(TYPE_MONSTER) and rc:IsSummonType(SUMMON_TYPE_SPECIAL) and rc:IsStatus(STATUS_SUMMON_TURN)
end

--Bronze Cloth - Andromeda
--[==[
-- ID: 922100044
-- Type: Spell / Equip Spell
--
-- Archetypes:
-- - cloth
-- - Bronze Cloth
-- Effect (EN):
-- Equip only to a "Saint" monster.
-- The equipped monster gains 300 ATK.
-- While the equipped monster is in Defense Position, your opponent cannot declare attacks on other monsters you control, also they cannot activate the effects of monsters that were Special Summoned this turn.
-- If this card is equipped to "Bronze Saint - Shun of Andromeda", the equipped monster can attack directly.
-- If this card is sent to the GY: You can add 1 Level 4 or lower "Bronze Saint" monster from your Deck to your hand.
-- You can only use 1 effect of "Bronze Cloth - Andromeda" per turn, and only once that turn.
--]==]
--Bronze Cloth - Andromeda
local s,id=GetID()
function s.initial_effect(c)
	--Activate: equip to 1 "Saint" monster
	local e0=aux.AddEquipProcedure(c,0,aux.FilterBoolFunction(Card.IsSetCard,SET_SAINT),nil,nil,nil,nil,s.actcon)
	e0:SetDescription(aux.Stringid(id,0))

	--ATK +300
	local e_atk=Effect.CreateEffect(c)
	e_atk:SetType(EFFECT_TYPE_EQUIP)
	e_atk:SetCode(EFFECT_UPDATE_ATTACK)
	e_atk:SetValue(300)
	c:RegisterEffect(e_atk)

	--While equipped monster is in DEF: opponent cannot attack other monsters; cannot activate effects of SS'd monsters this turn
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCondition(s.defcon)
	e1:SetValue(s.atlimit)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,1)
	e2:SetCondition(s.defcon)
	e2:SetValue(s.actlimit)
	c:RegisterEffect(e2)

	--If equipped to Shun: can attack directly
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_DIRECT_ATTACK)
	e3:SetCondition(s.dircon)
	e3:SetValue(1)
	c:RegisterEffect(e3)

	--If sent to GY: add 1 Level 4 or lower "Bronze Saint" monster from Deck
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,id)
	e4:SetTarget(s.gythtg)
	e4:SetOperation(s.gythop)
	c:RegisterEffect(e4)
end

s.listed_series={SET_SAINT,SET_BRONZE_SAINT,SET_CLOTH,SET_BRONZE_CLOTH}
s.listed_names={922100003}

function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(function(tc)
			return tc:IsFaceup() and tc:IsSetCard(SET_SAINT) and tc:IsControler(tp)
		end,tp,LOCATION_MZONE,0,1,nil)
end

function s.defcon(e)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:IsFaceup() and ec:IsDefensePos()
end
function s.dircon(e)
	local ec=e:GetHandler():GetEquipTarget()
	return aux.BronzeClothSaintMatch(ec,922100003) and ec:IsFaceup()
end
function s.atlimit(e,c)
	return c~=e:GetHandler():GetEquipTarget()
end
function s.actlimit(e,re,tp)
	local rc=re:GetHandler()
	return rc:IsLocation(LOCATION_MZONE) and rc:IsType(TYPE_MONSTER) and rc:IsSummonType(SUMMON_TYPE_SPECIAL) and rc:IsStatus(STATUS_SUMMON_TURN)
end

function s.gythfilter(c)
	return c:IsSetCard(SET_BRONZE_SAINT) and c:IsMonster() and c:GetLevel()>0 and c:GetLevel()<=4 and c:IsAbleToHand()
end
function s.gythtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.gythfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.gythop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.gythfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

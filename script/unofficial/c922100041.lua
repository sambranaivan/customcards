--Bronze Cloth - Pegasus
--[==[
-- ID: 922100041
-- Type: Spell / Equip Spell
--
-- Archetypes:
-- - cloth
-- - Bronze Cloth
-- Effect (EN):
-- Equip only to a "Saint" monster.
-- The equipped monster gains 500 ATK.
-- If the equipped monster attacks, your opponent cannot activate cards or effects until the end of the Damage Step.
-- If the equipped monster is "Bronze Saint - Seiya of Pegasus", it can make up to 2 attacks on monsters during each Battle Phase, also if it destroys an opponent's monster by battle: Inflict 500 damage to your opponent.
-- If this card is sent to the GY: You can add 1 Level 4 or lower "Bronze Saint" monster from your Deck to your hand.
-- You can only use 1 effect of "Bronze Cloth - Pegasus" per turn, and only once that turn.
--]==]
--Bronze Cloth - Pegasus
local s,id=GetID()
function s.initial_effect(c)
	--Activate: equip to 1 "Saint" monster
	local e0=aux.AddEquipProcedure(c,0,aux.FilterBoolFunction(Card.IsSetCard,SET_SAINT),nil,nil,nil,nil,s.actcon)
	e0:SetDescription(aux.Stringid(id,0))

	--ATK +500
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(500)
	c:RegisterEffect(e1)

	--When equipped monster attacks, opponent cannot activate cards/effects until end of Damage Step
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.atkcon)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)

	--If equipped monster is Seiya: extra attack + burn on battle destroy
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_EXTRA_ATTACK)
	e3:SetCondition(s.exacond)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,{id,1})
	e4:SetCondition(s.damcon)
	e4:SetTarget(s.damtg)
	e4:SetOperation(s.damop)
	c:RegisterEffect(e4)

	--If sent to GY: add 1 Level 4 or lower "Bronze Saint" monster from Deck
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetCountLimit(1,{id,2})
	e5:SetTarget(s.gythtg)
	e5:SetOperation(s.gythop)
	c:RegisterEffect(e5)
end

s.listed_series={SET_SAINT,SET_BRONZE_SAINT,SET_CLOTH,SET_BRONZE_CLOTH}
s.listed_names={922100000}

function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(function(tc)
			return tc:IsFaceup() and tc:IsSetCard(SET_SAINT) and tc:IsControler(tp)
		end,tp,LOCATION_MZONE,0,1,nil)
end

function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and Duel.GetAttacker()==ec
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	Duel.RegisterEffect(e1,tp)
end

function s.exacond(e)
	local ec=e:GetHandler():GetEquipTarget()
	return aux.BronzeClothSaintMatch(ec,922100000)
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return aux.BronzeClothSaintMatch(ec,922100000) and eg:IsContains(ec) and ec:IsRelateToBattle()
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Damage(1-tp,500,REASON_EFFECT)
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

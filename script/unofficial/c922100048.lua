--Bronze Cloth - Bear
--[==[
-- ID: 922100048
-- Type: Spell / Equip Spell
--
-- Archetypes:
-- - cloth
-- - Bronze Cloth
-- Effect (EN):
-- Equip only to a "Saint" monster.
-- The equipped monster gains 300 ATK.
-- If the equipped monster destroys an opponent's monster by battle: Your opponent discards 1 random card.
-- If the equipped monster is "Bronze Saint - Geki of Bear", at the start of the Damage Step, if it battles an opponent's monster with higher ATK: You can destroy that opponent's monster.
-- If this card is sent to the GY: You can add 1 Level 4 or lower "Bronze Saint" monster from your Deck to your hand.
-- You can only use 1 effect of "Bronze Cloth - Bear" per turn, and only once that turn.
--]==]
--Bronze Cloth - Bear
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

	--If equipped monster destroys by battle: opponent discards 1 random card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.discon)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)

	--If equipped monster is Geki: at start of Damage Step vs higher ATK, destroy that monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_CONFIRM)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.gekicon)
	e2:SetTarget(s.gekitg)
	e2:SetOperation(s.gekiop)
	c:RegisterEffect(e2)

	--If sent to GY: add 1 Level 4 or lower "Bronze Saint" monster from Deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,{id,2})
	e3:SetTarget(s.gythtg)
	e3:SetOperation(s.gythop)
	c:RegisterEffect(e3)
end

s.listed_series={SET_SAINT,SET_BRONZE_SAINT,SET_CLOTH,SET_BRONZE_CLOTH}
s.listed_names={922100007}

function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(function(tc)
			return tc:IsFaceup() and tc:IsSetCard(SET_SAINT) and tc:IsControler(tp)
		end,tp,LOCATION_MZONE,0,1,nil)
end

function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and eg:IsContains(ec) and ec:IsRelateToBattle()
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
	if #g==0 then return end
	local sg=g:RandomSelect(tp,1)
	Duel.SendtoGrave(sg,REASON_EFFECT+REASON_DISCARD)
end

function s.gekicon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	if not aux.BronzeClothSaintMatch(ec,922100007) then return false end
	local bc=ec:GetBattleTarget()
	return bc and bc:IsControler(1-tp) and bc:IsFaceup() and bc:IsRelateToBattle() and bc:GetAttack()>ec:GetAttack()
end
function s.gekitg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=e:GetHandler():GetEquipTarget()
	local bc=ec and ec:GetBattleTarget() or nil
	if chk==0 then return bc and bc:IsDestructable() end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0)
end
function s.gekiop(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	local bc=ec and ec:GetBattleTarget() or nil
	if bc and bc:IsRelateToBattle() then
		Duel.Destroy(bc,REASON_EFFECT)
	end
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

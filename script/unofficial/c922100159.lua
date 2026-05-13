--Fragment of Sagittarius - Right Arm
--[==[
-- ID: 922100159
-- Type: Spell / Equip Spell
--
-- Archetypes:
-- - Fragment of Sagittarius
-- Effect (EN):
-- Equip only to a "Black Saint" monster.
-- The equipped monster gains 600 ATK.
-- If the equipped monster destroys an opponent's monster by battle: Inflict 300 damage to your opponent.
-- Once per turn (Quick Effect): You can send this face-up card to the GY; destroy 1 face-up monster your opponent controls with original ATK less than or equal to the equipped monster's original ATK.
-- If this card is sent to the GY: You can add 1 "Black Saint" monster from your Deck to your hand.
-- You can only use 1 effect of "Fragment of Sagittarius - Right Arm" per turn, and only once that turn.
--]==]
--Fragment of Sagittarius - Right Arm
local s,id=GetID()
function s.initial_effect(c)
	--Activate: equip to 1 "Black Saint" monster you control
	aux.AddEquipProcedure(c,0,aux.FilterBoolFunction(Card.IsSetCard,SET_BLACK_SAINT),s.eqlimit,nil,nil,nil,s.actcon)

	--ATK +600
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(600)
	c:RegisterEffect(e2)

	--If equipped monster destroys by battle: inflict 300
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,{id,198})
	e3:SetCondition(s.damcon)
	e3:SetTarget(s.damtg)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)

	--Quick: send this; destroy 1 face-up monster with ATK <= equipped ATK
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_SZONE)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e4:SetCountLimit(1,{id,199})
	e4:SetCost(s.cost)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)

	--If sent to GY: add 1 "Black Saint" monster from Deck
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetCountLimit(1,{id,199})
	e5:SetTarget(s.gythtg)
	e5:SetOperation(s.gythop)
	c:RegisterEffect(e5)
end

function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(function(tc)
			return tc:IsFaceup() and tc:IsSetCard(SET_BLACK_SAINT) and tc:IsControler(tp)
		end,tp,LOCATION_MZONE,0,1,nil)
end

s.listed_series={SET_FRAGMENT_OF_SAGITTARIUS,SET_BLACK_SAINT}

function s.gythfilter(c)
	return c:IsSetCard(SET_BLACK_SAINT) and c:IsMonster() and c:IsAbleToHand()
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

function s.eqlimit(e,c)
	return c:IsSetCard(SET_BLACK_SAINT)
end

function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	local bc=Duel.GetAttacker()
	return ec~=nil and bc==ec and bc:IsRelateToBattle()
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(300)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,300)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.desfilter(c,atk)
	return c:IsFaceup() and c:IsMonster() and c:IsDestructable() and c:GetBaseAttack()<=atk
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ec=e:GetHandler():GetEquipTarget()
	if not ec then return end
	local atk=ec:GetBaseAttack()
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.desfilter(chkc,atk) end
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,0,LOCATION_MZONE,1,nil,atk) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	Duel.SelectTarget(tp,s.desfilter,tp,0,LOCATION_MZONE,1,1,nil,atk)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

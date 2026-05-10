--Bronze Cloth - Hydra
--[==[
-- ID: 922100047
-- Type: Spell / Equip Spell
--
-- Archetypes:
-- - cloth
-- - Bronze Cloth
--
-- Effect (EN):
-- Equip only to a "Saint" monster.
-- If an opponent's monster battles the equipped monster, after damage calculation: That opponent's monster loses 1000 ATK/DEF.
-- If the equipped monster is "Saint - Ichi of Hydra", and it attacks directly, your opponent cannot activate effects in the GY until the end of this turn.
-- When this card is sent from the field to the GY: You can add 1 "Bronze Saint" monster or 1 "Bronze Cloth" Equip Spell from your Deck to your hand.
-- You can only use 1 effect of "Bronze Cloth - Hydra" per turn, and only once that turn.
--]==]
--Bronze Cloth - Hydra
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

	--After damage calculation if battles equipped: opponent loses 1000 ATK/DEF
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DAMAGE_STEP_END)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.debcon)
	e3:SetOperation(s.debop)
	c:RegisterEffect(e3)

	--If equipped monster is Ichi and it attacks directly: opponent cannot activate GY effects this turn
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,{id,2})
	e4:SetCondition(s.gylockcon)
	e4:SetOperation(s.gylockop)
	c:RegisterEffect(e4)

end

s.listed_series={SET_SAINT,SET_CLOTH,SET_BRONZE_CLOTH}
s.listed_names={922100006}

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

function s.debcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	if not ec then return false end
	local bc=ec:GetBattleTarget()
	return bc and bc:IsControler(1-tp) and bc:IsRelateToBattle()
end
function s.debop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if not ec then return end
	local bc=ec:GetBattleTarget()
	if not bc or not bc:IsRelateToBattle() or not bc:IsFaceup() then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(-1000)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	bc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	bc:RegisterEffect(e2)
end

function s.gylockcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:IsCode(922100006) and Duel.GetAttacker()==ec and Duel.GetAttackTarget()==nil
end
function s.gylockop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetValue(function(_,re2) return re2:GetHandler():IsLocation(LOCATION_GRAVE) end)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

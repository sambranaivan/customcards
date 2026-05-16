--Bronze Cloth - Dragon
--[==[
-- ID: 922100042
-- Type: Spell / Equip Spell
--
-- Archetypes:
-- - cloth
-- - Bronze Cloth
-- Effect (EN):
-- Equip only to a "Saint" monster.
-- The equipped monster gains 300 ATK and 1000 DEF.
-- The equipped monster cannot be destroyed by monster effects.
-- If the equipped monster is "Bronze Saint - Shiryu of Dragon", your opponent cannot target it with card effects.
-- Once per turn, if the equipped monster in Defense Position would be destroyed by battle, it is not destroyed, and if you do, you can destroy 1 card your opponent controls.
-- If this card is sent to the GY: You can add 1 Level 4 or lower "Bronze Saint" monster from your Deck to your hand.
-- You can only use 1 effect of "Bronze Cloth - Dragon" per turn, and only once that turn.
--]==]
--Bronze Cloth - Dragon
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

	--DEF +1000
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_DEFENSE)
	e1:SetValue(1000)
	c:RegisterEffect(e1)

	--Equipped monster cannot be destroyed by monster effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetValue(s.indval)
	c:RegisterEffect(e2)

	--If equipped monster is Shiryu: cannot be targeted
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCondition(s.shirycon)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)

	--Once per turn, if equipped monster in DEF would be destroyed by battle: not destroyed, then destroy 1 opponent card
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,id)
	e4:SetTarget(s.reptg)
	e4:SetOperation(s.repop)
	c:RegisterEffect(e4)

	--If sent to GY: add 1 Level 4 or lower "Bronze Saint" monster from Deck
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetCountLimit(1,{id,1})
	e5:SetTarget(s.gythtg)
	e5:SetOperation(s.gythop)
	c:RegisterEffect(e5)
end

s.listed_series={SET_SAINT,SET_BRONZE_SAINT,SET_CLOTH,SET_BRONZE_CLOTH}
s.listed_names={922100001}

function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(function(tc)
			return tc:IsFaceup() and tc:IsSetCard(SET_SAINT) and tc:IsControler(tp)
		end,tp,LOCATION_MZONE,0,1,nil)
end

function s.indval(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER)
end
function s.shirycon(e)
	local ec=e:GetHandler():GetEquipTarget()
	return aux.BronzeClothSaintMatch(ec,922100001)
end

function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if chk==0 then
		return ec and ec:IsDefensePos() and (r&REASON_BATTLE)~=0
	end
	return Duel.SelectEffectYesNo(tp,c,96)
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,Card.IsDestructable,tp,0,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
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

--Silver Cloth - Eagle
--[==[
-- ID: 922100051
-- Type: Spell / Equip Spell
--
-- Archetypes:
-- - cloth
-- - saint-seiya
-- - Silver Saint
--
-- Effect (EN):
-- Equip only to a "Silver Saint" monster.
-- The equipped monster cannot be destroyed by Trap effects.
-- If the equipped monster is "Silver Saint - Marin of Eagle", once per turn, when your opponent activates a card or effect: You can add 1 Level 4 "Saint" monster from your Deck to your hand.
--]==]
--Silver Cloth - Eagle
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	--Equip limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(s.eqlimit)
	c:RegisterEffect(e1)

	--Equipped cannot be destroyed by Trap effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetValue(s.indval)
	c:RegisterEffect(e2)

	--If equipped to Marin: when opponent activates a card/effect, add 1 Level 4 "Saint"
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end

s.listed_series={SET_CLOTH,SET_SILVER_SAINT,SET_SAINT}
s.listed_names={922100012}

function s.eqlimit(e,c)
	return c:IsSetCard(SET_SILVER_SAINT)
end
function s.indval(e,re,tp)
	return re:IsActiveType(TYPE_TRAP)
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:IsCode(922100012) and rp==1-tp
end
function s.thfilter(c)
	return c:IsSetCard(SET_SAINT) and c:IsMonster() and c:IsLevel(4) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

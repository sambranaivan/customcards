--Fragment of Sagittarius - Helmet
--[==[
-- ID: 922100155
-- Type: Spell / Equip Spell
--
-- Archetypes:
-- - Fragment of Sagittarius
-- Effect (EN):
-- Equip only to a "Black Saint" monster.
-- The equipped monster gains 300 ATK.
-- Once per turn (Quick Effect): You can send this face-up card to the GY; negate the activation of an opponent's card or effect that targets your equipped monster, and if you do, destroy that card.
-- If this card is sent to the GY: You can add 1 "Black Saint" monster from your Deck to your hand.
-- You can only use 1 effect of "Fragment of Sagittarius - Helmet" per turn, and only once that turn.
--]==]
--Fragment of Sagittarius - Helmet
local s,id=GetID()
function s.initial_effect(c)
	--Activate: equip to 1 "Black Saint" monster you control
	aux.AddEquipProcedure(c,0,aux.FilterBoolFunction(Card.IsSetCard,SET_BLACK_SAINT),s.eqlimit,nil,nil,nil,s.actcon)

	--ATK +300
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(300)
	c:RegisterEffect(e2)

	--Quick: send this; negate targeting effect on equipped monster, then destroy
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,{id,199})
	e3:SetCondition(s.negcon)
	e3:SetCost(s.cost)
	e3:SetTarget(s.negtg)
	e3:SetOperation(s.negop)
	c:RegisterEffect(e3)

	--If sent to GY: add 1 "Black Saint" monster from Deck
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,{id,199})
	e4:SetTarget(s.gythtg)
	e4:SetOperation(s.gythop)
	c:RegisterEffect(e4)
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
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if not (ec and ec:IsFaceup()) then return false end
	if rp==tp or not Duel.IsChainNegatable(ev) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsContains(ec)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev)~=0 then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end

--Fragment of Sagittarius - Left Arm
--[==[
-- ID: 922100158
-- Type: Spell / Equip Spell
--
-- Archetypes:
-- - Fragment of Sagittarius
-- Effect (EN):
-- Equip only to a "Black Saint" monster.
-- The equipped monster gains 400 ATK.
-- Once per turn (Quick Effect): You can send this face-up card to the GY, then target 1 card in your opponent's Spell & Trap Zone; return that target to the hand.
-- If this card is sent to the GY: You can add 1 "Black Saint" monster from your Deck to your hand.
-- You can only use 1 effect of "Fragment of Sagittarius - Left Arm" per turn, and only once that turn.
--]==]
--Fragment of Sagittarius - Left Arm
local s,id=GetID()
function s.initial_effect(c)
	--Activate: equip to 1 "Black Saint" monster you control
	aux.AddEquipProcedure(c,0,aux.FilterBoolFunction(Card.IsSetCard,SET_BLACK_SAINT),s.eqlimit,nil,nil,nil,s.actcon)

	--ATK +400
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(400)
	c:RegisterEffect(e2)

	--Quick: send this; bounce 1 card in opponent S/T zone
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e3:SetCountLimit(1,{id,199})
	e3:SetCost(s.cost)
	e3:SetTarget(s.rttg)
	e3:SetOperation(s.rtop)
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

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.stfilter(c)
	return c:IsAbleToHand()
end
function s.rttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_SZONE) and s.stfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.stfilter,tp,0,LOCATION_SZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	Duel.SelectTarget(tp,s.stfilter,tp,0,LOCATION_SZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,0)
end
function s.rtop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end

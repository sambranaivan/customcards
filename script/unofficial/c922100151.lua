--Black Saint - Dark Dragon
--[==[
-- ID: 922100151
-- Type: Monster / Effect Monster
-- Level: 4
-- Attribute: DARK
-- Race: Warrior
-- ATK/DEF: 1600/1700
--
-- Archetypes:
-- - saint
-- - Black Saint
-- Effect (EN):
-- If this card is Normal or Special Summoned: You can equip 1 "Fragment of Sagittarius" Equip Spell from your Deck to this card, but send it to the GY during the End Phase.
-- Once per turn (Quick Effect): You can send 1 Equip Card equipped to this card to the GY; this card cannot be destroyed by battle or card effects this turn.
-- If this card is sent to the GY: You can add 1 "Fragment of Sagittarius" card from your GY to your hand.
-- You can only use each effect of "Black Saint - Dark Dragon" once per turn.
--]==]
--Black Saint - Dark Dragon
local s,id=GetID()
function s.initial_effect(c)
	--On summon: equip 1 Fragment from Deck; send it to GY during End Phase
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
	local e1b=e1:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)

	--Quick: send 1 Equip equipped to this; indestructible this turn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.indcon)
	e2:SetCost(s.indcost)
	e2:SetOperation(s.indop)
	c:RegisterEffect(e2)

	--If sent to GY: add 1 Fragment from GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,{id,2})
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end

s.listed_series={SET_BLACK_SAINT,SET_FRAGMENT_OF_SAGITTARIUS,SET_SAINT}

function s.fragdeckequip(c,ec)
	if not ec or not ec:IsFaceup() then return false end
	return c:IsSetCard(SET_FRAGMENT_OF_SAGITTARIUS) and c:IsEquipSpell() and not c:IsForbidden()
		and c:CheckEquipTarget(ec)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.fragdeckequip,tp,LOCATION_DECK,0,1,nil,c) end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_DECK)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or not c:IsFaceup() or not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectMatchingCard(tp,s.fragdeckequip,tp,LOCATION_DECK,0,1,1,nil,c)
	local tc=g:GetFirst()
	if tc and Duel.Equip(tp,tc,c,true) then
		aux.DelayedOperation(tc,PHASE_END,id,e,tp,function(ag)
			if #ag>0 then Duel.SendtoGrave(ag,REASON_EFFECT) end
		end,nil,0)
	end
end

function s.indcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipGroup():IsExists(s.indcostfilter,1,nil)
end
function s.indcostfilter(c)
	return c:IsType(TYPE_EQUIP) and c:IsAbleToGraveAsCost()
end
function s.indcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetEquipGroup():IsExists(s.indcostfilter,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=c:GetEquipGroup():FilterSelect(tp,s.indcostfilter,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.indop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsFaceup() then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2)
end

function s.fraggy(c)
	return c:IsSetCard(SET_FRAGMENT_OF_SAGITTARIUS) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.fraggy),tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.fraggy),tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

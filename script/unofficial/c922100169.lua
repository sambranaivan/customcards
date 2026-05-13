--Guilty, Master of Hell
--[==[
-- ID: 922100169
-- Type: Monster / Effect Monster
-- Level: 5
-- Attribute: DARK
-- Race: Warrior
-- ATK/DEF: 2100/1500
--
-- Archetypes:
-- (setcode 0 — not in a named ProjectIgnis archetype series)
-- Effect (EN):
-- If you control a "Black Saint" monster, you can Special Summon this card (from your hand).
-- If this card is Normal or Special Summoned: You can send 1 "Fragment of Sagittarius" card
-- from your Deck to the GY.
-- Once per turn (Quick Effect): You can send 1 "Fragment of Sagittarius" Equip Spell you
-- control to the GY; negate the activation of an opponent's monster effect.
-- If this face-up card is destroyed by battle or by your opponent's card effect: You can
-- Special Summon 1 "Black Saint - Ikki, Leader of Death Queen Island" from your hand or GY,
-- then you can equip 1 "Fragment of Sagittarius" Equip Spell from your GY to it.
-- You can only use each effect of "Guilty, Master of Hell" once per turn.
--]==]
--Guilty, Master of Hell
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon from hand if you control a Black Saint
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e0:SetType(EFFECT_TYPE_IGNITION)
	e0:SetRange(LOCATION_HAND)
	e0:SetCountLimit(1,id)
	e0:SetCondition(s.sphandcon)
	e0:SetTarget(s.sphandtg)
	e0:SetOperation(s.sphandop)
	c:RegisterEffect(e0)

	--On summon: send 1 Fragment from Deck to GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,{id,1})
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	local e1b=e1:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)

	--Quick: send 1 Fragment Equip you control; negate opponent monster effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,2})
	e2:SetCondition(s.negcon)
	e2:SetCost(s.cost)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)

	--If destroyed (battle or opponent effect): SS Ikki, then optionally equip 1 Fragment from GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,{id,3})
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end

s.listed_series={SET_FRAGMENT_OF_SAGITTARIUS,SET_BLACK_SAINT}
s.listed_names={922100148}

function s.sphandcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_BLACK_SAINT),tp,LOCATION_MZONE,0,1,nil)
end
function s.sphandtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.sphandop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.fragdeck(c)
	return c:IsSetCard(SET_FRAGMENT_OF_SAGITTARIUS) and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.fragdeck,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.fragdeck,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then Duel.SendtoGrave(g,REASON_EFFECT) end
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
function s.costfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EQUIP) and c:IsSetCard(SET_FRAGMENT_OF_SAGITTARIUS) and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_SZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_SZONE,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateActivation(ev)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and ((r&REASON_BATTLE)~=0 or rp==1-tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(Card.IsCode),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,922100148) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.fraggy(c)
	return c:IsSetCard(SET_FRAGMENT_OF_SAGITTARIUS) and c:IsType(TYPE_EQUIP) and c:IsAbleToChangeControler()
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(Card.IsCode),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,922100148)
	local tc=g:GetFirst()
	if not tc then return end
	if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.fraggy),tp,LOCATION_GRAVE,0,1,nil)
			and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
			local eg2=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.fraggy),tp,LOCATION_GRAVE,0,1,1,nil)
			local ec=eg2:GetFirst()
			if ec then Duel.Equip(tp,ec,tc) end
		end
	end
end

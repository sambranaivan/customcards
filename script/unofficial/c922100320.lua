--Bronze Saint - June of Chameleon
--[==[
-- ID: 922100320
-- Type: Monster / Effect Monster
-- Level: 4
-- Attribute: LIGHT
-- Race: Warrior
-- ATK/DEF: 1300/1600
--
-- Archetypes:
-- - Bronze Saint
-- - saint
-- - saint-seiya
--
-- Effect (EN):
-- When this card is Normal or Special Summoned: You can add 1 "Bronze Cloth - Chameleon"
-- from your Deck or GY to your hand.
-- You can only use this effect of "Bronze Saint - June of Chameleon" once per turn.
-- If this card is equipped with a "Cloth" Equip Spell: This card cannot be targeted by
-- the opponent's card effects.
-- Once per turn: You can target 1 "Bronze Saint" monster you control, other than this card,
-- that is equipped with an Equip Spell; until the End Phase, your opponent cannot target
-- that monster with card effects.
-- You can only use this effect of "Bronze Saint - June of Chameleon" once per turn.
--]==]
--Bronze Saint - June of Chameleon
local s,id=GetID()
function s.initial_effect(c)
	-- Effect 1: On summon → search Bronze Cloth - Chameleon from Deck or GY (HOPT)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e1b=e1:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)

	-- Effect 2: Passive – cannot be targeted while equipped with a Cloth
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCondition(s.cloakcon)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)

	-- Effect 3: Active – grant targeting immunity to an equipped Bronze Saint (HOPT)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.cktg)
	e3:SetOperation(s.ckop)
	c:RegisterEffect(e3)
end

s.listed_series={SET_SAINT,SET_BRONZE_SAINT,SET_CLOTH,SET_BRONZE_CLOTH}
s.listed_names={922100321}

-- Effect 1: search Bronze Cloth - Chameleon
function s.thfilter(c)
	return c:IsCode(922100321) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

-- Effect 2: passive camouflage condition
function s.cloakcon(e)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup()
		and c:GetEquipGroup():IsExists(Card.IsSetCard,1,nil,SET_CLOTH)
end

-- Effect 3: grant targeting immunity to an ally Bronze Saint
function s.ckfilter(c,e)
	local ec=e:GetHandler()
	return c~=ec and c:IsFaceup() and c:IsSetCard(SET_BRONZE_SAINT)
		and c:GetEquipGroup():GetCount()>0
end
function s.cktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.ckfilter(chkc,e)
	end
	if chk==0 then return Duel.IsExistingTarget(s.ckfilter,tp,LOCATION_MZONE,0,1,nil,e) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.ckfilter,tp,LOCATION_MZONE,0,1,1,nil,e)
end
function s.ckop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or not tc:IsFaceup() then return end
	local ef=Effect.CreateEffect(e:GetHandler())
	ef:SetType(EFFECT_TYPE_SINGLE)
	ef:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	ef:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	ef:SetValue(aux.tgoval)
	ef:SetReset(RESET_PHASE+PHASE_END)
	tc:RegisterEffect(ef)
end

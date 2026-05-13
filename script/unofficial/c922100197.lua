--Specter - Lune of Balrog
--[==[
-- ID: 922100197
-- Type: Monster / Effect Monster
-- Level: 4
-- Attribute: DARK
-- Race: Zombie
-- ATK/DEF: 1600/1000
--
-- Archetypes:
-- - Specter
-- Effect (EN):
-- If you have 1 or more "Specter" monsters in your GY: You can Special Summon this card from your hand.
-- If this card is Normal or Special Summoned: You can add 1 "Hades" Spell/Trap from your Deck to your hand.
-- You can only use each effect of "Specter - Lune of Balrog" once per turn.
--]==]
--Specter - Lune of Balrog
local s,id=GetID()
function s.initial_effect(c)
	-- Special Summon self from hand if Specter in GY
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_HAND)
	e0:SetCondition(s.spcon)
	c:RegisterEffect(e0)
	-- On Summon: add Hades S/T
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e1b=e1:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)
end
s.listed_series={SET_SPECTER, SET_SAINT}

function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_SPECTER),tp,LOCATION_GRAVE,0,1,nil)
end
function s.thfilter(c)
	return c:IsSetCard(SET_HADES) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
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

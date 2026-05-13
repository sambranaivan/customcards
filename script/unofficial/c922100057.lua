--Silver Cloth - Whale
--[==[
-- ID: 922100057
-- Type: Spell / Equip Spell
--
-- Archetypes:
-- - cloth
-- - Silver Cloth
-- Effect (EN):
-- Equip only to a "Silver Saint" monster.
-- If a card(s) would be returned from the field to the hand by your "Silver Saint" monster effect, you can send 1 "Cloth" card from your hand to the GY; return it to the Deck instead.
-- If this card is equipped to "Silver Saint - Whale Moses", once per turn, if a monster(s) is returned to the hand: Inflict 500 damage to your opponent.
--]==]
--Silver Cloth - Whale
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

	--Replacement-ish: if cards returned to hand by your "Silver Saint" monster effect, you can send 1 "Cloth" from hand; return them to Deck instead
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.repcon)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)

	--If equipped to Moses: once per turn, if a monster is returned to the hand, inflict 500
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_HAND)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.damcon)
	e3:SetTarget(s.damtg)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
end

s.listed_series={SET_CLOTH,SET_SILVER_CLOTH,SET_SAINT}
s.listed_names={922100018}

function s.eqlimit(e,c)
	return c:IsSetCard(SET_SILVER_SAINT)
end

function s.repcon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local ec=e:GetHandler():GetEquipTarget()
	return ec~=nil and re:GetHandler():IsSetCard(SET_SILVER_SAINT) and re:GetHandlerPlayer()==tp and (r&REASON_EFFECT)~=0
		and eg:IsExists(function(c) return c:IsPreviousLocation(LOCATION_ONFIELD) end,1,nil)
end
function s.handclothfilter(c)
	return c:IsSetCard(SET_CLOTH) and c:IsDiscardable()
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(s.handclothfilter,tp,LOCATION_HAND,0,1,nil) then return end
	if not Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local cg=Duel.SelectMatchingCard(tp,s.handclothfilter,tp,LOCATION_HAND,0,1,1,nil)
	if #cg==0 then return end
	Duel.SendtoGrave(cg,REASON_COST+REASON_DISCARD)
	--Send returned cards back to Deck (approximation of replacement)
	local g=eg:Filter(function(c) return c:IsLocation(LOCATION_HAND) and c:IsControler(tp) end,nil)
	if #g>0 then
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end

function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:IsCode(922100018) and eg:IsExists(Card.IsMonster,1,nil)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Damage(1-tp,500,REASON_EFFECT)
end

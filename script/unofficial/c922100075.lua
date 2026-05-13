--Gold Cloth - Gemini
--[==[
-- ID: 922100075
-- Type: Spell / Equip Spell
--
-- Archetypes:
-- - cloth
-- - Gold Cloth
-- Effect (EN):
-- Equip only to a "Gold Saint" monster.
-- The equipped monster gains 800 ATK.
-- Once per turn, when a card or effect is activated that would affect the equipped monster: You can negate that effect.
--]==]
--Gold Cloth - Gemini
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

	--ATK +800
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(800)
	c:RegisterEffect(e2)

	--Once per turn: negate an effect that would affect the equipped monster
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.negcon)
	e3:SetOperation(s.negop)
	c:RegisterEffect(e3)
end

s.listed_series={SET_CLOTH,SET_GOLD_CLOTH,SET_GOLD_SAINT,SET_SAINT}
function s.eqlimit(e,c)
	return c:IsSetCard(SET_GOLD_SAINT)
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	if not (ec and ec:IsFaceup()) then return false end
	if rp==tp then return false end
	if not Duel.IsChainDisablable(ev) then return false end
	if re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then
		local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
		return g and g:IsContains(ec)
	end
	return re:GetHandler()==ec
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateActivation(ev)
end

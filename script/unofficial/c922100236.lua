--Scale - Lymnades
--[==[
-- ID: 922100236
-- Type: Spell / Equip Spell
--
-- Archetypes:
-- - saint-seiya
--
-- Effect (EN):
-- Equip only to a "Marine General" monster.
-- Once per turn: You can reveal 1 random card in your opponent's hand.
-- If the equipped monster is "Marine General - Kasa of Lymnades", this card gains this effect.
-- ● Once per turn (Quick Effect): You can send this face-up Equip Card to the GY; this turn, 1 activated effect your opponent controls that targets a "Marine General" monster you control becomes "Your opponent discards 1 random card".
--]==]
--Scale - Lymnades
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c,nil,s.eqfilter)
	-- Reveal 1 random card in opponent hand
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetOperation(s.repop)
	c:RegisterEffect(e1)
	-- If equipped to Kasa, change targeting effects into discard random (approx.)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id+100)
	e2:SetCondition(s.chcon)
	e2:SetOperation(s.chop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_SAINT}

function s.eqfilter(c)
	return c:IsSetCard(SET_MARINE_GENERAL)
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
	if #g==0 then return end
	local sg=g:RandomSelect(tp,1)
	Duel.ConfirmCards(tp,sg)
	Duel.ShuffleHand(1-tp)
end
function s.chcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if not ec or not ec:IsCode(922100229) then return false end
	return rp~=tp and re:IsActivated() and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)
end
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeChainOperation(ev,s.disop)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
	if #g==0 then return end
	local sg=g:RandomSelect(tp,1)
	Duel.SendtoGrave(sg,REASON_EFFECT+REASON_DISCARD)
end

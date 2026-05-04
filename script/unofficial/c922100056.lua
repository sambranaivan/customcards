--Silver Cloth - Hound
--[==[
-- ID: 922100056
-- Type: Spell / Equip Spell
--
-- Archetypes:
-- - cloth
-- - Silver Cloth
--
-- Effect (EN):
-- Equip only to a "Silver Saint" monster.
-- Once per turn: You can reveal 1 random card in your opponent's hand.
-- If this card is equipped to "Silver Saint - Hound Asterion", you can apply this effect after revealing a card by this card's effect.
-- ● Draw 1 card, then discard 1 card.
--]==]
--Silver Cloth - Hound
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

	--Reveal 1 random card in opponent's hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.revcon)
	e2:SetOperation(s.revop)
	c:RegisterEffect(e2)
end

s.listed_series={SET_CLOTH,SET_SILVER_CLOTH,SET_SAINT}
s.listed_names={922100017}

function s.eqlimit(e,c)
	return c:IsSetCard(SET_SILVER_SAINT)
end

function s.revcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipTarget()~=nil and Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0
end
function s.revop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	local hg=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if not ec or #hg==0 then return end
	local rc=hg:RandomSelect(tp,1):GetFirst()
	if not rc then return end
	Duel.ConfirmCards(tp,rc)
	Duel.ConfirmCards(1-tp,rc)
	Duel.ShuffleHand(1-tp)
	--Asterion bonus: draw 1 then discard 1
	if ec:IsCode(922100017) then
		if Duel.IsPlayerCanDraw(tp,1) and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) then
			Duel.Draw(tp,1,REASON_EFFECT)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
			local g=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,nil)
			if #g>0 then
				Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
			end
		end
	end
end

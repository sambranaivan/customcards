--Odin's Decree of Silence
--[==[
-- ID: 922100189
-- Type: Spell / Quick-Play Spell
--
-- Archetypes:
-- - God Warrior
-- - saint-seiya
--
-- Effect (EN):
-- When your opponent activates a monster effect in the hand or GY in response to the activation of your "God Warrior" card or effect: Negate that effect.
-- Then, if you control "Palace of Valhalla - Throne of Hilda", you can place 1 Frost Counter on 1 face-up monster your opponent controls.
-- You can only activate 1 "Odin's Decree of Silence" per turn.
--]==]
--Odin's Decree of Silence
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.negcon)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_GOD_WARRIOR, SET_SAINT}

function s.prev_gw_chain(tp,ct)
	local te,tep=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	if not te then return false end
	local tc=te:GetHandler()
	return tep==tp and tc and tc:IsSetCard(SET_GOD_WARRIOR)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp then return false end
	local loc=re:GetHandler():GetLocation()
	if not re:IsActiveType(TYPE_MONSTER) then return false end
	if loc~=LOCATION_HAND and loc~=LOCATION_GRAVE then return false end
	if Duel.GetCurrentChain()<2 then return false end
	-- opponent effect is responding to your previous chain link
	return s.prev_gw_chain(tp,ev-1) and Duel.IsChainNegatable(ev)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,Group.FromCards(re:GetHandler()),1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev)~=0 then
		if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,922100172),tp,LOCATION_FZONE,0,1,nil)
			and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
			local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
			local tc=g:GetFirst()
			if tc then
				tc:AddCounter(0x10f8,1)
			end
		end
	end
end

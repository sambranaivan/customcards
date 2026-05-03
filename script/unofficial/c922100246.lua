--Thetys of Mermaid (Tech Handtrap)
--[==[
-- ID: 922100246
-- Type: Monster / Effect Monster
-- Level: 3
-- Attribute: WATER
-- Race: Aqua
-- ATK/DEF: 1000/1000
--
-- Archetypes:
-- - saint-seiya
--
-- Effect (EN):
-- If your opponent activates a card or effect in a column where you control no cards (Quick Effect): You can discard this card; negate that effect, and if you do, move 1 monster your opponent controls to another of their Main Monster Zones.
-- You can only use this effect of "Thetys of Mermaid" once per turn.
--]==]
--Thetys of Mermaid (Tech Handtrap)
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.negcon)
	e1:SetCost(s.cost)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_SAINT}

function s.col_empty(tp,rc)
	-- approximate: if you control no cards that share rc column
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,0,nil)
	for tc in aux.Next(g) do
		if tc:GetColumnGroup():IsContains(rc) then return false end
	end
	return true
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp then return false end
	local rc=re:GetHandler()
	return rc and Duel.IsChainNegatable(ev) and s.col_empty(tp,rc)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev)==0 then return end
	-- move 1 opponent monster to another zone
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tc=g:Select(tp,1,1,nil):GetFirst()
	if not tc then return end
	for nseq=0,4 do
		if nseq~=tc:GetSequence() and Duel.CheckLocation(1-tp,LOCATION_MZONE,nseq) then
			Duel.MoveSequence(tc,nseq)
			break
		end
	end
end

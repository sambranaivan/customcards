--Pillar Resonance Network
--[==[
-- ID: 922100265
-- Type: Spell / Normal Spell
--
-- Archetypes:
-- - Pillar
-- Effect (EN):
-- Target 1 "Pillar" card you control; place 1 "Pillar" card with a different name from your Deck face-up in your Spell & Trap Zone in an adjacent column.
-- If you control 3 or more "Pillar" cards with different names, you can draw 1 card.
-- You can only activate 1 "Pillar Resonance Network" per turn.
--]==]
--Pillar Resonance Network
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_LEAVE_GRAVE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
s.listed_series={SET_PILLAR, SET_SAINT}

function s.pillface(c)
	return c:IsFaceup() and c:IsSetCard(SET_PILLAR)
end
function s.pilldeck(c)
	return c:IsSetCard(SET_PILLAR) and c:IsSSetable()
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_SZONE) and s.pillface(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.pillface,tp,LOCATION_SZONE,0,1,nil) and Duel.IsExistingMatchingCard(s.pilldeck,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.pillface,tp,LOCATION_SZONE,0,1,1,nil)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local seq=tc:GetSequence()
	local adj={}
	if seq>0 then table.insert(adj,seq-1) end
	if seq<4 then table.insert(adj,seq+1) end
	local nseq=nil
	for _,s2 in ipairs(adj) do
		if Duel.CheckLocation(tp,LOCATION_SZONE,s2) then nseq=s2 break end
	end
	if not nseq then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,s.pilldeck,tp,LOCATION_DECK,0,1,1,nil)
	local pc=g:GetFirst()
	if pc then
		Duel.MoveToField(pc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		Duel.MoveSequence(pc,nseq)
	end
	-- draw if 3+ pillars
	local seen={}
	local ct=0
	local pg=Duel.GetMatchingGroup(s.pillface,tp,LOCATION_SZONE,0,nil)
	for pcc in aux.Next(pg) do
		local code=pcc:GetCode()
		if not seen[code] then seen[code]=true ct=ct+1 end
	end
	if ct>=3 then Duel.Draw(tp,1,REASON_EFFECT) end
end

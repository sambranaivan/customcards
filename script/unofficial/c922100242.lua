--Pillar of the Arctic Ocean
--[==[
-- ID: 922100242
-- Type: Spell / Continuous Spell
--
-- Archetypes:
-- - Pillar
-- Effect (EN):
-- When this card is activated: You can add 1 "Marine General" monster or 1 "Scale" card from your Deck to your hand.
-- At the end of the Damage Step, if a monster battled in this card's column: Change that monster to Defense Position.
-- You can only control 1 "Pillar of the Arctic Ocean".
-- You can only activate 1 "Pillar of the Arctic Ocean" per turn.
--]==]
--Pillar of the Arctic Ocean
local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	-- Activate search
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- End of Damage Step: if monster battled in this column, change it to DEF
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_PILLAR, SET_SAINT}

function s.thfilter(c)
	return (c:IsSetCard(SET_MARINE_GENERAL) and c:IsMonster() or (c:IsCode(922100230,922100231,922100232,922100233,922100234,922100235,922100236)))
		and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then Duel.SendtoHand(g,nil,REASON_EFFECT) Duel.ConfirmCards(1-tp,g) end
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	local c=e:GetHandler()
	if a and c:GetColumnGroup():IsContains(a) and a:IsFaceup() then
		Duel.ChangePosition(a,POS_FACEUP_DEFENSE)
	end
	if d and c:GetColumnGroup():IsContains(d) and d:IsFaceup() then
		Duel.ChangePosition(d,POS_FACEUP_DEFENSE)
	end
end

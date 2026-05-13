--Athena's Sanctuary - Reforged (Field Spell)
--[==[
-- ID: 922100080
-- Type: Spell / Field Spell
--
-- Archetypes:
-- (setcode 0 — not in a named ProjectIgnis archetype series)
-- Effect (EN):
-- All "Saint" monsters on the field gain 300 ATK/DEF.
-- You can only use each of the following effects of "Athena's Sanctuary - Reforged" once per turn.
-- ● When this card is activated: You can add 1 Level 4 or lower "Saint" monster from your Deck to your hand.
-- ● If a "Saint" monster you control would be destroyed by battle or card effect, you can send 1 "Cloth" card equipped to it to the GY instead.
-- ● If 1 or more "Cloth" cards were sent to your GY this turn: You can apply this effect; during the Standby Phase of your next turn, add 1 of those cards from your GY to your hand.
--]==]
--Athena's Sanctuary - Reforged (Field Spell)
local s,id=GetID()
function s.initial_effect(c)
	--Activate + search
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e0:SetOperation(s.actop)
	c:RegisterEffect(e0)

	--ATK/DEF +300 for all "Saint" monsters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_SAINT))
	e1:SetValue(300)
	c:RegisterEffect(e1)
	local e1b=e1:Clone()
	e1b:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1b)

	--Destruction replacement (once per turn)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.reptg)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)

	--Track "Cloth" sent to GY this turn
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetOperation(s.gyop)
	c:RegisterEffect(e3)

	--Next turn Standby: add 1 of those "Cloth" cards
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,{id,2})
	e4:SetCondition(s.thcon)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end

s.listed_series={SET_SAINT,SET_CLOTH}

function s.thfilter(c)
	return c:IsSetCard(SET_SAINT) and c:IsLevelBelow(4) and c:IsAbleToHand()
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end

function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(SET_SAINT) and c:IsControler(tp)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:GetEquipGroup():IsExists(Card.IsSetCard,1,nil,SET_CLOTH)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp) end
	return Duel.SelectYesNo(tp,aux.Stringid(id,2))
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
	local g=eg:Filter(s.repfilter,nil,tp)
	local tc=g:Select(tp,1,1,nil):GetFirst()
	if not tc then return end
	local eqg=tc:GetEquipGroup():Filter(Card.IsSetCard,nil,SET_CLOTH)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sg=eqg:Select(tp,1,1,nil)
	Duel.SendtoGrave(sg,REASON_EFFECT+REASON_REPLACE)
end

function s.gyfilter(c)
	return c:IsSetCard(SET_CLOTH)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=eg:Filter(s.gyfilter,nil)
	if #g==0 then return end
	local og=c:GetLabelObject()
	if not og then
		og=Group.CreateGroup()
		og:KeepAlive()
		c:SetLabelObject(og)
	end
	for tc in aux.Next(g) do
		og:AddCard(tc)
	end
	c:RegisterFlagEffect(id,RESET_PHASE+PHASE_END,0,1)
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and e:GetHandler():GetFlagEffect(id)~=0
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetHandler():GetLabelObject()
	if chk==0 then return g and g:IsExists(Card.IsAbleToHand,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetLabelObject()
	if not g then return end
	local sg=g:Filter(Card.IsAbleToHand,nil)
	if #sg==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tg=sg:Select(tp,1,1,nil)
	local tc=tg:GetFirst()
	if tc then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,Group.FromCards(tc))
	end
	c:ResetFlagEffect(id)
	g:Clear()
end

--Judgment of Lune's Scale
--[==[
-- ID: 922100222
-- Type: Trap / Normal Trap
--
-- Archetypes:
-- - saint-seiya
--
-- Effect (EN):
-- If you have 5 or more "Specter" monsters in your GY, when your opponent activates a monster effect: Declare 1 card type (Monster, Spell, or Trap); your opponent sends 1 card of that type from their Deck to the GY, or else negate that activation, and if you do, destroy that card.
-- You can only activate 1 "Judgment of Lune's Scale" per turn.
--]==]
--Judgment of Lune's Scale
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_SAINT}

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp then return false end
	return Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,SET_SPECTER),tp,LOCATION_GRAVE,0,nil)>=5
		and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
function s.deckfilter(c,typ)
	return c:IsType(typ) and c:IsAbleToGrave()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- Declare type
	local typ=Duel.AnnounceType(tp)
	local dtype=TYPE_MONSTER
	if typ==1 then dtype=TYPE_MONSTER
	elseif typ==2 then dtype=TYPE_SPELL
	else dtype=TYPE_TRAP end
	-- Opponent sends 1 of that type or we negate+destroy
	local g=Duel.GetMatchingGroup(s.deckfilter,1-tp,LOCATION_DECK,0,nil,dtype)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)
		local sg=g:Select(1-tp,1,1,nil)
		Duel.SendtoGrave(sg,REASON_EFFECT)
	else
		if Duel.NegateActivation(ev)~=0 then
			local rc=re:GetHandler()
			if rc:IsRelateToEffect(re) then
				Duel.Destroy(rc,REASON_EFFECT)
			end
		end
	end
end

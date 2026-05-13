--The Stolen Gold Cloth
--[==[
-- ID: 922100164
-- Type: Spell / Normal Spell
--
-- Archetypes:
-- (setcode 0 — not in a named ProjectIgnis archetype series)
-- Effect (EN):
-- Send 1 "Fragment of Sagittarius" card from your Deck to the GY, then target 1 "Black Saint" monster you control; equip 1 "Fragment of Sagittarius" Equip Spell from your GY to that target.
-- If you control "Black Saint - Ikki, Leader of Death Queen Island", you can send up to 2 "Fragment of Sagittarius" cards with different names from your Deck to the GY instead.
-- You can only activate 1 "The Stolen Gold Cloth" per turn.
--]==]
--The Stolen Gold Cloth
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

s.listed_series={SET_BLACK_SAINT,SET_FRAGMENT_OF_SAGITTARIUS}
s.listed_names={922100148}

function s.fragdeck(c)
	return c:IsSetCard(SET_FRAGMENT_OF_SAGITTARIUS) and c:IsAbleToGrave()
end
function s.bsfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_BLACK_SAINT)
end
function s.fraggy(c)
	return c:IsSetCard(SET_FRAGMENT_OF_SAGITTARIUS) and c:IsType(TYPE_EQUIP) and c:IsAbleToChangeControler()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.bsfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.bsfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.fragdeck,tp,LOCATION_DECK,0,1,nil)
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.fraggy),tp,LOCATION_GRAVE,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.bsfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not (tc and tc:IsRelateToEffect(e) and tc:IsFaceup()) then return end
	local ct=1
	if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,922100148),tp,LOCATION_MZONE,0,1,nil) then
		ct=2
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.fragdeck,tp,LOCATION_DECK,0,1,ct,nil)
	if #g>0 then
		-- if 2 chosen, enforce different names (best-effort: let player choose; if duplicates, only send 1)
		if #g==2 and g:GetFirst():GetCode()==g:GetNext():GetCode() then
			g=g:Select(tp,1,1,nil)
		end
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local eg2=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.fraggy),tp,LOCATION_GRAVE,0,1,1,nil)
	local ec=eg2:GetFirst()
	if ec then Duel.Equip(tp,ec,tc) end
end

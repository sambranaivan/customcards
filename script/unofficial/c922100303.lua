--Bronze Cloth Awakening
--[==[
-- ID: 922100303
-- Type: Spell / Quick-Play Spell
--
-- Archetypes:
-- - saint-seiya
-- - saint
-- - Bronze Saint
-- - cloth
-- - Bronze Cloth
--
-- Effect (EN):
-- Equip up to 2 "Bronze Cloth" Equip Spells with different names from your Deck to 1 "Bronze Saint" monster you control.
-- You cannot Special Summon from the Extra Deck the turn you activate this card, except "Saint" monsters.
-- You can only activate 1 "Bronze Cloth Awakening" per turn.
--]==]
--Bronze Cloth Awakening
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

s.listed_series={SET_SAINT,SET_BRONZE_SAINT,SET_CLOTH,SET_BRONZE_CLOTH}

function s.clothfilter(c)
	return c:IsSetCard(SET_BRONZE_CLOTH) and c:IsType(TYPE_EQUIP) and not c:IsForbidden()
end
function s.cloth2filter(c,code1)
	return c:IsSetCard(SET_BRONZE_CLOTH) and c:IsType(TYPE_EQUIP)
		and not c:IsForbidden() and c:GetCode()~=code1
end
function s.saintfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_BRONZE_SAINT)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.saintfilter(chkc) end
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.clothfilter,tp,LOCATION_DECK,0,1,nil)
			and Duel.IsExistingTarget(s.saintfilter,tp,LOCATION_MZONE,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.saintfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		if Duel.IsExistingMatchingCard(s.clothfilter,tp,LOCATION_DECK,0,1,nil)
			and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
			local g1=Duel.SelectMatchingCard(tp,s.clothfilter,tp,LOCATION_DECK,0,1,1,nil)
			local c1=g1:GetFirst()
			if c1 then
				local code1=c1:GetCode()
				if tc:IsFaceup() then Duel.Equip(tp,c1,tc,true) end
				if tc:IsFaceup() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
					and Duel.IsExistingMatchingCard(s.cloth2filter,tp,LOCATION_DECK,0,1,nil,code1) then
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
					local g2=Duel.SelectMatchingCard(tp,s.cloth2filter,tp,LOCATION_DECK,0,1,1,nil,code1)
					local c2=g2:GetFirst()
					if c2 and tc:IsFaceup() then Duel.Equip(tp,c2,tc,true) end
				end
			end
		end
	end
	local elock=Effect.CreateEffect(e:GetHandler())
	elock:SetType(EFFECT_TYPE_FIELD)
	elock:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	elock:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	elock:SetTargetRange(1,0)
	elock:SetTarget(s.splimit)
	elock:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(elock,tp)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(SET_SAINT)
end

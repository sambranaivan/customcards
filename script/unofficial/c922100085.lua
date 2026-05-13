--Golden Inheritance (Normal Spell)
--[==[
-- ID: 922100085
-- Type: Spell / Normal Spell
--
-- Archetypes:
-- (setcode 0 — not in a named ProjectIgnis archetype series)
-- Effect (EN):
-- Target 1 "Silver Saint" monster you control; equip 1 "Gold Cloth" Equip Spell from your Deck or GY to that target.
-- Immediately after this effect resolves, Special Summon 1 Rank 8 "Gold Saint" Xyz Monster from your Extra Deck, by using that target as material. (This is treated as an Xyz Summon. Transfer its materials to the Summoned monster.)
-- Also, for the rest of this turn after this card resolves, you cannot Special Summon from the Extra Deck, except "Saint" monsters.
-- If this card is in your GY: You can banish this card, then target 1 "Gold Saint" Xyz Monster you control; attach 1 "Cloth" card from your GY to it as material.
-- You can only use this GY effect of "Golden Inheritance" once per turn.
--]==]
--Golden Inheritance (Normal Spell)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	--GY: banish; attach 1 "Cloth" from GY to Gold Saint Xyz
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_LEAVE_GRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.atchtg)
	e2:SetOperation(s.atchop)
	c:RegisterEffect(e2)
end

s.listed_series={SET_SAINT,SET_SILVER_SAINT,SET_GOLD_SAINT,SET_CLOTH,SET_GOLD_CLOTH}

function s.silverfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_SILVER_SAINT)
end
function s.goldclothfilter(c)
	return c:IsType(TYPE_EQUIP) and c:IsSetCard(SET_GOLD_CLOTH) and c:IsAbleToChangeControler()
end
function s.xyzfilter(c,e,tp,mc)
	return c:IsSetCard(SET_GOLD_SAINT) and c:IsType(TYPE_XYZ) and c:IsRank(8)
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
		and mc:IsCanBeXyzMaterial(c,tp)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.silverfilter(chkc) end
	if chk==0 then
		return Duel.IsExistingTarget(s.silverfilter,tp,LOCATION_MZONE,0,1,nil)
			and (Duel.IsExistingMatchingCard(s.goldclothfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil)
				or Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,Duel.GetFirstTarget()))
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.silverfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not (tc and tc:IsRelateToEffect(e) and tc:IsFaceup()) then return end

	--Equip 1 Gold Cloth from Deck/GY
	if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingMatchingCard(s.goldclothfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local g=Duel.SelectMatchingCard(tp,s.goldclothfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
		local ec=g:GetFirst()
		if ec and Duel.Equip(tp,ec,tc) then
			-- leave as-is; equip limit handled in equip script
		end
	end

	--Xyz Summon Rank 8 Gold Saint using that target as material
	if Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,tc) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc)
		local xc=g:GetFirst()
		if xc then
			local mg=tc:GetOverlayGroup()
			if #mg>0 then
				Duel.Overlay(xc,mg)
			end
			Duel.Overlay(xc,Group.FromCards(tc))
			Duel.SpecialSummon(xc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
			xc:CompleteProcedure()
		end
	end

	--ED lock except "Saint"
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e4:SetTargetRange(1,0)
	e4:SetTarget(s.splimit)
	e4:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e4,tp)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(SET_SAINT)
end

function s.goldxyzfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(SET_GOLD_SAINT)
end
function s.clothgyfilter(c)
	return c:IsSetCard(SET_CLOTH) and c:IsAbleToRemove()
end
function s.atchtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.goldxyzfilter(chkc) end
	if chk==0 then
		return Duel.IsExistingTarget(s.goldxyzfilter,tp,LOCATION_MZONE,0,1,nil)
			and Duel.IsExistingMatchingCard(s.clothgyfilter,tp,LOCATION_GRAVE,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.goldxyzfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.atchop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not (tc and tc:IsRelateToEffect(e) and tc:IsFaceup()) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=Duel.SelectMatchingCard(tp,s.clothgyfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	local oc=g:GetFirst()
	if oc then
		Duel.Overlay(tc,Group.FromCards(oc))
	end
end

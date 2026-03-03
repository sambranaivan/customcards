--Instant Transmission
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x1d0}

function s.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	if #g<1 then return end
	local max=math.min(#g,3)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sg=g:Select(tp,1,max,nil)
	Duel.SendtoHand(sg,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,sg)
	local hg=sg:Filter(Card.IsLocation,nil,LOCATION_HAND)
	if #hg<1 then return end
	local opc=nil
	local bc=nil
	local gc=nil
	if #hg==1 then
		opc=hg:GetFirst()
	elseif #hg==2 then
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CONFIRM)
		local osg=hg:Select(1-tp,1,1,nil)
		opc=osg:GetFirst()
		hg:RemoveCard(opc)
		local rem=hg:GetFirst()
		local opt=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
		if opt==0 then
			Duel.Remove(rem,POS_FACEUP,REASON_EFFECT)
		else
			Duel.SendtoGrave(rem,REASON_EFFECT)
		end
		bc=rem
	else
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CONFIRM)
		local osg=hg:Select(1-tp,1,1,nil)
		opc=osg:GetFirst()
		hg:RemoveCard(opc)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local bsg=hg:Select(tp,1,1,nil)
		bc=bsg:GetFirst()
		hg:RemoveCard(bc)
		gc=hg:GetFirst()
		Duel.Remove(bc,POS_FACEUP,REASON_EFFECT)
		Duel.SendtoGrave(gc,REASON_EFFECT)
	end
	if not opc:IsLocation(LOCATION_HAND) then return end
	if Duel.SpecialSummon(opc,0,tp,tp,true,true,POS_FACEUP)<=0 then return end
	local ne1=Effect.CreateEffect(e:GetHandler())
	ne1:SetType(EFFECT_TYPE_SINGLE)
	ne1:SetCode(EFFECT_DISABLE)
	ne1:SetReset(RESET_EVENT+RESETS_STANDARD)
	opc:RegisterEffect(ne1)
	local ne2=Effect.CreateEffect(e:GetHandler())
	ne2:SetType(EFFECT_TYPE_SINGLE)
	ne2:SetCode(EFFECT_DISABLE_EFFECT)
	ne2:SetReset(RESET_EVENT+RESETS_STANDARD)
	opc:RegisterEffect(ne2)
	local base=opc:GetBaseAttack()
	if base>0 then
		local ae=Effect.CreateEffect(e:GetHandler())
		ae:SetType(EFFECT_TYPE_SINGLE)
		ae:SetCode(EFFECT_SET_ATTACK)
		ae:SetValue(math.floor(base/2))
		ae:SetReset(RESET_EVENT+RESETS_STANDARD)
		opc:RegisterEffect(ae)
	end
	local other_cards={}
	if bc then table.insert(other_cards,bc) end
	if gc then table.insert(other_cards,gc) end
	if #other_cards>0 then
		s.reg_swap(e:GetHandler(),opc,other_cards,tp)
	end
end

function s.reg_swap(source,goku,others,tp)
	local se=Effect.CreateEffect(source)
	se:SetDescription(aux.Stringid(id,1))
	se:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	se:SetType(EFFECT_TYPE_QUICK_O)
	se:SetCode(EVENT_FREE_CHAIN)
	se:SetRange(LOCATION_MZONE)
	se:SetCountLimit(1)
	se:SetCondition(function(e2)
		local c=e2:GetHandler()
		local ph=Duel.GetCurrentPhase()
		return c:IsFaceup() and c:IsSetCard(0x1d0) and c:IsLevelAbove(7)
			and ph>=PHASE_BATTLE_START and ph<=PHASE_DAMAGE_CAL
	end)
	se:SetTarget(function(e2,tp2,eg2,ep2,ev2,re2,r2,rp2,chk)
		if chk==0 then
			if Duel.GetLocationCount(tp2,LOCATION_MZONE)<=0 then return false end
			for _,oc in ipairs(others) do
				if (oc:IsLocation(LOCATION_REMOVED) or oc:IsLocation(LOCATION_GRAVE))
					and oc:IsCanBeSpecialSummoned(e2,0,tp2,true,true) then
					return true
				end
			end
			return false
		end
		Duel.SetOperationInfo(0,CATEGORY_TODECK,e2:GetHandler(),1,0,0)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
	end)
	se:SetOperation(function(e2,tp2,eg2,ep2,ev2,re2,r2,rp2)
		local c=e2:GetHandler()
		if not c:IsFaceup() or not c:IsRelateToEffect(e2) then return end
		local ag=Group.CreateGroup()
		for _,oc in ipairs(others) do
			if (oc:IsLocation(LOCATION_REMOVED) or oc:IsLocation(LOCATION_GRAVE))
				and oc:IsCanBeSpecialSummoned(e2,0,tp2,true,true) then
				ag:AddCard(oc)
			end
		end
		if #ag==0 then return end
		Duel.Hint(HINT_SELECTMSG,tp2,HINTMSG_SPSUMMON)
		local tg=ag:Select(tp2,1,1,nil)
		local tc=tg:GetFirst()
		local goku_code=c:GetCode()
		Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		if Duel.GetLocationCount(tp2,LOCATION_MZONE)>0
			and Duel.SpecialSummon(tc,0,tp2,tp2,true,true,POS_FACEUP)>0 then
			Duel.SkipPhase(tp2,PHASE_BATTLE_STEP,RESET_PHASE+PHASE_END,1)
			s.reg_cleanup(tc,tp2,goku_code)
		end
	end)
	se:SetReset(RESET_EVENT+RESETS_STANDARD)
	goku:RegisterEffect(se)
end

function s.reg_cleanup(tc,tp,goku_code)
	local ce=Effect.CreateEffect(tc)
	ce:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ce:SetCode(EVENT_PHASE+PHASE_END)
	ce:SetRange(LOCATION_MZONE)
	ce:SetCountLimit(1)
	ce:SetCondition(function(e3) return e3:GetHandler():IsFaceup() end)
	ce:SetOperation(function(e3,tp3)
		local mc=e3:GetHandler()
		if Duel.SendtoGrave(mc,REASON_EFFECT)>0 then
			local gg=Duel.GetMatchingGroup(
				function(fc) return fc:IsSetCard(0x1d0) and fc:IsCode(goku_code) and fc:IsAbleToHand() end,
				tp,LOCATION_DECK,0,nil)
			if #gg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
				local asg=gg:Select(tp,1,1,nil)
				Duel.SendtoHand(asg,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,asg)
			end
		end
	end)
	ce:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(ce)
end

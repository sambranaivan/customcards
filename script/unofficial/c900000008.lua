--Kamehameha
local s,id=GetID()
function s.initial_effect(c)
	--Activation: Mode 1 (all 6 chars → destroy, can't chain) or Mode 2 (opp more monsters → send to GY, end turn)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--GY: banish to add 1 character or SS Master Roshi with doubled ATK
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,5))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.gytg)
	e2:SetOperation(s.gyop)
	c:RegisterEffect(e2)
end
s.listed_names={900000011,900000028,900000029,900000030}
s.listed_series={0x1d0,0x1d5}

--Character filters for Mode 1 field check
function s.isgoku(c) return c:IsFaceup() and c:IsSetCard(0x1d0) end
function s.isgohan(c) return c:IsFaceup() and c:IsSetCard(0x1d5) end
function s.iskrillin(c) return c:IsFaceup() and c:IsCode(900000011) end
function s.istrunks(c) return c:IsFaceup() and c:IsCode(900000028) end
function s.isgoten(c) return c:IsFaceup() and c:IsCode(900000029) end
function s.isroshi(c) return c:IsFaceup() and c:IsCode(900000030) end

function s.mode1check(tp)
	return Duel.IsExistingMatchingCard(s.isgoku,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.isgohan,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.iskrillin,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.istrunks,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.isgoten,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.isroshi,tp,LOCATION_MZONE,0,1,nil)
end
function s.mode2check(tp)
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
		>Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
end

function s.tgfilter(c)
	return true
end

--Activation condition: at least one mode available
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return s.mode1check(tp) or s.mode2check(tp)
end

--Target: select mode and target card
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return (s.mode1check(tp) or s.mode2check(tp))
			and Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	end
	local b1=s.mode1check(tp)
	local b2=s.mode2check(tp)
	local mode=0
	if b1 and b2 then
		mode=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
	elseif b1 then
		mode=0
	else
		mode=1
	end
	e:SetLabel(mode)
	if mode==0 then
		Duel.SetChainLimit(aux.FALSE)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,0)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,0,0)
	end
end

--Operation: execute based on mode
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	if e:GetLabel()==0 then
		Duel.Destroy(tc,REASON_EFFECT)
	else
		if Duel.SendtoGrave(tc,REASON_EFFECT)>0 then
			Duel.SkipPhase(1-tp,PHASE_MAIN1,RESET_PHASE+PHASE_END,1)
			Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
			Duel.SkipPhase(1-tp,PHASE_MAIN2,RESET_PHASE+PHASE_END,1)
		end
	end
end

--GY effect: banish to add 1 character or SS Master Roshi
function s.thfilter(c)
	return (c:IsSetCard(0x1d0) or c:IsSetCard(0x1d5) or c:IsCode(900000011)
		or c:IsCode(900000028) or c:IsCode(900000029)) and c:IsAbleToHand()
end
function s.roshifilter(c,e,tp)
	return c:IsCode(900000030) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		local b2=Duel.IsExistingMatchingCard(s.roshifilter,tp,LOCATION_DECK,0,1,nil,e,tp)
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		return b1 or b2
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(s.roshifilter,tp,LOCATION_DECK,0,1,nil,e,tp)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if not b1 and not b2 then return end
	local opt=0
	if b1 and b2 then
		opt=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))
	elseif b2 then
		opt=1
	end
	if opt==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.roshifilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 then
			local tc=g:GetFirst()
			if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
				local e1=Effect.CreateEffect(tc)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetValue(tc:GetBaseAttack())
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
			end
		end
	end
end

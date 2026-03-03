--Super Saiyan Gogeta
local s,id=GetID()
local COUNTER_GENKIDAMA=0x91
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion: 1 "Goku" Lv7+ + 1+ "Vegeta" Lv7+ (Metamor or mentioning card only)
	Fusion.AddProcMixRep(c,false,false,s.fmat_veg,1,63,s.fmat_goku)
	--3-turn limit counter
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetLabel(0)
	e1:SetOperation(s.limop)
	c:RegisterEffect(e1)
	--Reset counter on summon
	local e1b=Effect.CreateEffect(c)
	e1b:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1b:SetLabelObject(e1)
	e1b:SetOperation(function(e) e:GetLabelObject():SetLabel(0) end)
	c:RegisterEffect(e1b)
	--ATK gain = |your LP - opponent's LP|
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	--Unaffected by card effects during Battle Phase
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.bpcon)
	e3:SetValue(s.immval)
	c:RegisterEffect(e3)
	--When attacks: negate all opponent's card effects until End Phase
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_DISABLE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetOperation(s.negop)
	c:RegisterEffect(e4)
end
s.listed_names={900000026,900000027}
s.listed_series={0x1d0,0x1d1,0x1d3,0x1d4}

--Fusion material filters
function s.fmat_goku(c,fc,sumtype,tp)
	return c:IsSetCard(0x1d0,fc,0,tp) and c:IsType(TYPE_MONSTER) and c:IsLevelAbove(7)
end
function s.fmat_veg(c,fc,sumtype,tp)
	return c:IsSetCard(0x1d1,fc,0,tp) and c:IsType(TYPE_MONSTER) and c:IsLevelAbove(7)
end

--ATK = |your LP - opponent's LP|
function s.atkval(e,c)
	local tp=c:GetControler()
	return math.abs(Duel.GetLP(tp)-Duel.GetLP(1-tp))
end

--Battle Phase immunity condition
function s.bpcon(e)
	local p=Duel.GetCurrentPhase()
	return p==PHASE_BATTLE_START or p==PHASE_BATTLE_STEP
		or p==PHASE_DAMAGE or p==PHASE_DAMAGE_CAL
end
function s.immval(e,te)
	return te:GetHandler()~=e:GetHandler()
end

--3-turn counter + chain on expiry
function s.gokufilter(c)
	return c:IsSetCard(0x1d0) and c:IsType(TYPE_NORMAL)
end
function s.vegetafilter(c)
	return c:IsSetCard(0x1d1) and c:IsType(TYPE_NORMAL)
end
function s.genkifilter(c)
	return c:IsCode(900000027) and c:IsAbleToHand()
end
function s.limop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsFaceup() then return end
	local ct=e:GetLabel()+1
	e:SetLabel(ct)
	if ct<3 then return end
	--3rd End Phase: send to GY
	if Duel.SendtoGrave(c,REASON_EFFECT)==0 then return end
	--SS 1 Normal "Goku" from Deck/GY/Banished
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		local g1=Duel.GetMatchingGroup(s.gokufilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
		if #g1>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg1=g1:Select(tp,1,1,nil)
			Duel.SpecialSummon(sg1,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	--SS 1 Normal "Vegeta" from Deck/GY/Banished
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		local g2=Duel.GetMatchingGroup(s.vegetafilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
		if #g2>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg2=g2:Select(tp,1,1,nil)
			Duel.SpecialSummon(sg2,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	--Add 1 "Genkidama" from Deck + optionally activate with 10 counters
	local g3=Duel.GetMatchingGroup(s.genkifilter,tp,LOCATION_DECK,0,nil)
	if #g3>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg3=g3:Select(tp,1,1,nil)
		Duel.SendtoHand(sg3,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg3)
		local tc=sg3:GetFirst()
		if tc:IsLocation(LOCATION_HAND) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			if tc:IsLocation(LOCATION_SZONE) and tc:IsFaceup() then
				Duel.AddCounter(tc,COUNTER_GENKIDAMA,10)
			end
		end
	end
end

--Negate all opponent's face-up card effects when attacking
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
	local tc=g:GetFirst()
	while tc do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end

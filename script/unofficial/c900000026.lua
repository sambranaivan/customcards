--Metamor
local s,id=GetID()
local TOKEN_GOGETA_FAIL=900000033
function s.initial_effect(c)
	--Activation (Continuous Trap)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Once per turn: random Goku + Vegeta → outcome depends on levels
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
end
s.listed_names={900000025,TOKEN_GOGETA_FAIL}
s.listed_series={0x1d0,0x1d1,0x1d3}

function s.gokufilter(c)
	return c:IsSetCard(0x1d0) and c:IsType(TYPE_MONSTER)
end
function s.vegetafilter(c)
	return c:IsSetCard(0x1d1) and c:IsType(TYPE_MONSTER)
end

function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.gokufilter,tp,LOCATION_DECK,0,1,nil)
			and Duel.IsExistingMatchingCard(s.vegetafilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end

function s.effop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local gg=Duel.GetMatchingGroup(s.gokufilter,tp,LOCATION_DECK,0,nil)
	local vg=Duel.GetMatchingGroup(s.vegetafilter,tp,LOCATION_DECK,0,nil)
	if #gg==0 or #vg==0 then return end
	local rg=gg:RandomSelect(tp,1)
	local goku=rg:GetFirst()
	local rv=vg:RandomSelect(tp,1)
	local vegeta=rv:GetFirst()
	local ag=Group.CreateGroup()
	ag:AddCard(goku)
	ag:AddCard(vegeta)
	Duel.SendtoHand(ag,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,ag)
	if not goku:IsLocation(LOCATION_HAND) or not vegeta:IsLocation(LOCATION_HAND) then return end
	local glv=goku:GetLevel()
	local vlv=vegeta:GetLevel()
	if glv<=6 and vlv<=6 then
		s.mode1(e,tp,goku,vegeta)
	elseif glv>=7 and vlv>=7 then
		s.mode3(e,tp,goku,vegeta)
	else
		s.mode2(e,tp)
	end
end

-------------------------------------------------------------------
-- Mode 1: Both Lv6 or lower → FAIL (total lockdown for 3 turns)
-------------------------------------------------------------------
function s.mode1(e,tp,goku,vegeta)
	local sg=Group.CreateGroup()
	sg:AddCard(goku)
	sg:AddCard(vegeta)
	if Duel.SendtoGrave(sg,REASON_EFFECT)==0 then return end
	for i=1,2 do
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_GOGETA_FAIL,0,TYPES_TOKEN,0,0,12,RACE_WARRIOR,ATTRIBUTE_LIGHT) then
			local token=Duel.CreateToken(tp,TOKEN_GOGETA_FAIL)
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_ATTACK)
		end
	end
	Duel.SpecialSummonComplete()
	--Tokens indestructible by battle
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.tokfilter)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END,6)
	Duel.RegisterEffect(e1,tp)
	--Tokens indestructible by effects
	local e1b=e1:Clone()
	e1b:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	Duel.RegisterEffect(e1b,tp)
	--Tokens cannot be tributed
	local e1c=e1:Clone()
	e1c:SetCode(EFFECT_UNRELEASABLE_EFFECT)
	Duel.RegisterEffect(e1c,tp)
	--No Extra Deck summons (both players)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetValue(s.splimit_extra)
	e2:SetReset(RESET_PHASE+PHASE_END,6)
	Duel.RegisterEffect(e2,tp)
	--No card activations (both players)
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,1)
	e3:SetValue(s.aclimit_all)
	e3:SetReset(RESET_PHASE+PHASE_END,6)
	Duel.RegisterEffect(e3,tp)
	--Opponent can attack directly
	local e4=Effect.CreateEffect(e:GetHandler())
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_DIRECT_ATTACK)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetReset(RESET_PHASE+PHASE_END,6)
	Duel.RegisterEffect(e4,tp)
	--You take no battle damage
	local e5=Effect.CreateEffect(e:GetHandler())
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetTargetRange(1,0)
	e5:SetValue(1)
	e5:SetReset(RESET_PHASE+PHASE_END,6)
	Duel.RegisterEffect(e5,tp)
end

function s.tokfilter(e,c)
	return c:IsCode(TOKEN_GOGETA_FAIL)
end
function s.splimit_extra(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_EXTRA)
end
function s.aclimit_all(e,re,tp)
	return true
end

-------------------------------------------------------------------
-- Mode 2: Mixed levels → partial fail (opponent locked but draws)
-------------------------------------------------------------------
function s.mode2(e,tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_GOGETA_FAIL,0,TYPES_TOKEN,0,0,12,RACE_WARRIOR,ATTRIBUTE_LIGHT) then
		local token=Duel.CreateToken(tp,TOKEN_GOGETA_FAIL)
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
	--Opponent draws 2 extra during their Standby Phase (3 total)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCondition(s.drawcon)
	e1:SetOperation(s.drawop)
	e1:SetReset(RESET_PHASE+PHASE_END,6)
	Duel.RegisterEffect(e1,tp)
	--Opponent cannot attack
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetReset(RESET_PHASE+PHASE_END,6)
	Duel.RegisterEffect(e2,tp)
	--Opponent cannot Normal Summon
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(0,1)
	e3:SetReset(RESET_PHASE+PHASE_END,6)
	Duel.RegisterEffect(e3,tp)
	--Opponent cannot Special Summon
	local e3b=Effect.CreateEffect(e:GetHandler())
	e3b:SetType(EFFECT_TYPE_FIELD)
	e3b:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3b:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3b:SetTargetRange(0,1)
	e3b:SetValue(s.splimit_all)
	e3b:SetReset(RESET_PHASE+PHASE_END,6)
	Duel.RegisterEffect(e3b,tp)
	--Opponent cannot Set
	local e3c=Effect.CreateEffect(e:GetHandler())
	e3c:SetType(EFFECT_TYPE_FIELD)
	e3c:SetCode(EFFECT_CANNOT_MSET)
	e3c:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3c:SetTargetRange(0,1)
	e3c:SetReset(RESET_PHASE+PHASE_END,6)
	Duel.RegisterEffect(e3c,tp)
	local e3d=Effect.CreateEffect(e:GetHandler())
	e3d:SetType(EFFECT_TYPE_FIELD)
	e3d:SetCode(EFFECT_CANNOT_SSET)
	e3d:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3d:SetTargetRange(0,1)
	e3d:SetReset(RESET_PHASE+PHASE_END,6)
	Duel.RegisterEffect(e3d,tp)
	--Opponent cannot activate
	local e4=Effect.CreateEffect(e:GetHandler())
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_ACTIVATE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(0,1)
	e4:SetValue(s.aclimit_all)
	e4:SetReset(RESET_PHASE+PHASE_END,6)
	Duel.RegisterEffect(e4,tp)
end

function s.splimit_all(e,c,sump,sumtype,sumpos,targetp)
	return true
end
function s.drawcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Draw(1-tp,2,REASON_EFFECT)
end

-------------------------------------------------------------------
-- Mode 3: Both Lv7+ → SUCCESS (Gogeta Fusion!)
-------------------------------------------------------------------
function s.mode3(e,tp,goku,vegeta)
	local sg=Group.CreateGroup()
	sg:AddCard(goku)
	sg:AddCard(vegeta)
	if Duel.SendtoGrave(sg,REASON_EFFECT)==0 then return end
	local fg=Duel.GetMatchingGroup(s.gogetafilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	if #fg==0 or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local fc=fg:Select(tp,1,1,nil):GetFirst()
	if Duel.SpecialSummon(fc,0,tp,tp,true,true,POS_FACEUP)<=0 then return end
	--This turn: negate all opponent's monsters + ATK to 0
	local og=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local oc=og:GetFirst()
	while oc do
		local ne1=Effect.CreateEffect(e:GetHandler())
		ne1:SetType(EFFECT_TYPE_SINGLE)
		ne1:SetCode(EFFECT_DISABLE)
		ne1:SetReset(RESETS_STANDARD_PHASE_END)
		oc:RegisterEffect(ne1)
		local ne2=Effect.CreateEffect(e:GetHandler())
		ne2:SetType(EFFECT_TYPE_SINGLE)
		ne2:SetCode(EFFECT_DISABLE_EFFECT)
		ne2:SetReset(RESETS_STANDARD_PHASE_END)
		oc:RegisterEffect(ne2)
		local ae=Effect.CreateEffect(e:GetHandler())
		ae:SetType(EFFECT_TYPE_SINGLE)
		ae:SetCode(EFFECT_SET_ATTACK_FINAL)
		ae:SetValue(0)
		ae:SetReset(RESETS_STANDARD_PHASE_END)
		oc:RegisterEffect(ae)
		oc=og:GetNext()
	end
end

function s.gogetafilter(c,e,tp)
	return c:IsCode(900000025) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end

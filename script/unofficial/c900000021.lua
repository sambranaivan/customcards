--Saiyan Supremacy
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Primary Fusion: 1 "Vegetto" Fusion Monster + 1 "Ultimate Gohan" + 1 "SS3 Gotenks"
	Fusion.AddProcMix(c,true,true,s.fmat_vegito,900000022,900000023)
	--Alt Fusion: 5 "Saiyan" monsters with different names
	Fusion.AddProcMixN(c,true,true,s.saiyanfilter,5)
	--Attack all opponent's monsters once each
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ATTACK_ALL)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Unaffected by other card effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.immval)
	c:RegisterEffect(e2)
	--If destroyed: SS 1 "Gogeta" from Extra Deck, grant all original effects
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetLabel(0)
	e3:SetCondition(s.descon)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
	--On summon: set ATK from combined materials (store value in e3's label)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetLabelObject(e3)
	e4:SetOperation(s.atkop)
	c:RegisterEffect(e4)
end
s.listed_names={900000022,900000023,900000024}
s.listed_series={0x1d0,0x1d1,0x1d2,0x1d3,0x1d4,0x1d5,0x1d6}
s.material_setcode={0x1d2,0x1d0,0x1d1,0x1d3,0x1d4,0x1d5,0x1d6}

--Fusion material: Vegetto archetype + Fusion type
function s.fmat_vegito(c,fc,sumtype,tp)
	return c:IsSetCard(0x1d2,fc,0,tp) and c:IsType(TYPE_FUSION)
end

--Alt material: any "Saiyan" monster (checks all Saiyan-related archetypes)
function s.issaiyan(c,fc,tp)
	return c:IsSetCard(0x1d0,fc,0,tp) or c:IsSetCard(0x1d1,fc,0,tp)
		or c:IsSetCard(0x1d2,fc,0,tp) or c:IsSetCard(0x1d3,fc,0,tp)
		or c:IsSetCard(0x1d4,fc,0,tp) or c:IsSetCard(0x1d5,fc,0,tp)
		or c:IsSetCard(0x1d6,fc,0,tp)
end
function s.saiyanfilter(c,fc,sumtype,tp,sub,mg,sg)
	return s.issaiyan(c,fc,tp)
		and (not sg or not sg:IsExists(s.saiyandupfilter,1,c,c:GetCode(fc,0,tp),fc,0,tp))
end
function s.saiyandupfilter(c,code,fc,sumtype,tp)
	return c:IsSummonCode(fc,0,tp,code)
end

--Immune to all other card effects
function s.immval(e,te)
	return te:GetHandler()~=e:GetHandler()
end

--On summon: set ATK = combined materials' original ATK
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local mg=c:GetMaterial()
	if not mg or #mg==0 then return end
	local totalatk=0
	local tc=mg:GetFirst()
	while tc do
		local atk=tc:GetBaseAttack()
		if atk>0 then totalatk=totalatk+atk end
		tc=mg:GetNext()
	end
	local ea=Effect.CreateEffect(c)
	ea:SetType(EFFECT_TYPE_SINGLE)
	ea:SetCode(EFFECT_SET_ATTACK)
	ea:SetValue(totalatk)
	ea:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(ea)
	e:GetLabelObject():SetLabel(totalatk)
end

--If destroyed (while on field): SS 1 "Gogeta" from Extra Deck
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_MZONE)
end
function s.gogetafilter(c,e,tp)
	return c:IsSetCard(0x1d3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.gogetafilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local atkval=e:GetLabel()
	s.gogeta_summon(e,tp,atkval)
end

--Shared summon + grant logic
function s.gogeta_summon(e,tp,atkval)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.gogetafilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #g<=0 then return end
	local tc=g:GetFirst()
	if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	s.granteffects(tc,atkval)
end

--Grant all original effects to Gogeta
function s.granteffects(tc,atkval)
	--Attack all
	local e1=Effect.CreateEffect(tc)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ATTACK_ALL)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
	--Immune to other card effects
	local e2=Effect.CreateEffect(tc)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.immval)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e2)
	--ATK
	if atkval>0 then
		local e3=Effect.CreateEffect(tc)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_SET_ATTACK)
		e3:SetValue(atkval)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3)
	end
	--If destroyed: SS another Gogeta (recursive chain)
	local e4=Effect.CreateEffect(tc)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetLabel(atkval)
	e4:SetCondition(s.descon)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	e4:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e4)
end

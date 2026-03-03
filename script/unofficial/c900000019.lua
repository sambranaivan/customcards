--Vegetto
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion: 1 "Goku" Lv7+ monster + 1+ "Vegeta" Lv7+ monster
	Fusion.AddProcMixRep(c,true,true,s.fmat_veg,1,63,s.fmat_goku)
	--Alt summon: banish Potara Earrings + materials from GY
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Cannot be destroyed by battle
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--Cannot be destroyed by card effects
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	--3-turn limit: return to Extra Deck after 3rd End Phase
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_MZONE)
	e4:SetLabel(0)
	e4:SetOperation(s.limop)
	c:RegisterEffect(e4)
	--On summon: reset turn counter + set ATK/DEF from materials
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetLabelObject(e4)
	e5:SetOperation(s.sumop)
	c:RegisterEffect(e5)
	--When leaves field: SS materials from banished
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,0))
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_LEAVE_FIELD)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetTarget(s.mattg)
	e6:SetOperation(s.matop)
	c:RegisterEffect(e6)
	--Double battle damage inflicted to opponent
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e7)
end
s.listed_names={900000017}
s.listed_series={0x1d0,0x1d1,0x1d2}

--Fusion material filters
function s.fmat_goku(c,fc,sumtype,tp)
	return c:IsSetCard(0x1d0) and c:IsType(TYPE_MONSTER) and c:IsLevelAbove(7)
end
function s.fmat_veg(c,fc,sumtype,tp)
	return c:IsSetCard(0x1d1) and c:IsType(TYPE_MONSTER) and c:IsLevelAbove(7)
end

--Alt summon: banish Potara + Goku Lv7+ + Vegeta Lv7+ from GY
function s.potfilter(c)
	return c:IsCode(900000017) and c:IsAbleToRemoveAsCost()
end
function s.gokugyf(c)
	return c:IsSetCard(0x1d0) and c:IsType(TYPE_MONSTER) and c:IsLevelAbove(7) and c:IsAbleToRemoveAsCost()
end
function s.veggyf(c)
	return c:IsSetCard(0x1d1) and c:IsType(TYPE_MONSTER) and c:IsLevelAbove(7) and c:IsAbleToRemoveAsCost()
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.IsExistingMatchingCard(s.potfilter,tp,LOCATION_GRAVE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.gokugyf,tp,LOCATION_GRAVE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.veggyf,tp,LOCATION_GRAVE,0,1,nil)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local gp=Duel.SelectMatchingCard(tp,s.potfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local gg=Duel.SelectMatchingCard(tp,s.gokugyf,tp,LOCATION_GRAVE,0,1,1,nil)
	local vegmax=Duel.GetMatchingGroupCount(s.veggyf,tp,LOCATION_GRAVE,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local gv=Duel.SelectMatchingCard(tp,s.veggyf,tp,LOCATION_GRAVE,0,1,vegmax,nil)
	local matg=gg:Clone()
	matg:Merge(gv)
	c:SetMaterial(matg)
	gp:Merge(gg)
	gp:Merge(gv)
	Duel.Remove(gp,POS_FACEUP,REASON_COST)
end

--3-turn counter
function s.limop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsFaceup() then return end
	local ct=e:GetLabel()+1
	e:SetLabel(ct)
	if ct>=3 then
		Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end

--On summon success: reset counter + set ATK/DEF
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	e:GetLabelObject():SetLabel(0)
	local mg=c:GetMaterial()
	if not mg or #mg==0 then return end
	local totalatk=0
	local totaldef=0
	local tc=mg:GetFirst()
	while tc do
		totalatk=totalatk+tc:GetBaseAttack()
		totaldef=totaldef+tc:GetBaseDefense()
		tc=mg:GetNext()
	end
	local ea=Effect.CreateEffect(c)
	ea:SetType(EFFECT_TYPE_SINGLE)
	ea:SetCode(EFFECT_SET_ATTACK)
	ea:SetValue(totalatk)
	ea:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(ea)
	local ed=Effect.CreateEffect(c)
	ed:SetType(EFFECT_TYPE_SINGLE)
	ed:SetCode(EFFECT_SET_DEFENSE)
	ed:SetValue(totaldef)
	ed:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(ed)
end

--When leaves field: SS materials from banished
function s.matspfilter(c,e,tp)
	return c:IsLocation(LOCATION_REMOVED) and c:IsFaceup()
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.mattg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		local mg=c:GetMaterial()
		return mg and #mg>0 and mg:IsExists(s.matspfilter,1,nil,e,tp)
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local mg=c:GetMaterial()
	if not mg then return end
	local sg=mg:Filter(s.matspfilter,nil,e,tp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if #sg<=0 or ft<=0 then return end
	if #sg>ft then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		sg=sg:Select(tp,ft,ft,nil)
	end
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
end

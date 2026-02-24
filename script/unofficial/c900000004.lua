--Goku Oozaru
local s,id=GetID()
function s.initial_effect(c)
	--ATK becomes 0 if Full Moon is not on the field
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.nomncon)
	e1:SetValue(0)
	c:RegisterEffect(e1)
	--DEF becomes 0 if Full Moon is not on the field
	local e1b=e1:Clone()
	e1b:SetCode(EFFECT_SET_DEFENSE)
	c:RegisterEffect(e1b)
	--If Special Summoned by Kid Goku: place Full Moon from Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.fmcon)
	e2:SetTarget(s.fmtg)
	e2:SetOperation(s.fmop)
	c:RegisterEffect(e2)
	--Gains 1000 ATK for each "Goku" or Warrior monster in your GY
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(s.atkval)
	c:RegisterEffect(e3)
	--Cannot attack directly
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	c:RegisterEffect(e4)
	--Once per turn: destroy all other cards on the field
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetTarget(s.destg)
	e5:SetOperation(s.desop)
	c:RegisterEffect(e5)
end
s.listed_names={900000001,900000005,900000006}
s.listed_series={0x1d0}
function s.moonfilter(c)
	return c:IsCode(900000005) and c:IsFaceup()
end
function s.nomncon(e)
	local tp=e:GetHandlerPlayer()
	return not Duel.IsExistingMatchingCard(s.moonfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
function s.fmcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:GetHandler():IsCode(900000001)
end
function s.fmfilter(c)
	return c:IsCode(900000005)
end
function s.fmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.fmfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.fmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,s.fmfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end
function s.gyfilter(c)
	return c:IsMonster() and (c:IsSetCard(SET_GOKU) or c:IsRace(RACE_WARRIOR))
end
function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(s.gyfilter,c:GetControler(),LOCATION_GRAVE,0,nil)*1000
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end

--Goku Kaio-ken X
local s,id=GetID()
function s.initial_effect(c)
	--Equip from hand or GY to a "Goku" Level 7+
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
	--Equip limit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(s.eqlimit)
	c:RegisterEffect(e2)
	--Double ATK while equipped
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_SET_ATTACK)
	e3:SetValue(s.atkdouble)
	c:RegisterEffect(e3)
	--Once per Duel: triple or quadruple ATK temporarily
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,id,EFFECT_COUNT_CODE_DUEL)
	e4:SetCondition(s.eqcon)
	e4:SetOperation(s.mulop)
	c:RegisterEffect(e4)
	--Once per Duel: 5x to 10x ATK, destroy at end of turn, ban copies
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_DUEL)
	e5:SetCondition(s.eqcon)
	e5:SetOperation(s.boostop)
	c:RegisterEffect(e5)
	--Normal Summon: add 1 "Kamehameha" from Deck/GY/Banished
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,3))
	e6:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_SUMMON_SUCCESS)
	e6:SetTarget(s.thtg)
	e6:SetOperation(s.thop)
	c:RegisterEffect(e6)
end
s.listed_names={900000008}
s.listed_series={0x1d0}
--Equip target filter
function s.eqfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_GOKU) and c:IsLevelAbove(7)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.eqfilter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) and c:IsRelateToEffect(e) then
		Duel.Equip(tp,c,tc)
	end
end
function s.eqlimit(e,c)
	return c:IsSetCard(SET_GOKU) and c:IsLevelAbove(7)
end
--Double ATK
function s.atkdouble(e,c)
	return c:GetBaseAttack()*2
end
--Equipped condition
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:IsFaceup()
end
--Triple or Quadruple ATK
function s.mulop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if not ec or not ec:IsFaceup() then return end
	local opt=Duel.SelectOption(tp,aux.Stringid(id,4),aux.Stringid(id,5))
	local mul=opt==0 and 3 or 4
	local curATK=ec:GetAttack()
	local bonus=curATK*(mul-1)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(bonus)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
	ec:RegisterEffect(e1)
end
--5x to 10x ATK, destroy and ban
function s.boostop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if not ec or not ec:IsFaceup() then return end
	local mul=Duel.AnnounceNumber(tp,5,6,7,8,9,10)
	local curATK=ec:GetAttack()
	local bonus=curATK*(mul-1)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(bonus)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
	ec:RegisterEffect(e1)
	--Destroy at End Phase
	local ecode=ec:GetCode()
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetLabelObject(ec)
	e2:SetCondition(s.descon2)
	e2:SetOperation(s.desop2)
	Duel.RegisterEffect(e2,tp)
	--Ban all copies of the equipped monster for the rest of the duel
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetLabel(ecode)
	e3:SetTarget(s.sumlimit)
	Duel.RegisterEffect(e3,tp)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(1,0)
	e4:SetLabel(ecode)
	e4:SetTarget(s.sumlimit)
	Duel.RegisterEffect(e4,tp)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetTargetRange(1,0)
	e5:SetLabel(ecode)
	e5:SetTarget(s.sumlimit)
	Duel.RegisterEffect(e5,tp)
end
function s.sumlimit(e,c)
	return c:IsCode(e:GetLabel())
end
function s.descon2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return tc:IsLocation(LOCATION_MZONE) and tc:IsFaceup()
end
function s.desop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsLocation(LOCATION_MZONE) and tc:IsFaceup() then
		Duel.Destroy(tc,REASON_EFFECT)
	end
	e:Reset()
end
--Search Kamehameha
function s.thfilter(c)
	return c:IsCode(900000008) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

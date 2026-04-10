-- Razor Leaf
local s,id=GetID()
function s.initial_effect(c)
	-- Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x3008} -- SET_BULBASAUR
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x3008)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.filter(c,atk)
	return c:IsFaceup() and c:GetAttack()<=atk
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
	if #g==0 then return false end
	local max_atk=0
	for tc in aux.Next(g) do
		if tc:GetAttack()>max_atk then max_atk=tc:GetAttack() end
	end
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.filter(chkc,max_atk) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil,max_atk) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local tg=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil,max_atk)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local atk=tc:GetAttack()
		local dg=Group.FromCards(tc)
		local extra=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,tc)
		local same_atk_g=Group.CreateGroup()
		for ec in aux.Next(extra) do
			if ec:GetAttack()==atk then
				same_atk_g:AddCard(ec)
			end
		end
		if #same_atk_g>0 then
			if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
				dg:Merge(same_atk_g)
			end
		end
		Duel.Destroy(dg,REASON_EFFECT)
	end
end

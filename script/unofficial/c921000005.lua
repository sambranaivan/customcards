-- Synthesis
local s,id=GetID()
function s.initial_effect(c)
	-- Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RECOVER+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
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
function s.get_power_val(c)
	local lv=c:GetLevel()
	if c:IsType(TYPE_XYZ) then lv=c:GetRank() end
	if c:IsType(TYPE_LINK) then lv=c:GetLink() end
	return lv
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
	local max_lv=0
	for tc in aux.Next(g) do
		local val=s.get_power_val(tc)
		if val>max_lv then max_lv=val end
	end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(max_lv*300)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,max_lv*300)
end
function s.thfilter(c)
	return c:IsSetCard(0x3008) and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Recover(p,d,REASON_EFFECT)>0 then
		local hg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,nil)
		if #hg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local opt=hg:Select(tp,1,1,nil)
			Duel.SendtoHand(opt,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,opt)
		end
	end
end

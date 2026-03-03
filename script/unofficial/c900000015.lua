--Dragon Fist
local s,id=GetID()
local WIN_REASON_DRAGON_FIST=0x92
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={900000014,900000032}
s.listed_series={0x1d0}

function s.gokufilter(c)
	return c:IsFaceup() and (c:IsCode(900000014) or c:IsCode(900000032))
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLP(tp)==100
			and Duel.IsExistingMatchingCard(s.gokufilter,tp,LOCATION_MZONE,0,1,nil)
			and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
	end
	Duel.SetChainLimit(aux.FALSE)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLP(tp)~=100 then return end
	local g=Duel.GetMatchingGroup(s.gokufilter,tp,LOCATION_MZONE,0,nil)
	if #g==0 then return end
	if Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local sg=g:Select(tp,1,1,nil)
	local tc=sg:GetFirst()
	tc:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,0)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetValue(0)
	e1:SetReset(RESETS_STANDARD_PHASE_END)
	tc:RegisterEffect(e1)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MUST_ATTACK)
	e2:SetReset(RESETS_STANDARD_PHASE_END)
	tc:RegisterEffect(e2)
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetValue(1)
	e3:SetReset(RESETS_STANDARD_PHASE_END)
	tc:RegisterEffect(e3)
	local e4=Effect.CreateEffect(e:GetHandler())
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e4:SetValue(1)
	e4:SetReset(RESETS_STANDARD_PHASE_END)
	tc:RegisterEffect(e4)
	local e5=Effect.CreateEffect(e:GetHandler())
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_TOGRAVE)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e5:SetCondition(s.wincon)
	e5:SetOperation(s.winop)
	e5:SetReset(RESETS_STANDARD_PHASE_END)
	tc:RegisterEffect(e5)
end

function s.wincon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetFlagEffect(id)>0 and c:GetBattleTarget()~=nil
end

function s.winop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	if bc and bc:IsRelateToBattle() then
		if Duel.SendtoGrave(bc,REASON_EFFECT)>0 then
			Duel.Win(tp,WIN_REASON_DRAGON_FIST)
		end
	end
end

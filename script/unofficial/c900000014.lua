--Super Saiyan 3 Goku
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:SetUniqueOnField(1,0,id)
	--Fusion summon: 1 "Goku" Normal Monster + 2 or more Level 6+ Warriors
	Fusion.AddProcMixRep(c,true,true,s.matfilter2,2,63,s.matfilter1)
	--Special Summon from Extra Deck by banishing GSS + GSS2
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Unaffected by Spell/Trap effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)
	--If "Dragon Fist" is activated: double ATK + 3 attacks this turn
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.dfcon)
	e3:SetOperation(s.dfop)
	c:RegisterEffect(e3)
	--If destroyed by battle or card effect: add 1 "Vegeta" monster + 1 "Potara Earrings"
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(s.thcon)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end
s.listed_names={900000002,900000003,900000013,900000015,900000017}
s.listed_series={0x1d0,0x1d1}

--Fusion material filters
function s.matfilter1(c,fc,sumtype,tp)
	return c:IsCode(900000002) and c:IsType(TYPE_NORMAL)
end
function s.matfilter2(c,fc,sumtype,tp)
	return c:IsRace(RACE_WARRIOR) and c:IsLevelAbove(6)
end

--Special Summon: banish GSS (900000003) + GSS2 (900000013) from hand/field/GY
local BANISH_LOCS=LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE
function s.spfilter1(c)
	return c:IsCode(900000003) and c:IsAbleToRemoveAsCost()
end
function s.spfilter2(c)
	return c:IsCode(900000013) and c:IsAbleToRemoveAsCost()
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.IsExistingMatchingCard(s.spfilter1,tp,BANISH_LOCS,0,1,nil)
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,BANISH_LOCS,0,1,nil)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g1=Duel.SelectMatchingCard(tp,s.spfilter1,tp,BANISH_LOCS,0,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g2=Duel.SelectMatchingCard(tp,s.spfilter2,tp,BANISH_LOCS,0,1,1,nil)
	g1:Merge(g2)
	Duel.Remove(g1,POS_FACEUP,REASON_COST)
end

--Immune to Spell/Trap effects
function s.efilter(e,te)
	return te:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end

--Dragon Fist activation trigger
function s.dfcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and re:GetHandler():IsCode(900000015)
end
function s.dfop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local atk=c:GetAttack()
		--Double ATK until End Phase
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		--Up to 3 attacks this turn (2 extra)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_EXTRA_ATTACK)
		e2:SetValue(2)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
	end
end

--Destroyed by battle or card effect: search Vegeta + Potara Earrings
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY)
end
function s.vegfilter(c)
	return c:IsSetCard(0x1d1) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.potfilter(c)
	return c:IsCode(900000017) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.vegfilter,tp,LOCATION_DECK,0,1,nil)
			and Duel.IsExistingMatchingCard(s.potfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local vg=Duel.GetMatchingGroup(s.vegfilter,tp,LOCATION_DECK,0,nil)
	local pg=Duel.GetMatchingGroup(s.potfilter,tp,LOCATION_DECK,0,nil)
	if #vg<1 or #pg<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g1=vg:Select(tp,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g2=pg:Select(tp,1,1,nil)
	g1:Merge(g2)
	Duel.SendtoHand(g1,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,g1)
end

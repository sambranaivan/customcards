--Bronze Saints - Burning Five Stars
--[==[
-- ID: 922100308
-- Type: Monster / Xyz Effect Monster
-- Rank: 4
-- Attribute: LIGHT
-- Race: Warrior
-- ATK/DEF: 2800/2400
--
-- Archetypes:
-- - Bronze Saint
-- - saint
-- - saint-seiya
--
-- Summoning Requirements:
-- 3 Level 4 "Bronze Saint" monsters
--
-- Effect (EN):
-- While this card has 3 or more Xyz Materials, it cannot be destroyed by battle or card effects,
-- and your opponent cannot target it with card effects.
-- Once per turn: You can detach 1 "Bronze Cloth" Equip Spell Xyz Material from this card;
-- this card can make 2 attacks on monsters this turn, also for each of its attacks this turn,
-- your opponent cannot activate cards or effects until the end of the Damage Step.
-- Once per turn: You can target 1 "Bronze Cloth" Equip Spell in your GY; attach it to this card as Xyz Material.
-- When this card is destroyed and sent to the GY: You can Special Summon up to 3 "Bronze Saint" monsters from your GY.
--]==]
--Bronze Saints - Burning Five Stars
local s,id=GetID()
function s.initial_effect(c)
	Xyz.AddProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,SET_BRONZE_SAINT),4,3)
	c:EnableReviveLimit()

	-- Effect 1: Indestructible + untargetable while 3+ materials
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_SINGLE)
	e1a:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1a:SetCondition(s.matcon3)
	e1a:SetValue(1)
	c:RegisterEffect(e1a)

	local e1b=Effect.CreateEffect(c)
	e1b:SetType(EFFECT_TYPE_SINGLE)
	e1b:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1b:SetCondition(s.matcon3)
	e1b:SetValue(1)
	c:RegisterEffect(e1b)

	local e1c=Effect.CreateEffect(c)
	e1c:SetType(EFFECT_TYPE_SINGLE)
	e1c:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1c:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1c:SetCondition(s.matcon3)
	e1c:SetValue(aux.tgoval)
	c:RegisterEffect(e1c)

	-- Effect 2: Detach Bronze Cloth → double attack + attack lock (HOPT)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_EXTRA_ATTACK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.furcon)
	e2:SetCost(s.furcost)
	e2:SetTarget(s.furtg)
	e2:SetOperation(s.furop)
	c:RegisterEffect(e2)

	-- Effect 3: Attach Bronze Cloth from GY as material (HOPT)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_LEAVE_GRAVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,2})
	e3:SetTarget(s.ovatg)
	e3:SetOperation(s.ovaop)
	c:RegisterEffect(e3)

	-- Effect 4: When destroyed → SP Summon Bronze Saints from GY
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCountLimit(1,{id,3})
	e4:SetCondition(s.lscon)
	e4:SetTarget(s.lstg)
	e4:SetOperation(s.lsop)
	c:RegisterEffect(e4)
end

s.listed_series={SET_SAINT,SET_BRONZE_SAINT,SET_CLOTH,SET_BRONZE_CLOTH}

-- Material count condition (3+)
function s.matcon3(e)
	return e:GetHandler():GetOverlayCount()>=3
end

-- Effect 2: Battle fury
function s.clothmatfilter(c)
	return c:IsSetCard(SET_BRONZE_CLOTH) and c:IsType(TYPE_EQUIP)
end
function s.furcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetOverlayGroup():IsExists(s.clothmatfilter,1,nil)
		and c:GetFlagEffect(id)==0
end
function s.furcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetOverlayGroup():IsExists(s.clothmatfilter,1,nil) end
	local og=c:GetOverlayGroup():Filter(s.clothmatfilter,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=og:Select(tp,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.furtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsFaceup() end
	Duel.SetOperationInfo(0,CATEGORY_EXTRA_ATTACK,nil,0,0,0)
end
function s.furop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not c:IsFaceup() then return end
	-- Grant 1 extra attack (2 total)
	local ea=Effect.CreateEffect(e:GetHandler())
	ea:SetType(EFFECT_TYPE_SINGLE)
	ea:SetCode(EFFECT_EXTRA_ATTACK)
	ea:SetValue(1)
	ea:SetReset(RESET_PHASE+PHASE_END)
	c:RegisterEffect(ea)
	-- For each attack this card makes, opponent cannot activate until end of Damage Step
	local al=Effect.CreateEffect(e:GetHandler())
	al:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	al:SetCode(EVENT_ATTACK_ANNOUNCE)
	al:SetRange(LOCATION_MZONE)
	al:SetCondition(s.atkblkcon)
	al:SetOperation(s.atkblkop)
	al:SetReset(RESET_PHASE+PHASE_END)
	c:RegisterEffect(al)
end
function s.atkblkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker()==e:GetHandler()
end
function s.atkblkop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
	Duel.RegisterEffect(e1,tp)
end

-- Effect 3: Attach Bronze Cloth from GY
function s.ovafilter(c)
	return c:IsSetCard(SET_BRONZE_CLOTH) and c:IsType(TYPE_EQUIP) and c:IsAbleToRemove()
end
function s.ovatg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.ovafilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.ovafilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	Duel.SelectTarget(tp,s.ovafilter,tp,LOCATION_GRAVE,0,1,1,nil)
end
function s.ovaop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or not c:IsFaceup() then return end
	if tc and tc:IsRelateToEffect(e) then
		Duel.Overlay(c,Group.FromCards(tc))
		c:RegisterFlagEffect(id,RESET_PHASE+PHASE_END,0,1)
	end
end

-- Effect 4: When destroyed → SP Summon Bronze Saints from GY
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_BRONZE_SAINT) and c:IsMonster()
		and not c:IsType(TYPE_XYZ)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.lscon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
end
function s.lstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	end
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,math.min(3,g:GetCount()),tp,LOCATION_GRAVE)
end
function s.lsop(e,tp,eg,ep,ev,re,r,rp)
	local n=math.min(3,Duel.GetLocationCount(tp,LOCATION_MZONE))
	if n<=0 then return end
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if g:GetCount()==0 then return end
	local n2=math.min(n,g:GetCount())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=g:Select(tp,1,n2,nil)
	for tc in aux.Next(sg) do
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

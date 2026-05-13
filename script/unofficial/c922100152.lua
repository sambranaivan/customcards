--Black Saint - Dark Cygnus
--[==[
-- ID: 922100152
-- Type: Monster / Effect Monster
-- Level: 4
-- Attribute: DARK
-- Race: Warrior
-- ATK/DEF: 1500/1300
--
-- Archetypes:
-- - saint
-- - Black Saint
-- Effect (EN):
-- If this card is Normal or Special Summoned: You can target 1 face-up monster your opponent controls; change it to Defense Position.
-- Once per turn (Quick Effect): You can send 1 "Fragment of Sagittarius" Equip Spell equipped to a monster you control to the GY, then target 1 face-up monster your opponent controls; negate its effects until the end of this turn.
-- If this card is sent to the GY as material for the Summon of a "Black Saint" monster: You can equip 1 "Fragment of Sagittarius" Equip Spell from your GY to that Summoned monster.
-- You can only use each effect of "Black Saint - Dark Cygnus" once per turn.
--]==]
--Black Saint - Dark Cygnus
local s,id=GetID()
function s.initial_effect(c)
	--On summon: change 1 opponent monster to DEF
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.postg)
	e1:SetOperation(s.posop)
	c:RegisterEffect(e1)
	local e1b=e1:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)

	--Quick: send 1 Fragment Equip equipped to a monster you control; negate 1 face-up monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.negcost)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)

	--If sent to GY as material for Summon of a Black Saint: equip 1 Fragment from GY to that monster
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.eqcon)
	e3:SetTarget(s.eqtg)
	e3:SetOperation(s.eqop)
	c:RegisterEffect(e3)
end

s.listed_series={SET_BLACK_SAINT,SET_FRAGMENT_OF_SAGITTARIUS,SET_SAINT}

function s.posfilter(c)
	return c:IsFaceup() and c:IsMonster() and c:IsCanChangePosition()
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.posfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSITION)
	Duel.SelectTarget(tp,s.posfilter,tp,0,LOCATION_MZONE,1,1,nil)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
	end
end

function s.frag_equip(c)
	return c:IsFaceup() and c:IsType(TYPE_EQUIP) and c:IsSetCard(SET_FRAGMENT_OF_SAGITTARIUS) and c:IsAbleToGraveAsCost()
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.frag_equip,tp,LOCATION_SZONE,0,nil)
	if chk==0 then return #g>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sg=g:Select(tp,1,1,nil)
	Duel.SendtoGrave(sg,REASON_COST)
end
function s.negfilter(c)
	return c:IsFaceup() and c:IsMonster()
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.negfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.negfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.negfilter,tp,0,LOCATION_MZONE,1,1,nil)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or not tc:IsFaceup() then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	tc:RegisterEffect(e2)
end

function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=e:GetHandler():GetReasonCard()
	return rc and rc:IsSetCard(SET_BLACK_SAINT)
end
function s.fraggy(c)
	return c:IsSetCard(SET_FRAGMENT_OF_SAGITTARIUS) and c:IsType(TYPE_EQUIP) and c:IsAbleToChangeControler()
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=e:GetHandler():GetReasonCard()
	if chk==0 then return rc and rc:IsFaceup() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.fraggy),tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_GRAVE)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local rc=e:GetHandler():GetReasonCard()
	if not (rc and rc:IsFaceup()) or Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.fraggy),tp,LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then Duel.Equip(tp,tc,rc) end
end

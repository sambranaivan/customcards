--Desecrated Sagittarius - Reassembled Gold Cloth
--[==[
-- ID: 922100162
-- Type: Monster / Fusion / Effect Monster
-- Level: 8
-- Attribute: DARK
-- Race: Warrior
-- ATK/DEF: 3000/2500
--
-- Archetypes:
-- - Black Saint
-- Effect (EN):
-- (This card is always treated as a "Black Saint" card.)
-- Must be Special Summoned from your Extra Deck (this is treated as a Fusion Summon) while you have 7 "Fragment of Sagittarius" cards with different names on your field and/or GY. (You do not use "Fusion" as an activation procedure.)
-- If this card is Special Summoned: You can equip up to 2 "Fragment of Sagittarius" Equip Spells from your GY to this card.
-- Gains these effects based on the number of Equip Cards equipped to it.
-- ● 1+: Cannot be destroyed by battle.
-- ● 2+: Cannot be targeted by your opponent's Spell/Trap effects.
-- ● 3+: Unaffected by your opponent's monster effects.
-- ● 5+: Once per turn (Quick Effect): You can send 1 Equip Card equipped to this card to the GY; negate the activation, and if you do, destroy that card.
-- You can only Special Summon "Desecrated Sagittarius - Reassembled Gold Cloth" once per turn this way.
--]==]
--Desecrated Sagittarius - Reassembled Gold Cloth
local s,id=GetID()

function s.initial_effect(c)
	c:EnableReviveLimit()
	--Cannot be Normal Summoned/Set
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_SUMMON)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	local e0b=e0:Clone()
	e0b:SetCode(EFFECT_CANNOT_MSET)
	c:RegisterEffect(e0b)

	--Fusion Summon from Extra Deck: 7 different Fragments on field/GY (OPT); no Fusion Spell
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	e1:SetValue(SUMMON_TYPE_FUSION)
	c:RegisterEffect(e1)

	--If Special Summoned: equip up to 2 Fragments from GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)

	--1+: indestructible by battle
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetCondition(function(e) return e:GetHandler():GetEquipCount()>=1 end)
	e3:SetValue(1)
	c:RegisterEffect(e3)

	--2+: cannot be targeted by opponent Spell/Trap effects
	local e3b=Effect.CreateEffect(c)
	e3b:SetType(EFFECT_TYPE_SINGLE)
	e3b:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3b:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3b:SetRange(LOCATION_MZONE)
	e3b:SetCondition(function(e) return e:GetHandler():GetEquipCount()>=2 end)
	e3b:SetValue(s.tgfilter)
	c:RegisterEffect(e3b)

	--3+: immune to opponent activated monster effects
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(function(e) return e:GetHandler():GetEquipCount()>=3 end)
	e4:SetValue(s.efilter)
	c:RegisterEffect(e4)

	--5+: Quick negate by sending 1 equip
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_CHAINING)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,{id,2})
	e5:SetCondition(s.negcon)
	e5:SetCost(s.negcost)
	e5:SetTarget(s.negtg)
	e5:SetOperation(s.negop)
	c:RegisterEffect(e5)
end

s.listed_series={SET_FRAGMENT_OF_SAGITTARIUS,SET_BLACK_SAINT}

function s.ctfrags(tp)
	local g=Duel.GetMatchingGroup(function(c) return c:IsSetCard(SET_FRAGMENT_OF_SAGITTARIUS) end,tp,LOCATION_MZONE+LOCATION_SZONE+LOCATION_GRAVE,0,nil)
	local seen={}
	local ct=0
	for tc in aux.Next(g) do
		local cd=tc:GetCode()
		if not seen[cd] then
			seen[cd]=true
			ct=ct+1
		end
	end
	return ct
end

function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and s.ctfrags(tp)==7
end

function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
end

function s.fraggy(c,ec)
	if not c:IsSetCard(SET_FRAGMENT_OF_SAGITTARIUS) or not c:IsType(TYPE_EQUIP) or c:IsForbidden() then return false end
	if not ec or not ec:IsFaceup() then return false end
	-- GY equips: CheckEquipTarget respects "Equip only to …" (IsAbleToChangeControler is unreliable in GY).
	return c:CheckEquipTarget(ec)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsRelateToEffect(e) and c:IsFaceup() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(function(tc) return s.fraggy(tc,c) end),tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_GRAVE)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or not c:IsFaceup() then return end
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(function(tc) return s.fraggy(tc,c) end),tp,LOCATION_GRAVE,0,1,math.min(2,ft),nil)
	for tc in aux.Next(g) do
		Duel.Equip(tp,tc,c)
	end
end

function s.tgfilter(e,re,rp)
	return rp==1-e:GetHandlerPlayer() and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
function s.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:IsActivated() and te:IsActiveType(TYPE_MONSTER)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipCount()>=5 and rp==1-tp and Duel.IsChainNegatable(ev)
end
function s.negcostfilter(c)
	return c:IsType(TYPE_EQUIP) and c:IsAbleToGraveAsCost()
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetEquipGroup():IsExists(s.negcostfilter,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=c:GetEquipGroup():FilterSelect(tp,s.negcostfilter,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev)~=0 then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end

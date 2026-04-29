--Athena's Sanctuary (Field Spell - base)
--[==[
-- ID: 922100079
-- Type: Spell / Field Spell
--
-- Archetypes:
-- - saint-seiya
--
-- Effect (EN):
-- All "Saint" monsters on the field gain 300 ATK/DEF.
-- Once per turn, if a "Saint" monster you control would be destroyed, you can send 1 "Cloth" Equip Card equipped to it to the GY instead.
--]==]
--Athena's Sanctuary (Field Spell - base)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	--ATK/DEF +300 for all "Saint" monsters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_SAINT))
	e1:SetValue(300)
	c:RegisterEffect(e1)
	local e1b=e1:Clone()
	e1b:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1b)

	--Once per turn destruction replacement
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.reptg)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
end

s.listed_series={SET_SAINT,SET_CLOTH}

function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(SET_SAINT) and c:IsControler(tp)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:GetEquipGroup():IsExists(Card.IsSetCard,1,nil,SET_CLOTH)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp) end
	if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		return true
	end
	return false
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
	local g=eg:Filter(s.repfilter,nil,tp)
	local tc=g:Select(tp,1,1,nil):GetFirst()
	if not tc then return end
	local eqg=tc:GetEquipGroup():Filter(Card.IsSetCard,nil,SET_CLOTH)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sg=eqg:Select(tp,1,1,nil)
	Duel.SendtoGrave(sg,REASON_EFFECT+REASON_REPLACE)
end

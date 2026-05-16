--Bronze Saint - Seiya of the Miracle Bonds
--[==[
-- ID: 922100303
-- Type: Monster / Fusion Monster
-- Level: 10
-- Attribute: LIGHT
-- Race: Warrior
-- ATK/DEF: 3000/2500
--
-- Archetypes:
-- - Saint
-- - Bronze Saint
-- Effect (EN):
-- 1 "Bronze Saint - Seiya of Pegasus" + 4 "Bronze Saint" monsters
-- Must first be Special Summoned (from your Extra Deck) by banishing the above cards you control and/or from your GY. (You do not use "Polymerization".)
-- You can only Special Summon "Bronze Saint - Seiya of the Miracle Bonds" once per turn this way.
-- If this card is Fusion Summoned: You can equip as many "Bronze Cloth" Equip Spells from your GY to this card as possible.
-- While this card is equipped with a "Bronze Cloth" Equip Spell, it gains that Equip Spell's effects that apply when equipped to its corresponding "Bronze Saint" monster.
--]==]
--Bronze Saint - Seiya of the Miracle Bonds
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Cannot be Normal Summoned/Set
	local e0a=Effect.CreateEffect(c)
	e0a:SetType(EFFECT_TYPE_SINGLE)
	e0a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0a:SetCode(EFFECT_CANNOT_SUMMON)
	e0a:SetValue(1)
	c:RegisterEffect(e0a)
	local e0b=e0a:Clone()
	e0b:SetCode(EFFECT_CANNOT_MSET)
	c:RegisterEffect(e0b)
	--Must first be Special Summoned from Extra by banishing the above cards (treated as Fusion Summon)
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCountLimit(1,{id,0})
	e0:SetCondition(s.spcon)
	e0:SetOperation(s.spop)
	e0:SetValue(SUMMON_TYPE_FUSION)
	c:RegisterEffect(e0)
	-- If Fusion Summoned: equip Bronze Cloth from GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,{id,1})
	e1:SetCondition(s.eqcon)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
end

s.listed_names={922100000}
s.listed_series={SET_SAINT,SET_BRONZE_SAINT,SET_BRONZE_CLOTH,SET_CLOTH}

function s.matfilter(c)
	return c:IsMonster() and c:IsSetCard(SET_BRONZE_SAINT) and c:IsAbleToRemoveAsCost()
end

function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local loc=LOCATION_MZONE|LOCATION_GRAVE
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.matfilter),tp,loc,0,nil)
	if #g<5 then return false end
	return g:IsExists(Card.IsCode,1,nil,922100000)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local loc=LOCATION_MZONE|LOCATION_GRAVE
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g1=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(function(tc)
		return s.matfilter(tc) and tc:IsCode(922100000)
	end),tp,loc,0,1,1,nil)
	local tc=g1:GetFirst()
	if not tc then return end
	local g=Group.FromCards(tc)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g2=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(function(c2)
		return s.matfilter(c2) and not g:IsContains(c2)
	end),tp,loc,0,4,4,nil)
	if #g2~=4 then return end
	g:Merge(g2)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsFusionSummoned()
end

function s.bronzecloth_gy(c,ec)
	if not ec or not ec:IsFaceup() then return false end
	if not c:IsSetCard(SET_BRONZE_CLOTH) or not c:IsType(TYPE_EQUIP) or c:IsForbidden() then return false end
	return c:CheckEquipTarget(ec)
end

function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsFaceup() and c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(function(tc) return s.bronzecloth_gy(tc,c) end),tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_GRAVE)
end

function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsFaceup() or not c:IsRelateToEffect(e) then return end
	while Duel.GetLocationCount(tp,LOCATION_SZONE)>0 do
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(function(tc) return s.bronzecloth_gy(tc,c) end),tp,LOCATION_GRAVE,0,nil)
		if #g==0 then break end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local tc=g:Select(tp,1,1,nil):GetFirst()
		if not tc then break end
		Duel.Equip(tp,tc,c)
	end
end

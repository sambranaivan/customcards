--Galaxia
--[==[
-- ID: 922100298
-- Type: Spell / Field Spell
--
-- Archetypes:
-- - Meta
-- Effect (EN):
-- All monsters on the field gain 200 ATK/DEF for each different Attribute among monsters on the field (max 1000 ATK/DEF).
-- Once per turn, during your Main Phase: You can send 1 monster from your hand to the GY; draw 1 card.
-- You can only control 1 "Galaxia".
--]==]
--Galaxia
local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id,LOCATION_FZONE)
	-- ATK/DEF boost by different attributes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
	local e1b=e1:Clone()
	e1b:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1b)
	-- Once per turn: send 1 monster from hand; draw 1
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.cost)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_META, SET_SAINT}

function s.val(e,c)
	local g=Duel.GetMatchingGroup(Card.IsMonster,e:GetHandlerPlayer(),LOCATION_MZONE,LOCATION_MZONE,nil)
	local attrs={}
	local ct=0
	for tc in aux.Next(g) do
		local a=tc:GetAttribute()
		if a~=0 and not attrs[a] then attrs[a]=true ct=ct+1 end
	end
	return math.min(1000,ct*200)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsMonster,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsMonster,tp,LOCATION_HAND,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Draw(tp,1,REASON_EFFECT)
end

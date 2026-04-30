--Steel Saint - Daichi of Land Armor
--[==[
-- ID: 922100144
-- Type: Monster / Effect Monster
-- Level: 4
-- Attribute: EARTH
-- Race: Machine
-- ATK/DEF: 1400/1800
--
-- Archetypes:
-- - Steel Saint
-- - saint
-- - saint-seiya
--
-- Effect (EN):
-- If a "Saint" monster(s) you control would be destroyed by battle or card effect (Quick Effect): You can discard this card; that monster(s) is not destroyed.
-- Then, if you control a "Saint" monster, you can Special Summon this card from your hand.
-- Also, for the rest of this turn after this effect resolves, you cannot Special Summon monsters from the Extra Deck, except "Saint" monsters.
-- You can only use this effect of "Steel Saint - Daichi of Land Armor" once per turn.
--]==]
--Steel Saint - Daichi of Land Armor
local s,id=GetID()
function s.initial_effect(c)
	--Discard; your Saint(s) not destroyed (this chain)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.repcon)
	e1:SetCost(s.cost)
	e1:SetOperation(s.repop)
	c:RegisterEffect(e1)
end

s.listed_series={SET_STEEL_SAINT,SET_SAINT}

function s.repcon(e,tp,eg,ep,ev,re,r,rp)
	--best-effort: if chain is about to destroy a Saint you control
	if not re then return false end
	if (re:GetCategory()&CATEGORY_DESTROY)==0 then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsExists(function(c) return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsSetCard(SET_SAINT) end,1,nil)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable(REASON_COST) end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	--Protect all your Saints until end of turn
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_SAINT))
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	Duel.RegisterEffect(e2,tp)
	--ED lock except Saint
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetTargetRange(1,0)
	e3:SetTarget(function(e,c,sump,sumtype,sumpos,targetp,se)
		return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(SET_SAINT)
	end)
	e3:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e3,tp)
end

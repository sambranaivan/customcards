--Sacrifice of the God Warriors
--[==[
-- ID: 922100186
-- Type: Spell / Quick-Play Spell
--
-- Archetypes:
-- - God Warrior
-- Effect (EN):
-- Target 1 "God Warrior" monster you control; destroy it, and if you do, place 2 Odin Sapphire Counters on 1 face-up "Palace of Valhalla - Throne of Hilda" you control, then draw 1 card.
-- For the rest of this turn after this card resolves, you cannot Special Summon monsters from the Extra Deck, except "God Warrior" monsters.
-- You can only activate 1 "Sacrifice of the God Warriors" per turn.
--]==]
--Sacrifice of the God Warriors
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_COUNTER+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_GOD_WARRIOR, SET_SAINT}

function s.gwfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_GOD_WARRIOR) and c:IsDestructable()
end
function s.palfilter(c,tp)
	return c:IsFaceup() and c:IsCode(922100172) and c:IsControler(tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.gwfilter(chkc) end
	if chk==0 then
		return Duel.IsExistingTarget(s.gwfilter,tp,LOCATION_MZONE,0,1,nil)
			and Duel.IsExistingMatchingCard(s.palfilter,tp,LOCATION_FZONE,0,1,nil,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.gwfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	local pal=Duel.GetMatchingGroup(s.palfilter,tp,LOCATION_FZONE,0,nil,tp):GetFirst()
	if Duel.Destroy(tc,REASON_EFFECT)>0 and pal and pal:IsFaceup() then
		pal:AddCounter(0x10f9,2)
		Duel.Draw(tp,1,REASON_EFFECT)
		-- Restrict Extra Deck summons
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(SET_GOD_WARRIOR)
end

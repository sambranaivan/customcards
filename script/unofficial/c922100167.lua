--Saint - Seiya, Cosmos of His Companions
--[==[
-- ID: 922100167
-- Type: Monster / Effect Monster
-- Level: 7
-- Attribute: LIGHT
-- Race: Warrior
-- ATK/DEF: 2600/1900
--
-- Archetypes:
-- - saint-seiya
--
-- Effect (EN):
-- If your opponent controls a "Black Saint" monster, you can Special Summon this card (from your hand).
-- If this card is Normal or Special Summoned: You can send 1 "Saint" monster from your Deck to the GY, then target 1 face-up "Black Saint" monster your opponent controls; negate its effects until the end of this turn.
-- Once per turn (Quick Effect): You can target 1 "Fragment of Sagittarius" Equip Spell your opponent controls; send it to the GY, and if you do, this card gains 800 ATK until the end of this turn.
-- At the start of the Damage Step, if this card battles a "Black Saint" monster while you have 3 or more "Saint" monsters with different names in your GY: Destroy that opponent's monster.
-- You can only use each effect of "Saint - Seiya, Cosmos of His Companions" once per turn.
--]==]
--Saint - Seiya, Cosmos of His Companions
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon from hand if opponent controls a Black Saint
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_HAND)
	e0:SetCondition(s.spcon)
	c:RegisterEffect(e0)

	--On summon: send 1 Saint from Deck, then negate 1 face-up Black Saint opponent controls
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	local e1b=e1:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)

	--Quick: send 1 Fragment Equip opponent controls; gain 800 ATK
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.qtg)
	e2:SetOperation(s.qop)
	c:RegisterEffect(e2)

	--Damage Step vs Black Saint with 3+ different Saint in GY: destroy that monster
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.descon)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end

s.listed_series={SET_SAINT,SET_BLACK_SAINT,SET_FRAGMENT_OF_SAGITTARIUS}

function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_BLACK_SAINT),tp,0,LOCATION_MZONE,1,nil)
end

function s.saintdeck(c)
	return c:IsSetCard(SET_SAINT) and c:IsMonster() and c:IsAbleToGrave()
end
function s.blackface(c)
	return c:IsFaceup() and c:IsSetCard(SET_BLACK_SAINT)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.saintdeck,tp,LOCATION_DECK,0,1,nil)
		and Duel.IsExistingMatchingCard(s.blackface,tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.saintdeck,tp,LOCATION_DECK,0,1,1,nil)
	if #g==0 then return end
	Duel.SendtoGrave(g,REASON_EFFECT)
	Duel.BreakEffect()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tg=Duel.SelectMatchingCard(tp,s.blackface,tp,0,LOCATION_MZONE,1,1,nil)
	local tc=tg:GetFirst()
	if tc then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		tc:RegisterEffect(e2)
	end
end

function s.fragopp(c)
	return c:IsFaceup() and c:IsType(TYPE_EQUIP) and c:IsSetCard(SET_FRAGMENT_OF_SAGITTARIUS) and c:IsAbleToGrave()
end
function s.qtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_SZONE) and s.fragopp(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.fragopp,tp,0,LOCATION_SZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	Duel.SelectTarget(tp,s.fragopp,tp,0,LOCATION_SZONE,1,1,nil)
end
function s.qop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	if Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and c:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(800)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end

function s.ctsaints(tp)
	local g=Duel.GetMatchingGroup(function(c) return c:IsSetCard(SET_SAINT) and c:IsMonster() end,tp,LOCATION_GRAVE,0,nil)
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
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	local tc=(a==c) and d or (d==c and a or nil)
	return tc and tc:IsFaceup() and tc:IsSetCard(SET_BLACK_SAINT) and s.ctsaints(tp)>=3
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	local tc=(a==c) and d or (d==c and a or nil)
	if tc and tc:IsRelateToBattle() then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

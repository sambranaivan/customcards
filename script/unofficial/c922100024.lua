--Silver Saint - Musca Dio
--[==[
-- ID: 922100024
-- Type: Monster / Synchro Monster
-- Level: 8
-- Attribute: DARK
-- Race: Warrior
-- ATK/DEF: 2200/2200
--
-- Archetypes:
-- - saint
-- - Silver Saint
-- Effect (EN):
-- 1 Tuner + 1+ non-Tuner "Saint" monsters
-- For the Synchro Summon of this card, you can treat 1 "Bronze Saint" monster you control as a Tuner.
-- Once per turn: You can target 1 face-up monster your opponent controls; place 1 Fly Counter on it.
-- Monsters with a Fly Counter have their effects negated, also they cannot be used as material for a Special Summon from the Extra Deck.
--]==]
--Silver Saint - Musca Dio
local s,id=GetID()
function s.initial_effect(c)
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(aux.FilterBoolFunction(Card.IsSetCard,SET_SAINT)),1,99,s.subtuner)
	c:EnableReviveLimit()

	--Place 1 Fly Counter
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.cttg)
	e1:SetOperation(s.ctop)
	c:RegisterEffect(e1)
end

s.listed_series={SET_SAINT,SET_SILVER_SAINT}

s.counter_place_list={0x10f5}

function s.subtuner(c,sc,sumtype,tp)
	return c:IsSetCard(SET_BRONZE_SAINT) and c:IsControler(tp)
end

function s.ctfilter(c)
	return c:IsFaceup() and c:IsCanAddCounter(0x10f5,1)
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.ctfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.ctfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.ctfilter,tp,0,LOCATION_MZONE,1,1,nil)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or not tc:IsFaceup() then return end
	tc:AddCounter(0x10f5,1)
	--Apply debuffs while it has a Fly Counter
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetCondition(s.discon)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	tc:RegisterEffect(e2)
	--Material restrictions (cover common Extra Deck materials)
	for _,code in ipairs({EFFECT_CANNOT_BE_FUSION_MATERIAL,EFFECT_CANNOT_BE_SYNCHRO_MATERIAL,EFFECT_CANNOT_BE_XYZ_MATERIAL,EFFECT_CANNOT_BE_LINK_MATERIAL}) do
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(code)
		e3:SetValue(1)
		e3:SetCondition(s.discon)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3)
	end
end
function s.discon(e)
	return e:GetHandler():GetCounter(0x10f5)>0
end

--The 108 Beads of the Wicked Rosary
--[==[
-- ID: 922100215
-- Type: Spell / Normal Spell
--
-- Archetypes:
-- - saint-seiya
--
-- Effect (EN):
-- Send cards from the top of your Deck to the GY until 3 "Specter" monsters are sent to your GY.
-- For the rest of this turn after this card resolves, you cannot Special Summon monsters, except "Specter", "Renegade Saint", or "Hades" monsters.
-- You can only activate 1 "The 108 Beads of the Wicked Rosary" per turn.
--]==]
--The 108 Beads of the Wicked Rosary
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_SAINT}

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local deck=Duel.GetFieldGroup(tp,LOCATION_DECK,0)
	local sentSpecter=0
	while #deck>0 and sentSpecter<3 do
		local tc=Duel.GetDecktopGroup(tp,1):GetFirst()
		if not tc then break end
		Duel.SendtoGrave(tc,REASON_EFFECT)
		if tc:IsSetCard(SET_SPECTER) and tc:IsMonster() then
			sentSpecter=sentSpecter+1
		end
		deck=Duel.GetFieldGroup(tp,LOCATION_DECK,0)
	end
	-- Restrict Special Summons for rest of turn
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not (c:IsSetCard(SET_SPECTER) or c:IsSetCard(SET_RENEGADE_SAINT) or c:IsSetCard(SET_HADES))
end

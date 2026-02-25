--Super Saiyan 3 Goku
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,900000013,s.matfilter)
end
function s.matfilter(c,fc,sumtype,tp)
	return c:IsRace(RACE_WARRIOR) and c:IsLevelAbove(7)
end

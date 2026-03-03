--Gogeta
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,s.matfilter1,s.matfilter2)
end
function s.matfilter1(c,fc,sumtype,tp)
	return c:IsSetCard(0x1d0)
end
function s.matfilter2(c,fc,sumtype,tp)
	return c:IsSetCard(0x1d1)
end

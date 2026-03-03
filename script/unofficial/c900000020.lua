--Vegetto Super Saiyan
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion: 1 "Goku" Lv7+ monster + 1 "Vegeta" Lv7+ monster
	Fusion.AddProcMix(c,true,true,s.fmat_goku,s.fmat_veg)
end
s.listed_series={0x1d0,0x1d1,0x1d2}
function s.fmat_goku(c,fc,sumtype,tp)
	return c:IsSetCard(0x1d0) and c:IsType(TYPE_MONSTER) and c:IsLevelAbove(7)
end
function s.fmat_veg(c,fc,sumtype,tp)
	return c:IsSetCard(0x1d1) and c:IsType(TYPE_MONSTER) and c:IsLevelAbove(7)
end

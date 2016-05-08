local att = {}
att.name = "bg_glockstock"
att.displayName = "GLR-440 Stock"
att.displayNameShort = "Stock"
att.isBG = true

att.statModifiers = {DrawSpeedMult = -0.1,
RecoilMult = -0.2,
OverallMouseSensMult = -0.1}

if CLIENT then
	att.displayIcon = surface.GetTextureID("atts/glockstock")
end

function att:attachFunc()
	self:setBodygroup(self.StockBGs.main, self.StockBGs.stock)
end

function att:detachFunc()
	self:setBodygroup(self.StockBGs.main, self.StockBGs.nostock)
end

CustomizableWeaponry:registerAttachment(att)
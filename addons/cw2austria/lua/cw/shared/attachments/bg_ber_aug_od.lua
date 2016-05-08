local att = {}
att.name = "bg_ber_aug_od"
att.displayName = "OD Paint Job"
att.displayNameShort = "OD"
att.isBG = true

att.statModifiers = {}

if CLIENT then
	att.displayIcon = surface.GetTextureID("atts/ber_aug_od")
	att.description = {[1] = {t = "olive drab finish for your weapon.", c = CustomizableWeaponry.textColors.POSITIVE}}
end

function att:attachFunc()
	if SERVER then
		return
	end

	if self.CW_VM then
		self.CW_VM:SetSkin(1)
	end
	if self.WMEnt then
		self.WMEnt:SetSkin(1)
	end
end

function att:detachFunc()
	if SERVER then
		return
	end

	if self.CW_VM then
		self.CW_VM:SetSkin(0)
	end
	if self.WMEnt then
		self.WMEnt:SetSkin(0)
	end
end

CustomizableWeaponry:registerAttachment(att)
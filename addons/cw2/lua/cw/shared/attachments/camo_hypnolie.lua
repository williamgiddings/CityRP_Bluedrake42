local att = {}
att.name = "camo_hypnolie"
att.displayName = "Hypnotic Lie"
att.displayNameShort = "Hypno Lie"
att.isBG = true

att.statModifiers = {}

if CLIENT then
	att.displayIcon = surface.GetTextureID("camos/hypnolie")
	att.description = {[1] = {t = "A custom finish for your weapon.", c = CustomizableWeaponry.textColors.POSITIVE},
	[2] = {t = "There's just something hypnotic about lying to your loved ones.", c = CustomizableWeaponry.textColors.POSITIVE}}
end

function att:attachFunc()
	if SERVER then
		return
	end

	if self.CW_VM then
		self.CW_VM:SetSkin(3)
	end
end

function att:detachFunc()
	if SERVER then
		return
	end

	if self.CW_VM then
		self.CW_VM:SetSkin(0)
	end
end

CustomizableWeaponry:registerAttachment(att)
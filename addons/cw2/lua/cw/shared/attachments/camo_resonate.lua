local att = {}
att.name = "camo_resonate"
att.displayName = "Resonate"
att.displayNameShort = "Resonate"
att.isBG = true

att.statModifiers = {}

if CLIENT then
	att.displayIcon = surface.GetTextureID("camos/resonate")
	att.description = {[1] = {t = "A custom finish for your weapon.", c = CustomizableWeaponry.textColors.POSITIVE},
	[2] = {t = "Can you hear a resonance stronger than words now?", c = CustomizableWeaponry.textColors.POSITIVE}}
end

function att:attachFunc()
	if SERVER then
		return
	end

	if self.CW_VM then
		self.CW_VM:SetSkin(2)
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
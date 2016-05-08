local att = {}
att.name = "camo_90stv"
att.displayName = "90's Television"
att.displayNameShort = "90's T.V."
att.isBG = true

att.statModifiers = {}

if CLIENT then
	att.displayIcon = surface.GetTextureID("camos/90stv")
	att.description = {[1] = {t = "A custom finish for your weapon.", c = CustomizableWeaponry.textColors.POSITIVE},
	[2] = {t = "Reminds me of the 90's.", c = CustomizableWeaponry.textColors.POSITIVE}}
end

function att:attachFunc()
	if SERVER then
		return
	end

	if self.CW_VM then
		self.CW_VM:SetSkin(1)
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
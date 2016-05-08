local att = {}
att.name = "bg_extmag"
att.displayName = "33 Round Magazine"
att.displayNameShort = "33 Mag"
att.isBG = true

att.statModifiers = {ReloadSpeedMult = -0.1}

if CLIENT then
	att.displayIcon = surface.GetTextureID("atts/extmag")
	att.description = {[1] = {t = "Increases mag size to 33 rounds.", c = CustomizableWeaponry.textColors.POSITIVE}}
end

function att:attachFunc()
	self:setBodygroup(self.MagBGs.main, self.MagBGs.extmag)
	self:unloadWeapon()
	self.Primary.ClipSize = 33
	self.Primary.ClipSize_Orig = 33
end

function att:detachFunc()
	self:setBodygroup(self.MagBGs.main, self.MagBGs.normmag)
	self:unloadWeapon()
	self.Primary.ClipSize = self.Primary.ClipSize_ORIG_REAL
	self.Primary.ClipSize_Orig = self.Primary.ClipSize_ORIG_REAL
end

CustomizableWeaponry:registerAttachment(att)
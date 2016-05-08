local att = {}
att.name = "md_shrek_pistol_compensator"
att.displayName = "Pistol Compensator"
att.displayNameShort = "Pistol Comp."
att.isSuppressor = false

att.statModifiers = {RecoilMult = -0.15,
DamageMult = 0.25,
AimSpreadMult = 0.25,
HipSpreadMult = 0.25}

if CLIENT then
	att.displayIcon = surface.GetTextureID("atts/pistolcomp")
end

CustomizableWeaponry:registerAttachment(att)
if CustomizableWeaponry then


AddCSLuaFile()
AddCSLuaFile("sh_sounds.lua")
include("sh_sounds.lua")

if server then
CustomizableWeaponry:registerAmmo("7.62x54mmR", "7.62x54mmR Rounds", 7.62, 54)
end

if CLIENT then
	SWEP.DrawCrosshair = false
	SWEP.PrintName = "AUG"
	SWEP.CSMuzzleFlashes = true
	SWEP.ViewModelMovementScale = 0.6
	
	SWEP.IconLetter = "w"
	killicon.Add("cw_ber_auga1-2", "weaponicons/aug-k", Color(255, 80, 0, 150))
	SWEP.SelectIcon = surface.GetTextureID("weaponicons/select/aug-h")
	
	SWEP.MuzzleEffect = "muzzleflash_6"
	SWEP.PosBasedMuz = false
	SWEP.SnapToGrip = true
	SWEP.ShellScale = 0.5
	SWEP.ShellOffsetMul = 1
	SWEP.ShellPosOffset = {x = 0, y = 0, z = -2}
	SWEP.ForeGripOffsetCycle_Draw = 0.4
	SWEP.ForeGripOffsetCycle_Reload = 0.74
	SWEP.ForeGripOffsetCycle_Reload_Empty = 0.88
	SWEP.FireMoveMod = 1
	
	SWEP.DrawTraditionalWorldModel = false
	SWEP.WM = "models/weapons/w_dber_aug.mdl"
	SWEP.WMPos = Vector(-4, -6, 5)
	SWEP.WMAng = Vector(0, 0, 180)
	
	SWEP.IronsightPos = Vector(-2.448, -1.2, 0.18)
	SWEP.IronsightAng = Vector(0.49, -0.129, 0)
	
	SWEP.MicroT1Pos = Vector(-2.445, -2.329, -0.187)
	SWEP.MicroT1Ang = Vector(0, 0, 0)

	SWEP.EoTechPos = Vector(-2.42, -3.152, -0.406)
	SWEP.EoTechAng = Vector(0, 0, 0)
	
	SWEP.ELCANBERPos = Vector(-2.415, -2.549, -0.667)
	SWEP.ELCANBERAng = Vector(0, 0, 0)
	
	SWEP.KobraPos = Vector(-2.431, -2.702, -0.265)
	SWEP.KobraAng = Vector(0, 0, 0)
	
	SWEP.ACOGV5Pos = Vector(-2.425, -1.201, -0.562)
	SWEP.ACOGV5Ang = Vector(0, 0, 0)
	
	SWEP.ShortDotPos = Vector(-2.415, -2.556, -0.211)
	SWEP.ShortDotAng = Vector(0, 0, 0)
	
	SWEP.SWAROVSKIScopePos = Vector(-2.422, -2.705, 0.016)
	SWEP.SWAROVSKIScopeAng = Vector(0, 0, 0)

	SWEP.SprintPos = Vector(-0.015, -0.035, 0.019)
	SWEP.SprintAng = Vector(-15.547, 15.92, -12.299)
	
	--SWEP.AlternativePos = Vector(1.2, -0.866, -0.361)
	--SWEP.AlternativeAng = Vector(0, 3.546, 3.148)
	
	--SWEP.AlternativePos = Vector(1.368, -0.506, -0.057)
	--SWEP.AlternativeAng = Vector(0, 0, 3.739)
	
	SWEP.AlternativePos = Vector(-0.038, -1.111, -0.38)
	SWEP.AlternativeAng = Vector(0, 0, 0)

	--SWEP.CustomizePos = Vector(1.87, -3.258, -1.3)
    --SWEP.CustomizeAng = Vector(10.232, 8.699, 10.218)
	
	--SWEP.CustomizePos = Vector(-7.151, -4.084, -2.701)
	--SWEP.CustomizeAng = Vector(34.007, 13.92, -35.901)
	
	--SWEP.CustomizePos = Vector(1.919, -4.422, -3.431)
	--SWEP.CustomizeAng = Vector(23.895, 11.244, 8.656)
	
	--SWEP.CustomizePos = Vector(-3.52, -4.329, -4.43)
	--SWEP.CustomizeAng = Vector(21.393, 34.372, -38.972)
	
	SWEP.CustomizePos = Vector(2.69, -3.198, -1.821)
	SWEP.CustomizeAng = Vector(9.949, 26.347, 8.168)

	--SWEP.BackupSights = {["md_ber_elcanv2"] = {[1] = Vector(-2.409, -1.979, -1.563), [2] = Vector(0, 0, 0)}}
	
	SWEP.BackupSights = {["bg_ber_swarovski_scope"] = {[1] = Vector(-2.467, -2.705, -0.463), [2] = Vector(0, 0, 0)}, ["md_ber_elcanv2"] = {[1] = Vector(-2.409, -1.979, -1.563), [2] = Vector(0, 0, 0)}}

    SWEP.BaseArm = "L_Arm_Controller"
	SWEP.BaseArmBoneOffset = Vector(-50, 0, 0)
	
	SWEP.SightWithRail = false
	SWEP.ACOGAxisAlign = {right = 0, up = 0, forward = 0}
	SWEP.ACOGV5AxisAlign = {right = 0, up = 0, forward = 0}
	SWEP.SchmidtShortDotAxisAlign = {right = 0, up = 0, forward = 0}
	SWEP.ELCANBERAxisAlign = {right = 0, up = 0, forward = 0}
	
	SWEP.CustomizationMenuScale = 0.015

	SWEP.AttachmentModelsVM = {
		["md_microt1"] = {model = "models/cw2/attachments/microt1.mdl", bone = "body", pos = Vector(-0.007, 1.24, 2.19), adjustment = {min =  -3.395, max = 1.24, axis = "y", inverseOffsetCalc = false}, angle = Angle(0, 0, 0), size = Vector(0.37, 0.37, 0.37)},
		["md_eotech"] = {model = "models/wystan/attachments/2otech557sight.mdl", bone = "body", pos = Vector(-0.25, 10.029, -8.091), adjustment = {min =  7.543, max = 10.029, axis = "y", inverseOffsetCalc = false}, angle = Angle(3, 90, 0), size = Vector(0.899, 0.899, 0.899)},
		["md_kobra"] = {model = "models/weapons/upgrades/a_optic_kobra.mdl", bone = "body", pos = Vector(0, 0.469, 2.094), adjustment = {min =  -2.317, max = 0.469, axis = "y", inverseOffsetCalc = false}, angle = Angle(0, 90, 0), size = Vector(0.899, 0.899, 0.899)},
		["md_ber_elcanv2"] = {model = "models/weapons/upgrades/elcan.mdl", bone = "body", pos = Vector(-0.013, 0, 3.03), adjustment = {min =  -1.818, max = 0, axis = "y", inverseOffsetCalc = false}, angle = Angle(0, 90, 0), size = Vector(0.8, 0.8, 0.8)},
		["md_schmidt_shortdot"] = { type = "Model", model = "models/cw2/attachments/schmidt.mdl", bone = "body", pos = Vector(0.282, 5.368, -2.475), adjustment = {min =  1.781, max = 5.368, axis = "y", inverseOffsetCalc = false}, angle = Angle(0, 90, 0), size = Vector(0.795, 0.795, 0.795)},
		["md_acogv5"] = {model = "models/weapons/v_dber_acoh.mdl", bone = "body", pos = Vector(0, 0.763, 1.84), angle = Angle(0, 0, 0), adjustment = {min =  -2.023, max = 0.763, axis = "y", inverseOffsetCalc = false}, size = Vector(1.001, 1.001, 1.001)},
		["md_ber_assault_suppressor"] = { model = "models/weapons/upgrades/a_suppressor_sec2.mdl", bone = "body", pos = Vector(0.025, -11.257, 0.616), angle = Angle(0, 90, 0), size = Vector(0.89, 0.89, 0.89)},
		["md_evo_frontsight"] = {model = "models/weapons/evo_front.mdl", bone = "body", pos = Vector(-0.008, -7.97, 1.623), angle = Angle(0, 90, 0), size = Vector(0.685, 0.685, 0.685)},
		["md_evo_rearsight"] = {model = "models/weapons/evo_rear.mdl", bone = "body", pos = Vector(0.004, -2.859, 1.633), angle = Angle(0, 90, 0), size = Vector(0.675, 0.675, 0.675)},
	}
	
	SWEP.LuaVMRecoilAxisMod = {vert = 1.5, hor = 2, roll = 1, forward = 1, pitch = 1}
	
	SWEP.LaserPosAdjust = Vector(0, 0, 0)
	SWEP.LaserAngAdjust = Angle(1, 180, 0) 
end

function SWEP:RenderTargetFunc()

if self.AttachmentModelsVM.md_rail then
	self.AttachmentModelsVM.md_rail.active = false
end
	
	if self.AimPos != self.IronsightPos then -- if we have a sight/scope equiped, hide the front and rar sights
	self.AttachmentModelsVM.md_evo_frontsight.active = false
	self.AttachmentModelsVM.md_evo_rearsight.active = false
	else
	self.AttachmentModelsVM.md_evo_frontsight.active = true
	self.AttachmentModelsVM.md_evo_rearsight.active = true
	end

end

--SWEP.BoltBone = "bolt"
--SWEP.BoltShootOffset = Vector(-1.9, 0, 0)
--SWEP.BoltBonePositionRecoverySpeed = 25

SWEP.LuaViewmodelRecoil = false

SWEP.SightBGs = {main = 2,  swarovski = 1, none = 0}


SWEP.Attachments = {[1] = {header = "Sights", offset = {400, -300}, atts = {"md_microt1", "md_eotech", "md_kobra", "md_ber_elcanv2", "md_schmidt_shortdot", "md_acogv5", "bg_ber_swarovski_scope"}},
[2] = {header = "Muzzle", offset = {-100, -200},  atts = {"md_ber_assault_suppressor"}},
[3] = {header = "Change of Pace", offset = {600, 200},  atts = {"bg_ber_aug_od", "bg_ber_aug_tan"}},
["+reload"] = {header = "Ammo", offset = {-300, 300}, atts = {"am_magnum", "am_matchgrade"}},
	}

SWEP.Animations = {fire = {"shoot1", "shoot2", "shoot3"},
	reload = "reload",
	reload_empty = "reload_empty",
	idle = "idle",
	draw = "draw"}
	
SWEP.Sounds = {draw = {{time = 0, sound = "CW_FOLEY_LIGHT"}},
	
	reload = {{time = 0.1, sound = "CW_FOLEY_LIGHT"},
	{time = 0.1, sound = "CW_BER_AUG_MAGOUT"},
	{time = 1, sound = "CW_FOLEY_LIGHT"},
	{time = 1.6, sound = "CW_BER_AUG_MAGIN"},
	{time = 2, sound = "CW_FOLEY_LIGHT"}},
	
	reload_empty = {{time = 0.1, sound = "CW_FOLEY_LIGHT"},
	{time = 0.1, sound = "CW_BER_AUG_MAGOUT"},
	{time = 1, sound = "CW_FOLEY_LIGHT"},
	{time = 1.6, sound = "CW_BER_AUG_MAGIN"},
	{time = 2.2, sound = "CW_FOLEY_LIGHT"},
	{time = 1.7, sound = "CW_BER_AUG_BOLTPULL"}}}

SWEP.SpeedDec = 15

SWEP.Slot = 3
SWEP.SlotPos = 0
SWEP.NormalHoldType = "smg"
SWEP.RunHoldType = "passive"
SWEP.FireModes = {"auto"}
SWEP.Base = "cw_base"
SWEP.Category = "BER_CW 2.0"

SWEP.Author			= "BER_"
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""

SWEP.ViewModelFOV	= 70
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/v_dber_aug.mdl"
SWEP.WorldModel		= "models/weapons/w_dber_aug.mdl"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "5.56x45MM"

SWEP.FireDelay = 0.086
SWEP.FireSound = "CW_BER_AUG_FIRE"
SWEP.FireSoundSuppressed = "CW_BER_AUG_FIRE_SUPPRESSED"
SWEP.Recoil = 0.7

SWEP.HipSpread = 0.05
SWEP.AimSpread = 0.0005
SWEP.VelocitySensitivity = 2
SWEP.MaxSpreadInc = 0.04
SWEP.SpreadPerShot = 0.03
SWEP.SpreadCooldown = 0.15
SWEP.Shots = 1
SWEP.Damage = 37
SWEP.DeployTime = 0.7

SWEP.ReloadSpeed = 1.2
SWEP.ReloadTime = 2.6
SWEP.ReloadTime_Empty = 3.2
SWEP.ReloadHalt = 2.6
SWEP.ReloadHalt_Empty = 3.2

SWEP.SnapToIdlePostReload = false


end
if CustomizableWeaponry then


AddCSLuaFile()
AddCSLuaFile("sh_sounds.lua")
include("sh_sounds.lua")

if CLIENT then
	SWEP.DrawCrosshair = false
	SWEP.PrintName = "SCOUT"
	SWEP.CSMuzzleFlashes = true
	SWEP.ViewModelMovementScale = 1
	
	SWEP.IconLetter = "w"
	killicon.Add("cw_famas_g2", "weaponicons/famas-k", Color(255, 80, 0, 150))
	SWEP.SelectIcon = surface.GetTextureID("weaponicons/select/scoot-h")
	
	SWEP.MuzzleEffect = "muzzleflash_6"
	SWEP.PosBasedMuz = false
	SWEP.SnapToGrip = true
	SWEP.ShellScale = 0.55
	SWEP.ShellDelay = 0.7
	SWEP.ShellOffsetMul = 1
	SWEP.ShellPosOffset = {x = 0, y = 0, z = -2}
	SWEP.ForeGripOffsetCycle_Draw = 0.4
	SWEP.ForeGripOffsetCycle_Reload = 0.74
	SWEP.ForeGripOffsetCycle_Reload_Empty = 0.88
	SWEP.FireMoveMod = 1
	
	SWEP.DrawTraditionalWorldModel = false
	SWEP.WM = "models/weapons/w_dber_scoot.mdl"
	SWEP.WMPos = Vector(-1, 0, 0)
	SWEP.WMAng = Vector(0, 0, 180)

	SWEP.IronsightPos = Vector(-2.165, 2, 0.879)
	SWEP.IronsightAng = Vector(0.141, -0.027, 0)
	
	SWEP.SCOUTPos = Vector(-2.152, 2, 0.597)
	SWEP.SCOUTAng = Vector(1.026, 0.008, -0.285)

	SWEP.MicroT1Pos = Vector(-2.876, -1.04, -1.208)
	SWEP.MicroT1Ang = Vector(0.225, -0.459, 2.184)

	SWEP.EoTechPos = Vector(-2.142, -1, 0.261)
	SWEP.EoTechAng = Vector(0, 0, 0)

	SWEP.AimpointPos = Vector(-2.899, -1.93, -1.257)
	SWEP.AimpointAng = Vector(-0.086, -0.728, 1.909)

	SWEP.ACOGPos = Vector(-2.241, 0, 0.119)
	SWEP.ACOGAng = Vector(0, 0, 0)

	SWEP.SprintPos = Vector(-0.08, 1.118, -0.04)
	SWEP.SprintAng = Vector(-8.207, 12.529, -13.77)

	SWEP.CustomizePos = Vector(0.685, -2.191, -1.162)
	SWEP.CustomizeAng = Vector(14.541, 22.09, 0)

	SWEP.BackupSights = {["md_acog"] = {[1] = Vector(-2.83, -2.053, -2.31), [2] = Vector(0.595, -0.56, 2.381)}}

    SWEP.BaseArm = "L_Arm_Controller"
	SWEP.BaseArmBoneOffset = Vector(-50, 0, 0)
	
	SWEP.SightWithRail = false
	SWEP.ACOGAxisAlign = {right = -1, up = 1.36, forward = 0}
	SWEP.SCOOPAxisAlign = {right = 0, up = 0, forward = 0}

	SWEP.AlternativePos = Vector(-0.08, 0.43, 0.159)
	SWEP.AlternativeAng = Vector(0, 0, 0)
	
	SWEP.CustomizationMenuScale = 0.017

	SWEP.AttachmentModelsVM = {
	["md_evo_frontsight"] = {model = "models/weapons/evo_front.mdl", bone = "body", pos = Vector(12.965, -1.032, -0.004), angle = Angle(0, 0, -90), size = Vector(0.589, 0.589, 0.589)}, 
	["md_evo_rearsight"] = {model = "models/weapons/evo_rear.mdl", bone = "body", pos = Vector(4.188, -1.068, 0.004), angle = Angle(0, 0, -90), size = Vector(0.55, 0.55, 0.55)},
	["md_eotech"] = {model = "models/weapons/ber_millenia_eotech.mdl", bone = "body", pos = Vector(-4.022, 7.59, -0.231), angle = Angle(0, 3, -90), size = Vector(0.8, 0.8, 0.8)},
	["md_ber_assault_suppressor"] = {model = "models/weapons/long_supp_millenia.mdl", bone = "body", pos = Vector(17.909, -0.738, 0.143), angle = Angle(0, -90, 0), size = Vector(0.771, 0.771, 0.771)},
	["md_ber_scoop"] = {model = "models/weapons/v_scoop_v2.mdl", bone = "body", pos = Vector(2.21, -1.117, -0.009), angle = Angle(90, 0, -90), size = Vector(0.699, 0.699, 0.699)},
	}
	

	
	SWEP.LuaVMRecoilAxisMod = {vert = 1.5, hor = 2, roll = 1, forward = 1, pitch = 1}
	
	SWEP.LaserPosAdjust = Vector(0.7, 0, 0)
	SWEP.LaserAngAdjust = Angle(-0.25, 180, 0) 
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

--SWEP.BoltBone = "ophandle"
--SWEP.BoltShootOffset = Vector(0, 2.5, 0)

SWEP.AttachmentDependencies = {["md_anpeq15"] = {"md_sight_rail"}}

SWEP.ADSFireAnim = true
SWEP.LuaViewmodelRecoil = false

SWEP.SightBGs = {main = 1, sg1 = 1, none = 0}



SWEP.Attachments = {[1] = {header = "Sights", offset = {300, 0}, atts = {"bg_ber_steyr_scopev2"}},
[2] = {header = "Muzzle", offset = {-200, -200},  atts = {"md_ber_assault_suppressor"}},
["+reload"] = {header = "Ammo", offset = {-300, 300}, atts = {"am_magnum", "am_matchgrade"}}}

SWEP.Animations = {fire = {"shoot"},
	reload = "reload_cham",
	reload_empty = "reload",
	idle = "idle",
	draw = "draw"}
	
SWEP.Sounds = {draw = {{time = 0.2, sound = "CW_BER_SCOOT_DRAW"}},

	reload = {{time = 0.1, sound = "CW_BER_SCOOT_BOLTHANDLE"},
	{time = 0.4, sound = "CW_BER_SCOOT_BOLTBACK"},
	{time = 0.7, sound = "CW_FOLEY_LIGHT"},
	{time = 1, sound = "CW_BER_SCOOT_MAGRELEASE"},
	{time = 1.5, sound = "CW_BER_SCOOT_MAGOUT"},
	{time = 1.6, sound = "CW_FOLEY_LIGHT"},
	{time = 2.6, sound = "CW_BER_SCOOT_MAGIN"},
	{time = 3.5, sound = "CW_BER_SCOOT_BOLTFORWARD"}},
	
	reload_cham = {{time = 0.1, sound = "CW_BER_SCOOT_BOLTHANDLE"},
	{time = 0.4, sound = "CW_BER_SCOOT_BOLTBACK"},
	{time = 0.7, sound = "CW_FOLEY_LIGHT"},
	{time = 1, sound = "CW_BER_SCOOT_MAGRELEASE"},
	{time = 1.5, sound = "CW_BER_SCOOT_MAGOUT"},
	{time = 1.6, sound = "CW_FOLEY_LIGHT"},
	{time = 2.6, sound = "CW_BER_SCOOT_MAGIN"},
	{time = 3.5, sound = "CW_BER_SCOOT_BOLTFORWARD"}},
	
	shoot = {{time = 0.1, sound = "CW_FOLEY_LIGHT"},
	{time = 0.3, sound = "CW_BER_SCOOT_BOLTHANDLES"},
	{time = 0.5, sound = "CW_BER_SCOOT_BOLTBACKS"},
	{time = 0.8, sound = "CW_BER_SCOOT_BOLTFORWARDS"}}}

SWEP.SpeedDec = 15

SWEP.Slot = 3
SWEP.SlotPos = 0
SWEP.NormalHoldType = "ar2"
SWEP.RunHoldType = "passive"
SWEP.FireModes = {"bolt"}
SWEP.Base = "cw_base"
SWEP.Category = "BER_CW 2.0"

SWEP.Author			= "Spy"
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""

SWEP.ViewModelFOV	= 70
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/v_dber_scoot.mdl"
SWEP.WorldModel		= "models/weapons/w_dber_scoot.mdl"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true
SWEP.AimBreathingEnabled = true

SWEP.Primary.ClipSize		= 5
SWEP.Primary.DefaultClip	= 5
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "7.62x51MM"

SWEP.FireDelay = 1.2
SWEP.FireSound = "CW_BER_SCOOT_FIRE"
SWEP.FireSoundSuppressed = "CW_BER_SCOOT_FIRE_SUPPRESSED"
SWEP.Recoil = 0.7

SWEP.Chamberable = false

SWEP.HipSpread = 0.06
SWEP.AimSpread = 0.000001
SWEP.VelocitySensitivity = 1.7
SWEP.MaxSpreadInc = 0.04
SWEP.SpreadPerShot = 0.02
SWEP.SpreadCooldown = 0.18
SWEP.Shots = 1
SWEP.Damage = 89
SWEP.DeployTime = 1

SWEP.ReloadSpeed = 1
SWEP.ReloadTime = 4.1
SWEP.ReloadTime_Empty = 4.1
SWEP.ReloadHalt = 4.1
SWEP.ReloadHalt_Empty = 4.1

SWEP.SnapToIdlePostReload = false


end
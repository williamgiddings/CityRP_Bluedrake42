include("shared.lua")

local baseFont = "CW_HUD72"
local ammoText = "CW_HUD60"

function ENT:Initialize()
	surface.SetFont(baseFont)
	self.baseHorSize, self.vertFontSize = surface.GetTextSize(self.PrintName)
	self.baseHorSize = self.baseHorSize < 600 and 600 or self.baseHorSize
	self.baseHorSize = self.baseHorSize + 20
	self.halfBaseHorSize = self.baseHorSize * 0.5
	self.halfVertFontSize = self.vertFontSize * 0.5
	self.resupplyAmountText = "+" .. self.ResupplyAmount .. " rounds per resupply"
end

ENT.displayDistance = 256 -- the distance within which the contents of the box will be displayed
ENT.upOffset = Vector(0, 0, 30)

local white, black = Color(255, 255, 255, 255), Color(0, 0, 0, 255)

function ENT:Draw()
	self:DrawModel()
	
	local ply = LocalPlayer()

	if ply:GetPos():Distance(self:GetPos()) > self.displayDistance then
		return
	end
	
	local eyeAng = EyeAngles()
	eyeAng.p = 0
	eyeAng.y = eyeAng.y - 90
	eyeAng.r = 90
	
	cam.Start3D2D(self:GetPos() + self.upOffset, eyeAng, 0.05)
		surface.SetDrawColor(0, 200, 255, 255)
		surface.DrawRect(-self.halfBaseHorSize, 0, self.baseHorSize, self.vertFontSize)
		
		surface.SetDrawColor(0, 0, 0, 150)
		surface.DrawRect(-self.halfBaseHorSize, self.vertFontSize, self.baseHorSize, self.vertFontSize * 2)
		
		if not self.CaliberSpecific then
			draw.ShadowText(self.PrintName, baseFont, 0, self.halfVertFontSize, white, black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.ShadowText(self.dt.ammoCharge .. (self.dt.ammoCharge == 1 and "x resupply left" or "x resupplies left"), ammoText, 0, self.vertFontSize + self.halfVertFontSize, white, black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			
			local wep = ply:GetActiveWeapon()
			
			if IsValid(wep) and wep.CW20Weapon then
				draw.ShadowText("+" .. wep.Primary.ClipSize_Orig .. " rounds per resupply", ammoText, 0, self.vertFontSize * 2 + self.halfVertFontSize, white, black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			else
				draw.ShadowText("Can't resupply", ammoText, 0, self.vertFontSize * 2 + self.halfVertFontSize, white, black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		else
			draw.ShadowText(self.Caliber, baseFont, 0, self.halfVertFontSize, white, black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.ShadowText(self.dt.ammoCharge .. (self.dt.ammoCharge == 1 and " round left" or " rounds left"), ammoText, 0, self.vertFontSize + self.halfVertFontSize, white, black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			
			draw.ShadowText(self.resupplyAmountText, ammoText, 0, self.vertFontSize * 2 + self.halfVertFontSize, white, black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	cam.End3D2D()
end

function ENT:Think()
end 
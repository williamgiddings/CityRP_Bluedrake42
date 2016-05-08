AddCSLuaFile()

-- thanks to this module/plug-in based design, you can simply change a few vars to whatever you wish to get the desired functionality in your gamemode without having to modify the base itself

CustomizableWeaponry.registeredAttachments = {}
CustomizableWeaponry.registeredAttachmentsSKey = {} -- SKey stands for 'string key', whereas the registeredAttachments has numerical indexes
CustomizableWeaponry.suppressors = {}
CustomizableWeaponry.sights = {}
CustomizableWeaponry.knownStatTexts = {}
CustomizableWeaponry.giveAllAttachmentsOnSpawn = 1 -- set to 0 to disable all attachments on spawn
CustomizableWeaponry.canOpenInteractionMenu = true -- whether the interaction menu can be opened
CustomizableWeaponry.playSoundsOnInteract = true -- whether it should play sounds when interacting with the weapon (attaching stuff, changing ammo, etc)
CustomizableWeaponry.customizationEnabled = true -- whether we can customize our guns in general

CustomizableWeaponry.textColors = {POSITIVE = Color(200, 255, 200, 255),
	NEGATIVE = Color(255, 200, 200, 255),
	VPOSITIVE = Color(175, 255, 175, 255),
	VNEGATIVE = Color(255, 150, 150, 255),
	REGULAR = Color(255, 255, 255, 255),
	COSMETIC = Color(169, 240, 255, 255),
	BLACK = Color(0, 0, 0, 255),
	GRAY = Color(200, 200, 200, 255)}
	
CustomizableWeaponry.sounds = {UNSUPPRESSED = 0,
	SUPPRESSED = 1}
	
local fallbackFuncs = {}

function fallbackFuncs:canEquip()
	return true
end

local totalAtts = 1

-- base func for registering atts
function CustomizableWeaponry:registerAttachment(tbl)
	-- register suppressors in a separate table with it's name as a key to avoid having to loop when doing stuff with attachments
	if tbl.isSuppressor then
		CustomizableWeaponry.suppressors[tbl.name] = tbl
	end
	
	if tbl.isSight then
		CustomizableWeaponry.sights[tbl.name] = tbl
	end
	
	if tbl.reticle then
		tbl._reticle = Material(tbl.reticle)
		tbl._reticleIcon = surface.GetTextureID(tbl.reticle)
	end
	
	tbl.id = totalAtts
	
	-- create convars for setting up which attachments should be given upon spawn
	
	if SERVER then
		local cvName = "cw_att_" .. tbl.name
		CreateConVar(cvName, CustomizableWeaponry.giveAllAttachmentsOnSpawn, {FCVAR_ARCHIVE, FCVAR_NOTIFY})
		tbl.cvar = cvName
	end
	
	local cvName = "cw_att_" .. tbl.name .. "_cl"
	
	if CLIENT then
		CreateClientConVar(cvName, CustomizableWeaponry.giveAllAttachmentsOnSpawn, true, true)
	end
	
	tbl.clcvar = cvName
	
	-- set the metatable of the current attachment to a fallback table, so that we can fallback to pre-defined funcs in case we're calling a nil method
	setmetatable(tbl, {__index = fallbackFuncs})
	
	tbl.FOVModifier = tbl.FOVModifier and tbl.FOVModifier or 15
	
	local val, key = self:findAttachment(tbl.name)
	-- don't register attachments that are already registered
	
	if val then
		-- instead, just override them
		self.registeredAttachments[key] = tbl
		self.registeredAttachmentsSKey[tbl.name] = tbl
		return
	end
	
	if CLIENT then
		self:createStatText(tbl)
	end

	table.insert(self.registeredAttachments, tbl)
	
	self.registeredAttachmentsSKey[tbl.name] = tbl
	
	totalAtts = totalAtts + 1
end

function CustomizableWeaponry:findAttachment(name)
	-- find the matching attachment
	for k, v in ipairs(self.registeredAttachments) do
		if v.name == name then
			return v, k
		end
	end
	
	-- if there is none, return nil
	return nil
end

function CustomizableWeaponry:canBeAttached(att, attachmentList)
	if not att.dependencies then
		return true
	end
	
	attachmentList = attachmentList or self.Attachments
	local dependency = nil
	
	for k, v in pairs(attachmentList) do
		if v.last then
			for k2, v2 in ipairs(v.atts) do
				if att.dependencies[v2] then
					if v.last == k2 then
						return true
					else
						dependency = att.dependencies[v2]
					end
				end
			end
		end
	end
	
	return false, dependency
end

local emptyString = ""

function CustomizableWeaponry:formAdditionalText(att)
	if att.isGrenadeLauncher then
		return CustomizableWeaponry.grenadeTypes.getGrenadeText(self)
	end
	
	return emptyString
end

function CustomizableWeaponry:cycleSubCustomization()
	if self.SightColorTarget then
		CustomizableWeaponry.colorableParts.cycleColor(self, self.SightColorTarget)
	elseif self.GrenadeTarget then
		CustomizableWeaponry.grenadeTypes.cycleGrenades(self)
	end
	
	self.SubCustomizationCycleTime = nil
end

local by = " by "
local percentage = "%"

-- this func is called only once per attachment, so don't worry about a possible performance bottleneck, even if it has a lot of loops
function CustomizableWeaponry:createStatText(att)
	-- no point in doing anything if there are no stat modifiers
	if not att.statModifiers then
		return
	end
	
	-- create a new desc table in case it has none
	if not att.description then
		att.description = {}
	end
	
	local pos
	
	-- loop through, find the spot where the positive stat text is
	for k, v in ipairs(att.description) do
		if v.c == CustomizableWeaponry.textColors.POSITIVE or v.c == CustomizableWeaponry.textColors.VPOSITIVE then
			pos = k + 1
			break
		end
	end
	
	-- if there is none, assume first possible position
	if not pos then
		pos = #att.description + 1
	end
	
	-- loop through, insert POSITIVE text, count amount of text inserts
	for stat, amount in pairs(att.statModifiers) do
		local text, color = self:formatWeaponStatText(stat, amount)
		
		if text and color and color == CustomizableWeaponry.textColors.POSITIVE then
			table.insert(att.description, pos, {t = text, c = color})
		end
	end
	
	pos = nil
	
	-- loop through again, this time, find where the negative text is
	for k, v in ipairs(att.description) do
		if v.c == CustomizableWeaponry.textColors.NEGATIVE or v.c == CustomizableWeaponry.textColors.VNEGATIVE then
			pos = k + 1
			break
		end
	end
	
	-- if there is none, assume bottom of description table
	
	if not pos then
		pos = #att.description + 1
	end
	
	for stat, amount in pairs(att.statModifiers) do
		local text, color = self:formatWeaponStatText(stat, amount)
		
		if text and color and color == CustomizableWeaponry.textColors.NEGATIVE then
			table.insert(att.description, pos, {t = text, c = color})
		end
	end
end

function CustomizableWeaponry:formatWeaponStatText(target, amount)
	local statText = self.knownStatTexts[target]
	
	if statText then
		-- return text and colors as specified in the table
		if amount < 0 then
			return statText.lesser .. by .. math.Round(math.abs(amount * 100)) .. percentage, statText.lesserColor
		elseif amount > 0 then
			return statText.greater .. by .. math.Round(math.abs(amount * 100)) .. percentage, statText.greaterColor
		end
	end
	
	-- no result, rip
	return nil
end

-- 'name' - name of the stat in the 'statModifiers' table
-- 'greaterThan' - the text to display when the stat is greater than zero
-- 'lesserThan' - the text to display when the stat is lesser than zero
function CustomizableWeaponry:registerRecognizedStat(name, lesser, greater, lesserColor, greaterColor)
	self.knownStatTexts[name] = {lesser = lesser, greater = greater, lesserColor = lesserColor, greaterColor = greaterColor}
end

-- register the recognized stats so that people just have to fill out the 'statModifiers' table and be done with it
CustomizableWeaponry:registerRecognizedStat("DamageMult", "Decreases damage", "Increases damage", CustomizableWeaponry.textColors.NEGATIVE, CustomizableWeaponry.textColors.POSITIVE)
CustomizableWeaponry:registerRecognizedStat("RecoilMult", "Decreases recoil", "Increases recoil", CustomizableWeaponry.textColors.POSITIVE, CustomizableWeaponry.textColors.NEGATIVE)
CustomizableWeaponry:registerRecognizedStat("FireDelayMult", "Increases firerate", "Decreases firerate", CustomizableWeaponry.textColors.POSITIVE, CustomizableWeaponry.textColors.NEGATIVE)
CustomizableWeaponry:registerRecognizedStat("HipSpreadMult", "Decreases hip spread", "Increases hip spread", CustomizableWeaponry.textColors.POSITIVE, CustomizableWeaponry.textColors.NEGATIVE)
CustomizableWeaponry:registerRecognizedStat("AimSpreadMult", "Decreases aim spread", "Increases aim spread", CustomizableWeaponry.textColors.POSITIVE, CustomizableWeaponry.textColors.NEGATIVE)
CustomizableWeaponry:registerRecognizedStat("ClumpSpreadMult", "Decreases clump spread", "Increases clump spread", CustomizableWeaponry.textColors.POSITIVE, CustomizableWeaponry.textColors.NEGATIVE)
CustomizableWeaponry:registerRecognizedStat("DrawSpeedMult", "Decreases deploy speed", "Increases deploy speed", CustomizableWeaponry.textColors.NEGATIVE, CustomizableWeaponry.textColors.POSITIVE)
CustomizableWeaponry:registerRecognizedStat("ReloadSpeedMult", "Decreases reload speed", "Increases reload speed", CustomizableWeaponry.textColors.NEGATIVE, CustomizableWeaponry.textColors.POSITIVE)
CustomizableWeaponry:registerRecognizedStat("OverallMouseSensMult", "Decreases handling", "Increases handling", CustomizableWeaponry.textColors.NEGATIVE, CustomizableWeaponry.textColors.POSITIVE)
CustomizableWeaponry:registerRecognizedStat("VelocitySensitivityMult", "Increases mobility", "Decreases mobility", CustomizableWeaponry.textColors.POSITIVE, CustomizableWeaponry.textColors.NEGATIVE)
CustomizableWeaponry:registerRecognizedStat("SpreadPerShotMult", "Decreases spread per shot", "Increases spread per shot", CustomizableWeaponry.textColors.POSITIVE, CustomizableWeaponry.textColors.NEGATIVE)
CustomizableWeaponry:registerRecognizedStat("MaxSpreadIncMult", "Decreases accumulative spread", "Increases accumulative spread", CustomizableWeaponry.textColors.POSITIVE, CustomizableWeaponry.textColors.NEGATIVE)

-- too lazy to re-write the directory every single time, so just create a local string that we'll concatenate
local path = "cw/shared/attachments/"

-- load attachment files
for k, v in pairs(file.Find("cw/shared/attachments/*", "LUA")) do
	loadFile(path .. v)
end

local path = "cw/shared/ammotypes/"

-- load ammo type files (they're the same as attachments, really, but this way it's very easy to integrate it with the weapon customization menu)
for k, v in pairs(file.Find("cw/shared/ammotypes/*", "LUA")) do
	loadFile(path .. v)
end
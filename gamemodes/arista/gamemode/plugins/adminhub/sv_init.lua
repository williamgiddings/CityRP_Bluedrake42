--[[
Name: "sv_init.lua".
Product: "gofuckyourself".
--]]

local PLUGIN = {};

-- Create a variable to store the plugin for the shared file.
PLUGIN_SHARED = PLUGIN;

-- Include the shared file and add it to the client download list.
include("sh_init.lua");
AddCSLuaFile("sh_init.lua");
cityrp.adminhub = {}

-- Pre-cache for networking.
util.AddNetworkString( "cityrp_adminhub_openmenu" );
util.AddNetworkString( "cityrp_adminhub_closemenu" );
util.AddNetworkString( "cityrp_adminhub_addlogline" );

cityrp.command.add("adminhub", "m", 1, function(player, arguments)
	if !IsValid(player) then return end
	if (string.lower(arguments[1]) == "") || (string.lower(arguments[1]) == "open") then
		cityrp.adminhub.OpenMenu(player)
	elseif (string.lower(arguments[1]) == "close") then
		cityrp.adminhub.CloseMenu(player)
	elseif (string.lower(arguments[1]) == "opacity") then
		if !arguments[2] then return end
		cityrp.adminhub.ChangeOpacity(player, math.Clamp(arguments[2], 0, 255))
	else
		player:Notify("Invalid argument.", 1);
	end
end)

function cityrp.adminhub.OpenMenu(player)
	local opacity = player._adminhubopacity or 150
	--[[
	umsg.Start("cityrp_adminhub_openmenu", player)
		umsg.Short(opacity)
	umsg.End()
	]]--
	
	net.Start( "cityrp_adminhub_openmenu" );
		net.WriteInt( opacity, 16 );
	net.Send( player );
end

function cityrp.adminhub.CloseMenu(player)
	--[[
	umsg.Start("cityrp_adminhub_closemenu", player)
	umsg.End()
	]]--
	
	net.Start( "cityrp_adminhub_closemenu" );
	net.Send( player );
end

function cityrp.adminhub.ChangeOpacity(player, opacity)
	cityrp.adminhub.CloseMenu(player)
	player._adminhubopacity = opacity
	cityrp.adminhub.OpenMenu(player)
end

function cityrp.adminhub.ChangeHeight(player, height)
	cityrp.adminhub.CloseMenu(player)
	cityrp._adminhubheight = height
	cityrp.adminhub.OpenMenu(player)
end

function cityrp.adminhub.AddLogLine(event, text, color)
	local date = tostring(os.date())
	if !color then color = Color(255,255,255,255) end
	MsgC(color, "["..date.."]["..event.."]", text.."\n")
	for _, v in pairs(player.GetAll()) do 
		if v:IsAdmin() or v:IsModerator() then
			--[[
			umsg.Start("cityrp_adminhub_addlogline", v)
				umsg.Char(color.r)
				umsg.Char(color.g)
				umsg.Char(color.b)
				umsg.String(event)
				umsg.String(text)
			umsg.End()
			]]--
			
			net.Start( "cityrp_adminhub_addlogline" );
				net.WriteInt( color.r, 8 );
				net.WriteInt( color.g, 8 );
				net.WriteInt( color.b, 8 );
				net.WriteString( event );
				net.WriteString( text );
			net.Send( v );
		end
	end
-- Log hooks:
end

hook.Add("PlayerSpawn", "colorlog_spawn", function(player)
	if !IsValid(player) then return end
	cityrp.adminhub.AddLogLine("SPAWN", player:Nick().." ("..player:SteamID()..") spawned as "..team.GetName(player:Team())..".", Color(32,255,32, 255))
end)

hook.Add("PlayerConnect", "colorlog_connect", function(nick)
	cityrp.adminhub.AddLogLine("CONNECT", nick.." connected.")
end)

hook.Add("PlayerDeath", "colorlog_death", function(player, weapon, killer)
	if !IsValid(player) then return end
	if IsValid(weapon) then 
	if (weapon:GetClass() == "prop_vehicle_jeep") then 
		local drivern, drivers
		if IsValid(weapon:GetDriver()) then drivern, drivers = weapon:GetDriver():Nick() or "*Unknown*", weapon:GetDriver():SteamID() or "*Unknown*" else drivern, drivers = "*Unknown*", "*Unknown*" end
		cityrp.adminhub.AddLogLine("CDM", player:Nick().." ("..player:SteamID()..") has been run over by "..drivern.." ("..drivers..") using "..tostring(weapon:GetModel())..".", Color(40,40,255))
	elseif (weapon:GetClass() == "prop_physics") then
		local powner = weapon:GetNWEntity("OwnerObj") 
		local pname, psid, pmodel
		if IsValid(powner) then pname, psid, pmodel = powner:Nick() or "*Unknown*", powner:SteamID() or "*Unknown*", weapon:GetModel() or "*Unknown*" else pname, psid, pmodel = "*Unknown*", "*Unknown*","*Unknown*" end
		cityrp.adminhub.AddLogLine("PROPKILL", player:Nick().." ("..player:SteamID()..") has been propkilled by "..pname.." ("..psid..") using "..pmodel..".", Color(255, 153, 0))
	else
		if IsValid(killer) and killer:IsPlayer() then 
			cityrp.adminhub.AddLogLine("KILL", player:Nick().." ("..player:SteamID()..") was killed by "..killer:Nick().." ("..killer:SteamID()..") using "..tostring(weapon)..".", Color(255,0,0,255))
		else 
			cityrp.adminhub.AddLogLine("KILL", player:Nick().." ("..player:SteamID()..") was killed by "..tostring(weapon)..".")
		end
	end
	else 
		cityrp.adminhub.AddLogLine("KILL", player:Nick().." ("..player:SteamID()..") was killed by "..tostring(killer)..".", Color(255,0,0,255))
	end
end)



-- Register the plugin.
cityrp.plugin.register(PLUGIN)
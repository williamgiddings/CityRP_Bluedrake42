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

-- A function to reset a player's AFK time.
function PLUGIN.resetTime(player)
	local uniqueID = player:UniqueID();
	
	-- Create a timer to kick the player for being AFK.
	if(!player:IsModerator() and !player:IsDeveloperOnly()) then
		timer.Create("Auto Kick: "..uniqueID, 900, 0, function()
			if(IsValid(player) and !player:IsModerator() and !player:IsDeveloperOnly()) then
				game.ConsoleCommand("kickid "..player:SteamID().." AFK\n");
			else
				timer.Remove("Auto Kick: "..uniqueID);
			end;
		end);
	end;
end;

-- Add the hooks.
cityrp.hook.add("PlayerInitialSpawn", PLUGIN.resetTime);
cityrp.hook.add("PlayerDeath", PLUGIN.resetTime);
cityrp.hook.add("PlayerSpawn", PLUGIN.resetTime);
cityrp.hook.add("KeyPress", PLUGIN.resetTime);

-- Register the plugin.
cityrp.plugin.register(PLUGIN);
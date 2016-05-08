local PLUGIN = {};

local nextThink = 0
hook.Add("Think", "adminhelp", function()
	if (nextThink > CurTime()) then return end
	for k, v in pairs( g_Player.GetAll() ) do
		if (v._Initialized && v:IsAdmin()) then
			if(v.phased && !v._AdminHelp && v._AdminHelpToggle) then
				v:SetNSVar("AdminHelp", true);
				v._AdminHelp = true;
			elseif((!v.phased && v._AdminHelp) or !v._AdminHelpToggle) then
				v:SetNSVar("AdminHelp", false);
				v._AdminHelp = false;
			end
		end;
	end;

	nextThink = CurTime() + 1
end);

cityrp.command.add("esp", "a", 0, function(player)
	esp = player._AdminHelpToggle;
	if(esp) then
		player:printMessage( "Admin Help Turned off.");
		player:SetPData("AdminHelpToggle", false);
		player._AdminHelpToggle = false;
	else
		player:printMessage( "Admin Help Turned on.");
		player:SetPData("AdminHelpToggle", true);
		player._AdminHelpToggle = true;
	end;
end);


function PLUGIN.InitialSpawn(player)
	local esp = player:GetPData("AdminHelpToggle");
	
	if(esp == nil) then
		player._AdminHelpToggle = true;
	else
		player._AdminHelpToggle = esp;
	end;
end
hook.Add("PlayerInitialSpawn", "AdminHelpInitialSpawn", PLUGIN.InitialSpawn)

hook.Add("PlayerDeath","ASNLRPlayerDeath", function(victim, weapon, killer)
	victim.LastDeath = os.time();
	victim.LastDeathPos = victim:GetPos();
	victim:SetNSVar("LastDeath", os.time());
end)

--[[
	Name: "sv_init.lua".
	Product: "CityRP".
--]]

local PLUGIN = {};

-- Create a variable to store the plugin for the shared file.
PLUGIN_SHARED = PLUGIN;

-- Include the shared file and add it to the client download list.
include("sh_init.lua");
AddCSLuaFile("sh_init.lua");

PLUGIN.Laws = {};
PLUGIN.President = nil;

util.AddNetworkString( "updateguilawspress" )
util.AddNetworkString( "updateguilaws" )
util.AddNetworkString( "requestguilaws" )

cityrp.command.add("addlaw", "b", 0, function(ply, law)
	if ply:Team() == TEAM_PRESIDENT then
		local text = table.concat(law, " ");
		table.insert(PLUGIN.Laws, text)
		
		net.Start( "updateguilaws" )
			net.WriteTable(PLUGIN.Laws)
		net.Broadcast()
		
		cityrp.chatBox.add(nil, ply, "law", text);
	end
end, "Commands", "<Law>", "Adds a law to the laws list.");
	
cityrp.command.add("removelaw", "b", 0, function(ply, lawindex)
	if ply:Team() == TEAM_PRESIDENT or ply:IsModerator() then
	
		table.remove(PLUGIN.Laws, lawindex[1])
		
		net.Start( "updateguilaws" )
			net.WriteTable(PLUGIN.Laws)
		net.Broadcast()
		
	end
end, "Commands", "<Law index>", "Removes a law from the laws list.");

cityrp.command.add("clearlaws", "b", 0, function(ply)
	if ply:Team() == TEAM_PRESIDENT or ply:IsModerator() then
	
		table.Empty(PLUGIN.Laws)
		ply:Notify("Laws are cleaned up!", 2);
		
		net.Start( "updateguilaws" )
			net.WriteTable(PLUGIN.Laws)
		net.Broadcast()

	end
end, "Commands", "", "Clears the laws list.");

cityrp.command.add("laws", "b", 0, function(ply)
	
	if table.Count(PLUGIN.Laws) > 0 then
		ply:printMessage( "[LAWS]" );
		for i, law in pairs(PLUGIN.Laws) do
			ply:printMessage( i .. ". " .. law);
		end
	else
		ply:printMessage( "There are currently no laws." );
	end
end, "Commands", "", "Check the laws");

net.Receive( "requestguilaws", function( length, client )
	net.Start( "updateguilaws" )
		net.WriteTable(PLUGIN.Laws)
	net.Send(client)
end )

hook.Add( "PlayerSpawn", "presidentlawsspawn", function(ply)
	
	if ply:Team() == TEAM_PRESIDENT then
		PLUGIN.President = ply;
	end
	
	net.Start( "updateguilawspress" ); net.Send(ply);
	net.Start( "updateguilaws" )
		net.WriteTable(PLUGIN.Laws)
	net.Send(ply)
end)
 
hook.Add( "DoPlayerDeath", "presidentlawsdeath", function(ply, attacker)

	if ply:Team() == TEAM_PRESIDENT then
		if ( IsValid(attacker) and attacker:IsPlayer() ) then
			if ( attacker:Team() == TEAM_POLICEOFFICER or attacker:Team() == TEAM_POLICECOMMANDER or attacker:Team() == TEAM_GA or attacker:Team() == TEAM_GAL ) then
				return
			else
				PLUGIN.President = nil;
				table.Empty(PLUGIN.Laws)
				
				net.Start( "updateguilaws" )
					net.WriteTable(PLUGIN.Laws)
				net.Broadcast()
			end
		end
	end

end)

hook.Add( "PlayerSilentDeath", "presidentlawssilentdeath", function(ply)
	
	if PLUGIN.President == ply then
	
		PLUGIN.President = nil;
		table.Empty(PLUGIN.Laws)
		
		net.Start( "updateguilaws" )
			net.WriteTable(PLUGIN.Laws)
		net.Broadcast()
		
	end
	
end)

hook.Add( "PlayerDisconnected", "presidentlawsdisconnect", function(ply)

	if (ply:Team() == TEAM_PRESIDENT) then
	
		PLUGIN.President = nil;
		table.Empty(PLUGIN.Laws)
		
		net.Start( "updateguilaws" )
			net.WriteTable(PLUGIN.Laws)
		net.Broadcast()
		
	end

end)

-- Register the plugin.
cityrp.plugin.register(PLUGIN);
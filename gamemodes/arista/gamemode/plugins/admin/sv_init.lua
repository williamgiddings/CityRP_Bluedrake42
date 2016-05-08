--[[
Name: "sv_admincommands.lua".
Product: "gofuckyourself".
--]]

local PLUGIN = {};
PLUGIN.name = "Anonymous";

cityrp.acommands = {}
cityrp.acommands.commands = {}

util.AddNetworkString("cityrp_adminhelp")
util.AddNetworkString("cityrp_adminchat")
util.AddNetworkString("cityrp_adminDoString")
util.AddNetworkString("cityrp_adminpopup")
util.AddNetworkString("cityrp_remoteadminhelp")
util.AddNetworkString("cityrp_remoteadminchat")

console = {};
console.Name = function() return "Console" end;
console.IsValid = function() return true end;
console.IsPlayer = function() return true end;
console.SteamID = function() return "" end;
console.IsAdmin = function() return true end;
console.IsSuperAdmin = function() return true end;

function cityrp.acommands.AddCommand(cmd, func, args, access)
	cityrp.acommands.commands[cmd] = {}
	cityrp.acommands.commands[cmd].func = func
	cityrp.acommands.commands[cmd].access = access
	if args then cityrp.acommands.commands[cmd].args = args end
end

function cityrp.acommands.getRankSteamID(steamid)
	local q1 = "SELECT _svrank FROM "..cityrpserver["MySQL Table"].." WHERE _SteamID='"..steamid.."';"
	local rank = nil
	DB:Query(q1, function(data)
		rank = data
	end)
	while (rank != nil) do 
		return rank
	end
end

function cityrp.acommands.precacheadmins()
	cityrp.acommands.admins = {
		{"STEAM_0:0:5119023", "Temar"},
		{"STEAM_0:1:38395357", "Shadow"},
		{"STEAM_0:1:34016841", "Pechvarry"},
		{"STEAM_0:0:12825720", "Nudelholz"},
		{"STEAM_0:0:26859943", "Faustie"},
		{"STEAM_0:0:17895125", "StillAlive"},
		{"STEAM_0:1:15472195", "SoulRipper"},
		{"STEAM_0:0:2744596", "Killjoy"},
		{"STEAM_0:0:20116682", "Holdem"},
		{"STEAM_0:0:43130641", "Beflok"},
		{"STEAM_0:1:11680391", "Grub"},
		{"STEAM_0:0:29604176", "Termin"},
		{"STEAM_0:1:33499744", "Vauld"},
		{"STEAM_0:0:25301902", "Matt"},
		{"STEAM_0:0:29177355", "Jamie"},
		{"STEAM_0:1:25877876", "Adman"},
		{"STEAM_0:1:21567584", "DoomDude1"},
		{"STEAM_0:1:42793994", "Fultzy"},
		{"STEAM_0:0:6082080", "Narcotic"},
		{"STEAM_0:0:52623191", "GhostRider"},
		{"STEAM_0:1:14131954", "Jokhah"},
		{"STEAM_0:1:35377420", "Doctor Internet"},
		{"STEAM_0:1:33631470", "LivKX"},
	};
end
cityrp.acommands.precacheadmins();

function cityrp.acommands.isadmin(sid)
	for _, v in pairs(cityrp.acommands.admins) do
		if(v[1] == sid) then
			return v[2];
		end;
	end
	return false;
end

hook.Add("PlayerSay", "cityrp_handleadmincommands", function(ply, text)
	local catch = false;
	if (string.Left(text, 1) == "!") then
		local extext = string.Explode(" ", text)
		local cmd = string.lower(string.Trim( string.sub(extext[1], 2)))
		table.remove(extext, 1)
		local args = extext

		if (cityrp.acommands.commands[cmd]) then
			if (cityrp.acommands.commands[cmd].args) and (#args < cityrp.acommands.commands[cmd].args) then 
				ply:Notify( "That command requires "..(cityrp.acommands.commands[cmd].args).." arguments!", 1, 4)
			elseif (!cityrp.acommands.commands[cmd].args) then
				ply:Notify( "You do not have access to that!", 1, 4)
			elseif (cityrp.access.hasAccess(ply, cityrp.acommands.commands[cmd].access)) then
				local chk, err = pcall(cityrp.acommands.commands[cmd].func, ply, unpack(args))
				if !chk then 
					print("Chat Command function error!")
					print(err)
				end
			else
				ply:Notify( "You do not have access to "..cmd.."!", 1, 4)
			end
		else
			ply:Notify( "That command does not exist!", 1, 4)
		end
		catch = true;
	elseif (string.Left(text, 9) == "/announce" && ply:IsAdmin()) then 
		local at = string.Trim( string.sub(text, 10) )
		for k, v in pairs( g_Player.GetAll() ) do
			v:PrintMessage(1, at);
		end;
		cityrp.player.printMessageAll(at);
		catch = true;
	elseif (string.Left(text, 2) == "@@") then 
		local at = string.Trim( string.sub(text, 3) )
		cityrp.acommands.adminChat(ply, at)
		catch = true;
	elseif (string.Left(text, 1) == "@") then 
		local at = string.Trim( string.sub(text, 2) )
		cityrp.acommands.adminHelp(ply, at)
		catch = true;
	elseif (string.Left(text, 2) == "##" and ply:IsAdmin()) then 
		local at = string.Trim( string.sub(text, 3) )
		cityrp.acommands.popup(ply, at, false)
		catch = true;
	elseif (string.Left(text, 1) == "#" and ply:IsAdmin()) then 
		local at = string.Trim( string.sub(text, 2) )
		local target = string.Explode(" ", at);
		at = string.Trim( string.sub(at, string.len(target[1])+1) )
		cityrp.acommands.popup(ply, at, target[1])
		catch = true;
	end
	if(catch) then
		cityrp.logs.add(ply:Name(), ply:SteamID(), nil, nil, "say", text);
		return "";
	end;
end)


function cityrp.acommands.HandleCommand(ply, _, args)
	if !args || #args == 0 then return end
	if !IsValid(ply) then return end
	local cmd = args[1]
	table.remove(args, 1)
	if(cmd == "luarun") then
		cityrp.acommands.luarun(ply, _, args)
	elseif (cityrp.acommands.commands[cmd]) then
		if (cityrp.acommands.commands[cmd].args) and (#args < cityrp.acommands.commands[cmd].args) then 
			ply:Notify( "That command requires "..(cityrp.acommands.commands[cmd].args).." arguments!", 1, 4)
			return ""
		end
		if (cityrp.access.hasAccess(ply, cityrp.acommands.commands[cmd].access)) then
			local chk, err = pcall(cityrp.acommands.commands[cmd].func, ply, unpack(args))
			if !chk then 
				print("Chat Command function error!")
				print(err)
				return ""
			end
		else
			ply:Notify( "You do not have access to "..cmd.."!", 1, 4)
			return ""
		end
	else
		ply:Notify( "That command does not exist!", 1, 4)
		return ""
	end
end
concommand.Add("cityrp_admin", cityrp.acommands.HandleCommand)
concommand.Add("ulx", cityrp.acommands.HandleCommand)

function cityrp.acommands.GetPlayerByName(name)
	target, more = cityrp.player.get(name);
	if(!target and more) then
		return more;
	else
		return target;
	end;
	-- local founds = {}
	-- if(!name or string.len(name) < 2) then
		-- return founds;
	-- end;
	-- for _,v in pairs(player.GetAll()) do 
		-- if string.find(string.lower(v:Nick()), string.lower(name), 1, true) then 
			-- table.insert(founds, v)
		-- end
	-- end
	-- if (#founds == 1) then 
		-- return founds[1]
	-- else
		-- return founds
	-- end
end
			
function cityrp.acommands.GetPlayerBySteamID(steamid)
	local founds = {}
	if(steamid and string.len(steamid) > 1) then
		for _,v in pairs(player.GetAll()) do 
			if string.find(string.lower(v:SteamID()), string.lower(steamid), 1, true) then 
				table.insert(founds, v)
			end
		end
	end;
	if (#founds == 1) then
		return founds[1]
	else
		return founds
	end
end

function cityrp.acommands.adminHelp(ply, text)
	if !IsValid(ply) then return end
	local mods = {}
	for k,v in pairs(player.GetAll()) do 
		if v:IsModerator() then table.insert(mods, v) end
	end
	if(!ply:IsModerator()) then
		ply:ChatPrint("To admins: "..text)
	end
	net.Start("cityrp_adminhelp")
		net.WriteString(text)
		net.WriteEntity(ply)
	net.Send(mods)
	DB:Query("INSERT INTO "..cityrpserver["MySQL Chat Table"].." (server, type, name, steamid, msg, time) VALUES ('"..FLServer.."', 'ahelp', '"..mysql_escape(ply:Name()).."', '"..ply:SteamID().."', '"..mysql_escape(text).."', "..os.time()..")");
end

function cityrp.acommands.adminChat(ply, text)
	if !IsValid(ply) then return end
	local admins = {}
	for k,v in pairs(player.GetAll()) do 
		if v:IsAdmin() then table.insert(admins, v) end
	end
	net.Start("cityrp_adminchat")
		net.WriteString(text)
		net.WriteEntity(ply)
	net.Send(admins)
	DB:Query("INSERT INTO "..cityrpserver["MySQL Chat Table"].." (server, type, name, steamid, msg, time) VALUES ('"..FLServer.."', 'achat', '"..mysql_escape(ply:Name()).."', '"..ply:SteamID().."', '"..mysql_escape(text).."', "..os.time()..")");
end

function cityrp.acommands.chatcheck()
	if(!cityrp.acommands.chatlastid) then
		DB:Query("SELECT id FROM chat ORDER BY id DESC Limit 1", function(result)
			if (result and type(result) == "table" and #result > 0) then
				cityrp.acommands.chatlastid = result[1].id;
			end;
		end);
		return;
	end;
	DB:Query("SELECT id, server, type, name, steamid, msg FROM chat WHERE server != '"..FLServer.."' AND id > "..cityrp.acommands.chatlastid.." ORDER BY id", function(result)
		if (result and type(result) == "table" and #result > 0) then
			for _, v in pairs(result) do 
			--	result = result[1];
				if(v.type == "ahelp") then
					local mods = {}
					for k,v in pairs(player.GetAll()) do 
						if v:IsModerator() then table.insert(mods, v) end
					end
					net.Start("cityrp_remoteadminhelp")
						net.WriteString(v.msg)
						net.WriteString(v.name.." ("..v.steamid..")")
						net.WriteString(v.server)
					net.Send(mods)
				elseif(v.type == "achat") then
					local admins = {}
					for k,v in pairs(player.GetAll()) do 
						if v:IsAdmin() then table.insert(admins, v) end
					end
					net.Start("cityrp_remoteadminchat")
						net.WriteString(v.msg)
						net.WriteString(v.name.." ("..v.steamid..")")
						net.WriteString(v.server)
					net.Send(admins)
				end;
				cityrp.acommands.chatlastid = v.id;
			end;
		end;
	end);
end;

timer.Create('cityrp_remote_chatcheck', 5, 0, cityrp.acommands.chatcheck);

function cityrp.acommands.popup(ply, text, target)
	if !IsValid(ply) then return end
	if(!target) then
		target = player.GetAll();
	else
		local t, more = cityrp.player.get(target)
		
		-- Check if we got a valid target.
		if (t) then
			target = t;
		elseif(more) then
			local names = cityrp.player.playerstostring(more);
			ply:Notify( target.." matches multiple users ("..names..")", 1);
			return;
		else
			ply:Notify( target.." is not a valid player!", 1);
			return;
		end;
	end;
	net.Start("cityrp_adminpopup")
		net.WriteString(text)
		net.WriteEntity(ply)
	net.Send(target)
end

function cityrp.acommands.adminDo(admin, text, icon, hidden)
	if !IsValid(admin) then return end
	icon = icon or "icon16/exclamation"
	net.Start("cityrp_adminDoString")
		net.WriteString(text)
		net.WriteString(icon)
	if((string.find(admin:Name(), "[FL]", 1, true) or string.find(admin:Name(), "Console", 1, true) or !admin:IsAdmin()) and (!admin.phased or !admin._AdminHCToggle) and !hidden) then
		net.WriteFloat(0)
		net.Send(player.GetAll())
	elseif(!admin:IsAdmin()) then
		local mods = {}
		for k,v in pairs(player.GetAll()) do 
			if v:IsModerator() then table.insert(mods, v) end
		end
		net.WriteFloat(1)
		net.Send(mods)
	else
		local admins = {}
		for k,v in pairs(player.GetAll()) do 
			if v:IsAdmin() then table.insert(admins, v) end
		end
		net.WriteFloat(1)
		net.Send(admins)
	end;
end

cityrp.acommands.Positions =  {}
for i=0,360,45 do table.insert( cityrp.acommands.Positions, Vector(math.cos(i),math.sin(i),0) ) end -- Around
table.insert( cityrp.acommands.Positions, Vector(0,0,1) )

function cityrp.acommands.FindPosition( ply )
	local size = Vector( 32, 32, 72 )
	
	local StartPos = ply:GetPos() + Vector(0,0,size.z/2)
	
	for _,v in ipairs( cityrp.acommands.Positions ) do
		local Pos = StartPos + v * size * 1.5
		
		local tr = {}
		tr.start = Pos
		tr.endpos = Pos
		tr.mins = size / 2 * -1
		tr.maxs = size / 2
		local trace = util.TraceHull( tr )
		
		if (!trace.Hit) then
			return Pos - Vector(0,0,size.z/2)
		end
	end
	
	return false
end

cityrp.acommands.AddCommand("kick", function(ply, target, reason, ...)
	local targetobj = false
	targetobj = cityrp.acommands.GetPlayerByName(target)
	local res = string.Implode(" ", {...})
	reason = reason.." "..res
	if (type(targetobj) == "table") and (#targetobj > 1) then
		local names = {}
		for _,v in pairs(targetobj) do
			table.insert(names, v:Nick())
		end
		ply:Notify( "Multiple targets found: "..string.Implode(", ",names), 1, 4)
		return
	end
	if !IsValid(targetobj) then 
		targetobj = cityrp.acommands.GetPlayerBySteamID(target)
	end
	if !IsValid(targetobj) then 
		ply:Notify( "No target found!", 1, 4)
		return
	else
		local atex = Format("%s kicked %s for \"%s\".", ply:Nick(true), targetobj:Nick(), reason)
		targetobj:Kick("You have been Kicked for reason: "..reason)
		cityrp.acommands.adminDo(ply, atex, "icon16/door_out")
	end
end, 2, "m")

cityrp.acommands.AddCommand("goto", function(ply, target)
	local targetobj = false
	targetobj = cityrp.acommands.GetPlayerByName(target)
	if (type(targetobj) == "table") and (#targetobj > 1) then
		local names = {}
		for _,v in pairs(targetobj) do
			table.insert(names, v:Nick())
		end
		ply:Notify( "Multiple targets found: "..string.Implode(", ",names), 1, 4)
		return
	end
	if !IsValid(targetobj) then 
		targetobj = cityrp.acommands.GetPlayerBySteamID(target)
	end
	if !IsValid(targetobj) then 
		ply:Notify( "No target found!", 1, 4)
		return
	elseif(targetobj.phased and targetobj:IsAdmin() and !ply:IsAdmin()) then 
		ply:Notify( "You can not teleport to a phased admin!", 1, 4)
		return
	elseif(targetobj.phased && !ply.phased) then 
		ply:Notify( "You must be Phased to goto a Phased user!", 1, 4)
		return
	else
		ply._tpbloc = ply:GetPos()
		if ply:InVehicle() then ply:ExitVehicle() end
		if (targetobj:InVehicle()) then
			ply:SetPos(targetobj:GetVehicle():GetPos() + Vector(0,0,50))
			local atex = Format("%s teleported to %s.", ply:Nick(), targetobj:Nick())
			cityrp.acommands.adminDo(ply, atex, "icon16/world_go", ply.phased)
		else
			if (ply:GetMoveType() == MOVETYPE_NOCLIP) then
				ply:SetPos(targetobj:GetPos() + targetobj:GetForward() * 45)
				local atex = Format("%s teleported to %s.", ply:Nick(), targetobj:Nick())
				cityrp.acommands.adminDo(ply, atex, "icon16/world_go", ply.phased)
			else
				local pos = cityrp.acommands.FindPosition(targetobj)
				if !pos then
					ply:SetPos(targetobj:GetPos() + Vector(0,0,72))
					local atex = Format("%s teleported to %s.", ply:Nick(), targetobj:Nick())
					cityrp.acommands.adminDo(ply, atex, "icon16/world_go", ply.phased)
				else
					ply:SetPos(pos)
					local atex = Format("%s teleported to %s.", ply:Nick(), targetobj:Nick())
					cityrp.acommands.adminDo(ply, atex, "icon16/world_go", ply.phased)
				end
			end
		end
	end
end, 1, "m")

cityrp.acommands.AddCommand("gotov", function(ply, target)
	local targetobj = false
	targetobj = cityrp.acommands.GetPlayerByName(target)
	if (type(targetobj) == "table") and (#targetobj > 1) then
		local names = {}
		for _,v in pairs(targetobj) do
			table.insert(names, v:Nick())
		end
		ply:Notify( "Multiple targets found: "..string.Implode(", ",names), 1, 4)
		return
	end
	if !IsValid(targetobj) then 
		targetobj = cityrp.acommands.GetPlayerBySteamID(target)
	end
	if !IsValid(targetobj) then 
		ply:Notify( "No target found!", 1, 4)
		return
	else
		for k, v in pairs( ents.FindByClass([[prop_vehicle_jeep]]) ) do
			if(IsValid(v._Owner)) then
				if(v._Owner == targetobj) then
					ply._tpbloc = ply:GetPos()
					if ply:InVehicle() then ply:ExitVehicle() end
				--	if (targetobj:InVehicle()) then
				--		ply:SetPos(targetobj:GetVehicle():GetPos() + Vector(0,0,50))
				--	else
						if (ply:GetMoveType() == MOVETYPE_NOCLIP) then
							ply:SetPos(v:GetPos() + v:GetForward() * 45)
							local atex = Format("%s teleported to %s's Vehicle.", ply:Nick(), targetobj:Nick())
							cityrp.acommands.adminDo(ply, atex, "icon16/world_go", ply.phased)
						else
							local pos = cityrp.acommands.FindPosition(v)
							if !pos then
								ply:SetPos(v:GetPos() + Vector(0,0,72))
								local atex = Format("%s teleported to %s's Vehicle.", ply:Nick(), targetobj:Nick())
								cityrp.acommands.adminDo(ply, atex, "icon16/world_go", ply.phased)
							else
								ply:SetPos(pos)
								local atex = Format("%s teleported to %s's Vehicle.", ply:Nick(), targetobj:Nick())
								cityrp.acommands.adminDo(ply, atex, "icon16/world_go", ply.phased)
							end
						end
				--	end
					return;
				end;
			end;
		end;
		ply:Notify( "No vehicle found!", 1, 4)
		return
	end
end, 1, "m")

cityrp.acommands.AddCommand("gotod", function(ply, target)
	local targetobj = false
	targetobj = cityrp.acommands.GetPlayerByName(target)
	if (type(targetobj) == "table") and (#targetobj > 1) then
		local names = {}
		for _,v in pairs(targetobj) do
			table.insert(names, v:Nick())
		end
		ply:Notify( "Multiple targets found: "..string.Implode(", ",names), 1, 4)
		return
	end
	if !IsValid(targetobj) then 
		targetobj = cityrp.acommands.GetPlayerBySteamID(target)
	end
	if !IsValid(targetobj) then 
		ply:Notify( "No target found!", 1, 4)
		return
	elseif(!targetobj.LastDeathPos) then 
		ply:Notify( "No last death position found!", 1, 4)
		return
	else
		ply._tpbloc = ply:GetPos()
		if ply:InVehicle() then ply:ExitVehicle() end
		ply:SetPos(targetobj.LastDeathPos)
		local atex = Format("%s teleported to %s's Last death position.", ply:Nick(), targetobj:Nick())
		cityrp.acommands.adminDo(ply, atex, "icon16/world_go", ply.phased)
	end
end, 1, "m")

cityrp.acommands.AddCommand("bring", function(ply, target)
	local targetobj = false
	targetobj = cityrp.acommands.GetPlayerByName(target)
	if (type(targetobj) == "table") and (#targetobj > 1) then
		local names = {}
		for _,v in pairs(targetobj) do
			table.insert(names, v:Nick())
		end
		ply:Notify( "Multiple targets found: "..string.Implode(", ",names), 1, 4)
		return
	end
	if !IsValid(targetobj) then 
		targetobj = cityrp.acommands.GetPlayerBySteamID(target)
	end
	if !IsValid(targetobj) then 
		ply:Notify( "No target found!", 1, 4)
		return
	else
		if ply:InVehicle() then ply:ExitVehicle() end
		targetobj._tpbloc = targetobj:GetPos();
		if (targetobj:InVehicle()) then targetobj:ExitVehicle() end
		if (targetobj:GetMoveType() == MOVETYPE_NOCLIP) then
			targetobj:SetPos(ply:GetPos() + ply:GetForward() * 45)
			local atex = Format("%s brought %s.", ply:Nick(), targetobj:Nick())
			cityrp.acommands.adminDo(ply, atex, "icon16/world_go")
		else
			local pos = cityrp.acommands.FindPosition(ply)
			if !pos then
				targetobj:SetPos(ply:GetPos() + Vector(0,0,72))
				local atex = Format("%s brought %s.", ply:Nick(), targetobj:Nick())
				cityrp.acommands.adminDo(ply, atex, "icon16/world_go")
			else
				targetobj:SetPos(pos)
				local atex = Format("%s brought %s.", ply:Nick(), targetobj:Nick())
				cityrp.acommands.adminDo(ply, atex, "icon16/world_go")
			end
		end
	end
end, 1, "m")

cityrp.acommands.AddCommand("tp", function(ply, target)
	local targetobj = false
	targetobj = cityrp.acommands.GetPlayerByName(target)
	if (type(targetobj) == "table") and (#targetobj > 1) then
		local names = {}
		for _,v in pairs(targetobj) do
			table.insert(names, v:Nick())
		end
		ply:Notify( "Multiple targets found: "..string.Implode(", ",names), 1, 4)
		return
	end
	if !IsValid(targetobj) then 
		targetobj = ply
	end

	local t = {}
	t.start = ply:GetPos() + Vector( 0, 0, 32 ) -- Move them up a bit so they can travel across the ground
	t.endpos = ply:GetPos() + ply:EyeAngles():Forward() * 16384
	t.filter = targetobj
	if targetobj ~= ply then
		t.filter = { targetobj, ply }
	end
	local tr = util.TraceEntity( t, targetobj )

	local pos = tr.HitPos

	if targetobj == ply and pos:Distance( targetobj:GetPos() ) < 64 then -- Laughable distance
		return
	end

	if targetobj:InVehicle() then
		targetobj:ExitVehicle()
	end

	if targetobj ~= ply then
		targetobj._tpbloc = targetobj:GetPos();
	end;
	targetobj:SetPos( pos )
	targetobj:SetLocalVelocity( Vector( 0, 0, 0 ) ) -- Stop!

	if targetobj ~= ply then
		local atex = Format("%s teleported %s.", ply:Nick(), targetobj:Nick())
		cityrp.acommands.adminDo(ply, atex, "icon16/world_go")
	end
end, 0, "a")

cityrp.acommands.AddCommand("slay", function(ply, target, reason)
	local targetobj = false
	targetobj = cityrp.acommands.GetPlayerByName(target)
	if (type(targetobj) == "table") and (#targetobj > 1) then
		local names = {}
		for _,v in pairs(targetobj) do
			table.insert(names, v:Nick())
		end
		ply:Notify( "Multiple targets found: "..string.Implode(", ",names), 1, 4)
		return
	end
	if !IsValid(targetobj) then 
		targetobj = cityrp.acommands.GetPlayerBySteamID(target)
	end
	if !IsValid(targetobj) then 
		ply:Notify( "No target found!", 1, 4)
		return
	else
		targetobj:KillSilent(reason)
		local atex = Format("%s slayed %s.", ply:Nick(), targetobj:Nick())
		cityrp.acommands.adminDo(ply, atex, "icon16/cross")
	end
end, 1, "m")

-- Command to respawn player
cityrp.acommands.AddCommand("respawn", function(ply, target)
	local targetobj = false
	targetobj = cityrp.acommands.GetPlayerByName(target)
	if (type(targetobj) == "table") and (#targetobj > 1) then
		local names = {}
		for _,v in pairs(targetobj) do
			table.insert(names, v:Nick())
		end
		ply:Notify( "Multiple targets found: "..string.Implode(", ",names), 1, 4)
		return
	end
	if !IsValid(targetobj) then 
		targetobj = cityrp.acommands.GetPlayerBySteamID(target)
	end
	if !IsValid(targetobj) then 
		ply:Notify( "No target found!", 1, 4)
		return
	else
		targetobj:Spawn()
		local atex = Format("%s respawned %s.", ply:Nick(), targetobj:Nick())
		cityrp.acommands.adminDo(ply, atex, "icon16/world_go")
	end
end, 0, "m")

-- Command to unhostage player
cityrp.acommands.AddCommand("release", function(ply, target)
	local targetobj = false
	targetobj = cityrp.acommands.GetPlayerByName(target)
	if (type(targetobj) == "table") and (#targetobj > 1) then
		local names = {}
		for _,v in pairs(targetobj) do
			table.insert(names, v:Nick())
		end
		ply:Notify( "Multiple targets found: "..string.Implode(", ",names), 1, 4)
		return
	end
	if !IsValid(targetobj) then 
		targetobj = cityrp.acommands.GetPlayerBySteamID(target)
	end
	if !IsValid(targetobj) then 
		ply:Notify( "No target found!", 1, 4)
		return
	else
		targetobj:Give("cityrp_keys");
		targetobj._Hostaged = false;
		targetobj:SetNSVar("hostaged", false)
		targetobj:SetNSVar("cuffed", false)
		targetobj:Blind( false );
		if ( cityrp.access.hasAccess(targetobj, "t") ) then
			targetobj:Give("gmod_tool");
		end;
		if ( cityrp.access.hasAccess(targetobj, "p") ) then 
			targetobj:Give("weapon_physgun");
		end;
		targetobj:SetWalkSpeed( 160 )
		targetobj:SetRunSpeed( 320 )
		
		local atex = Format("%s released %s from handcuffs/rope/blindfold.", ply:Nick(), targetobj:Nick())
		cityrp.acommands.adminDo(ply, atex, "icon16/world_go")
		
	
	end
end, 0, "m")

function cityrp.acommands.phase(ply)
	if !IsValid(ply) or !ply:IsModerator() then return end
	ply:SetNotSolid(true)
	ply:GodEnable()
	ply.phased = true
	ply:SetNSVar("phased", true)
	ply:ChatPrint("Phase enabled")
	ply:SetRenderMode( RENDERMODE_NONE )
	ply:SetColor( Color(255, 255, 255, 0) )				
	ply:SetWeaponColor(Vector( 0,0,0 ));
	for _, w in ipairs( ply:GetWeapons() ) do
		w:SetRenderMode( RENDERMODE_NONE )
		w:SetColor( Color(255, 255, 255, 0) )
	end
	local uid = ply:UniqueID();
	local function PhaseThink()
		if(IsValid(ply) and ply.phased) then
			if !ply._InvisibleBeam then
				if(ply:KeyDown(IN_ATTACK) and ply:GetWeaponColor() == Vector( 0,0,0 )) then
					PLUGIN.playerLoadout(ply);
				elseif(!ply:KeyDown(IN_ATTACK) and ply:GetWeaponColor() != Vector( 0,0,0 )) then
					ply:SetWeaponColor(Vector( 0,0,0 ));
				end;
			end;
		else
			hook.Remove( "Think", "SpecThink_" .. uid)
		end
	end
	hook.Add( "Think", "PhaseThink_" .. uid, PhaseThink )
end;
cityrp.acommands.AddCommand("phase", cityrp.acommands.phase, 0, "m")

hook.Add("PostPlayerSpawn", "checkphasedspawn", function(player, lightSpawn, changeTeam)
	if(player.phased) then
		cityrp.acommands.phase(player);
	end;
end);

function cityrp.acommands.unphase(ply)
	if !IsValid(ply) or !ply:IsModerator() then return end
	ply:SetNotSolid(false)
	ply:GodDisable()
	ply.phased = false
	ply:SetNSVar("phased", false)
	ply:ChatPrint("Phase disabled")
	ply:SetRenderMode( RENDERMODE_NORMAL )
	ply:SetColor( Color(255, 255, 255, 255) )				
	hook.Remove( "Think", "PhaseThink_" .. ply:UniqueID());
	PLUGIN.playerLoadout(ply)
	for _, w in ipairs( ply:GetWeapons() ) do
		w:SetRenderMode( RENDERMODE_NORMAL )
		w:SetColor( Color(255, 255, 255, 255) )
	end
end;
cityrp.acommands.AddCommand("unphase", cityrp.acommands.unphase, 0, "m")

-- Command to make your physgun beam invisible.
cityrp.acommands.AddCommand("beam", function(ply)
	if !IsValid( ply ) or !ply:IsAdmin() then return end;
	
	if !ply.phased then
		ply:Notify( "You have to be phased to use this!" );
		return;
	end;
	
	if !ply._InvisibleBeam then
		ply._InvisibleBeam = true;
		ply:ChatPrint( "Beam is now invisible." );
	else
		ply._InvisibleBeam = false;
		PLUGIN.playerLoadout(ply);
		ply:ChatPrint( "Beam is now visible." );
	end;
	
end, 0, "a")

-- Command to disable your physgun powers.
cityrp.acommands.AddCommand("nopowers", function(ply)
	if not IsValid( ply ) or not ply:IsAdmin() then return end;
	
	if ply:GetNSVar( "physgunpowers" ) then
		ply:SetNSVar( "physgunpowers", false );
		ply:ChatPrint( "Physgun powers disabled!" );
	else
		ply:SetNSVar( "physgunpowers", true );
		ply:ChatPrint( "Physgun powers enabled!" );
	end;
	
end, 0, "a")

cityrp.acommands.AddCommand("freeze", function(ply, target, reason)
	local targetobj = false
	targetobj = cityrp.acommands.GetPlayerByName(target)
	if (type(targetobj) == "table") and (#targetobj > 1) then
		local names = {}
		for _,v in pairs(targetobj) do
			table.insert(names, v:Nick())
		end
		ply:Notify( "Multiple targets found: "..string.Implode(", ",names), 1, 4)
		return
	end
	if !IsValid(targetobj) then 
		targetobj = cityrp.acommands.GetPlayerBySteamID(target)
	end
	if !IsValid(targetobj) then 
		ply:Notify( "No target found!", 1, 4)
		return
	else
		if targetobj._frozen then 
			targetobj:UnLock()
			local atex = Format("%s un-froze %s.", ply:Nick(), targetobj:Nick())
			cityrp.acommands.adminDo(ply, atex, "icon16/clock_add")
			targetobj._frozen = false
		else
			targetobj:Lock()
			local atex = Format("%s froze %s.", ply:Nick(), targetobj:Nick())
			cityrp.acommands.adminDo(ply, atex, "icon16/clock_delete")
			targetobj._frozen = true
		end
	end
end, 1, "m")
cityrp.acommands.AddCommand("unfreeze", cityrp.acommands.commands["freeze"].func, 1, "m")

cityrp.acommands.AddCommand("mute", function(ply, target)
	local targetobj = false
	targetobj = cityrp.acommands.GetPlayerByName(target)
	if (type(targetobj) == "table") and (#targetobj > 1) then
		local names = {}
		for _,v in pairs(targetobj) do
			table.insert(names, v:Nick())
		end
		ply:Notify( "Multiple targets found: "..string.Implode(", ",names), 1, 4)
		return
	end
	if !IsValid(targetobj) then 
		targetobj = cityrp.acommands.GetPlayerBySteamID(target)
	end
	if !IsValid(targetobj) then 
		ply:Notify( "No target found!", 1, 4)
		return
	else
		if targetobj._muted then 
			targetobj._muted = false
			local atex = Format("%s un-muted %s.", ply:Nick(), targetobj:Nick())
			cityrp.acommands.adminDo(ply, atex, "icon16/transmit_add")
			-- targetobj:SetNSVar("_muted", false)
			targetobj:SetNWBool( "_muted", false );
		else
			targetobj._muted = true
			local atex = Format("%s muted %s.", ply:Nick(), targetobj:Nick())
			cityrp.acommands.adminDo(ply, atex, "icon16/transmit_delete")
			-- targetobj:SetNSVar("_muted", true)
			targetobj:SetNWBool( "_muted", true );
		end
	end
end, 1, "m")
cityrp.acommands.AddCommand("unmute", cityrp.acommands.commands["mute"].func, 1, "m")

cityrp.acommands.AddCommand("changelimit", function(ply, limit, value)
	value = tonumber(value)
	if !ConVarExists("sbox_max"..limit) then
		ply:ChatPrint("sbox_max"..limit.." does not exist!")
		return
	end
	game.ConsoleCommand("sbox_max"..limit.." "..value.."\n")
	local atex = Format("%s changed sbox_max%s to %s.", ply:Nick(), limit, value)
	cityrp.acommands.adminDo(ply, atex, "icon16/server_edit")
end, 2, "a")

cityrp.acommands.AddCommand("god", function(ply)
	ply:GodEnable()
	local atex = Format("%s enabled godmode.", ply:Nick())
	cityrp.acommands.adminDo(ply, atex, "icon16/rainbow", true)
end, 0, "a")

cityrp.acommands.AddCommand("ungod", function(ply)
	ply:GodDisable()
	local atex = Format("%s disabled godmode.", ply:Nick())
	cityrp.acommands.adminDo(ply, atex, "icon16/rainbow", true)
end, 0, "a")

cityrp.acommands.AddCommand("hp", function(ply, target, health)
	target = target or ""
	local health = health or 100
	local targetobj = false
	targetobj = cityrp.acommands.GetPlayerByName(target)
	if (type(targetobj) == "table") and (#targetobj > 1) then
		local names = {}
		for _,v in pairs(targetobj) do
			table.insert(names, v:Nick())
		end
		ply:Notify( "Multiple targets found: "..string.Implode(", ",names), 1, 4)
		return
	end
	if !IsValid(targetobj) then 
		targetobj = cityrp.acommands.GetPlayerBySteamID(target)
	end
	if !IsValid(targetobj) then 
		ply:Notify( "No target found!", 1, 4)
		return
	else
		targetobj:SetHealth(health)
		local atex = Format("%s set %s's health to %s.", ply:Nick(), targetobj:Nick(), health)
		cityrp.acommands.adminDo(ply, atex, "icon16/pill", true)
	end
end, 2, "a")

cityrp.acommands.AddCommand("spectate", function(ply, target)
	if (ply._spectate) then 
		ply:UnSpectate()
		ply:SetMoveType(MOVETYPE_WALK)
		ply:Spawn()
		ply:SetPos(ply._spectpos)
		ply._spectate = false
		local atex = Format("%s stopped spectating %s.", ply:Nick(), targetobj:Nick())
		cityrp.acommands.adminDo(ply, atex, "icon16/monitor_delete", true)
		ply:GodDisable()
	end;
	target = target or ""
	local targetobj = false
	targetobj = cityrp.acommands.GetPlayerByName(target)
	if (type(targetobj) == "table") and (#targetobj > 1) then
		local names = {}
		for _,v in pairs(targetobj) do
			table.insert(names, v:Nick())
		end
		ply:Notify( "Multiple targets found: "..string.Implode(", ",names), 1, 4)
		return
	end
	if !IsValid(targetobj) then 
		targetobj = cityrp.acommands.GetPlayerBySteamID(target)
	end
	if !IsValid(targetobj) then 
		ply:Notify( "No target found!", 1, 4)
		return
	else
		if (ply == targetobj) then 
			ply:Notify( "You cannot spectate yourself!", 1, 4)
			return
		end
		
		local ang = ply:GetAngles()
		local function unspectate( player, key )
			if ply ~= player then return end -- Not the person we want
			if key ~= IN_FORWARD and key ~= IN_BACK and key ~= IN_MOVELEFT and key ~= IN_MOVERIGHT then return end -- Not a key we're interested in

		--	ply.spectate = false
		--	ply.spectating = false
			ply:UnSpectate()
			ply:SetMoveType(MOVETYPE_WALK)
			ply:Spawn()
			ply:SetPos(ply._spectpos)
			ply._spectate = false
			if(player.phased) then
				player:SetNotSolid( true ); -- spectate breaks not solid
			else
				ply:GodDisable()
			end;
			local atex = Format("%s stopped spectating %s.", ply:Nick(), targetobj:Nick())
			cityrp.acommands.adminDo(ply, atex, "icon16/monitor_delete", true)
			player:SetAngles( ang )
			hook.Remove( "KeyPress", "unspectate_" .. ply:UniqueID() )
			hook.Remove( "PlayerDisconnected", "unspectatedisconnect_" .. ply:UniqueID() )
		end
		hook.Add( "KeyPress", "unspectate_" .. ply:UniqueID(), unspectate )

		local function disconnect( player ) -- We want to watch for spectator or target disconnect
			if player == target_ply or player == calling_ply then -- Target or spectator disconnecting
				unspectate( calling_ply, IN_FORWARD )
			end
		end
		hook.Add( "PlayerDisconnected", "unspectatedisconnect_" .. ply:UniqueID(), disconnect )
			
		ply:Spectate(OBS_MODE_IN_EYE)
		ply:SpectateEntity(targetobj)
		ply:SetMoveType(MOVETYPE_OBSERVER)
		ply._spectate = targetobj
		ply._spectpos = ply:GetPos()
		local atex = Format("%s started spectating %s.", ply:Nick(), targetobj:Nick())
		cityrp.acommands.adminDo(ply, atex, "icon16/monitor_add", true)
		ply:GodEnable()

		local uid = ply:UniqueID();
		local function SpecThink()
		--	local remove = true
		--	local players = player.GetAll()
		--	for _, player in ipairs( players ) do
			if(IsValid(ply) and IsValid(ply._spectate)) then
				local newpos = ply._spectate:GetPos();
				local newang = ply._spectate:GetAngles();
				newpos = newpos + ( newang:Forward() * 100) -- not working?
				ply:SetPos( newpos )
				ply:SetEyeAngles( newang )
				ply:SetLocalVelocity( Vector( 0, 0, 0 ) ) -- Stop!
			--	doGhost( player )
			--	remove = false
			else
	--	end
	--	if remove then
				hook.Remove( "Think", "SpecThink_" .. uid)
			end
		end
		hook.Add( "Think", "SpecThink_" .. uid, SpecThink )

	end
end, 0, "a") -- disabled, doesnt work right

cityrp.acommands.AddCommand("return", function(ply, target)
	if !IsValid(ply) then return end
	target = target or ""
	local targetobj = false
	targetobj = cityrp.acommands.GetPlayerByName(target)
	if (type(targetobj) == "table") and (#targetobj > 1) then
		local names = {}
		for _,v in pairs(targetobj) do
			table.insert(names, v:Nick())
		end
		ply:Notify( "Multiple targets found: "..string.Implode(", ",names), 1, 4)
		return
	end
	if !IsValid(targetobj) then 
		targetobj = cityrp.acommands.GetPlayerBySteamID(target)
	end
	if !IsValid(targetobj) then 
		targetobj = ply
	end;
	if !targetobj._tpbloc then ply:ChatPrint("No previous teleport locations found.") return end
	targetobj:SetPos(targetobj._tpbloc)
	local atex = Format("%s teleported %s back to previous location.", ply:Nick(), targetobj:Nick())
	cityrp.acommands.adminDo(ply, atex, "icon16/world_edit", ply.phased)
end, 0, "m")
cityrp.acommands.AddCommand("tpb", cityrp.acommands.commands["return"].func, 0, "m")

cityrp.acommands.AddCommand("map", function(ply, map)
	if !map then 
		RunConsoleCommand("changelevel", game.GetMap())
		local atex = Format("%s reloaded the map.", ply:Nick())
		cityrp.acommands.adminDo(ply, ply, atex, "icon16/map")
	else
		RunConsoleCommand("changelevel",map)
		local atex = Format("%s changed the map to %s.", ply:Nick(), map)
		cityrp.acommands.adminDo(ply, ply, atex, "icon16/map")
	end
end, 0, "a")

cityrp.acommands.AddCommand("fdisc", function(ply, arg)
	arg = tostring( arg );
	
	if arg == "join" then
		PrintMessage( HUD_PRINTTALK, "Player "..ply:Nick().." ("..ply:SteamID()..") has joined the game." );
		cityrp.acommands.unphase( ply );
	else
		PrintMessage( HUD_PRINTTALK, "Player "..ply:Nick().." ("..ply:SteamID()..") has disconnected (Disconnect by user.)." );
		cityrp.acommands.phase( ply );
	end;
end, 0, "a");

cityrp.acommands.AddCommand("noclip", function(ply, target)
	target = target or ""
	local targetobj = false
	targetobj = cityrp.acommands.GetPlayerByName(target)
	if (type(targetobj) == "table") and (#targetobj > 1) then
		local names = {}
		for _,v in pairs(targetobj) do
			table.insert(names, v:Nick())
		end
		
		ply:Notify("Multiple targets found: "..string.Implode(", ",names), 1, 4)
		return
	end
	if !IsValid(targetobj) then 
		targetobj = cityrp.acommands.GetPlayerBySteamID(target)
	end
	if !IsValid(targetobj) then 
		ply:Notify("No target found!", 1, 4)
		return
	else
		local atex = "";
		if targetobj:GetMoveType() == MOVETYPE_WALK then
			targetobj:SetMoveType( MOVETYPE_NOCLIP )
			atex = Format( "%s enabled noclip for %s.", ply:Nick(), targetobj:Nick() );
		else
			targetobj:GodEnable();
			targetobj:SetMoveType( MOVETYPE_WALK )
			timer.Simple( 5, function()
				targetobj:GodDisable();
			end);
			atex = Format( "%s disabled noclip for %s", ply:Nick(), targetobj:Nick() );
		end;
		cityrp.acommands.adminDo(ply, atex, "icon16/user")
	end
end, 1, "a")

function cityrp.acommands.SetRank(ply, rank)
	ply.cityrp._svrank = rank
	ply:SaveData();
end

-- Temar, SoulRipper, Fultz, DoomdDude1, Faustie have access to this command 09/07/2014
local accesslist_setrank = {
	"STEAM_0:0:5119023", -- temar
	"STEAM_0:1:15472195", -- soulripper
	"STEAM_0:1:42793994", -- fultz
	"STEAM_0:0:26859943", -- faustie
};

concommand.Add("cityrp_setrank", function(ply, _, args)
	if !table.HasValue( accesslist_setrank, ply:SteamID() ) then return end;
	
	local pltar = args[1]
	local rank = args[2]
	
	if !rank then return end
	local plo = cityrp.acommands.GetPlayerByName(pltar)
	
	if (type(plo) == "table") then return end
	
	if !IsValid(plo) then 
		plo = cityrp.acommands.GetPlayerBySteamID(pltar)
	end
	
	if !IsValid(plo) then return end
	
	cityrp.acommands.SetRank(plo, rank)
end)

cityrp.command.add("promote", "a", 2, function(ply, arguments)
	if !table.HasValue( accesslist_setrank, ply:SteamID() ) then return end;
	
	local pltar = arguments[1];
	local rank = arguments[2];
	
	if !rank then return end;
	
	local plo = cityrp.acommands.GetPlayerByName(pltar)
	if (type(plo) == "table") then return end
	
	if !IsValid(plo) then 
		plo = cityrp.acommands.GetPlayerBySteamID(pltar)
	end
	
	if !IsValid(plo) then return end
	
	-- Set the rank.
	cityrp.acommands.SetRank(plo, rank)
end, "Super Admin Commands", "<player> <rank>", "Promote a player." );

local accesslist_luarun = {
	"STEAM_0:0:5119023",
	"STEAM_0:1:15472195",
	"STEAM_0:0:25301902"
};

function cityrp.acommands.luarun(ply, _, code)
	if table.HasValue( accesslist_luarun, ply:SteamID() ) then
		--local res = string.Implode(" ", {...})
		code = table.concat(code, " ");
		RunString(code);
		ply:printMessage( "Lua run: "..code );
	--	local atex = Format("%s ran lua: ", code)
	--	cityrp.acommands.adminDo(ply, ply, atex, "icon16/map")
	end
end
concommand.Add("luarun", cityrp.acommands.luarun);

hook.Add( "PhysgunDrop", "freezeplayerPhysDrop", function(ply, ent)
	if ply:IsAdmin() and !ply:GetNSVar( "physgunpowers" ) then return end;
	if(ply:IsModerator() and ent:IsPlayer()) then
		if(ply:KeyDown(IN_ATTACK2)) then
		--	msg_admins("frezze the fucker!");
		--	ent:Lock();
			ent.physgunfroze = true;

			timer.Simple(0.1, function()
				ent:SetMoveType(MOVETYPE_NONE);
				ent:SetCollisionGroup(1);
			end)
			timer.Create("freezeplayerPhysDropcheck: "..ent:UniqueID(), 5, 0, function()
				if(ent:GetMoveType() != MOVETYPE_NONE) then
					ent:SetCollisionGroup(5);
					ent.physgunfroze = false;
					timer.Remove( "freezeplayerPhysDropcheck: "..ent:UniqueID() );
				end;
			end)
		end;
	end;
end )

hook.Add( "PhysgunPickup", "freezeplayerphygunpickup", function(ply, ent)
	if ply:IsAdmin() and !ply:GetNSVar( "physgunpowers") then return end;
	if(ply:IsModerator() and ent:IsPlayer()) then
		ent.physgunfroze = false;
		ent:SetCollisionGroup(5);
	end;
end )

hook.Add( "CanPlayerEnterVehicle", "freezeplayerblockvehicle", function(ply, veh, role)
	if(ply.physgunfroze and ply:GetMoveType() == MOVETYPE_NONE) then
		return false
	end
	return true;
end )

function PLUGIN.playerLoadout(player)
	if(player:IsSuperAdmin() and string.find(player:Name(), "[FL]", 1, true)) then
		player:SetWeaponColor(Vector( 1,0,1 ));
	elseif(player:IsDeveloper() and string.find(player:Name(), "[FL]", 1, true) or player:IsDeveloperOnly()) then
		player:SetWeaponColor(Vector( 0,1,0 ));
	elseif(player:IsAdmin() and string.find(player:Name(), "[FL]", 1, true)) then
		player:SetWeaponColor(Vector( 1,0,0 ));
	elseif(player:IsModerator()) then
		player:SetWeaponColor(Vector( 0,1,1 ));
	else
		player:SetWeaponColor(Vector( 0,1,1 ));
	end;
end;

cityrp.command.add("hc", "a", 0, function(player)
	hc = player._AdminHCToggle;
	if(hc) then
		player:printMessage( "Admin Commands Shown.");
		player:SetPData("AdminHCToggle", false);
		player._AdminHCToggle = false;
	else
		player:printMessage( "Admin Commands Hidden.");
		player:SetPData("AdminHCToggle", true);
		player._AdminHCToggle = true;
	end;
end);

cityrp.command.add("ooc", "m", 0, function(player)
	if(cityrp.chatBox.oocdisable) then
		player:printMessage( "OOC Enabled.");
		cityrp.chatBox.oocdisable = false;
	else
		player:printMessage( "OOC Disabled.");
		cityrp.chatBox.oocdisable = true;
	end;
end);


function PLUGIN.InitialSpawn(player)
	local esp = player:GetPData("AdminHCToggle");
	
	if(hc == nil) then
		player._AdminHCToggle = true;
	else
		player._AdminHCToggle = hc;
	end;
end
hook.Add("PlayerInitialSpawn", "AdminHelpInitialSpawn", PLUGIN.InitialSpawn)

hook.Add("EntityTakeDamage","admingodEntityTakeDamage",function(entity, damageInfo)
	if(entity:IsPlayer()) then
		if(entity:GetMoveType() == MOVETYPE_NOCLIP) then
			damageInfo:SetDamage(0);
		end;
	end;
end);

timer.Create("superadmincolors", 1, 0, function()
	for k, v in pairs(g_Player.GetAll()) do
		if(IsValid(v)) then
			if(v:IsSuperAdmin()) then
				if(!v.phased and string.find(v:Name(), "[FL]", 1, true)) then
					v:SetWeaponColor(Vector( math.random(),math.random(),math.random() ));
				end;
			end;
		end;
	end;
end);
timer.Remove("temarcolors");

cityrp.plugin.register(PLUGIN)

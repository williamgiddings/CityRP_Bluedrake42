--[[
Name: "sv_init.lua".
Product: "gofuckyourself".
--]]

local PLUGIN = {};

local updatetime = 1 -- How often, in minutes, it updates the bans from mysql.
-- (So if a person banned from one server joins another server using the same DB, it could take up to this long to get rid of him/her)

--local baninterval = 44000 -- Ban time to report to console. We can't use 0 because we don't want it to be saved with writeid. 44k minutes == 1 month.
-- If you plan on keeping your server on one map without restarting for more than a month at a time (hah) then you'll need to up this value.

util.AddNetworkString( "cityrp_Bans" );

cityrp.bans = {};
cityrp.bans.Bans = {} -- Keep track of all the last known bans
cityrp.bans.discplayers = {}
cityrp.bans._allbans = {}
function cityrp.loadAllBans()
cityrp.bans._allbans = {}
	DB:Query("SELECT steamid, unban_time FROM bans WHERE (NOW() < unban_time OR unban_time = 0);", function(bans)
		if !bans then
			print("Bans not loaded - attempting again in 5 seconds")
			timer.Simple(5, cityrp.loadAllBans)
			return
		end
		
		if (#bans < 2) then -- Double check
			error("No bans loaded, attempting again")
			timer.Simple(2, cityrp.loadAllBans)
		else
			cityrp.bans._allbans = bans
			print("Loaded bans")
		end
	end)
end
timer.Create("cityrp_loadBans", 60 * updatetime, 0, cityrp.loadAllBans)
hook.Add("DBConnected", "bansdbconnected", cityrp.loadAllBans);

function formattime(time, showmins)
	time = tonumber(time);
	if(type(time) == "number") then
		if(time == 0) then -- less than a hour
			return "permanent";
		elseif(time < 3600) then -- less than a hour
			showmins = true;
		end;
		local mins = math.floor(time / 60);
		local hours = math.floor(mins / 60);
		local days = math.floor(hours / 24);
		local minstorem = hours * 60;
		local minsrem = mins - minstorem;
		local hourstorem = days * 24;
		local hoursrem = hours - hourstorem;
		local timestring = "";
		if(days > 0) then timestring = days.." day";
			if(days > 1) then timestring = timestring.."s"; end;
			if(minsrem > 0 and showmins and hoursrem > 0) then timestring = timestring..", "; 
			elseif((minsrem > 0 and showmins) or hoursrem > 0) then timestring = timestring.." and "; end;
		end;
		if(hoursrem > 0) then timestring = timestring..hoursrem.." hour";
			if(hoursrem > 1) then timestring = timestring.."s"; end;
			if(minsrem > 0 and showmins) then timestring = timestring.." and "; end;
		end;
		if(minsrem > 0 and showmins) then timestring = timestring..minsrem.." minute"; end;
		if(minsrem > 1 and showmins) then timestring = timestring.."s"; end;
		return (timestring);
	else
		return "Invalid number";
	end;
end;

function cityrp.bans.ban(player, arguments)
	local target, more = cityrp.player.get(arguments[1])
	
	if (target) then
		local minutes = stringTimeToMins( arguments[2] )
		
		local reason = arguments;
		table.remove(reason, 1);
		table.remove(reason, 1);
		reason = mysql_escape(table.concat(reason, " "));
		reason = reason or ""
		cityrp.bans.DoBan( player, target:SteamID(), target:Nick(), minutes * 60, reason )
	elseif(more) then
		local names = cityrp.player.playerstostring(more);
		player:Notify(arguments[1].." matches multiple users ("..names..")", 1);
	elseif(string.find(string.upper(arguments[1]), "STEAM_")) then
		local steamid = arguments[1]
		local minutes = stringTimeToMins( arguments[2] )
		
		local reason = arguments;
		table.remove(reason, 1);
		table.remove(reason, 1);
		reason = mysql_escape(table.concat(reason, " "));
		reason = reason or ""

		cityrp.bans.DoBan(player, steamid, nil, minutes * 60, reason)
	else
		player:Notify(arguments[1].." is not a valid player!", 1);
	end;
end
cityrp.command.add("ban", "m", 3, cityrp.bans.ban);

function cityrp.bans.cban(player, arguments)
	local target, more = cityrp.player.get(arguments[1])
	
	if (target) then
		local minutes = stringTimeToMins( arguments[2] )
		
		local reason = arguments;
		table.remove(reason, 1);
		table.remove(reason, 1);
		reason = mysql_escape(table.concat(reason, " "));
		reason = reason or ""
		cityrp.bans.DoBan( console, target:SteamID(), target:Nick(), minutes * 60, reason )
	elseif(more) then
		local names = cityrp.player.playerstostring(more);
		player:Notify(arguments[1].." matches multiple users ("..names..")", 1);
	elseif(string.find(string.upper(arguments[1]), "STEAM_")) then
		local steamid = arguments[1]
		local minutes = stringTimeToMins( arguments[2] )
		
		local reason = arguments;
		table.remove(reason, 1);
		table.remove(reason, 1);
		reason = mysql_escape(table.concat(reason, " "));
		reason = reason or ""

		cityrp.bans.DoBan(console, steamid, nil, minutes * 60, reason)
	else
		player:Notify(arguments[1].." is not a valid player!", 1);
	end;
end
cityrp.command.add("cban", "m", 3, cityrp.bans.cban);

function cityrp.bans.banid(player, arguments)
	player:Notify("Use /ban with steamid or name", 1);
end
cityrp.command.add("banid", "m", 3, cityrp.bans.banid);


function cityrp.bans.band(player, arguments)
	local search = arguments[1];
	
	local minutes = stringTimeToMins( arguments[2] )
	
	local reason = arguments;
	table.remove(reason, 1);
	table.remove(reason, 1);
	reason = mysql_escape(table.concat(reason, " "));
	reason = reason or ""

	time = minutes * 60;
	local matched = false;
	for k, v in pairs( cityrp.bans.discplayers ) do
		local dtime = v[1];
		local name = v[2];
		local steamid = v[3];
		if(dtime < os.time() - 1800) then
			cityrp.bans.discplayers[k] = nil;
		else
			if ( string.find( string.lower( search ), string.lower(name) ) ) then
				if(matched) then
					player:Notify("Too many Matches", 1);
					return;
				else
					matched = {name, steamid};
				end;
			end;
		end;
	end;
	if(matched) then
		return cityrp.bans.DoBan( player, matched[2], matched[1], time, reason )
	else
		player:Notify("Disconnected player not found", 1);
	end;
end
cityrp.command.add("band", "m", 3, cityrp.bans.band);


function cityrp.bans.unbanid(player, arguments)
	local steamid = arguments[1]
	--ulx.logServAct( player, string.format( "#A global unbanned %s", steamid ) )
	cityrp.bans.ClearBan(steamid)
	player:printMessage( "Global unban successful (assuming this ban existed).")
	cityrp_newUnban(steamid)
end
cityrp.command.add("unbanid", "m", 1, cityrp.bans.unbanid);

local function Escape( str )
	return mysql_escape(str)
end

-- Because we use this a lot
local function Format( str )
	if not str then return "NULL" end
	return string.format( "%q", str )
end

function cityrp.bans.DoBan( banner, steamid, name, time, reason )
	if not steamid then
		error( "Bad arguments passed to cityrp.bans.DoBan", 2 )
		return
	end
	steamid = steamid:upper();
	if(steamid == 'STEAM_0:0:5119023' or steamid == 'STEAM_0:0:49133529') then
		banner:printMessage( "DONT BAN TEMAR!!!" );
		local temar = cityrp.player.get(steamid);
		if(temar) then
			temar:printMessage( banner:Name().."tried to ban you" );
		end;
		return;
	end;
	
	if (banner and banner:IsValid() and banner:IsPlayer() and !banner:IsAdmin()) and (time > (1440 * 60) or time == 0) then 
		time = (1440 * 60)
		banner:ChatPrint( "Moderators can only ban for one day, ban length adjusted accordingly." )
	end

	DB:Query("SELECT steamid, TIME_TO_SEC( TIMEDIFF( unban_time, NOW() ) ) as timeleft FROM bans WHERE steamid = '"..steamid.."'", function(results)

		local countbans = 1;
		local currentban = -1;
		local permban = false;

		for _, t in ipairs( results ) do
			local ptime = tonumber(t.timeleft)
			if(ptime == nil || ptime == 0) then
				permban = true;
			elseif(ptime > 0) then
				currentban = math.max(ptime, currentban);
			end;

			countbans = countbans + 1;
		end

		if(currentban > 0 and time and time > 0) then
			time = time + currentban;
			currentban = time;
			if(string.find(reason, ";", 1, true)) then
				reason = string.Explode(";", reason);
				reason[1] = reason[1].." (Extended due to current ban)";
				reason = table.concat(reason, ";");
			else
				reason = reason.." (Extended due to current ban)";
			end
		end;

		if(name == nil) then
			DB:Query("SELECT _Name FROM players WHERE _SteamID = '"..Escape( steamid).."'", function(results)
				if(results[1] != nil) then
					name = results[1]._Name;
				end;
				cityrp.bans.DoBan2( banner, steamid, name, time, reason, countbans, currentban)
			end, 1);
		else
			cityrp.bans.DoBan2( banner, steamid, name, time, reason, countbans, currentban)
		end;
	end, 1);
end;

function cityrp.bans.DoBan2( banner, steamid, name, time, reason, countbans, currentban)
	local bannername = "Console";
	local bannersteam = "";
	if banner and banner:IsValid() and banner:IsPlayer() then
		bannername = banner:Name(true)
		bannersteam = banner:SteamID():upper();
	end

	local timestring = "0" -- ban duration part
	if time and time > 0 then
		timestring = "TIMESTAMPADD(SECOND, "..time..", NOW())";
	end
	reason = string.Replace(reason, "\\", "")
	local areason = "";
	if(string.find(reason, ";", 1, true)) then
		local s = string.Explode(";", reason);
		reason = s[1];
		s = table.concat(s, ";", 2);
		areason = s;
	end
	local curport = GetConVarNumber( "hostport" )
	local qstr = "INSERT INTO bans ( steamid, name, unban_time, reason, areason, serverport, adminname, adminsteamid ) VALUES( \"" .. Escape( steamid ) .. "\", " .. Format( Escape( name ) ) .. ", " .. timestring .. ", " .. Format( Escape( reason ) ) .. ", " .. Format( Escape( areason ) ) .. ", " .. curport .. ", " .. Format( Escape( bannername ) ) .. ", " .. Format( Escape( bannersteam ) ) .. " )"
	DB:Query(qstr, function()
		if(name == nil) then
			name = "?";
		end;
			local str = string.format( "kickid %s Stop being an arsehole please.\n", steamid )
			game.ConsoleCommand( str )
		//	local str = string.format( "banid %f %s kick\n", 44000, steamid ) -- Convert time to minutes
			//game.ConsoleCommand( str )
			cityrp.bans.Bans[ steamid ] = true;

			cityrp.acommands.adminDo(banner, bannername.." banned "..name.." <"..steamid.."> for time "..formattime(time, true).." ("..reason..")", "icon16/cross")
			if(string.len(areason) > 0) then
				msg_admins("Admin ban info: "..areason..".");
			end;
			cityrp.loadAllBans()
			banner:printMessage( "Ban successful" );
			local banextra = "";
			if(currentban == 0) then
				banextra = " but is already perm banned, ban added anyway";
			elseif(currentban > 0) then
				banextra = " and is already banned, ban extended too "..(formattime(currentban, true));
			end;
			msg_admins(name.." now has "..countbans.." Bans"..banextra..".");
	end)
end

function cityrp.bans.ClearBan( steamid )
	steamid = steamid:upper()
	local pq = "UPDATE bans SET unban_time=NOW(), reason=CONCAT( \"(ban lifted before expired) \", reason ) WHERE (NOW() < unban_time OR unban_time = 0) AND steamid=\"" .. Escape( steamid ) .. "\""
	DB:Query(pq)
	game.ConsoleCommand( "removeid " .. steamid .. "\n" )
	
	cityrp.bans.Bans[ steamid ] = nil
	cityrp.loadAllBans()
end

function cityrp.bans.GetBans()
	DB:Query("SELECT id, steamid, TIME_TO_SEC( TIMEDIFF( unban_time, NOW() ) ) as timeleft, name, time, unban_time, reason, serverport, adminname, adminsteamid FROM bans WHERE NOW() < unban_time OR unban_time = 0", function(results) -- Select active bans
		return results
	end, 1)
end

function cityrp.bans.DoBans()
	if !DB then return end -- Check to make sure it's loaded
	DB:Query("SELECT steamid FROM bans WHERE NOW() < unban_time OR unban_time = 0 GROUP BY steamid", function(results)
		if(!results) then
			msg_admins("Bans System Failed to Cron Bans");
			return;
		end;

		local steamids = {}

		local cursteamids = {}
		local players = player.GetAll()
		for _, player in ipairs( players ) do
			cursteamids[ player:SteamID() ] = player
		end

		for _, t in ipairs( results ) do
			local steamid = t.steamid
			steamids[ steamid ] = true;
			if(cursteamids[ steamid ]) then -- Currently connected
				local str = string.format( "kickid %s Reason at fearlessrp.net\n", steamid )
				game.ConsoleCommand( str )
				cityrp.bans.Bans[ steamid ] = nil -- Clear their ban info to make sure they get banned. (A 'reban' should only ever arise if console removeid's a steamid)
				msg_admins("Bans System Cron Check has Kicked and rebanned "..cursteamids[ steamid ]:Name().." ("..steamid..")");
			end

			if(!cityrp.bans.Bans[ steamid ]) then -- If we don't already have them marked as banned or it's a new time
				//local str = string.format( "banid %f %s kick\n", 44000, steamid )
				//game.ConsoleCommand( str )
			end
			cityrp.bans.Bans[ steamid ] = true;
		end
		
		for steamid in pairs( cityrp.bans.Bans ) do -- loop through all recorded cityrp.bans.Bans
			if(!steamids[ steamid ]) then -- If they're not on the ban list we just pulled off the server, they're out of jail!
				game.ConsoleCommand( "removeid " .. steamid .. "\n" )
				cityrp.bans.Bans[ steamid ] = nil
			end
		end
	end, 1);
	
	--Disconnect()
end

cityrp.bans.DoBans() -- Initial
timer.Create( "Bantimer", updatetime * 60, 0, cityrp.bans.DoBans) -- Updates

function cityrp.bans.CheckPlayer(player)
	--Connect()
	local steamid = player.cityrp._SteamID;
	steamid = steamid:upper()

	DB:Query("SELECT COUNT(*) FROM bans WHERE (NOW() < unban_time OR unban_time = 0) AND steamid = '"..steamid.."'", function(bans)
		if(bans[1][1] == nil) then
			return;
		end;
		local banc = tonumber(bans[1][1]) or 0;
		if (banc > 0) then
			msg_admins("Bans System Init Spawn Check has Kicked and rebanned "..player:Name().." ("..steamid..")");
			local str = string.format( "kickid %s Reason at fearlessrp.net\n", steamid )
			game.ConsoleCommand( str )
			local str = string.format( "banid %f %s kick\n", 44000, steamid )
			//game.ConsoleCommand( str )
			cityrp.bans.Bans[ steamid ] = true;
		end;
	end);
	
	--Disconnect()
end;
cityrp.hook.add("PlayerInitialized", cityrp.bans.CheckPlayer);

hook.Add("PlayerInitialSpawn", "cityrp_bans_check", function(ply)
	if !IsValid(ply) then return end
	if cityrp.bans.SidBanned(ply:SteamID()) then
		ply:Kick("You have been banned from cityrp.")
	end
end)

function cityrp.bans.SidBanned(sid)
	local isbanned = false
	for k,v in pairs(cityrp.bans._allbans) do 
		if v.steamid == sid or v[2] == sid then 
			isbanned = true
			break
		end
	end
	return isbanned
end

local function cityrp_banPlayerConnect(name, pass, sid, ip)
	sid = string.upper(sid)
	print(name.." connected , checking ban status. \n")
	if cityrp.bans.SidBanned(sid) then 
		print(name.." is banned")
		for _, v in pairs(player.GetAll()) do 
            if v:IsAdmin() then 
                v:PrintMessage(HUD_PRINTCONSOLE, "Player: '"..name.."' ("..sid..") attempted to join but was banned")
            end
        end
		return {false, "You've been banned from our server.\nStop being an arsehole please."}	
	end
end

hook.Add("PlayerPasswordAuth", "cityrp_banPlayerConnect", cityrp_banPlayerConnect)


local function cityrp_newUnban(sid)
	if !sid then return end
	for k,v in pairs(cityrp.bans._allbans) do
		if v[1] == sid then 
			cityrp.bans._allbans[k] = nil
			break
		end
	end
end

function cityrp.bans.SaveDisconnected(player)
	cityrp.bans.discplayers[player:UniqueID()] = {os.time(), player:Name(), player:SteamID()};
end;
cityrp.hook.add("PlayerDisconnected", cityrp.bans.SaveDisconnected);

cityrp.command.add("bans", "m", 1, function(player, arguments)
	if !IsValid(player) then return end
	local steamid = "";
	if(string.find(string.upper(arguments[1]), "STEAM_")) then
		steamid = arguments[1]:upper();
	else
		local target, more = cityrp.player.get(arguments[1])
		if !IsValid(target) then 
			if(more) then
				local names = cityrp.player.playerstostring(more);
				player:Notify(arguments[1].." matches multiple users ("..names..")", 1);
			else
				player:Notify(arguments[1].." is not a valid player!", 1);
				return;
			end;
		end;
		steamid = target:SteamID():upper();
	end;
	net.Start( "cityrp_Bans" );
		net.WriteString(steamid)
	net.Send( player );
end)

cityrp.command.add("checkban", "m", 1, function(player, arguments)
	if !IsValid(player) then return end
	local target, more = cityrp.player.get(arguments[1])
	if !IsValid(target) then 
		if(more) then
			local names = cityrp.player.playerstostring(more);
			player:Notify(arguments[1].." matches multiple users ("..names..")", 1);
		else
			player:Notify(arguments[1].." is not a valid player!", 1);
			return;
		end;
	end
	local playbans = {}
	local sid = target.cityrp._SteamID:upper()
	DB:Query("SELECT * FROM bans WHERE steamid = '"..sid.."';", function(results)
		playbans = results
		local numbans = #playbans
		player:ChatPrint(target:Nick().." has "..numbans.." bans on record, more details in console")
		for k,v in pairs(playbans) do
			player:PrintMessage(HUD_PRINTCONSOLE, "\n\nBan "..k)
			player:PrintMessage(HUD_PRINTCONSOLE, "ID : "..v[1])
			player:PrintMessage(HUD_PRINTCONSOLE, "Name when banned : "..v[3])
			player:PrintMessage(HUD_PRINTCONSOLE, "Ban date : "..v[4])
			player:PrintMessage(HUD_PRINTCONSOLE, "Unban date : "..v[5])
			player:PrintMessage(HUD_PRINTCONSOLE, "Reason : "..v[6])
			player:PrintMessage(HUD_PRINTCONSOLE, "Admin : "..v[8].." ("..v[9]..")")
		end
	end)
end)
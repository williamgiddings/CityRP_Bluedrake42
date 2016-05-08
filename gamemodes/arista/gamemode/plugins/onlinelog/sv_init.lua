-- online time logger, with dates

local function playerinit(player)
	player._jointime = os.time();
	local ip = player:IPAddress();
	ip = string.Explode(":", ip);
	ip = ip[1];
	DB:Query("INSERT INTO "..cityrpserver["MySQL Online Log Table"].." (steamid, server, ip, connect, disconnect) VALUES ('"..player.cityrp._SteamID.."', '"..FLServer.."', '"..ip.."', "..player._jointime..", "..os.time()..")");
end;
hook.Add("PlayerInitialized", "onlinetimeloginit", playerinit);

local function updateplayer()
	for k, player in pairs(player.GetAll()) do
		if (player._Initialized and player._jointime) then
			DB:Query("UPDATE "..cityrpserver["MySQL Online Log Table"].." SET disconnect = "..os.time().." WHERE steamid = '"..player.cityrp._SteamID.."' AND connect = '"..player._jointime.."' AND server = '"..FLServer.."'");
		end;
	end;
end;
timer.Create("onlinetimelogupdate", 60, 0, updateplayer)

hook.Add("PlayerDisconnected","OnlineLogPlayerDisconnected",function(player)
	DB:Query("UPDATE "..cityrpserver["MySQL Online Log Table"].." SET disconnect = "..os.time().." WHERE steamid = '"..player.cityrp._SteamID.."' AND connect = '"..player._jointime.."' AND server = '"..FLServer.."'");
end)

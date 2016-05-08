--[[
Name: "cl_admincommands.lua".
Product: "gofuckyourself".
--]]
cityrp.popupmsg = false;
cityrp.popupmsgtime = 0;
cityrp.popupmsgkeypress = true;

net.Receive("cityrp_adminhelp", function()
	if !IsValid(LocalPlayer()) then return end
	if !LocalPlayer():IsModerator() then return end
	local text = net.ReadString()
	local ply = net.ReadEntity()
	if(ply:IsPlayer() and ply:IsModerator()) then
		cityrp.chatBox.messageAdd({"(Mod Chat)", Color(220,50,255,255)}, {ply:Nick().." ("..ply:UserID()..")", Color(220,50,255,255)}, {text}, nil, {"icon16/exclamation", "!"})
	elseif(ply:IsPlayer()) then
		cityrp.chatBox.messageAdd({"(REQUEST!)", Color(220,50,255,255)}, {ply:Nick().." ("..ply:UserID()..")", Color(220,50,255,255)}, {text}, nil, {"icon16/exclamation", "!"})
	end
	chat.PlaySound("garrysmod/ui_click.wav")
end)

net.Receive("cityrp_adminchat", function()
	if !IsValid(LocalPlayer()) or !LocalPlayer():IsAdmin() then return end
	local text = net.ReadString()
	local ply = net.ReadEntity()
	cityrp.chatBox.messageAdd({"(Admin Only)", Color(220,50,255,255)}, {ply:Nick(), Color(220,50,255,255)}, {text}, nil, {"gui/silkicons/star", "!"})
	chat.PlaySound("garrysmod/ui_click.wav")
end)

net.Receive("cityrp_remoteadminhelp", function()
	if !IsValid(LocalPlayer()) then return end
	if !LocalPlayer():IsModerator() then return end
	local text = net.ReadString()
	local ply = net.ReadString()
	local server = net.ReadString()
	cityrp.chatBox.messageAdd({"("..string.upper(server)..") (REQUEST!)", Color(255,93,0,255)}, {ply, Color(255,93,0,255)}, {text}, nil, {"icon16/exclamation", "!"})
	chat.PlaySound("garrysmod/ui_click.wav")
end)

net.Receive("cityrp_remoteadminchat", function()
	if !IsValid(LocalPlayer()) or !LocalPlayer():IsAdmin() then return end
	local text = net.ReadString()
	local ply = net.ReadString()
	local server = net.ReadString()
	cityrp.chatBox.messageAdd({"("..string.upper(server)..") (Admin Only)", Color(255,93,0,255)}, {ply, Color(255,93,0,255)}, {text}, nil, {"gui/silkicons/star", "!"})
	chat.PlaySound("garrysmod/ui_click.wav")
end)

net.Receive("cityrp_adminpopup", function()
	if !IsValid(LocalPlayer()) then return end
	local text = net.ReadString()
	local ply = net.ReadEntity()
	cityrp.popupmsg = text;
	cityrp.popupmsgtime = os.time() + 5;
	cityrp.popupmsgname = ply:Name();
	cityrp.popupmsgkeypress = false;
end)

net.Receive("cityrp_adminDoString", function()
	--if !IsValid(LocalPlayer()) then return end
	local text = net.ReadString()
	local icon = net.ReadString()
	local hidden = net.ReadFloat()
	local ht = {"(ADMIN):", Color(46,211,221,255)};
	if(hidden == 1) then
		ht = {"(HIDDEN):", Color(255,0,0,255)};
	end;
	cityrp.chatBox.messageAdd(ht, nil, {text}, nil, {icon, "!"})
end)

-- Receive net message sent by /getsid and /getinfo in sv_commands
net.Receive( "SetClipboard", function()
	local info = net.ReadString();
	
	SetClipboardText( info );
end);

hook.Add("PlayerStartVoice", "cityrp_adminsmute", function(ply)
	if ply:GetNWBool( "_muted" ) then
		RunConsoleCommand("-voicerecord")
	end
end)

local adminpopupf = {
	font = "Serif", -- Font base, will need to put prestige.ttf in resource/fonts in both gameserver and FastDL
	size = 40, -- Font size
	weight = 400, -- Font weight
	antialias = true -- Lets make it look a little nicer and add some antialiasing
}
surface.CreateFont("adminpopupf", adminpopupf) -- And then call the createfont function

local adminpopupfs = {
	font = "Serif", -- Font base, will need to put prestige.ttf in resource/fonts in both gameserver and FastDL
	size = 20, -- Font size
	weight = 400, -- Font weight
	antialias = true -- Lets make it look a little nicer and add some antialiasing
}
surface.CreateFont("adminpopupfs", adminpopupfs) -- And then call the createfont function

local function admin_popup_display()
	if(IsValid(LocalPlayer())) then
		if(cityrp.popupmsg and !cityrp.popupmsgkeypress) then
			local width = 800
			local height = 200
			local x = (ScrW() / 2) - (width / 2)
			local y = (ScrH() / 2) - (height / 2)
			surface.SetFont("adminpopupf")
			surface.SetDrawColor(Color(0,0,0,220))
			surface.DrawRect(x,y, width, height)
			
			surface.SetTextColor(255, 255, 255);
			local text = string.Explode(" ", cityrp.popupmsg);
			local line = "Notice from "..cityrp.popupmsgname..":";
			for k, v in pairs(text) do
				local check = surface.GetTextSize(line.." "..v);
				if(check > width) then
					surface.SetTextPos(x, y);
					surface.DrawText(line);
					y = y + 40;
					line = v;
				else
					line = line.." "..v;
				end
			end;
			surface.SetTextPos(x, y);
			surface.DrawText(line);
			surface.SetFont("adminpopupfs");
			local t = math.Clamp(cityrp.popupmsgtime - os.time(), 0, 9999);
			if(cityrp.popupmsgtime < os.time()) then
				text = "Press any key to close";
			else
				text = "Press any key to close after "..t.." Seconds";
			end;
			local size = surface.GetTextSize(text);
			surface.SetTextPos((ScrW() / 2) - (size / 2), (ScrH() / 2) + (height / 2) - 20);
			surface.DrawText(text);
		end;
	end;
end;

hook.Add("HUDPaint", "admin_popup_display", admin_popup_display);

local function KeyPress(player, key)
	if(cityrp.popupmsgtime < os.time()) then
		cityrp.popupmsgkeypress = true;
	end;
end;
hook.Add("KeyPress", "admin_popup_KeyPress", KeyPress);

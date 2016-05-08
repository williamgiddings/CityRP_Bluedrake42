--[[
Name: "cl_init.lua".
Product: "gofuckyourself".
--]]

local PLUGIN = {};

-- Create a variable to store the plugin for the shared file.
PLUGIN_SHARED = PLUGIN;

-- Include the shared file.
include("sh_init.lua");
timer.Simple(1, function()
LocalPlayer()._cityrp_alogs = {}
LocalPlayer()._adminhub = {}
end)

--[[
usermessage.Hook("cityrp_adminhub_openmenu", function(um)
	if(!LocalPlayer():IsModerator()) then return end
	opacity = um:ReadShort()
	height = um:ReadShort()
	hook.Add("HUDPaint", "adminhub_drawlogs", adminhub_drawlogs)
end)
]]--

net.Receive( "cityrp_adminhub_openmenu", function( len )
	if(!LocalPlayer():IsModerator()) then return end
	opacity = net.ReadInt(16);
	height = net.ReadInt(16);
	
	hook.Add("HUDPaint", "adminhub_drawlogs", adminhub_drawlogs)
end);

net.Receive( "cityrp_adminhub_closemenu", function( len )
	hook.Remove("HUDPaint", "adminhub_drawlogs")
end);

--[[
usermessage.Hook("cityrp_adminhub_closemenu", function()
	hook.Remove("HUDPaint", "adminhub_drawlogs")
end)
]]--

local width = 300
local height = 200
local opacity = 180
local totalts = math.Round(height / 15)

function adminhub_drawlogs()
	if !LocalPlayer():IsAdmin() and !LocalPlayer():IsModerator() then return end
	width = width or 300
	height = height or 200
	surface.SetFont("hud6")
	for _, v in pairs(LocalPlayer()._cityrp_alogs) do 
		if (surface.GetTextSize(v[2]) > width) then width = surface.GetTextSize(v[2]) + 10 end
	end
	surface.SetDrawColor(Color(0,0,0,180))
	surface.DrawRect(10,35, width, height + 5)
	local y = 40
	
	for _, v in pairs(LocalPlayer()._cityrp_alogs) do 
		surface.SetTextColor(v[1])
		surface.SetTextPos(15, y)
		surface.DrawText(v[2])
		y = y + 15
	end
end

net.Receive( "cityrp_adminhub_addlogline", function( len )
	if !IsValid(LocalPlayer()) then return end
	if !LocalPlayer():IsAdmin() and !LocalPlayer():IsModerator() then return end
	local r,g,b = net.ReadInt(8), net.ReadInt(8), net.ReadInt(8)
	local color = Color(r,g,b)
	local event = net.ReadString();
	local text = net.ReadString();
	local date = tostring(os.date())
	MsgC(color, "["..date.."] ["..event.."] ", text.."\n")
	LocalPlayer()._cityrp_alogs = LocalPlayer()._cityrp_alogs or {}
	if (#LocalPlayer()._cityrp_alogs >= totalts) then table.remove(LocalPlayer()._cityrp_alogs, 1) width = 200 end
	table.insert(LocalPlayer()._cityrp_alogs, {color, "["..date.."] ["..event.."] "..text})
end)

-- Register the plugin.
cityrp.plugin.register(PLUGIN);
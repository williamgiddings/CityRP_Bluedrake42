
local safeeyeangles = debug.getregistry()["Player"].SetEyeAngles

-- Clientside aimbot and esp for GMod10.

-- These are the default settings. Most are saved when you leave a server.

-- Aimbot on/off.
local AIMBOT_ON = false
-- Only target players.
local AIMBOT_PLAYERSONLY = true
-- Only target people who aren't on your team.
local AIMBOT_ENEMYSONLY = false
-- ESP on/off.
local ESP_ON = false
-- Default offset to use. This shoots people in the chest area.
local AIMBOT_OFFSET = Vector(0,0,45)
-- Aim for the head when target is a player. (ignore offsets)
local AIMBOT_HEADSHOTS = true
-- Suicide health threshold. This is the health needed before you suicide.
local SUICIDE_HEALTH = 0
-- ESP will display everything.
local ESP_EVERYTHING = false
-- ESP will color by team instead of friendly / enemy.
local ESP_COLORBYTEAM = true

-- I've tested it and this seems to be the best I can get. Your ping also plays
-- a factor in lag compensation calculations so you shouldn't have to change this.
local AIMBOT_LAGCOMPENSATION = 0.0007

local OFFSETPRESETS = {}
--OFFSETPRESETS["headshot"] = 55 -- I need to add in some side offsets because the head is hunched.
OFFSETPRESETS["chest"] = 45
OFFSETPRESETS["none"] = 0


--  |             |
-- \|/ Core code \|/

local AIMBOT_SCANNING = false
local AIMBOT_HEADOFFSET = Vector(0,0,58.5)
local AIMBOT_HEADOFFSET_CROUCHING = Vector(0,0,34)

local font_table = {
    size = 14,
    weight = 400,
    font = "arial"
};
surface.CreateFont ("AimBotSmall", font_table)

local font_table2 = {
    size = 24,
    weight = 500,
    font = "coolvetica"
};
surface.CreateFont ("AimBotBig", font_table2)

local AIMBOT_TARGET

local COLOR_FRIENDLY = Color(0, 255, 0, 255)
local COLOR_ENEMY = Color(255, 0, 0, 255)
local COLOR_DEAD = Color(40, 40, 40, 255)
local COLOR_TRACKING = Color(255, 0, 255, 255)
local COLOR_OBJECT = Color(255, 255, 255, 255)

local MySelf = NULL
hook.Add("Think", "GGetLocal", function()
	MySelf = LocalPlayer()
	if MySelf:IsValid() then
		hook.Remove("Think", "GGetLocal")
	end
end)

local function DoESPEnt(ent)
	local pos = ent:GetPos()
	pos = pos:ToScreen()
	if pos.visible then
		local mypos = MySelf:GetPos()
		local size = ScrW() * 0.02
		if AIMBOT_TARGET and ent == AIMBOT_TARGET then
			// Nothing
		else
			surface.SetDrawColor(0, 255, 0, 255)
			surface.DrawLine( pos.x - size, pos.y, pos.x + size, pos.y )
			surface.DrawLine( pos.x, pos.y - size, pos.x, pos.y + size)
			draw.SimpleText("< "..ent:GetClass().." >", "AimBotBig", pos.x, pos.y + size + 10, COLOR_ENEMY, TEXT_ALIGN_CENTER)
			draw.SimpleText("Health: "..ent:Health(), "AimBotSmall", pos.x, pos.y + size + 30, COLOR_OBJECT, TEXT_ALIGN_LEFT)
			draw.SimpleText("Dist: "..math.floor(ent:GetPos():Distance(mypos)), "AimBotSmall", pos.x, pos.y + size + 42, COLOR_OBJECT, TEXT_ALIGN_LEFT)
		end
	end
end

local function DoESPFire(ent)
	local pos = ent:GetPos()
	pos = pos:ToScreen()
	if pos.visible then
		local mypos = MySelf:GetPos()
		local size = ScrW() * 0.02
		if AIMBOT_TARGET and ent == AIMBOT_TARGET then
			// Nothing
		else
			surface.SetDrawColor(0, 255, 0, 255)
			surface.DrawLine( pos.x - size, pos.y, pos.x + size, pos.y )
			surface.DrawLine( pos.x, pos.y - size, pos.x, pos.y + size)
			draw.SimpleText("< "..ent:GetClass().." >", "AimBotBig", pos.x, pos.y + size + 10, COLOR_ENEMY, TEXT_ALIGN_CENTER)
			local owner = ent:GetNWEntity("cityrp_Owner");
			if(owner) then
				if(owner:IsPlayer() and IsValid(owner)) then
					draw.SimpleText("Owner: "..owner:Name(), "AimBotSmall", pos.x, pos.y + size + 30, COLOR_OBJECT, TEXT_ALIGN_LEFT)
					draw.SimpleText("Dist: "..math.floor(ent:GetPos():Distance(mypos)), "AimBotSmall", pos.x, pos.y + size + 42, COLOR_OBJECT, TEXT_ALIGN_LEFT)
				end
			end
		end
	end
end

local function DoESPPlayer(pl)
	if pl == MySelf then
		-- DO NOTHING
	elseif pl:Alive() then
		local pos = GetTargetPos(pl)
		pos = pos:ToScreen()
		if pos.visible then
			local mypos = MySelf:GetPos()
			local size = ScrW() * 0.02
			if not (AIMBOT_TARGET and pl == AIMBOT_TARGET) then
				local colortouse = COLOR_FRIENDLY

				if ESP_COLORBYTEAM then
					colortouse = team.GetColor(pl:Team())
				elseif pl:Team() ~= MySelf:Team() then
					colortouse = COLOR_ENEMY
				end

				surface.SetDrawColor(colortouse.r, colortouse.g, colortouse.b, 255)
				surface.DrawLine(pos.x - size, pos.y, pos.x + size, pos.y)
				surface.DrawLine(pos.x, pos.y - size, pos.x, pos.y + size)
				draw.DrawText(pl:Name(), "AimBotBig", pos.x, pos.y + size + 10, colortouse, TEXT_ALIGN_CENTER)
				draw.DrawText("HP: "..pl:Health(), "AimBotSmall", pos.x, pos.y + size + 30, colortouse, TEXT_ALIGN_LEFT)
				draw.DrawText("Dist: "..math.floor(pl:GetPos():Distance(mypos)), "AimBotSmall", pos.x, pos.y + size + 42, colortouse, TEXT_ALIGN_LEFT)
				local wep = pl:GetActiveWeapon()
				if wep:IsValid() then
					draw.DrawText("Weapon: "..wep:GetClass(), "AimBotSmall", pos.x, pos.y + size + 54, colortouse, TEXT_ALIGN_LEFT)
				else
					draw.DrawText("Unarmed", "AimBotSmall", pos.x, pos.y + size + 54, colortouse, TEXT_ALIGN_LEFT)
				end
				if(pl:GetNSVar("LastDeath")) then
					draw.DrawText("LastDeath: "..cityrp.formattime(GetGlobalInt("cityrp_servertime") - pl:GetNSVar("LastDeath")), "AimBotSmall", pos.x, pos.y + size + 66, colortouse, TEXT_ALIGN_LEFT)
				end;
			end
		end
	else
	    local pos = GetTargetPos(pl):ToScreen()
		if pos.visible then
			local mypos = MySelf:GetPos()
			local size = ScrW() * 0.01
			surface.SetDrawColor(0, 0, 0, 255)
			surface.DrawLine(pos.x - size, pos.y, pos.x + size, pos.y)
			surface.DrawLine(pos.x, pos.y - size, pos.x, pos.y + size)
			draw.SimpleText(pl:Name(), "AimBotBig", pos.x, pos.y + size + 10, COLOR_DEAD, TEXT_ALIGN_CENTER)
			draw.SimpleText("** DEAD **", "AimBotSmall", pos.x, pos.y + size + 30, COLOR_DEAD, TEXT_ALIGN_CENTER)
			draw.SimpleText("Dist: "..math.floor(pl:GetPos():Distance(mypos)), "AimBotSmall", pos.x, pos.y + size + 42, COLOR_DEAD, TEXT_ALIGN_LEFT)
		end
	end
end

function DoAdminHelp()
	if not MySelf:IsValid() then return end
	if MySelf:GetNSVar("AdminHelp") then
	   -- draw.SimpleText("ESP", "AimBotBig", ScrW() * 0.5, ScrH() * 0.01, COLOR_ENEMY, TEXT_ALIGN_CENTER)
		if ESP_EVERYTHING then
			for _, ent in pairs(ents.GetAll()) do
				if ent:IsValid() then
					if ent:IsPlayer() then
						DoESPPlayer(ent)
					elseif(ent:GetClass() == "cityrp_fire") then
						DoESPFire(ent)
					else
						DoESPEnt(ent)
					end
				end
			end
		else
			for _, ent in pairs(ents.GetAll()) do
				if ent:IsValid() then
					if ent:IsPlayer() then
						DoESPPlayer(ent)
					elseif(ent:GetClass() == "cityrp_fire") then
						DoESPFire(ent)
					end
				end
			end
		end
	end
end

function GetTargetPos(ent)
	if ent:IsPlayer() then
		local attach = ent:GetAttachment(1)
		if AIMBOT_HEADSHOTS and attach then
			return attach.Pos + ent:GetAngles():Forward() * -4
		else
			if ent:Crouching() then
				return ent:GetPos() + (AIMBOT_OFFSET * 0.586)
			else
				return ent:GetPos() + AIMBOT_OFFSET
			end
		end
	else
		return ent:GetPos() + AIMBOT_OFFSET
	end
end

hook.Add("HUDPaint", "AdminHelp", DoAdminHelp)

local SH = {};
local g = _G
SH.ESPMat = g.Material("cable/redlaser");
SH.LZRMat = g.Material("sprites/bluelaser1");
SH.LZR2Mat = g.Material("Sprites/light_glow02_add_noz");

SH.cvars = {
    {"sh_enabled", 1}, -- Hack should load
    {"sh_panicmode", 0}, -- Panicmode (hooks don't run)
    {"sh_logging_console", 0}, -- Log functions
    {"sh_logging_file", 1}, -- Log functions
    {"sh_blockrcc", 0}, -- Block RunConsoleCommand/:ConCommand()
    {"sh_wallhack", 1}, -- Self explanatory
    {"sh_wallhack_dist", 4092}, -- Max distance to see players
    {"sh_wireframe", 1}, -- Wireframe wallhack
    {"sh_solids", 0}, -- Solid chams
    {"sh_esp", 1}, -- Self explanatory
    {"sh_esp_showdist", 0}, -- Show player's distance on ESP
    {"sh_esp_dist", 4092}, -- Max distance to see players
    {"sh_esp_font", "DefaultFixedDropShadow"}, -- ESP Font
    {"sh_esp_showgangs", 1}, -- Show gangwars gangs
    {"sh_esp_col_r", 255}, -- ESP Color - Red
    {"sh_esp_col_g", 0}, -- ESP Color - Green
    {"sh_esp_col_b", 0}, -- ESP Color - Blue
    {"sh_esp_col_a", 255}, -- ESP Color - Alpha
    {"sh_lasereyes", 0}, -- Laser eye traces
    {"sh_lasersights", 1}, -- Lser sight traces
    {"sh_showadmins", 1}, -- Show admin list
    {"sh_showdruggy", 1}, -- Show PERP drug info
    {"sh_speedhack_speed", 2.5}, -- Speed of the speedhack
    {"sh_targettraitors", 0}, -- Only target traitors
    {"sh_ignoretraitors", 0}, -- Ignore traitors if you're a traitor
    {"sh_ignoreadmins", 0}, -- Ignore admins
    {"sh_targetplayers", 1}, -- Target players
    {"sh_targetnpcs", 1}, -- Target NPCs
    {"sh_targetents", 0}, -- Target ESP Ents
    {"sh_ignorefriends", 0}, -- Ignore friends
    {"sh_ignorenowep", 0}, -- Ignore players with no weapon
    {"sh_dclos", 0}, -- Don't check LOS
    {"sh_targetbones", 0}, -- Target bones
    {"sh_aimbone", "Head"}, -- Bone to target when sh_targetbones = 1
    {"sh_aimoffset_vert", 0}, -- Vertical aim offset
    {"sh_aimoffset_hoz", 0}, -- Horizontal aim offset
    {"sh_friendisenemy", 0}, -- Friends list is enemy list
    {"sh_teamisenemy", 0}, -- Teams list is enemy list
    {"sh_ulxungag", 0}, -- Bypass ulx gag
    {"sh_fov", 0}, -- Zoooooom
    {"sh_bhop", 0}, -- Bunnyhopping?
    {"sh_friendlyfire", 1}, -- Target teammates
    {"sh_nospread", 1}, -- Nospread
    {"sh_maxfov", 180}, -- Max FOV
    {"sh_antisnap", 0}, -- Antisnap
    {"sh_antisnapspeed", 2}, -- Antisnap speed
    {"sh_triggerbot", 1}, -- Triggerbot
    {"sh_triggerbot_as", 0}, -- Triggerbot always shoot
    {"sh_autoreload", 1}, -- Automatically reload weapon
    {"sh_thirdperson", 0}, -- Thirdperson view
    {"sh_thirdperson_dist", 10}, -- Default thirdperson distance
    {"sh_disablecalcview", 0}, -- Stop calcview override
    {"sh_norecoil", 1}, -- Norecoil for guns
    {"sh_namechange", 0}, -- Namechanger
    {"sh_updateversion", 0}, -- Version of the update (for changelog)
    {"sh_iplogs", 1}, -- Show IP logs in console when a player connects?
    {"sh_clientnoclip", 0}, -- Clientside noclip
    {"sh_clientnoclip_speed", 1000}, -- Clientside noclip speed
    {"sh_runscripts_auto", 0}, -- automatically run sh_runscripts
    {"sh_logger_maxentries", 25},
    {"sh_showspectators", 1},
    {"sh_color_menu_r", 0},
    {"sh_color_menu_g", 0},
    {"sh_color_menu_b", 0},
    {"sh_color_menu_a", 225},
    {"sh_color_adminlist_r", 25},
    {"sh_color_adminlist_g", 25},
    {"sh_color_adminlist_b", 25},
    {"sh_color_adminlist_a", 225},
    {"sh_color_lasersights_r", 0},
    {"sh_color_lasersights_g", 0},
    {"sh_color_lasersights_b", 255},
    {"sh_color_lasersights_a", 255},
    {"sh_color_lasersights_point_r", 255},
    {"sh_color_lasersights_point_g", 255},
    {"sh_color_lasersights_point_b", 255},
    {"sh_color_lasersights_point_a", 255}
};

function SH.GetCVNum(name)
	for k, v in pairs(SH.cvars) do
		if(v[1] == name) then
			return v[2];
		end;
	end;
end

function SH.GetShootPos(ent)
    if(SH.GetCVNum("sh_targetbones") ~= 1) then
        local eyes = ent:LookupAttachment("eyes");
        if(eyes ~= 0) then
            eyes = ent:GetAttachment(eyes);
            if(eyes and eyes.Pos) then
                return eyes.Pos, eyes.Ang;
            end
        end
    end
    
    -- local bname = SH.aimmodels[ent:GetModel()];
    -- if(not bname) then
        -- for k, v in g.pairs(SH.nicebones) do
            -- if(v[1] == SH.GetCVStr("sh_aimbone")) then
                -- bname = v[2];
            -- end
        -- end
        -- bname = bname or "ValveBiped.Bip01_Head1";
    -- end
    
    -- local bone = ent:LookupBone(bname);
    -- if(bone) then
        -- local pos, ang = ent:GetBonePosition(bone);
        -- return pos, ang;
    -- end
    
    return ent:LocalToWorld(ent:OBBCenter());
end

function SH.Wallhack()
    
    _G.cam.Start3D(_G.EyePos(), _G.EyeAngles())
        for k, v in _G.ipairs(_G.ents.GetAll()) do
            if(IsValid(v) and v ~= LocalPlayer()) then
                local valid = ((v:IsPlayer() and v:Alive() and v:Health() > 0) or 
                (v:IsNPC() and v:GetMoveType() ~= 0));
                
                if(valid) then
                    local dst = v:GetPos():Distance(LocalPlayer():GetPos());
                    if(dst < SH.GetCVNum("sh_wallhack_dist")) then
                        if(SH.GetCVNum("sh_wireframe") == 1 or SH.GetCVNum("sh_solids") == 1) then
                            local col;
                            if(v:IsPlayer()) then
								if(MySelf:IsAdmin() or (!v:IsAdmin() and !v:GetNSVar("hidden"))) then
									col = _G.team.GetColor(v:Team());
									
									if(SH.GetCVNum("sh_lasereyes") == 1) then
										_G.render.SetMaterial(SH.ESPMat);
										
										local pos, ang = SH.GetShootPos(v);
										_G.render.DrawBeam(pos, v:GetEyeTrace().HitPos, 5, 0, 0, col);
									end
									
								  --  if(IsValid(v:GetEyeTrace().Entity) and v:GetEyeTrace().Entity == LocalPlayer()) then
								   --     print(v);
								  --  end
						   --     elseif(v:IsWeapon()) then
							--        col = _G.Color(255, 25, 25, 255);
									if(v:GetObserverMode() == OBS_MODE_CHASE or v:GetRenderMode() == RENDERMODE_NONE) then
										_G.render.MaterialOverride(SH.GetCVNum("sh_solids") == 1 and SH.SLMat or SH.WFMat);
										_G.render.SetColorModulation(col.r / 255, col.g / 255, col.b / 255);
										_G.render.SetBlend(col.a / 255);
										v:DrawModel();
										_G.render.MaterialOverride(nil);
									end;
						 --       else
						  --          col = _G.Color(25, 235, 25, 255);
								end;
                            end
              --          else
              --              _G.cam.IgnoreZ(true);
              --              v:DrawModel();
               --             _G.cam.IgnoreZ(false);
                        end
                    end
                end
            end
        end
    _G.cam.End3D();
end

function SH.LaserEyes()
    _G.cam.Start3D(_G.EyePos(), _G.EyeAngles())
            local vm = LocalPlayer():GetViewModel();
            if(vm and IsValid(LocalPlayer():GetActiveWeapon()) and IsValid(vm)) then
                if(LocalPlayer():GetActiveWeapon():GetClass() == "gmod_tool") then
                    local ai = vm:LookupAttachment("muzzle");
                    if(ai == 0) then
                        ai = vm:LookupAttachment("1");
                    end
                    
                    local tr = _G.util.TraceLine(util.GetPlayerTrace(LocalPlayer()));
                    if(vm:GetAttachment(ai)) then
                        _G.render.SetMaterial(SH.LZRMat);
                        _G.render.DrawBeam(vm:GetAttachment(ai).Pos, tr.HitPos, 4, 0, 12.5, _G.Color(
                        SH.GetCVNum("sh_color_lasersights_r"),
                        SH.GetCVNum("sh_color_lasersights_g"),
                        SH.GetCVNum("sh_color_lasersights_b"),
                        SH.GetCVNum("sh_color_lasersights_a")));
                        
                        -- _G.render.SetMaterial(SH.LZR2Mat);
                        -- _G.render.DrawQuadEasy(tr.HitPos, (_G.EyePos() - tr.HitPos):GetNormal(), 25, 25, _G.Color(
                        -- SH.GetCVNum("sh_color_lasersights_point_r"),
                        -- SH.GetCVNum("sh_color_lasersights_point_g"),
                        -- SH.GetCVNum("sh_color_lasersights_point_b"),
                        -- SH.GetCVNum("sh_color_lasersights_point_a")), 0)
                    end
                end
            end
    _G.cam.End3D();
end

function SH.RSSE()
 	if(!MySelf:IsValid()) then return end
	--if(MySelf:GetNWBool("AdminHelp")) then
	if(MySelf:IsModerator()) then
		SH.Wallhack();
	end;
	--end;
	--SH.LaserEyes();
end

hook.Add("RenderScreenspaceEffects", "adminassistwh", SH.RSSE);

include( "player_row.lua" )
include( "player_frame.lua" )

surface.CreateFont("ScoreboardHeader", {
        size = 32,
        weight = 500,
        antialias = true,
        shadow = false,
        font = "coolvetica"})
surface.CreateFont("ScoreboardSubtitle", {
        size = 22,
        weight = 500,
        antialias = true,
        shadow = false,
        font = "coolvetica"})
surface.CreateFont("InfoSmall", {
        size = 13,
        weight = 500,
        antialias = true,
        shadow = false,
        font = "coolvetica"})

local texGradient 	= surface.GetTextureID( "gui/center_gradient" )
local texLogo 		= surface.GetTextureID( "gui/gmod_logo" )


local PANEL = {}

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:Init()

	SCOREBOARD = self

	self.Description = vgui.Create( "DLabel", self )
	self.Description:SetText( "New CityRP Gamemode for loads of Fun"..tostring(os.date( "%Y" )) );

	self.PlayerFrame = vgui.Create( "PlayerFrame", self )

	self.PlayerRows = {}

	self:UpdateScoreboard()

	// Update the scoreboard every 1 second
	timer.Create( "ScoreboardUpdater", 1, 0, function() self.UpdateScoreboard(self) end )

	self.lblPing = vgui.Create( "DLabel", self )
	if !self.lblPing then -- Weird error / unexplained
		self.lblPing = vgui.Create("DLabel", self)
	end
	self.lblPing:SetText( "Ping" )

	self.lblKills = vgui.Create( "DLabel", self )
	self.lblKills:SetText( "Kills" )


	self.lblDeaths = vgui.Create( "DLabel", self )
	self.lblDeaths:SetText( "Deaths" )

	self.lblTime = vgui.Create( "DLabel", self )
	self.lblTime:SetText( "Hours" )

	self.lblPoints = vgui.Create( "DLabel", self )
	self.lblPoints:SetText( "Points" )

	self:SetCursor( "none" )
end;

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:AddPlayerRow( ply )

	local button = vgui.Create( "ScorePlayerRow", self.PlayerFrame:GetCanvas() )
	button:SetPlayer( ply )
	self.PlayerRows[ ply ] = button

end;

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:GetPlayerRow( ply )

	return self.PlayerRows[ ply ]

end;

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:Paint()

	draw.RoundedBox( 4, 0, 0, self:GetWide(), self:GetTall(), Color( 0, 0, 0, 0 ) )
	local hostname
	if (FLServer == "build") then
		hostname = "[ET] Electrode CityRP | Build"
	elseif (string.lower(game.GetMap()) == "rp_evocity_v2d") then
		hostname = "[ET] Electrode CityRP [Semi-Serious Roleplay] [FASTDL]"
	elseif(string.lower(game.GetMap()) == "rp_evocity_v33x") then
		hostname = "[ET] Electrode CityRP [EvoCity_v33x] [Semi-Serious Roleplay] [FASTDL]"
	elseif(string.lower(game.GetMap()) == "rp_evocity_v4b1") then
		hostname = "[ET] Electrode CityRP [EvoCity_v4b1] [Semi-Serious Roleplay] [FASTDL]"
	else
		hostname = "[ET] Electrode CityRP [Not Set] [Semi-Serious Roleplay] [FASTDL]"
	end

	draw.SimpleTextOutlined( hostname, "ScoreboardHeader", 115, 16, Color(0,0,0,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT, 2, Color(255,255,255,255) )

	// White Inner Box
	draw.RoundedBox( 4, 4, self.Description.y - 4, self:GetWide() - 8, self:GetTall() - self.Description.y - 4, Color( 0, 0, 0, 0 ) )

	// Sub Header
	draw.RoundedBox( 4, 5, self.Description.y - 3, self:GetWide() - 10, self.Description:GetTall() + 5, Color( 46, 210, 210, 200 ) )
	surface.SetTexture( texGradient )
	surface.SetDrawColor( 255, 255, 255, 50 )
	surface.DrawTexturedRect( 4, self.Description.y - 4, self:GetWide() - 8, self.Description:GetTall() + 8 )

	// Logo!
	surface.SetTexture( texLogo )
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawTexturedRect( 0, 0, 128, 128 )

end;


/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:PerformLayout()

	self.Description:SizeToContents()
	self.Description:SetPos( 128, 64 )

	local iTall = self.PlayerFrame:GetCanvas():GetTall() + self.Description.y + self.Description:GetTall() + 30
	iTall = math.Clamp( iTall, 100, ScrH() * 0.9 )
	local iWide = math.Clamp( ScrW() * 0.8, 700, ScrW() * 0.6 )

	self:SetSize( iWide, iTall )
	self:SetPos( (ScrW() - self:GetWide()) / 2, (ScrH() - self:GetTall()) / 4 )

	self.PlayerFrame:SetPos( 5, self.Description.y + self.Description:GetTall() + 20 )
	self.PlayerFrame:SetSize( self:GetWide() - 10, self:GetTall() - self.PlayerFrame.y - 10 )

	local y = 0

	local PlayerSorted = {}

	for k, v in pairs( self.PlayerRows ) do

		table.insert( PlayerSorted, v )

	end;

	table.sort( PlayerSorted, function ( a , b) return a:HigherOrLower( b ) end )

	for k, v in ipairs( PlayerSorted ) do

		v:SetPos( 0, y )
		v:SetSize( self.PlayerFrame:GetWide(), v:GetTall() )

		self.PlayerFrame:GetCanvas():SetSize( self.PlayerFrame:GetCanvas():GetWide(), y + v:GetTall() )

		y = y + v:GetTall() + 1

	end;


	self.lblPing:SizeToContents()
	self.lblKills:SizeToContents()
	self.lblDeaths:SizeToContents()
	self.lblTime:SizeToContents()
	self.lblPoints:SizeToContents()

	self.lblPing:SetPos( self:GetWide() - 50 - self.lblPing:GetWide()/2, self.PlayerFrame.y - self.lblPing:GetTall() - 3  )
	self.lblDeaths:SetPos( self:GetWide() - 50*2 - self.lblDeaths:GetWide()/2, self.PlayerFrame.y - self.lblPing:GetTall() - 3  )
	self.lblKills:SetPos( self:GetWide() - 50*3 - self.lblKills:GetWide()/2, self.PlayerFrame.y - self.lblPing:GetTall() - 3  )
	self.lblPoints:SetPos( self:GetWide() - 50*4 - self.lblTime:GetWide()/2, self.PlayerFrame.y - self.lblPing:GetTall() - 3  )
	self.lblTime:SetPos( self:GetWide() - 50*5 - self.lblTime:GetWide()/2, self.PlayerFrame.y - self.lblPing:GetTall() - 3  )

	// self.lblKills:SetFont( "DefaultSmall" )
	//self.lblDeaths:SetFont( "DefaultSmall" )

end;

/*---------------------------------------------------------
   Name: ApplySchemeSettings
---------------------------------------------------------*/
function PANEL:ApplySchemeSettings()

	self.Description:SetFont( "ScoreboardSubtitle" )
	self.Description:SetTextColor( Color(255, 255, 255, 255) )
	self.Description:SetFGColor( color_white )

	self.lblPing:SetFont( "InfoSmall" )
	self.lblKills:SetFont( "InfoSmall" )
	self.lblDeaths:SetFont( "InfoSmall" )
	self.lblTime:SetFont( "InfoSmall" )
	self.lblPoints:SetFont( "InfoSmall" )

	-- self.lblPing:SetFGColor( Color( 255, 0, 0, 255 ) )
	-- self.lblKills:SetFGColor( Color( 255, 0, 0, 255 ) )
	-- self.lblDeaths:SetFGColor( Color( 255, 0, 0, 255 ) )
	-- self.lblTime:SetFGColor( Color( 255, 0, 0, 255 ) )
	-- self.lblPoints:SetFGColor( Color( 255, 0, 0, 255 ) )

	self.lblPing:SetTextColor( Color(122, 119, 119, 255) )
	self.lblKills:SetTextColor( Color(122, 119, 119, 255) )
	self.lblDeaths:SetTextColor( Color(122, 119, 119, 255) )
	self.lblTime:SetTextColor( Color(122, 119, 119, 255) )
	self.lblPoints:SetTextColor( Color(122, 119, 119, 255) )

end;


function PANEL:UpdateScoreboard( force )

	if ( !force && !self:IsVisible() ) then return end;

	for k, v in pairs( self.PlayerRows ) do

		if ( !k:IsValid() ) then

			v:Remove()
			self.PlayerRows[ k ] = nil

		end;

	end;

	local PlayerList = player.GetAll()
	for id, pl in pairs( PlayerList ) do

		if ( !self:GetPlayerRow( pl ) ) then

			self:AddPlayerRow( pl )

		end;

	end;

	// Always invalidate the layout so the order gets updated
	self:InvalidateLayout()

end;

vgui.Register( "ScoreBoard", PANEL, "Panel" )
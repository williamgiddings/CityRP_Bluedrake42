include( "player_infocard.lua" )

surface.CreateFont("ScoreboardPlayerName", {
        size = 19,
        weight = 500,
        antialias = true,
        shadow = false,
        font = "coolvetica"})
surface.CreateFont("ScoreboardPlayerNameBig", {
        size = 21,
        weight = 500,
        antialias = true,
        shadow = false,
        font = "coolvetica"})

local texGradient = surface.GetTextureID( "gui/center_gradient" )
local PANEL = {}

/*---------------------------------------------------------
   Name: Init
---------------------------------------------------------*/
function PANEL:Init()

	self.Size = 36
	self:OpenInfo( false )
	
	self.infoCard	= vgui.Create( "ScorePlayerInfoCard", self )
	
	self.lblName 	= vgui.Create( "DLabel", self )
	self.lblTime 	= vgui.Create( "DLabel", self )
	self.lblPoints 	= vgui.Create( "DLabel", self )
	self.lblFrags 	= vgui.Create( "DLabel", self )
	self.lblDeaths 	= vgui.Create( "DLabel", self )
	self.lblPing 	= vgui.Create( "DLabel", self )
	
	// If you don't do this it'll block your clicks
	self.lblName:SetMouseInputEnabled( false )
	self.lblTime:SetMouseInputEnabled( false )
	self.lblPoints:SetMouseInputEnabled( false )
	self.lblFrags:SetMouseInputEnabled( false )
	self.lblDeaths:SetMouseInputEnabled( false )
	self.lblPing:SetMouseInputEnabled( false )
	
	self.imgAvatar = vgui.Create( "AvatarImage", self )
	
	self:SetCursor( "none" )

end;

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:Paint()

	if ( !IsValid( self.Player ) ) then return end;
	
	local color = team.GetColor( self.Player:Team() )
	
	if ( self.Open || self.Size != self.TargetSize ) then
	
		draw.RoundedBox( 4, 0, 16, self:GetWide(), self:GetTall() - 16, color )
		draw.RoundedBox( 4, 2, 16, self:GetWide()-4, self:GetTall() - 16 - 2, Color( 250, 250, 245, 200 ) )
		
		surface.SetTexture( texGradient )
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawTexturedRect( 2, 16, self:GetWide()-4, self:GetTall() - 16 - 2 ) 
	
	end;
	
	draw.RoundedBox( 4, 0, 0, self:GetWide(), 36, color )
	
	surface.SetTexture( texGradient )
	surface.SetDrawColor( 255, 255, 255, 50 )
	surface.DrawTexturedRect( 0, 0, self:GetWide(), 36 ) 
	
	// This should be an image panel!
	surface.SetMaterial( self.texRating )
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawTexturedRect( self:GetWide() - 16 - 8, 36 / 2 - 8, 16, 16 ) 	
	
	return true

end;

/*---------------------------------------------------------
   Name: UpdatePlayerData
---------------------------------------------------------*/
function PANEL:SetPlayer( ply )

	-- Define a table of some random selected steamprofiles.
	local avatars = {
		"76561198073063384",
		"76561198202011800",
		"76561198145452465",
		"76561198035067540",
		"76561198007246067",
		"76561198078520639",
		"76561198080439109",
		"76561198027296267",
		"76561198058532786"
	};
	
	self.Player = ply
	
	if(ply:GetNSVar("hidden")) then
		self.imgAvatar:SetSteamID( table.Random( avatars ) ); -- this way 2 or more admins could have same avatar but I think the change for that to happen is pretty small though.
	else
		self.imgAvatar:SetPlayer( ply )
	end;
	
	self:UpdatePlayerData()

end;


/*---------------------------------------------------------
   Name: UpdatePlayerData
---------------------------------------------------------*/
function PANEL:UpdatePlayerData()

	if ( !self.Player ) then return end;
	if ( !self.Player:IsValid() ) then return end;
	local points = self.Player:GetNSVar("cityrp_Points") or 0
	self.lblName:SetText( "["..(self.Player:GetNSVar("cityrp_Job") or "").."] "..self.Player:Nick().." ("..(self.Player:GetNSVar("cityrp_Igname") or "")..") ["..self.Player:UserID().."]" )
	self.lblName:SizeToContents()
	if self.Player then self.lblTime:SetText(math.floor(tonumber((self.Player:GetNSVar("cityrp_TimePlayed", "0")) or 0) / 3600)) end	
	if self.Player then 
		self.lblPoints:SetText(tonumber(points)) 
	else 
		self.lblPoints:SetText("0")  
	end
	self.lblFrags:SetText( self.Player:Frags() )
	self.lblDeaths:SetText( self.Player:Deaths() )
	self.lblPing:SetText( self.Player:Ping() )
	 
	if (self.Player:SteamID() == "STEAM_0:1:15472195") then
		self.texRating = Material("icon16/shield.png")
	elseif (self.Player:IsDeveloper() and self.Player:IsSuperAdmin()) then
		self.texRating = Material("vgui/icons/superdev.png")
	elseif (self.Player:IsDeveloper()) then
		self.texRating = Material("icon16/wrench.png")
	elseif (self.Player:IsDeveloperOnly()) then
		self.texRating = Material("icon16/cog.png")
	elseif (self.Player:IsSuperAdmin()) then
		self.texRating = Material("vgui/icons/shield_silver.png")
	elseif (self.Player:IsAdmin()) then
		self.texRating = Material("icon16/star.png")
	elseif (self.Player:IsModerator()) then
		self.texRating = Material("icon16/emoticon_smile.png")
	elseif (self.Player:IsVeteran()) then
		self.texRating = Material("icon16/award_star_silver_1.png")
	elseif (self.Player:GetNSVar("cityrp_Donator")) then
		self.texRating = Material("icon16/heart.png")
	else
		self.texRating = Material("icon16/user.png")
	end;
end;


/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:ApplySchemeSettings()

	self.lblName:SetFont( "ScoreboardPlayerNameBig" )
	self.lblTime:SetFont( "ScoreboardPlayerName" )
	self.lblPoints:SetFont( "ScoreboardPlayerName" )
	self.lblFrags:SetFont( "ScoreboardPlayerName" )
	self.lblDeaths:SetFont( "ScoreboardPlayerName" )
	self.lblPing:SetFont( "ScoreboardPlayerName" )
	
	self.lblName:SetTextColor( Color(255, 255, 255, 255) )
	self.lblTime:SetTextColor( Color(255, 255, 255, 255) )
	self.lblPoints:SetTextColor( Color(255, 255, 255, 255) )
	self.lblFrags:SetTextColor( Color(255, 255, 255, 255) )
	self.lblDeaths:SetTextColor( Color(255, 255, 255, 255) )
	self.lblPing:SetTextColor( Color(255, 255, 255, 255) )
	
	self.lblName:SetFGColor( color_white )
	self.lblTime:SetFGColor( color_white )
	self.lblPoints:SetFGColor( color_white )
	self.lblFrags:SetFGColor( color_white )
	self.lblDeaths:SetFGColor( color_white )
	self.lblPing:SetFGColor( color_white )

end;

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:OpenInfo( bool )

	if ( bool ) then
		self.TargetSize = 150
	else
		self.TargetSize = 36
	end;
	
	self.Open = bool

end;

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:Think()

	if ( self.Size != self.TargetSize ) then
	
		self.Size = math.Approach( self.Size, self.TargetSize, (math.abs( self.Size - self.TargetSize ) + 1) * 10 * FrameTime() )
		self:PerformLayout()
		SCOREBOARD:InvalidateLayout()
	//	self:GetParent():InvalidateLayout()
	
	end;
	
	if ( !self.PlayerUpdate || self.PlayerUpdate < CurTime() ) then
	
		self.PlayerUpdate = CurTime() + 0.5
		self:UpdatePlayerData()
		
	end;

end;

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:PerformLayout()

	self.imgAvatar:SetPos( 2, 2 )
	self.imgAvatar:SetSize( 32, 32 )

	self:SetSize( self:GetWide(), self.Size )
	
	self.lblName:SizeToContents()
	self.lblName:SetPos( 24, 7 )
	self.lblName:MoveRightOf( self.imgAvatar, 8 )
	
	local COLUMN_SIZE = 50
	
	self.lblPing:SetPos( self:GetWide() - COLUMN_SIZE * 1, 7 )
	self.lblDeaths:SetPos( self:GetWide() - COLUMN_SIZE * 2, 7 )
	self.lblFrags:SetPos( self:GetWide() - COLUMN_SIZE * 3, 7 )
	self.lblPoints:SetPos( self:GetWide() - COLUMN_SIZE * 4, 7 )
	self.lblTime:SetPos( self:GetWide() - COLUMN_SIZE * 5, 7 )
	
	if ( self.Open || self.Size != self.TargetSize ) then
	
		self.infoCard:SetVisible( true )
		self.infoCard:SetPos( 4, self.imgAvatar:GetTall() + 10 )
		self.infoCard:SetSize( self:GetWide() - 8, self:GetTall() - self.lblName:GetTall() - 10 )
	
	else
	
		self.infoCard:SetVisible( false )
	
	end;
	
	

end;

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:HigherOrLower( row )
	if ( !self.Player ) then return end;
	if ( !self.Player:IsPlayer() ) then return end;
	if ( !IsValid(self.Player) ) then return end;
	if ( !self.Player:Team() ) then return end;
	
	if ( !row.Player ) then return end;
	if ( !row.Player:IsPlayer() ) then return end;
	if ( !IsValid(row.Player) ) then return end;
	if ( !row.Player:Team() ) then return end;
	
	return self.Player:Team() < row.Player:Team()
end;


vgui.Register( "ScorePlayerRow", PANEL, "Button" )
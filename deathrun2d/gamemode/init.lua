//////////////////////////////////////////////////
// DeathRun 2D (by Hurricaaane (Ha3))
// - Main serverside.
//////////////////////////////////////////////////

AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "tables.lua" )
AddCSLuaFile( "ply_extension.lua" )
AddCSLuaFile( "sh_partialbrush.lua" )
AddCSLuaFile( "sh_datasharing.lua" )
AddCSLuaFile( "cl_sidescrolling.lua" )
AddCSLuaFile( "overv_chataddtext.lua" )
AddCSLuaFile( "cl_endgamesplash.lua" )

include( "shared.lua" )
include( "tables.lua" )
include( "ply_extension.lua" )
include( "sh_partialbrush.lua" )
include( "sh_datasharing.lua" )
include( "overv_chataddtext.lua" )

resource.AddFile("materials/dr2d/worldicon_use.vmt")
resource.AddFile("materials/dr2d/worldicon_use.vtf")
resource.AddFile("materials/dr2d/worldicon_arrow.vmt")
resource.AddFile("materials/dr2d/worldicon_arrow.vtf")


////////////////////
// Sounds
////////////////////

function GM:SetDeathSound( teamDiscrim, deathSound )
	if not self.Data.DeathSounds then self.Data.DeathSounds = {} end
	
	if (self.Data.DeathSounds[teamDiscrim] != deathSound) and (deathSound != "") then
		print("Death Sound : ", teamDiscrim, deathSound )
		
		local ext = string.Right(deathSound, 4)
		
		if (ext == ".wav") or (ext == ".mp3") then
			resource.AddFile("sound/" .. deathSound)
		end
	end

	self.Data.DeathSounds[teamDiscrim] = deathSound or ""
end

function GM:PlayerJoinTeam(ply, teamid) 
	if (!GAMEMODE:InRound()) and ply:Team() == TEAM_UNASSIGNED and (teamid == TEAM_RUNNERS or TEAM_KILLERS) then 
		ply:SetTeam(1)
	end
	
	if ply:Team() != TEAM_SPECTATOR and teamid == TEAM_SPECTATOR then
		ply:SetTeam(TEAM_SPECTATOR)
		ply:KillSilent()
		ply:ChatPrint(""..ply:Nick()..", you've joined Spectators.")
	end	
	
	if (ply:Team() == TEAM_UNASSIGNED or TEAM_SPECTATOR) and ( GAMEMODE:InRound() ) and GetGlobalFloat("RoundStartTime",CurTime()) - 20 < CurTime() 
		and (teamid == TEAM_RUNNERS or TEAM_KILLERS) then
		ply:SetTeam(1)
		timer.Simple(1, function()
			ply:Spawn()
			print("Late player successfully spawned.")
		end)
	end	
	
	if (ply:Team() == TEAM_UNASSIGNED or TEAM_SPECTATOR) and ( GAMEMODE:InRound() ) and GetGlobalFloat("RoundStartTime",CurTime()) + 20 < CurTime()
		and (teamid == TEAM_RUNNERS or TEAM_KILLERS) then
		timer.Simple(1, function()
		ply:KillSilent()
		ply:SetTeam(1)
		ply:ChatPrint("You'll spawn automatically when next round starts, "..ply:Nick()..".")
		print("Late player has not been spawned.")
		end)
	end
end


function GM:PlayerDeathSound( )
	return (self.Data.DeathSounds != nil)
end

function GM:PlayerDeath( victim )
	victim:ForceFlashlight( false )

	if self.Data.DeathSounds and self.Data.DeathSounds[victim:Team()] and self.Data.DeathSounds[victim:Team()] != "" then
		victim:EmitSound( self.Data.DeathSounds[victim:Team()] )
	end
	
	//victim:EmitSound("../../../common/left 4 dead 2 demo/left4dead2/sound/music/undeath/death.wav")
end

hook.Add( "PlayerSay", "restart", function( ply, text, team )
	if game.GetMap() == "dr2d_prison_break_v1"
	if ( string.sub( text, 1, 6 ) == "/repos" ) then
		if ply:Team() == TEAM_KILLERS then
			ply:SetPos(Vector(1189.562744, 740.533936, -86.191582))
		end
	end
	end
end )

//////////////////// 
// Misc
////////////////////



////////////////////
// Rounds
////////////////////

function GM:CanStartRound()
	if #team.GetPlayers( TEAM_RUNNERS ) + #team.GetPlayers( TEAM_KILLERS ) >= 2 then return true end
	return false
end

function GM:OnRoundStart( num )
	UTIL_UnFreezeAllPlayers()
	
end

function GM:OnRoundResult( t )
	UTIL_FreezeAllPlayers()
	team.AddScore( t, 1 )
	
	local rp = RecipientFilter()
	rp:AddAllPlayers( )
	umsg.Start("HaveRunnersWon", rp)
		umsg.Bool(t == TEAM_RUNNERS)
	umsg.End()
	
end

function GM:RoundTimerEnd()
	if ( !GAMEMODE:InRound() ) then return end
	GAMEMODE:RoundEndWithResult( ROUND_RESULT_DRAW )

end

function GM:InitPostEntity( )
	self:GatherPartialBrushList()
end

function GM:PlayerInitialSpawn( ply )
	self.BaseClass:PlayerInitialSpawn( ply )
	
	self:UpdatePartialBrushList( ply )
	self:UpdateEventSounds( ply )
	ply:CrosshairDisable()
end

function GM:PlayerSpawn( ply )

	ply:SetAllowFullRotation( false )

	if self.Data.FlashlightSpawn and self.Data.FlashlightSpawn != 0 then
		if (self.Data.FlashlightSpawn == 3) or (self.Data.FlashlightSpawn == ply:Team()) then
			ply:ForceFlashlight( true )
		end
	end
	
	self.BaseClass:PlayerSpawn(ply)
	
	if (!GAMEMODE:InRound()) then
	
	if team.NumPlayers( TEAM_RUNNERS ) >= 2 and team.NumPlayers( TEAM_KILLERS ) < 1 then
		local StartingDeath = table.Random( team.GetPlayers( TEAM_RUNNERS ) )
		StartingDeath:SetTeam( TEAM_KILLERS )
		StartingDeath:KillSilent()
		StartingDeath:Spawn()
	end
	
	if team.NumPlayers( TEAM_RUNNERS ) >= 8 and team.NumPlayers( TEAM_KILLERS ) == 1 then
		local SecondaryDeath = table.Random( team.GetPlayers( TEAM_RUNNERS ) )
		SecondaryDeath:SetTeam( TEAM_KILLERS )
		SecondaryDeath:KillSilent()
		SecondaryDeath:Spawn()
	end
	end
end


function GM:PlayerSwitchFlashlight( ply )
	if ply._ForceFlashlight then return true end

	if self.Data.FlashlightSwitch and self.Data.FlashlightSwitch != 0 then
		if (self.Data.FlashlightSwitch == 3) or (self.Data.FlashlightSwitch == ply:Team()) then
			return false
		end
	end
	return true
end


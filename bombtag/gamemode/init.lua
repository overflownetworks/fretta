
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_hud.lua" )

include( "shared.lua" )
include( "ply_extension.lua" )
include( "tables.lua" )

resource.AddFile( "materials/bombtag/bomb.vtf" )
resource.AddFile( "materials/bombtag/bomb.vmt" )
resource.AddFile( "materials/bombtag/clock.vtf" )
resource.AddFile( "materials/bombtag/clock.vmt" )
resource.AddFile( "materials/bombtag/hand.vtf" )
resource.AddFile( "materials/bombtag/hand.vmt" )

function GM:CanStartRound()
	if #team.GetPlayers( TEAM_ALIVE ) >= 2 then return true end
	return false
end

function GM:AlivePlayers( t )

	local tbl = {}

	for k,v in pairs( team.GetPlayers( t ) ) do
		if v:Alive() then
			table.insert( tbl, v )
		end
	end

	return tbl

end

function GM:ActivePlayers()

	local tbl = team.GetPlayers( TEAM_DEAD )
	table.Add( tbl, team.GetPlayers( TEAM_ALIVE ) )

	return tbl

end

function GM:PickNewPlayer()

	if #GAMEMODE:AlivePlayers( TEAM_ALIVE ) < 1 then return end

	for k,v in pairs( player.GetAll() ) do
		v:SetCarrier( false )
	end

	local newply = table.Random( GAMEMODE:AlivePlayers( TEAM_ALIVE ) )
	newply:SetCarrier( true )
	newply:SetTime( math.random( 20, 40 ) )
	newply:StripWeapons()
	newply:Give( "weapon_bomb" )

end

function GM:CheckForBomber()

	for k,v in pairs( team.GetPlayers( TEAM_ALIVE ) ) do
		if v:IsCarrier() then
			return v
		end
	end

	return

end

function GM:CheckRoundEnd()

	// Do checks here!
	if ( !GAMEMODE:InRound() ) then return end

	if ( #GAMEMODE:AlivePlayers( TEAM_ALIVE ) == 1 and #GAMEMODE:ActivePlayers() > 1 ) then

		local ply = GAMEMODE:AlivePlayers( TEAM_ALIVE )[1]
		GAMEMODE:RoundEndWithResult( ply )
		GAMEMODE.LastWinner = ply
	elseif ( #GAMEMODE:AlivePlayers( TEAM_ALIVE ) == 0 and #GAMEMODE:ActivePlayers() > 1 ) then
		local ply = table.Random(player.GetAll())
		GAMEMODE:RoundEndWithResult( ply )
		GAMEMODE.LastWinner = ply
	end

end

function GM:OnRoundEnd()

	for k,v in pairs( GAMEMODE:ActivePlayers() ) do

		if not v:Alive() or v:Team() == TEAM_DEAD then

			v:SetTeam( TEAM_ALIVE )
			v:Spawn()
			v:StripWeapons()


		end

		v:StripWeapons()

	end

end


function GM:OnRoundStart( num )

	UTIL_UnFreezeAllPlayers()



end

function GM:Think()

	self.BaseClass:Think()

	local bomber = GAMEMODE:CheckForBomber()

	if not bomber and team.NumPlayers( TEAM_ALIVE ) > 1 then
		GAMEMODE:PickNewPlayer()
	end

end

function GM:EntityTakeDamage(target, dmginfo)--( ent, inflictor, attacker, amount, dmginfo )

	if not target:IsPlayer() then return end
	if not target:Alive() then return end

	if target:Team() == TEAM_ALIVE and #GAMEMODE:AlivePlayers( TEAM_ALIVE ) == 1 then
		dmginfo:ScaleDamage( 0 )
	end

end

function GM:GetFallDamage( ply, flFallSpeed )

	return 0

end

function GM:DoPlayerDeath( ply, attacker, dmginfo )

	if dmginfo:IsExplosionDamage() then
		ply:SetModel( table.Random( GAMEMODE.Corpses ) )
	end

	ply:CallClassFunction( "OnDeath", attacker, dmginfo )
	ply:CreateRagdoll()
	ply:AddDeaths( 1 )

end


function GM:PlayerJoinTeam(ply, teamid)
	if (!GAMEMODE:InRound()) and ply:Team() == TEAM_UNASSIGNED and teamid == TEAM_ALIVE then
		ply:SetTeam(1)
	end

	if (ply:Team() == TEAM_UNASSIGNED or TEAM_SPECTATOR) and ( GAMEMODE:InRound() ) and GetGlobalFloat("RoundStartTime",CurTime()) + 30 < CurTime() and teamid == TEAM_ALIVE then
		ply:SetTeam(2)
		ply:KillSilent()
		ply:Spawn()
	elseif (ply:Team() == TEAM_UNASSIGNED or TEAM_SPECTATOR) and ( GAMEMODE:InRound() ) and teamid == TEAM_ALIVE then
		ply:SetTeam(1)
		ply:Spawn()
	end

	if ply:Team() != TEAM_SPECTATOR and teamid == TEAM_SPECTATOR then
		ply:SetTeam(TEAM_SPECTATOR)
		ply:KillSilent()
	end
end

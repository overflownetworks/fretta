local CLASS = {}  
  
CLASS.DisplayName           = "Runner"
CLASS.WalkSpeed             = 350
CLASS.CrouchedWalkSpeed     = 0.4
CLASS.RunSpeed              = 250
CLASS.DuckSpeed             = 0.4
CLASS.JumpPower             = 175
CLASS.DrawTeamRing          = true
CLASS.MaxHealth				= 100
CLASS.StartHealth			= 100
CLASS.Description           = ""

CLASS.RespawnTime           = 3
CLASS.DropWeaponOnDie		= true
CLASS.TeammateNoCollide 	= true
CLASS.AvoidPlayers			= false

function CLASS:Loadout( pl ) 
	pl:Give("weapon_crowbar")
end

function CLASS:ShouldDrawLocalPlayer( pl )
	return true
end

function CLASS:OnDeath(pl, attacker, dmginfo)

end



     
player_class.Register( "Runner", CLASS )  
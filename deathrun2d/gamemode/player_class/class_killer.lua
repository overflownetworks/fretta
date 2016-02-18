local CLASS = {}  
  
CLASS.DisplayName           = "Killer"
CLASS.WalkSpeed             = 350
CLASS.CrouchedWalkSpeed     = 0.4
CLASS.RunSpeed              = 500
CLASS.DuckSpeed             = 0.4
CLASS.JumpPower             = 175
CLASS.DrawTeamRing          = true
CLASS.MaxHealth				= 100
CLASS.StartHealth			= 100
CLASS.Description           = ""
//CLASS.PlayerModel	= "models/grim.mdl"

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

function CLASS:OnSpawn(pl)
	pl:ChatPrint("Type /repos,", Color(255, 0, 0, 255), "to respawn if you get stuck behind buttons!", Color(255, 255, 255, 255))
	timer.Simple(5, function()
		pl:ChatPrint("If buttons aren't working,", Color(255, 0, 0, 255), "hover your mouse cursor over them first!", Color(255, 255, 255, 255))
	end)
	
end

function CLASS:OnDeath(pl, attacker, dmginfo)

end
     
player_class.Register( "Killer", CLASS )  
-- Particles
game.AddParticles("particles/ravo_custom.pcf")
game.AddParticles("particles/mbd_blood_trail.pcf")
game.AddParticles("particles/vortigaunt_fx.pcf")
game.AddParticles("particles/antlion_gib_02.pcf")

PrecacheParticleSystem("big_smoke_cloud_orange")

--[[ PrecacheParticleSystem("vortigaunt_glow_charge_cp0")
PrecacheParticleSystem("vortigaunt_glow_charge_cp1") ]]
PrecacheParticleSystem("vortigaunt_glow_charge_cp1_beam")
PrecacheParticleSystem("vortigaunt_glow_charge_cp1_beam2")
PrecacheParticleSystem("vortigaunt_glow_charge_cp1_beam3")
PrecacheParticleSystem("vortigaunt_glow_charge_cp1_beam4")
PrecacheParticleSystem("vortigaunt_glow_charge_cp1_beam5")
PrecacheParticleSystem("vortigaunt_glow_charge_cp1_beam6")

PrecacheParticleSystem("antlion_gib_02_slime")
PrecacheParticleSystem("antlion_gib_02_juice")

PrecacheParticleSystem("mbd_blood_trail_00")
PrecacheParticleSystem("mbd_blood_trail_01")
PrecacheParticleSystem("mbd_blood_cloud_00")
PrecacheParticleSystem("mbd_blood_cloud_01")
PrecacheParticleSystem("mbd_blood_cloud_green_00")
PrecacheParticleSystem("mbd_blood_droplets_00")
PrecacheParticleSystem("mbd_blood_droplets_01")

--- -- - -- -
-- Look here:::: mbd_autorun_shared.lua and custom.lua ("PopulateContent") and cl_spawnmenu.lua ("model") and "createMachineTableFromJSON( ... )" This is where it all starts >.) Yaay
-- Custom Spawnlist/meny...
-- --- -
--

--[[---------------------------------------------------------

  Sandbox Gamemode

  This is GMod's default gamemode

-----------------------------------------------------------]]

include( "player_extension.lua" )
include( "persistence.lua" )
include( "save_load.lua" )
include( "player_class/player_sandbox.lua" )
include( "drive/drive_sandbox.lua" )
include( "editor_player.lua" )

--
-- Make BaseClass available
--
DEFINE_BASECLASS( "gamemode_base" )

--[[ GM.Name 	= "Sandbox"
GM.Author 	= "TEAM GARRY"
GM.Email 	= "teamgarry@garrysmod.com"
GM.Website 	= "www.garrysmod.com" ]]
GM.Name = "My Base Defence"
GM.Author = "ravo (Norway) Rasmus"
GM.Email = "N/A"
GM.Website = "N/A"

GM.IsSandboxDerived = true

cleanup.Register( "props" )
cleanup.Register( "ragdolls" )
cleanup.Register( "effects" )
cleanup.Register( "npcs" )
cleanup.Register( "constraints" )
cleanup.Register( "ropeconstraints" )
cleanup.Register( "sents" )
cleanup.Register( "vehicles" )


local physgun_limited = CreateConVar( "physgun_limited", "0", FCVAR_REPLICATED )

--[[---------------------------------------------------------
   Name: gamemode:CanTool( ply, trace, mode )
   Return true if the player is allowed to use this tool
-----------------------------------------------------------]]
function GM:CanTool( ply, trace, mode )

	-- The jeep spazzes out when applying something
	-- todo: Find out what it's reacting badly to and change it in _physprops
	if ( mode == "physprop" && trace.Entity:IsValid() && trace.Entity:GetClass() == "prop_vehicle_jeep" ) then
		return false
	end
	
	-- If we have a toolsallowed table, check to make sure the toolmode is in it
	if ( trace.Entity.m_tblToolsAllowed ) then
	
		local vFound = false	
		for k, v in pairs( trace.Entity.m_tblToolsAllowed ) do
			if ( mode == v ) then vFound = true end
		end

		if ( !vFound ) then return false end

	end
	
	-- Give the entity a chance to decide
	if ( trace.Entity.CanTool ) then
		return trace.Entity:CanTool( ply, trace, mode )
	end

	return true
	
end


--[[---------------------------------------------------------
   Name: gamemode:GravGunPunt( )
   Desc: We're about to punt an entity (primary fire).
		 Return true if we're allowed to.
-----------------------------------------------------------]]
function GM:GravGunPunt( ply, ent )

	if ( ent:IsValid() && ent.GravGunPunt ) then
		return ent:GravGunPunt( ply )
	end

	return BaseClass.GravGunPunt( self, ply, ent )
	
end

--[[---------------------------------------------------------
   Name: gamemode:GravGunPickupAllowed( )
   Desc: Return true if we're allowed to pickup entity
-----------------------------------------------------------]]
function GM:GravGunPickupAllowed( ply, ent )

	if ( ent:IsValid() && ent.GravGunPickupAllowed ) then
		return ent:GravGunPickupAllowed( ply )
	end

	return BaseClass.GravGunPickupAllowed( self, ply, ent )
	
end


--[[---------------------------------------------------------
   Name: gamemode:PhysgunPickup( )
   Desc: Return true if player can pickup entity
-----------------------------------------------------------]]
function GM:PhysgunPickup( ply, ent )

	-- Don't pick up persistent props
	if ( ent:GetPersistent() ) then return false end

	if ( ent:IsValid() && ent.PhysgunPickup ) then
		return ent:PhysgunPickup( ply )
	end
	
	-- Some entities specifically forbid physgun interaction
	if ( ent.PhysgunDisabled ) then return false end
	
	local EntClass = ent:GetClass()

	-- Never pick up players
	if ( EntClass == "player" ) then return false end
	
	if ( physgun_limited:GetBool() ) then
	
		if ( string.find( EntClass, "prop_dynamic" ) ) then return false end
		if ( string.find( EntClass, "prop_door" ) ) then return false end
		
		-- Don't move physboxes if the mapper logic says no
		if ( EntClass == "func_physbox" && ent:HasSpawnFlags( SF_PHYSBOX_MOTIONDISABLED ) ) then return false  end
		
		-- If the physics object is frozen by the mapper, don't allow us to move it.
		if ( string.find( EntClass, "prop_" ) && ( ent:HasSpawnFlags( SF_PHYSPROP_MOTIONDISABLED ) || ent:HasSpawnFlags( SF_PHYSPROP_PREVENT_PICKUP ) ) ) then return false end
		
		-- Allow physboxes, but get rid of all other func_'s (ladder etc)
		if ( EntClass != "func_physbox" && string.find( EntClass, "func_" ) ) then return false end

	
	end
	
	if ( SERVER ) then 
	
		--[[ ply:SendHint( "PhysgunFreeze", 2 )
		ply:SendHint( "PhysgunUse", 8 ) ]]
		
	end
	
	return true
	
end


--[[---------------------------------------------------------
   Name: gamemode:EntityKeyValue( ent, key, value )
   Desc: Called when an entity has a keyvalue set
	      Returning a string it will override the value
-----------------------------------------------------------]]
function GM:EntityKeyValue( ent, key, value )

	-- Physgun not allowed on this prop..
	if ( key == "gmod_allowphysgun" && value == '0' ) then
		ent.PhysgunDisabled = true
	end

	-- Prop has a list of tools that are allowed on it.
	if ( key == "gmod_allowtools" ) then
		ent.m_tblToolsAllowed = string.Explode( " ", value )
	end
	
end

--[[---------------------------------------------------------
   Name: gamemode:PlayerNoClip( player, bool )
   Desc: Player pressed the noclip key, return true if
		  the player is allowed to noclip, false to block
-----------------------------------------------------------]]
function GM:PlayerNoClip( pl, on )
	
	-- Don't allow if player is in vehicle
	if ( !IsValid( pl ) || pl:InVehicle() || !pl:Alive() ) then return false end
	
	-- Always allow to turn off noclip, and in single player
	if ( !on || game.SinglePlayer() ) then return true end

	return GetConVarNumber( "sbox_noclip" ) > 0
	
end

--[[---------------------------------------------------------
   Name: gamemode:CanProperty( pl, property, ent )
   Desc: Can the player do this property, to this entity?
-----------------------------------------------------------]]
function GM:CanProperty( pl, property, ent )
	
	--
	-- Always a chance some bastard got through
	--
	if ( !IsValid( ent ) ) then return false end


	--
	-- If we have a toolsallowed table, check to make sure the toolmode is in it
	-- This is used by things like map entities
	--
	if ( ent.m_tblToolsAllowed ) then
	
		local vFound = false	
		for k, v in pairs( ent.m_tblToolsAllowed ) do
			if ( property == v ) then vFound = true end
		end

		if ( !vFound ) then return false end

	end

	--
	-- Who can who bone manipulate?
	--
	if ( property == "bonemanipulate" ) then

		if ( game.SinglePlayer() ) then return true end

		if ( ent:IsNPC() ) then return GetConVarNumber( "sbox_bonemanip_npc" ) != 0 end
		if ( ent:IsPlayer() ) then return GetConVarNumber( "sbox_bonemanip_player" ) != 0 end
		
		return GetConVarNumber( "sbox_bonemanip_misc" ) != 0

	end

	--
	-- Weapons can only be property'd if nobody is holding them
	--
	if ( ent:IsWeapon() and IsValid( ent:GetOwner() ) ) then
		return false
	end

	-- Give the entity a chance to decide
	if ( ent.CanProperty ) then
		return ent:CanProperty( pl, property )
	end

	return true
	
end

--[[---------------------------------------------------------
   Name: gamemode:CanDrive( pl, ent )
   Desc: Return true to let the entity drive.
-----------------------------------------------------------]]
function GM:CanDrive( pl, ent )
	
	local classname = ent:GetClass();

	--
	-- Only let physics based NPCs be driven for now
	--
	if ( ent:IsNPC() ) then

		if ( classname == "npc_cscanner" ) then return true end
		if ( classname == "npc_clawscanner" ) then return true end
		if ( classname == "npc_manhack" ) then return true end
		if ( classname == "npc_turret_floor" ) then return true end
		if ( classname == "npc_rollermine" ) then return true end
		
		return false

	end

	if ( classname == "prop_dynamic" ) then return false end
	if ( classname == "prop_door" ) then return false end

	--
	-- I'm guessing we'll find more things we don't want the player to fly around during development
	--

	return true
	
end


--[[---------------------------------------------------------
	To update the player's animation during a drive
-----------------------------------------------------------]]
function GM:PlayerDriveAnimate( ply ) 

	local driving = ply:GetDrivingEntity()
	if ( !IsValid( driving ) ) then return end

	ply:SetPlaybackRate( 1 )
	ply:ResetSequence( ply:SelectWeightedSequence( ACT_HL2MP_IDLE_MAGIC ) )

	--
	-- Work out the direction from the player to the entity, and set parameters 
	--
	local DirToEnt = driving:GetPos() - ( ply:GetPos() + Vector( 0, 0, 50 ) )
	local AimAng = DirToEnt:Angle()

	if ( AimAng.p > 180 ) then
		AimAng.p = AimAng.p - 360
	end

	ply:SetPoseParameter( "aim_yaw",		0 )
	ply:SetPoseParameter( "aim_pitch",		AimAng.p )
	ply:SetPoseParameter( "move_x",			0 )
	ply:SetPoseParameter( "move_y",			0 )
	ply:SetPoseParameter( "move_yaw",		0 )
	ply:SetPoseParameter( "move_scale",		0 )

	AimAng.p = 0;
	AimAng.r = 0;

	ply:SetRenderAngles( AimAng )
	ply:SetEyeTarget( driving:GetPos() )

end

function fleshBodyPartPlayARandomSound(entity)
	if !entity or !entity:IsValid() then return end

	-- Some sound
	local sound1 = math.random(3, 4)

	entity:EmitSound("flesh_bloody_break")
	timer.Simple(0.1, function()
		if entity and entity:IsValid() then
			entity:EmitSound("flesh_squishy_impact_hard"..sound1)
		end
	end)
end
function fleshPlayARandomSound(entity)
	if !entity or !entity:IsValid() then return end

	-- Some sound
	local sound1 = math.random(1, 4)
	local sound2 = math.random(1, 4)

	local getSound = function(soundInt)
		local soundString

		if soundInt == 1 then soundString = "flesh_squishy_impact_hard1" end
		if soundInt == 2 then soundString = "flesh_squishy_impact_hard2" end
		if soundInt == 3 then soundString = "flesh_squishy_impact_hard3" end
		if soundInt == 4 then soundString = "flesh_squishy_impact_hard4" end

		return soundString
	end

	entity:EmitSound(getSound(sound1))
	timer.Simple(0.12, function()
		if entity and entity:IsValid() then
			entity:EmitSound(getSound(sound2))
		end
	end)

	timer.Simple(0.2, function()
		if entity and entity:IsValid() then
			entity:EmitSound("flesh_bloody_break")
		end
	end)
end
function fleshPlayHeadShotSound(entity)
	if !entity or !entity:IsValid() then return end

	local sound1 = math.random(1, 4)
	local sound2 = math.random(1, 4)

	-- Some sound
	entity:EmitSound("flesh_bloody_break")

	timer.Simple(0.1, function()
		if entity and entity:IsValid() then
			entity:EmitSound("flesh_squishy_impact_hard"..sound1)
			entity:EmitSound("flesh_bloody_impact_hard1")
			timer.Simple(0.15, function()
				if entity and entity:IsValid() then
					entity:EmitSound("flesh_squishy_impact_hard"..sound2)
				end
			end)
		end
	end)
end

function spawnBodyBodyPartParticles(entity, pos, ang, noBloodDrops)
	local effect = "mbd_blood_cloud_01"
	local effect2 = "mbd_blood_droplets_00"

	ParticleEffect(effect, pos, ang, entity)
	if !noBloodDrops then ParticleEffect(effect2, pos, ang, entity) end

	if !game.SinglePlayer() and attackerEnt and attackerEnt:IsValid() and attackerEnt:IsPlayer() then
		net.Start("mbd_PlayParticleEffectClient")
			net.WriteTable({
				effect,
				pos,
				ang,
				entity
			})
		net.Send(attackerEnt)
		--
		if !noBloodDrops then
			net.Start("mbd_PlayParticleEffectClient")
				net.WriteTable({
					effect2,
					pos,
					ang,
					entity
				})
			net.Send(attackerEnt)
		end
	end

	timer.Create("mdb:StopParticlesBodyPart"..entity:EntIndex(), 2, 1, function()
		if entity and entity:IsValid() then entity:StopParticles() end
	end)
end

-- -- -
-- - PreLoad all FA:S 2 SWEPS here also...
--- -
-- FA:S 2
util.PrecacheModel("models/weapons/view/shotguns/toz34.mdl")
util.PrecacheModel("models/weapons/world/rifles/ak12.mdl")
util.PrecacheModel("models/weapons/world/rifles/ak12.mdl")
util.PrecacheModel("models/weapons/view/support/sr25.mdl")
util.PrecacheModel("models/weapons/w_sr25.mdl")
util.PrecacheModel("models/weapons/w_snip_sg550.mdl")
util.PrecacheModel("models/weapons/view/rifles/sg550.mdl")
util.PrecacheModel("models/weapons/w_sg550.mdl")
util.PrecacheModel("models/weapons/w_rif_ak47.mdl")
util.PrecacheModel("models/weapons/view/pistols/p226.mdl")
util.PrecacheModel("models/weapons/w_pist_p228.mdl")
util.PrecacheModel("models/weapons/w_pist_p228.mdl")
util.PrecacheModel("models/weapons/view/pistols/ots33.mdl")
util.PrecacheModel("models/weapons/world/pistols/ots33.mdl")
util.PrecacheModel("models/weapons/world/pistols/ots33.mdl")
util.PrecacheModel("models/weapons/view/support/m82.mdl")
util.PrecacheModel("models/weapons/w_m82.mdl")
util.PrecacheModel("models/weapons/w_snip_sg550.mdl")
util.PrecacheModel("models/weapons/view/rifles/m4a1.mdl")
util.PrecacheModel("models/weapons/w_m4.mdl")
util.PrecacheModel("models/weapons/w_rif_m4a1.mdl")
util.PrecacheModel("models/weapons/view/support/m21.mdl")
util.PrecacheModel("models/weapons/w_m14.mdl")
util.PrecacheModel("models/weapons/w_snip_awp.mdl")
util.PrecacheModel("models/weapons/view/pistols/m1911.mdl")
util.PrecacheModel("models/weapons/w_1911.mdl")
util.PrecacheModel("models/weapons/w_pist_p228.mdl")
util.PrecacheModel("models/weapons/view/rifles/m14.mdl")
util.PrecacheModel("models/weapons/w_m14.mdl")
util.PrecacheModel("models/weapons/w_snip_awp.mdl")
util.PrecacheModel("models/weapons/view/rifles/g36c.mdl")
util.PrecacheModel("models/weapons/w_g36e.mdl")
util.PrecacheModel("models/weapons/w_rif_m4a1.mdl")
util.PrecacheModel("models/weapons/view/rifles/famas.mdl")
util.PrecacheModel("models/weapons/w_famas.mdl")
util.PrecacheModel("models/weapons/w_rif_famas.mdl")
util.PrecacheModel("models/weapons/view/pistols/deagle.mdl")
util.PrecacheModel("models/weapons/w_deserteagle.mdl")
util.PrecacheModel("models/weapons/w_pist_deagle.mdl")
util.PrecacheModel("models/weapons/view/rifles/an94.mdl")
util.PrecacheModel("models/weapons/world/rifles/an94.mdl")
util.PrecacheModel("models/weapons/world/rifles/an94.mdl")
util.PrecacheModel("models/weapons/view/rifles/ak12.mdl")
util.PrecacheModel("models/weapons/world/rifles/ak12.mdl")
util.PrecacheModel("models/weapons/world/rifles/ak12.mdl")
util.PrecacheModel("models/weapons/view/rifles/sks.mdl")
util.PrecacheModel("models/weapons/world/rifles/sks.mdl")
util.PrecacheModel("models/weapons/w_snip_awp.mdl")
util.PrecacheModel("models/weapons/view/rifles/sg552.mdl")
util.PrecacheModel("models/weapons/w_sg550.mdl")
util.PrecacheModel("models/weapons/w_rif_ak47.mdl")
util.PrecacheModel("models/weapons/view/support/rpk.mdl")
util.PrecacheModel("models/weapons/w_ak47.mdl")
util.PrecacheModel("models/weapons/w_rif_ak47.mdl")
util.PrecacheModel("models/weapons/view/rifles/rk95.mdl")
util.PrecacheModel("models/weapons/world/rifles/rk95.mdl")
util.PrecacheModel("models/weapons/w_rif_ak47.mdl")
util.PrecacheModel("models/weapons/view/smgs/bizon.mdl")
util.PrecacheModel("models/weapons/w_smg_biz.mdl")
util.PrecacheModel("models/weapons/w_smg_biz.mdl")
util.PrecacheModel("models/weapons/view/shotguns/m3s90.mdl")
util.PrecacheModel("models/weapons/w_m3.mdl")
util.PrecacheModel("models/weapons/w_shot_m3super90.mdl")
util.PrecacheModel("models/weapons/view/support/m24.mdl")
util.PrecacheModel("models/weapons/w_m24.mdl")
util.PrecacheModel("models/weapons/w_snip_awp.mdl")
util.PrecacheModel("models/weapons/view/pistols/glock20.mdl")
util.PrecacheModel("models/weapons/w_pist_glock18.mdl")
util.PrecacheModel("models/weapons/w_pist_glock18.mdl")
util.PrecacheModel("models/weapons/view/rifles/g3.mdl")
util.PrecacheModel("models/weapons/w_g3a3.mdl")
util.PrecacheModel("models/weapons/w_rif_ak47.mdl")
util.PrecacheModel("models/weapons/view/rifles/ak74.mdl")
util.PrecacheModel("models/weapons/w_ak47.mdl")
util.PrecacheModel("models/weapons/w_rif_ak47.mdl")
util.PrecacheModel("models/weapons/view/rifles/ak47.mdl")
util.PrecacheModel("models/weapons/w_ak47.mdl")
util.PrecacheModel("models/weapons/w_rif_ak47.mdl")
util.PrecacheModel("models/Items/AR2_Grenade.mdl")
util.PrecacheModel("models/weapons/view/pistols/ragingbull.mdl")
util.PrecacheModel("models/weapons/w_357.mdl")
util.PrecacheModel("models/weapons/view/rifles/galil.mdl")
util.PrecacheModel("models/weapons/w_rif_galil.mdl")
--
util.PrecacheModel("models/Items/BoxMRounds.mdl")
util.PrecacheModel("models/Items/BoxSRounds.mdl")
util.PrecacheModel("models/Items/ammocrate_smg1.mdl")
-- OWN SWEPS
util.PrecacheModel("models/sweprepair/sweprepair.mdl")
util.PrecacheModel("models/sweprepair_w/sweprepair_w.mdl")
util.PrecacheModel("models/sweprepair/sweprepair.mdl")
util.PrecacheModel("models/sweprepair_w/sweprepair_w.mdl")

-- Custom models..
util.PrecacheModel("models/zombie/Classic_split.mdl")
util.PrecacheModel("models/zombie/Zombie_Soldier_split.mdl")
util.PrecacheModel("models/combine/Combine_Super_Soldier_split.mdl")
util.PrecacheModel("models/combine/Combine_Soldier_split.mdl")
util.PrecacheModel("models/combine/Combine_Soldier_PrisonGuard_split.mdl")

util.PrecacheModel("models/zombie/soldier_leftarm.mdl")
util.PrecacheModel("models/zombie/soldier_rightarm.mdl")
util.PrecacheModel("models/zombie/soldier_leftleg.mdl")
util.PrecacheModel("models/zombie/soldier_rightleg.mdl")

util.PrecacheModel("models/combine/super_soldier_head.mdl")
util.PrecacheModel("models/combine/super_soldier_leftarm.mdl")
util.PrecacheModel("models/combine/super_soldier_rightarm.mdl")
util.PrecacheModel("models/combine/super_soldier_leftleg.mdl")
util.PrecacheModel("models/combine/super_soldier_rightleg.mdl")

util.PrecacheModel("models/combine/soldier_head.mdl")
util.PrecacheModel("models/combine/soldier_leftarm.mdl")
util.PrecacheModel("models/combine/soldier_rightarm.mdl")
util.PrecacheModel("models/combine/soldier_leftleg.mdl")
util.PrecacheModel("models/combine/soldier_rightleg.mdl")

util.PrecacheModel("models/combine/soldier_prisonguard_head.mdl")
util.PrecacheModel("models/combine/soldier_prisonguard_leftarm.mdl")
util.PrecacheModel("models/combine/soldier_prisonguard_rightarm.mdl")
util.PrecacheModel("models/combine/soldier_prisonguard_leftleg.mdl")
util.PrecacheModel("models/combine/soldier_prisonguard_rightleg.mdl")

-- Sounds
util.PrecacheSound("game/buildpoints_collected.wav")
util.PrecacheSound("game/buybox_buysound.wav")
util.PrecacheSound("game/buybox_category_click_Mike_Koenig.wav")
util.PrecacheSound("game/buybox_category_click_SoundBible_Mike_Koenig.wav")
util.PrecacheSound("game/countdown_beep_halo.wav")
util.PrecacheSound("game/end_game_theme_song.wav")
util.PrecacheSound("game/money_collected.wav")
util.PrecacheSound("game/prop_spawn.wav")
util.PrecacheSound("game/pyramid_drop_pickup.wav")
util.PrecacheSound("game/siren1_2_newMix_Mike_Koenig.wav")
util.PrecacheSound("game/train_whistle1_newMix.wav")
util.PrecacheSound("game/lobby_menu_class_pick.wav")
util.PrecacheSound("game/slow_breathing.wav")
util.PrecacheSound("game/prop_spawn_error.wav")

util.PrecacheSound("game/vehicle/horn_jeep.wav")
util.PrecacheSound("game/vehicle/horn_jalopy.wav")
util.PrecacheSound("game/vehicle/horn_jalopy2.wav")
util.PrecacheSound("game/vehicle/horn_airboat.wav")
util.PrecacheSound("game/vehicle/horn_clown.wav")

util.PrecacheSound("swep/droppingwrench.wav")
util.PrecacheSound("swep/hammer.wav")
util.PrecacheSound("swep/hammer2.wav")
util.PrecacheSound("swep/metal_bang1.wav")
util.PrecacheSound("swep/metal_bang2.wav")
util.PrecacheSound("swep/ticktock.wav")
util.PrecacheSound("swep/ticktock_SoundBible_Mike_Koenig.wav")
util.PrecacheSound("swep/ticktock2.wav")
util.PrecacheSound("swep/ticktock2_SoundBible_Mike_Koenig.wav")
util.PrecacheSound("swep/prop_ok0.wav")
util.PrecacheSound("swep/prop_ok1.wav")
util.PrecacheSound("swep/prop_ok2.wav")
util.PrecacheSound("swep/vehicle_ok0.wav")
util.PrecacheSound("swep/vehicle_ok1.wav")
util.PrecacheSound("swep/vehicle_ok2.wav")

util.PrecacheSound("blocker/short_circut.wav")

util.PrecacheSound("fleshNew/flesh_bloody_break.wav")
util.PrecacheSound("fleshNew/flesh_bloody_impact_hard1.wav")
util.PrecacheSound("fleshNew/flesh_squishy_impact_hard1.wav")
util.PrecacheSound("fleshNew/flesh_squishy_impact_hard2.wav")
util.PrecacheSound("fleshNew/flesh_squishy_impact_hard3.wav")
util.PrecacheSound("fleshNew/flesh_squishy_impact_hard4.wav")

util.PrecacheSound("mysterybox_bo3/bye_bye.wav")
util.PrecacheSound("mysterybox_bo3/chains_locked.wav")
util.PrecacheSound("mysterybox_bo3/child.wav")
util.PrecacheSound("mysterybox_bo3/close.wav")
util.PrecacheSound("mysterybox_bo3/disappear.wav")
util.PrecacheSound("mysterybox_bo3/flux_l.wav")
util.PrecacheSound("mysterybox_bo3/flux_r.wav")
util.PrecacheSound("mysterybox_bo3/land.wav")
util.PrecacheSound("mysterybox_bo3/music_box.wav")
util.PrecacheSound("mysterybox_bo3/nani.wav")
util.PrecacheSound("mysterybox_bo3/open.wav")
util.PrecacheSound("mysterybox_bo3/poof.wav")
util.PrecacheSound("mysterybox_bo3/purchase.wav")
util.PrecacheSound("mysterybox_bo3/rich.wav")
util.PrecacheSound("mysterybox_bo3/whoosh.wav")

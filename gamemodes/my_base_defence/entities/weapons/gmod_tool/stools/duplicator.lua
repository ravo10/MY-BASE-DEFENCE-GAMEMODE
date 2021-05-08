
AddCSLuaFile()

include( "duplicator/transport.lua" )
include( "duplicator/arming.lua" )

if ( CLIENT ) then

	include( "duplicator/icon.lua" )

else

	AddCSLuaFile( "duplicator/arming.lua" )
	AddCSLuaFile( "duplicator/transport.lua" )
	AddCSLuaFile( "duplicator/icon.lua" )
	util.AddNetworkString( "CopiedDupe" )

end

TOOL.Category = "Construction"
TOOL.Name = "#tool.duplicator.name"
TOOL.Stored = true

TOOL.Information = {
	{ name = "left" },
	{ name = "right" }
}

cleanup.Register( "duplicates" )

--
-- PASTE
--
function TOOL:LeftClick( trace )

	if ( CLIENT ) then return true end

	--
	-- Get the copied dupe. We store it on the player so it will still exist if they die and respawn.
	--
	local dupe = self:GetOwner().CurrentDupe
	if ( !dupe ) then return end

	--
	-- We want to spawn it flush on thr ground. So get the point that we hit
	-- and take away the mins.z of the bounding box of the dupe.
	--
	local SpawnCenter = trace.HitPos
	SpawnCenter.z = SpawnCenter.z - dupe.Mins.z

	--
	-- Spawn it rotated with the player - but not pitch.
	--
	local SpawnAngle 	= self:GetOwner():EyeAngles()
	SpawnAngle.pitch 	= 0
	SpawnAngle.roll 	= 0

	--
	-- Spawn them all at our chosen positions
	--
	duplicator.SetLocalPos( SpawnCenter )
	duplicator.SetLocalAng( SpawnAngle )

	DisablePropCreateEffect = true

		local Ents, Constraints = duplicator.Paste( self:GetOwner(), dupe.Entities, dupe.Constraints )

	DisablePropCreateEffect = nil

	duplicator.SetLocalPos( Vector( 0, 0, 0 ) )
	duplicator.SetLocalAng( Angle( 0, 0, 0 ) )

	--
	-- Create one undo for the whole creation
	--
	undo.Create( "Duplicator" )

		for k, ent in pairs( Ents ) do
			undo.AddEntity( ent )
		end

		for k, ent in pairs( Ents )	do
			self:GetOwner():AddCleanup( "duplicates", ent )
		end

		undo.SetPlayer( self:GetOwner() )

	undo.Finish()


	-- M.B.D. Custom
	timer.Simple(0.15, function()
		for k, ent in pairs( Ents ) do
			if (
				ent and
				ent:IsValid() and
				string.match(ent:GetName(), "mbd_")
			) then
				-- Check if whitelisted will happen in networkString "PlayerWantsToSpawnProp"
				
				-- Found the Correct Parent
				--
				-- Update the NPC Bullseye "Virtual" Parent (maybe I don't need to...)
				local hitboxChild = ent:GetNWEntity("mbd_npc_bullseye_child", nil)
				if hitboxChild and ent and ent:IsValid() then
					hitboxChild:SetNWEntity("mbd_npc_bullseye_parent", ent)
				end
				if ent and ent:IsValid() and self:GetOwner() and self:GetOwner():IsValid() then
					-- Make Non-Solid
					ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

					ent:SetNWBool("IsFromDuplication", true)

					ent:SetNWEntity("PlayerOwnerEnt", self:GetOwner())
					ent:SetCreator(self:GetOwner())

					if (string.match(ent:GetClass(), "prop_vehicle")) then
						MBDAddSomeMBDStuffAVehicle(ent, ent:GetClass())
					end
				end
			else
				ClientPrintAddTextMessage(self:GetOwner(), {Color(254, 81, 0), "You are only allowed to spawn duplications built in M.B.D.!"})

				if (
					ent and
					ent:IsValid()
				) then
					ent:Remove()
				end
			end
		end
	end)

	return true

end

--
-- Copy
--
function TOOL:RightClick( trace )

	if ( !IsValid( trace.Entity ) ) then return false end
	if ( CLIENT ) then return true end
	
	if SERVER then
		trace.Entity = GetCorrectEntForProps(trace.Entity)

		-- Hinder Duplication of unwanted entites
		if HinderDuplicationOrRemovalOfEntities(self, trace.Entity, "dup") then return false end
	end

	--
	--- MBD Specs..>>
	local DuplicatorPlayerOwner = self:GetOwner()

	local __EntModel 			= trace.Entity:GetModel()
	local __EntClass 			= trace.Entity:GetClass()
	local __IsWeldedToVehicle	= false
	local __TheVehicleEnt		= nil

	--
	--- Check if it is a ADMIN-entity and not allowed or what...
	if __EntClass then
		--
		-- Needs to be an Admin
		if (
			__EntClass == "mbd_buybox" and
			DuplicatorPlayerOwner:MBDIsNotAnAdmin(true)
		) then return false end
		--
		-- Needs to be a SuperAdmin
		if (
			__EntClass == "mbd_npc_spawner_all" and
			DuplicatorPlayerOwner:MBDIsNotAnAdmin(false)
		) then return false end
	else return false end

	for _, v in pairs(constraint.GetAllConstrainedEntities(trace.Entity)) do
		-- Remove isWelded...
		-- -- ->
		--- MBD Specs.. >>
		if string.match(v:GetClass(), "prop_vehicle") then __TheVehicleEnt = v end
		if (
			v:IsValid() and
			v:GetNWBool("isWeldedToVehicle", false)
		) then __IsWeldedToVehicle = true end
	end
	if (
		__IsWeldedToVehicle or (
			__EntModel and (
				string.match(__EntModel, "models/buggy.mdl") or
				string.match(__EntModel, "models/vehicle.mdl") or
				string.match(__EntModel, "models/airboat.mdl")
			)
		)
	) then
		DuplicatorPlayerOwner = trace.Entity:GetCreator()

		if __TheVehicleEnt then DuplicatorPlayerOwner = __TheVehicleEnt:GetCreator() end
		if DuplicatorPlayerOwner == "" or !DuplicatorPlayerOwner then return false end
		
		if !DuplicatorPlayerOwner or ( DuplicatorPlayerOwner and !DuplicatorPlayerOwner:IsValid() ) then return false end
		--
		-- -- -->>
		if DuplicatorPlayerOwner:MBDIsNotAnAdmin(true) then
			---- -- -
			-- Not allowed; you can only have one vehicle..>
			return false
		end
	end

	--
	-- Set the position to our local position (so we can paste relative to our `hold`)
	--
	duplicator.SetLocalPos( trace.HitPos )
	duplicator.SetLocalAng( Angle( 0, self:GetOwner():EyeAngles().yaw, 0 ) )

	local Dupe = duplicator.Copy( trace.Entity )

	duplicator.SetLocalPos( Vector( 0, 0, 0 ) )
	duplicator.SetLocalAng( Angle( 0, 0, 0 ) )

	if ( !Dupe ) then return false end

	--
	-- Tell the clientside that they're holding something new
	--
	net.Start( "CopiedDupe" )
		net.WriteUInt( 1, 1 )
	net.Send( self:GetOwner() )

	--
	-- Store the dupe on the player
	--
	self:GetOwner().CurrentDupeArmed = false
	self:GetOwner().CurrentDupe = Dupe

	return true

end

--[[---------------------------------------------------------
	Builds the context menu
-----------------------------------------------------------]]
function TOOL.BuildCPanel( CPanel )

	CPanel:AddControl( "Header", { Description = "#tool.duplicator.desc" } )

	CPanel:AddControl( "Button", { Text = "#tool.duplicator.showsaves", Command = "dupe_show" } )

end

if ( CLIENT ) then

	--
	-- Received by the client to alert us that we have something copied
	-- This allows us to enable the save button in the spawn menu
	--
	net.Receive( "CopiedDupe", function( len, client )

		if ( net.ReadUInt( 1 ) == 1 ) then
			hook.Run( "DupeSaveAvailable" )
		else
			hook.Run( "DupeSaveUnavailable" )
		end

	end )

end

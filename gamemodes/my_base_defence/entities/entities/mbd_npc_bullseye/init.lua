AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
	self:SetModelScale(0)
	self:Activate()
	
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:SetColor(Color(
		255,
		255,
		255,
		0
	))

	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetNotSolid(true)

	self:AddEFlags(EFL_DONTWALKON)
	self:AddEFlags(EFL_DONTBLOCKLOS)
	
	self:DrawShadow(false)

	-- NPC Bullseye
	--
	local npc_bullseye = ents.Create("npc_bullseye")

	npc_bullseye:SetModel(self:GetModel())
	npc_bullseye:SetSolid(SOLID_OBB)
	npc_bullseye:SetModelScale(1.4, 0)
	npc_bullseye:DrawShadow(false)

	npc_bullseye:SetName("mbd_prop_bullseye_target")

	npc_bullseye:SetRenderMode(RENDERMODE_TRANSALPHA)
	npc_bullseye:SetColor(
		Color(0, 0, 0, 100)
	)
	npc_bullseye:SetPersistent(true)
	npc_bullseye:SetMoveType(MOVETYPE_NONE)
	npc_bullseye:DrawShadow(false)
	npc_bullseye:SetSolid(SOLID_OBB) -- Veldig viktig for at skudd skal gå igjennom, og alle NPC som Zombie kan slå den
	
	npc_bullseye:SetParent(self)
	npc_bullseye:SetOwner(self:GetOwner())
	npc_bullseye:SetCreator(self:GetOwner())

	npc_bullseye:SetPos(self:GetPos())
	npc_bullseye:SetAngles(self:GetAngles())

	npc_bullseye:Spawn()
	npc_bullseye:Activate()

	-- --

	-- Init physics only on server, so it doesn't mess up physgun beam
	-- Very important for Ent:Use
	if (SERVER) then self:PhysicsInit(SOLID_VPHYSICS) end
end

local maybeResetPos = function (_self, _selfParentPos, _NPCBullsEyePos, _Dist, _Pos)
	--
	--- Check if the Prop is to far away... The Reset... (this only applies when a prop has an NPC-enemy)
	-- Or else, it will follow always...
	if (
		_selfParentPos:DistToSqr(_NPCBullsEyePos) > (_Dist*_Dist) or
		!_self:GetNWBool("has_bullseye_hater", false)
	) then
		-- print("Reset Track Pos")
		_self:SetNWEntity("bullseye_hater_npc", nil)
		_self:SetNWBool("has_bullseye_hater", false)

		_self:SetPos(_Pos)
	end
end

changeToRoofMaybeVisually = function (isARoof, _ParentProp)
	local _colorRoof = Color(
		0,
		0,
		0,
		255
	)

	-- Make it a roof (set color to show)
	if isARoof then
		local _color = _ParentProp:GetColor()
		local _colorString = _color.r..",".._color.g..",".._color.b..",".._color.a

		timer.Simple(0.15, function()
			if (
				_ParentProp and
				_ParentProp:IsValid() and
				_ParentProp:GetColor() != _colorRoof and
				_ParentProp:GetNWString("originalColorRoof", "") == ""
			) then
				_ParentProp:SetNWString("originalColorRoof", _colorString)
				_ParentProp:SetColor(_colorRoof)
			end
		end)
	else
		local _color = _ParentProp:GetNWString("originalColorRoof", "")
		if _color == "" then return end

		_color = string.Split(_color, ",")
		_color = Color(
			_color[1],
			_color[2],
			_color[3],
			_color[4]
		)

		timer.Simple(0.15, function()
			if (
				_ParentProp and
				_ParentProp:IsValid() and
				_ParentProp:GetColor() != _color
			) then
				_ParentProp:SetNWString("originalColorRoof", "")
				_ParentProp:SetColor(_color)
			end
		end)
	end
end

function ENT:Think()
	local _Pos 				= 0
	local _ParentProp 		= nil
	local _ChildBullseye 	= nil
	local _npc_bullseye		= nil
	local _NewZPos 			= nil -- Use this to add or subtract from LocalZ pos
	local _NewZPosLocal 	= nil -- Use this to add or subtract from LocalZ pos

	--
	--- -- Set Good position for bullseye...>>
	_ParentProp		= self:GetNWEntity("mbd_npc_bullseye_parent", nil)
	_ChildBullseye	= _ParentProp:GetNWEntity("mbd_npc_bullseye_child", nil)

	if !_ParentProp or !_ParentProp:IsValid() then return end
	if !_ChildBullseye or !_ChildBullseye:IsValid() then
		-- Set what "NPC Bullseye" the Parent is connected to
		--- -
		_ParentProp:SetNWEntity("mbd_npc_bullseye_child", self)

		if self then _npc_bullseye = self:GetChildren()[1] end
	end

	-- Check that the prop is not laying flat.. (if a roof, then don't move in the z-axis...)
	local angles = _ParentProp:GetAngles()
	local pitch = math.Round(angles.p)
	local roll = math.Round(angles.r)
	if pitch < 0 then pitch = pitch * -1 end
	if roll < 0 then roll = roll * -1 end
	
	local isARoof = false
	
	local entModel = _ParentProp:GetModel()
	local limit = 20
	
	if (
		(
			pitch <= limit
		) and (
			roll <= limit or
			180 - roll <= limit
		) and (
			entModel == "models/props_phx/construct/metal_plate4x4.mdl" or
			entModel == "models/props_phx/construct/metal_plate4x4_tri.mdl" or
			entModel == "models/props_phx/construct/windows/window4x4.mdl" or
			entModel == "models/hunter/plates/plate4x4.mdl" or
			entModel == "models/hunter/plates/plate4x6.mdl" or
			entModel == "models/hunter/plates/plate4x7.mdl" or
			entModel == "models/hunter/plates/plate4x8.mdl" or
			entModel == "models/hunter/plates/plate5x5.mdl" or
			entModel == "models/hunter/plates/plate5x6.mdl" or
			entModel == "models/hunter/plates/plate5x7.mdl" or
			entModel == "models/hunter/plates/plate5x8.mdl" or
			entModel == "models/hunter/plates/plate6x6.mdl"
		)
	) then isARoof = true end

	-- Check
	changeToRoofMaybeVisually(isARoof, _ParentProp)

	local entMinPos = _ParentProp:LocalToWorld(_ParentProp:OBBMins())
	local entMaxPos = _ParentProp:LocalToWorld(_ParentProp:OBBMaxs())
	
	if entMinPos.z < entMaxPos.z then
		-- Just leave it like this
		_NewZPos = entMinPos.z + 50 -- +50 = Good height for NPC
	else
		-- Get the Correct Position
		_NewZPos = entMaxPos.z + 50 -- +50 = Good height for NPC
	end

	_Pos = _ParentProp:OBBCenter()

	-- For Vehicles
	if _ParentProp:GetClass() != "prop_physics" then
		if (_ParentProp:GetModel() == "models/vehicle.mdl") then
			-- Jalopy
			_Pos.y		= _ParentProp:OBBMaxs().y - 20 -- On the engine (front)...
			_NewZPos 	= _NewZPos + 15
		elseif (_ParentProp:GetModel() == "models/airboat.mdl") then 
			-- Airboat 
			_Pos.y 		= _ParentProp:OBBMins().y + 5 -- On the engine (back)...
			_NewZPos 	= _NewZPos + 30
		else
			-- Jeep 
			_Pos.y		= _ParentProp:OBBMins().y + 5 -- On the engine (back)...
		end
	end

	-- If the Prop is at an angle, move it in the X-direction
	local _Pitch = _ParentProp:GetAngles().pitch
	_Pos.x = _Pos.x - (_Pitch * 1.95)

	_Pos 	= _ParentProp:LocalToWorld(_Pos)
	_Pos.z	= _NewZPos
	-- --
	-- Check if there is an NPC Close to the Bullseye...
	local SelfPos = self:GetPos()
	SelfPos 	= self:WorldToLocal(SelfPos)
	SelfPos.x 	= (SelfPos.x - 50)

	SelfPos 	= self:LocalToWorld(SelfPos)
	SelfPos.z 	= _Pos.z

	local _Dist 	= 87
	local _DistProp = 112
	
	local _ExtraDist = _ParentProp:OBBMaxs()
	_ExtraDist = math.max(_ExtraDist.x, _ExtraDist.y, _ExtraDist.z)

	_Dist = _Dist + _ExtraDist -- Looks to be working pretty nicely

	local checkIfPlayerIsNear = function ()
		if (!self:GetNWBool("has_bullseye_hater", false)) then
			local _DistancePlayer = 80
			for k,v in pairs(player.GetAll()) do
				if (
					v and
					v:IsValid() and
					self:GetPos():DistToSqr(v:GetPos()) <= (_DistancePlayer*_DistancePlayer) -- Check if within range
				) then
					self:SetNWBool("playerIsNear", true)
	
					break
				end
			end
		end
	end

	local setSolid = function ()
		if !self:IsSolid() then
			-- print('SOLID')

			-- Make collideable
			self:SetCollisionGroup(COLLISION_GROUP_WORLD)
			self:GetChildren()[1]:SetSolid(SOLID_VPHYSICS)
		end
	end
	local setNotSolid = function ()
		if self:IsSolid() then
			-- print('NOT SOLID')

			-- Make non-collideable...
			self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
			self:GetChildren()[1]:SetSolid(SOLID_NONE)
		end
	end

	checkIfPlayerIsNear()
	-- -

	local NPCs = ents.FindByClass("npc_*")
	for k,v in pairs(NPCs) do
		local FoundANPC = false

		if MBD_CheckIfNotBullseyeEntity(v:GetClass()) then
			if (
				v and
				v:IsValid() and
				SelfPos:DistToSqr(v:GetPos()) <= (_Dist*_Dist) -- Check if within range
			) then
				FoundANPC = true

				-- Rather Move In-front of this NPC...
				local NPC = v

				local NPCPos = NPC:GetPos()
				NPCPos = NPC:WorldToLocal(NPCPos)
				NPCPos.x = (NPCPos.x + 40)

				local OverRidePos = nil

				if (
					NPC and
					NPC:IsValid() and
					NPC.GetEnemy
				) then
					local NPCEnemy = NPC:GetEnemy()

					self:SetNWEntity("bullseye_hater_npc", NPCEnemy)

					if SelfPos:DistToSqr(_ParentProp:GetPos()) > (_DistProp*_DistProp) then
						-- Reset....
						OverRidePos = _ParentProp:OBBCenter()

						if (
							!self or
							!self:IsValid() or
							!_ParentProp:IsValid() or
							!_ParentProp:IsValid() or
							!self:GetChildren()[1] or
							!self:GetChildren()[1]:IsValid()
						) then return end
						
						maybeResetPos(self, _ParentProp:GetPos(), self:GetChildren()[1]:GetPos(), _DistProp, _Pos)
					elseif (
						NPCEnemy and
						NPCEnemy:IsValid() and
						NPCEnemy == _npc_bullseye and
						SelfPos:DistToSqr(_ParentProp:GetPos()) > (_DistProp*_DistProp) and -- Check if within range from the Parent prop
						SelfPos:DistToSqr(_ParentProp:GetPos()) <= (_DistProp + 0.1*_DistProp + 0.1)
					) then
						-- Don't know if this actually matters...
						-- Just move a little closer to Prop (for more realism...)
						local ParentPosCenter = _ParentProp:OBBCenter()

						local xPosDifference = (math.max(ParentPosCenter.x, NPCPos.x) - math.min(ParentPosCenter.x, NPCPos.x))
						local yPosDifference = (math.max(ParentPosCenter.y, NPCPos.y) - math.min(ParentPosCenter.y, NPCPos.y))
						local zPosDifference = (math.max(ParentPosCenter.z, NPCPos.z) - math.min(ParentPosCenter.z, NPCPos.z))

						NPCPos.x = (NPCPos.x - xPosDifference + 15)
						NPCPos.y = (NPCPos.y - yPosDifference + 15)
						NPCPos.z = (NPCPos.z - zPosDifference)
					end
				end



				local WorldPos = NPC:LocalToWorld(NPCPos)
				WorldPos.z = _Pos.z

				if OverRidePos then WorldPos = _ParentProp:LocalToWorld(OverRidePos) WorldPos.z = _Pos.z end

				_Pos = WorldPos
				if (
					isARoof and
					NPC and
					NPC:IsValid()
				) then
					local minZPos = _ParentProp:LocalToWorld(_ParentProp:OBBMins()).z
					local maxZPosEnemy = NPC:LocalToWorld(NPC:OBBMaxs()).z

					-- If position is equal or higher up than the enemy,
					-- then use the roof-settings for the NPC Bullseye
					if (
						minZPos >= (maxZPosEnemy - 10)
					) then
						-- Set minimum roof Z-axis
						_Pos.z = minZPos
					else
						if SelfPos:DistToSqr(_ParentProp:GetPos()) > (_Dist*_Dist) then
							-- Reset....
							maybeResetPos(self, _ParentProp:GetPos(), self:GetChildren()[1]:GetPos(), _Dist, _Pos)
						end
					end
				else
					_ParentProp:SetCollisionGroup(COLLISION_GROUP_BREAKABLE_GLASS)
				end
				
				self:SetNWBool("playerIsNear", false)
				
				setSolid()
				
				break
			end
		end

		if (
			k == #NPCs and
			!FoundANPC
		) then
			-- Reset if no NPC in range...
			self:SetNWEntity("bullseye_hater_npc", nil)
			self:SetNWBool("has_bullseye_hater", false)

			checkIfPlayerIsNear()
		end
	end
	-- Move away from Players... To try and hindre the NPC Bullseye colliding with the weapon...
	-- This will cause the weapon to not fire !
	timer.Simple(0.2, function()
		if (
			!self or
			!self:IsValid() or
			!_ParentProp:IsValid() or
			!_ParentProp:IsValid() or
			!self:GetChildren()[1] or
			!self:GetChildren()[1]:IsValid()
		) then return end
		
		local BullseyeHater = self:GetNWEntity("bullseye_hater_npc", nil)
		local HasANPCPos = self:GetNWBool("has_bullseye_hater", false)

		-- Set
		if (
			self and
			self:IsValid()
		) then
			if !_ParentProp or !_ParentProp:IsValid() then return end

			local _selfParentPos = _ParentProp:GetPos()
			_selfParentPos.z = SelfPos.z
			local _NPCBullsEyePos = self:GetChildren()[1]:GetPos()
			_NPCBullsEyePos.z = SelfPos.z

			local PlayerIsNear = self:GetNWBool("playerIsNear", false)

			--
			--- If a Player is near... Set the Position once until reset (Player goes away or NPC is close by)
			if PlayerIsNear then
				setNotSolid()
			end

			-- NPCs can still shoot a non-tracking NPC bullseye !

			if (
				!PlayerIsNear and
				BullseyeHater and
				BullseyeHater:IsValid() and
				!HasANPCPos
			) then
				-- print("Tracking a NPC")
				self:SetNWBool("has_bullseye_hater", true)

				self:SetPos(_Pos)

				setSolid()

				maybeResetPos(self, _selfParentPos, _NPCBullsEyePos, _Dist, _Pos)
			elseif (
				!PlayerIsNear and (
					!BullseyeHater or
					!BullseyeHater:IsValid()
				)
			) then
				-- print("Not Tracking a NPC")
				self:SetNWBool("has_bullseye_hater", false)

				self:SetPos(_Pos)

				setSolid()

				maybeResetPos(self, _selfParentPos, _NPCBullsEyePos, _Dist, _Pos)
			end
		end
	end)
	-- -- --
	local phys = self:GetPhysicsObject()
	if (IsValid(phys)) then phys:Sleep() end

	self:NextThink(CurTime() + 0.5)
	return true
end
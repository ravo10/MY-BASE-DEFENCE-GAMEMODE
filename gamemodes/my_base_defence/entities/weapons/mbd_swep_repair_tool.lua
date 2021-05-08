-- Know Which Animation Is Running (only one at a time)
-- For the Prop Repair Tool
MBD_AnOnAnimationIsRunning_swepPropRepair 	= false
MBD_AnOffAnimationIsRunning_swepPropRepair 	= false
-- For the Vehicle Repair Tool
MBD_AnOnAnimationIsRunning_swepVehicleRepair 	= false
MBD_AnOffAnimationIsRunning_swepVehicleRepair 	= false
--- - -- -
-- THA MOTHER >> >
function MBD_PlayAnimationViewModel(self, typeString, isForVehicleRepairSWEP, dataEndPoint)
	-- Get the current Position
	local PosX, PosY, PosZ = self.IronSightsPos.x, self.IronSightsPos.y, self.IronSightsPos.z
	local AngX, AngY, AngZ = self.IronSightsAng.x, self.IronSightsAng.y, self.IronSightsAng.z
	
	-- These Control The End Point From Current Pos...
	-- Figure out how much is needed to reach the end Position.. >> >
	local PosXExtra, PosYExtra, PosZExtra = (dataEndPoint.Pos.x - PosX), (dataEndPoint.Pos.y - PosY), (dataEndPoint.Pos.z - PosZ)
	local AngXExtra, AngYExtra, AngZExtra = (dataEndPoint.Ang.x - AngX), (dataEndPoint.Ang.y - AngY), (dataEndPoint.Ang.z - AngZ)
	-- -
	-- -- --
	-- ::: Settings
	local _Amount 			= 0.08 -- Amount to add/subtract from Pos/Ang (How Fast)
	local _NextFrameDelay 	= 0.01 -- Delay before the next frame is going to run (Seconds) (How Smooth)
	--- -- -
	-- -
	--
	-- Find about the time it takes...
	local AboutTimeDelay = nil
	if typeString == "off" then
		AboutTimeDelay = (((PosXExtra + PosYExtra + PosZExtra + AngXExtra + AngYExtra + AngZExtra) * -1) / 6)
	else
		AboutTimeDelay = ((PosXExtra + PosYExtra + PosZExtra + AngXExtra + AngYExtra + AngZExtra) / 6)
	end
	AboutTimeDelay = (AboutTimeDelay / _Amount) * _NextFrameDelay

	AboutTimeDelay = math.Round(AboutTimeDelay, 2)
	--
	local AnimationFinished = false

	timer.Remove("mbd:AnimationFinished001")
	timer.Create("mbd:AnimationFinished001", AboutTimeDelay + 0.3, 1, function()
		AnimationFinished = true
	end)

	-- Animate one round...
	-- --- -
	local function nextFrame()
		local AnOnAnimationIsRunning 	= nil
		local AnOffAnimationIsRunning 	= nil
		
		if isForVehicleRepairSWEP then
			AnOnAnimationIsRunning 	= MBD_AnOnAnimationIsRunning_swepVehicleRepair
			AnOffAnimationIsRunning = MBD_AnOffAnimationIsRunning_swepVehicleRepair
		else
			AnOnAnimationIsRunning 	= MBD_AnOnAnimationIsRunning_swepPropRepair
			AnOffAnimationIsRunning = MBD_AnOffAnimationIsRunning_swepPropRepair
		end

		if (
			!AnimationFinished and (
				(
					!AnOffAnimationIsRunning and
					typeString == "on"
				) or (
					!AnOnAnimationIsRunning and
					typeString == "off"
				)
			)
		) then
			if typeString == "off" then
				PosX, PosY, PosZ = (PosX - _Amount), (PosY - _Amount), (PosZ - _Amount)
				AngX, AngY, AngZ = (AngX - _Amount), (AngY - _Amount), (AngZ - _Amount)
			else
				PosX, PosY, PosZ = (PosX + _Amount), (PosY + _Amount), (PosZ + _Amount)
				AngX, AngY, AngZ = (AngX + _Amount), (AngY + _Amount), (AngZ + _Amount)
			end

			-- Go to next frame....
			-- Update
			self.IronSightsPos = Vector(PosX, PosY, PosZ)
			self.IronSightsAng = Vector(AngX, AngY, AngZ)

			timer.Simple(_NextFrameDelay, function()
				nextFrame()
			end)
		elseif AnimationFinished and typeString == "on" then
			-- Spawn some particless On HitPos
			local RoundCounter = 0 -- For giving an effect when the health is full

			local function EffectAnimation()
				RoundCounter = (RoundCounter + 1)

				if isForVehicleRepairSWEP then
					AnOnAnimationIsRunning 	= MBD_AnOnAnimationIsRunning_swepVehicleRepair
					AnOffAnimationIsRunning = MBD_AnOffAnimationIsRunning_swepVehicleRepair
				else
					AnOnAnimationIsRunning 	= MBD_AnOnAnimationIsRunning_swepPropRepair
					AnOffAnimationIsRunning = MBD_AnOffAnimationIsRunning_swepPropRepair
				end

				local _Owner = self:GetOwner()

				if !_Owner or !_Owner:IsValid() then return end
				-- Do what you want heree
				-- -
				local _HitPosEntity = _Owner:GetEyeTrace().Entity

				-- Only spawn Effect if not world/player and Distance is <= 60
				-- -- - >> >
				if (
					_HitPosEntity and
					_HitPosEntity:IsValid() and
					!_HitPosEntity:IsWorld() and
					!_HitPosEntity:IsPlayer() and
					(
                        (
                            (
								_HitPosEntity:IsVehicle() or
								_HitPosEntity:IsNPC()
							) and
                            isForVehicleRepairSWEP
                        ) or (
                            !_HitPosEntity:IsVehicle() and
                            !isForVehicleRepairSWEP
                        )
					) and
					_Owner and
					_Owner:IsValid() and
					checkIfWitinHealingArea(_HitPosEntity, _Owner)
				) then
					local tEffectTypes = {}
					local IsFullHealth 	= _HitPosEntity:GetNWInt("healthLeft", -1) == _HitPosEntity:GetNWInt("healthTotal", -2)

					-- --- -
					-- Mucchh Sparkss
					if !IsFullHealth then
						table.insert(tEffectTypes, "ManhackSparks")
						table.insert(tEffectTypes, "Sparks")
					else
						-- Health full
						if RoundCounter >= 20 then
							RoundCounter = 0 -- Reset

							-- Show some sparks (just a little)
							table.insert(tEffectTypes, "Sparks")
						end
					end

					-- Send To Server, so it can be produced serverside, and
					-- everybody will know about it/see it
					if !checkIfWitinHealingArea(_HitPosEntity, _Owner) then return end

					if CLIENT then
						net.Start("SpawnAnEffectServerside", true)
							net.WriteTable({
								ID 				= 2,
								EffectTypeTable = tEffectTypes,
								WorldPos 		= nil,
								TraceData 		= _Owner:GetEyeTrace()
							})
						net.SendToServer()
					end
				end

				timer.Simple(0.01, function()
					-- Next Frame >> >
					if AnimationFinished and !AnOffAnimationIsRunning then EffectAnimation() else
						if (
							_Owner and
							_Owner:IsValid() and
							_Owner:KeyDown(IN_SPEED)
						) then
							-- Show a Pointer kind of where the Player looks...
							local tEffectTypes = {
								"VortDispel"
							}

							if (
								_Owner and
								_Owner:IsValid() and
								_Owner:KeyDown(IN_USE)
							) then
								table.insert(tEffectTypes, "ToolTracer")
							else
								table.insert(tEffectTypes, "AR2Impact")
							end

							-- Send To Server, so it can be produced serverside, and
							-- everybody will know about it/see it
							if !checkIfWitinHealingArea(_HitPosEntity, _Owner) then return end

							if CLIENT then
								net.Start("SpawnAnEffectServerside", true)
									net.WriteTable({
										ID 				= 1,
										EffectTypeTable = tEffectTypes,
										WorldPos 		= nil,
										TraceData 		= _Owner:GetEyeTrace()
									})
								net.SendToServer()
							end
						end
					end
				end)
			end
			EffectAnimation()
		end
	end

	-- Start this shjieet
	nextFrame()
end
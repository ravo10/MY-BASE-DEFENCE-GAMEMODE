--
-- GLOVAL VARS.
PlayersConnected 		            = {}
PlayerClassesAvailable	            = nil
PlayersClassData 		            = nil

amoutOfPlayersBeforeIncreaseInClass = 4

function ResetClassesVaribles()
	PlayerClassesAvailable	= { -- 0=engineer 1=mechanic 2=medic 3=terminator
		engineer 	= {
			total = 2,
			taken = 0
		},
		mechanic 	= {
			total = 1,
			taken = 0
		},
		medic 		= {
			total = 1,
			taken = 0
		},
		terminator 	= {
			total = 1,
			taken = 0
		}
	}
	PlayersClassData = {}
end ResetClassesVaribles()

net.Receive("PlayerClass", playerClass)
--- PLAYER WANTS to buy something
net.Receive("PlayerWantsToBuySomething", function(len, pl)
	--
	local whatPlayerWantsToBuy = net.ReadTable()
	-- Check if item is whitelisted
	if not table.HasValue(MBDWhitelistAllCurrentAllowedClasses, whatPlayerWantsToBuy.entClass) then
		pl:Kick("The item you tried to purchase is not Whitelisted. The server assumes you are trying to cheat.") return end

	local IsAllowedWithoutClass = function(_className, trackID)
		-- print("'IsAllowedWithoutClass' trackID: ", trackID)
		-- When allowed
		if pl:MBDIsAnAdmin(false) then
			return true
		end

		if (
			_className ~= true and (
				not _className or
				_className == ""
			)
		) then
			-- Like so the BuyBox fills up *without* any needed Player Class as value; no access to this...
			ClientPrintAddTextMessage(pl, {Color(254, 81, 0), "No access... Choose a class first? Only Admin are allowed to buy weapons without a class."})
		end

		return false
	end
	--
	---
	--
	if (
		pl:GetNWInt("classInt", -1) ~= -1 or (
			IsAllowedWithoutClass(true, "1") and
			GetConVar("mbd_superAdminsDontHaveToPay"):GetInt() == 1
		)
	) then
		-- -- -
		--
		local _TClassData = PlayersClassData
		if IsAllowedWithoutClass(true, "2") then
			-- Just allow every Admin always
			_TClassData = { {UniqueID = pl:UniqueID()} }
		end
		
		for k,v in pairs(_TClassData) do
			-- Figure out if Player is allowed to buy this weapon with his class... security
			--
			if v.UniqueID == pl:UniqueID() then
				local __className = v.ClassName
				-- FOUND THE PLAYER...
				--
				local AllThingsPlayerCanBuy = nil
				local addToAllThingsPlayerCanBuy = function(_table, _className, _superAdmin)
					if !_table then print("M.B.D. Error (addToAllThingsPlayerCanBuy): Could access '_table'... It was nil.") return end

					AllThingsPlayerCanBuy = {}

					local loopTable = _table
					if !_superAdmin then loopTable = _table[_className] end
					if !loopTable then print("M.B.D. Error (addToAllThingsPlayerCanBuy): Could access '_table[__className]'... It was nil.") return end

					for _,d in pairs(loopTable) do
						if !_superAdmin then
							table.Add(AllThingsPlayerCanBuy, d)
						else
							-- Super admins will have every class weapons available
							for __,e in pairs(d) do
								table.Add(AllThingsPlayerCanBuy, e)
							end
						end
					end
				end

				-- Wait until "AvailableThingsToBuy" is loaded (set to 5 seconds (is needed))
				if !AvailableThingsToBuy then
					ClientPrintAddTextMessage(pl, {Color(0, 254, 208), "You will get your equipment once the data is loaded... Please wait."})
				end

				local timerID = "AvailableThingsToBuyLoader001"..pl:UniqueID()
				if timer.Exists(timerID) then return end
				timer.Create(timerID, 0.15, (10 / 0.15), function()
					if (
						AvailableThingsToBuy and (
							IsAllowedWithoutClass(true, "3.0") or (
								-- Players
								!IsAllowedWithoutClass(__className, "3.1") and (
									__className and
									__className != ""
								)
							)
						)
					) then
						-- OK
						timer.Remove(timerID)
						if !pl or !pl:IsValid() then return end

						--- - -
						-- Add Equipments data
						addToAllThingsPlayerCanBuy(AvailableThingsToBuy, __className, IsAllowedWithoutClass(true, "4"))
						if !AllThingsPlayerCanBuy then print("M.B.D. Error (PlayerWantsToBuySomething): Could not create 'AllThingsPlayerCanBuy'... It was nil.") return end

						for l,w in pairs(AllThingsPlayerCanBuy) do
						-- Figure out if Player is allowed to buy this weapon with his class... security
							--
							local __class = string.lower(w.entClass)

							if (__class == string.lower(whatPlayerWantsToBuy.entClass)) then
								-- FOUND THE CORRECT... CHECK IF PLAYER HAS enough money (again)
								--
								if (
									pl:GetNWInt("money", -1) >= w.price or (
										IsAllowedWithoutClass(true, "5") and
										GetConVar("mbd_superAdminsDontHaveToPay"):GetInt() == 1
									)
								) then
									local __buy = function()
										-- Take money from the Player
										if (
											pl:MBDIsNotAnAdmin(true) or (
												IsAllowedWithoutClass(true, "6") and
												GetConVar("mbd_superAdminsDontHaveToPay"):GetInt() == 0
											)
										) then
											pl:SetNWInt("money", (pl:GetNWInt("money", -1) - w.price))

											ClientPrintAddTextMessage(pl, {Color(254, 208, 0), "You bought: ", Color(208, 0, 254), w.name, Color(254, 208, 0), "; Thank you for your purchase."})
										else
											-- Admin
											ClientPrintAddTextMessage(pl, {Color(254, 208, 0), "You (Admin) was given: ", Color(208, 0, 254), w.name, Color(254, 208, 0), " for FREE! ", Color(254, 81, 0), "(ノಠ益ಠ)ノ"})
										end

										SendLocalSoundToAPlayer("game_buybox_buysound", pl)
									end

									if (
										string.match(__class, "_att_") or
										string.match(__class, "mbd_fas2_m67") or
										string.match(__class, "mbd_fas2_ammo") or
										string.match(__class, "item_") -- Like a healthcharger etc.
									) then -- If it is an entity/attachment/ammobox (not a weapon) =>> Spawn right above Players head
										--
										-- Spawn above Players head =>
										local __Ent	= ents.Create(__class)

										local __LocalPl_Pos		= pl:WorldToLocal(pl:GetPos())
										local __LocalPl_OBBMax	= pl:OBBMaxs()
										local __LocalPl_OBBMin	= pl:OBBMins()
										__LocalPl_OBBMax.z = (__LocalPl_OBBMax.z + 20)
										-- __LocalPl_OBBMin.z = (__LocalPl_OBBMin.z + 20) 

										__LocalPl_Pos.z = __LocalPl_OBBMax.z
										__LocalPl_Pos.y =  (__LocalPl_Pos.y - 5)

										if string.match(__class, "item_") then
											__LocalPl_Pos.z = __LocalPl_Pos.z + 10
											__LocalPl_Pos.y =  (__LocalPl_Pos.y - 10)
										end

										local __WorldPos = pl:LocalToWorld(__LocalPl_Pos)

										__Ent:SetPos(__WorldPos)
										--
										--- -
										__Ent:Spawn()
										__Ent:Activate()
										--
										__buy()
									else
										-- GIVE (more important) =>
										--
										if (
											__class == "rpg_round" or
											__class == "item_rpg_round"
										) then
											-- These needs to be given like this (the normal way)
											if __class == "rpg_round" or __class == "item_rpg_round" then
												pl:GiveAmmo(3, __class, true)
											end
										else
											pl:Give(__class)
											
											timer.Simple(0.3, function() pl:SelectWeapon(__class) end)
										end
										--
										__buy()
									end
								else
									ClientPrintAddTextMessage(pl, {Color(254, 81, 0), "You don't have enough money to buy: ", Color(0, 173, 254), w.name, Color(254, 81, 0), " !"})
								end

								break
							end
						end
					end
				end)

				break
			end
		end
	else ClientPrintAddTextMessage(pl, {Color(254, 208, 0), "No access... Choose a class first? Only Admin are allowed to buy weapons without a class.", Color(254, 81, 0), " Maybe Admins have to pay (", Color(81, 0, 254), "check settings", Color(254, 81, 0), ")"}) end
end)
--- GIVE PLAYER something the ADMIN wants
net.Receive("GiveAPlayerBuildpointsOrMoney", function(len, pl)
	--
	local what		= net.ReadTable()

	local Type 		= what.Type
	local Amount 	= what.Amount
	local Player 	= what.Player
	local Admin 	= what.Admin

	if Player == false then Player = pl end -- If Player was not defined... = self
	if !Player or !Player:IsValid() then return end

	local _Text 			= ""
	local _Text2 			= ""
	local SubTractPoints 	= 0
	if !Admin then SubTractPoints = Amount end

	local function CheckIfPlayerCanSendMoney(TypeText)
		if SubTractPoints != 0 then
			if pl:GetNWInt(Type, 0) < SubTractPoints then
				-- Not enough
				net.Start("NotificationReceivedFromServer")
					net.WriteTable({
						Text 	= "You don't have enough "..TypeText.." to give!",
						Type	= NOTIFY_ERROR,
						Time	= 5
					})
				net.Send(pl)

				return false -- Not OK
			else return true --[[ OK ]] end
		else return true --[[ OK; an Admin ]] end
	end

	-- OK >>>
	if (Type == "money") then
		if !CheckIfPlayerCanSendMoney("£B.D.") then return false end

		Player:SetNWInt("money", (Player:GetNWInt("money", 0) + Amount))

		---- -
		-- Subtract the amount >>
		if SubTractPoints != 0 then
			pl:SetNWInt("money", (pl:GetNWInt("money", 0) - Amount))
		end

		_Text = "You received "..Amount.." £B.D."
		_Text2 = "You gave "..Amount.." £B.D."
	elseif (Type == "buildPoints") then
		if !CheckIfPlayerCanSendMoney("B.P.") then return false end

		Player:SetNWInt("buildPoints", (Player:GetNWInt("buildPoints", 0) + Amount))

		---- -
		-- Subtract the amount >>
		if SubTractPoints != 0 then
			pl:SetNWInt("buildPoints", (pl:GetNWInt("buildPoints", 0) - Amount))
		end

		_Text = "You received "..Amount.." B.P."
		_Text2 = "You gave "..Amount.." B.P."
	end

	-- Notify the Player that received the money/build points
	net.Start("NotificationReceivedFromServer")
		net.WriteTable({
			Text 	= _Text.." from: "..pl:Nick().."!",
			Type	= NOTIFY_GENERIC,
			Time	= 4
		})
	net.Send(Player)
	-- -- -
	-- Notify the Giver
	net.Start("NotificationReceivedFromServer")
		net.WriteTable({
			Text 	= _Text2.." to: "..Player:Nick().."!",
			Type	= NOTIFY_GENERIC,
			Time	= 4
		})
	net.Send(pl)
end)
--- - - =>> IF PLAYER wants to change his class, then update this on the SERVERSIDE also
function amountOfPlayersChanged()
	-- Check if the PlayerClassesAvailable needs a change...
	local amountOfPlayersOnServer 		= #PlayersConnected
	local amountOfPlayersOnServerModulo = amountOfPlayersOnServer

	-- FIND THE HIGHEST NUMBER THAT HAVE : amountOfPlayersOnServerModulo % amoutOfPlayersBeforeIncreaseInClass == 0
	for i=1,amountOfPlayersOnServer do
		
		--
		if (
			amoutOfPlayersBeforeIncreaseInClass == 0 or
			(amountOfPlayersOnServerModulo % amoutOfPlayersBeforeIncreaseInClass) == 0
		) then
			-- ADJUST
			-- Engineer 	= 2 per. Four players
			-- mechanic 	= 1 per. Four players
			-- medic 		= 1 per. Four players
			-- terminator 	= 1 per. Four players
			--
			if (amoutOfPlayersBeforeIncreaseInClass == 0) then amoutOfPlayersBeforeIncreaseInClass = 1 end
			local _amount = ((amountOfPlayersOnServerModulo / amoutOfPlayersBeforeIncreaseInClass) + 1)
			
			--
			--
			PlayerClassesAvailable = {
				engineer 	= {
					total = (2 * _amount),
					taken = PlayerClassesAvailable['engineer'].taken
				},
				mechanic 	= {
					total = (1 * _amount),
					taken = PlayerClassesAvailable['mechanic'].taken
				},
				medic 		= {
					total = (1 * _amount),
					taken = PlayerClassesAvailable['medic'].taken
				},
				terminator 	= {
					total = (1 * _amount),
					taken = PlayerClassesAvailable['terminator'].taken
				}
			}
		else
			--
			amountOfPlayersOnServerModulo = (amountOfPlayersOnServerModulo - 1)
		end
	end
end

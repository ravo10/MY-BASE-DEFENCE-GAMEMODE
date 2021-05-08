--
--
-- DYNAMIC HEALTH LOGIC/ALGORITHM FOR PROPS !! =>>
function GetDynamicHealthForThisProp(ent, model) -- : Returns Health (number)
	if ent and model then return print("M.B.D. Error (GetDynamicHealthForThisProp): Select an Entity or a Model!") end
	
	if ent and ent:IsValid() then
		model = ent:GetModel()
	elseif !model then
		return print("M.B.D. Error (GetDynamicHealthForThisProp): Entity is not valid!")
	end

	-- - OK >>

	local calculatedHealth = nil

	local WeightFromModel 	= nil
	local MaterialFromModel = nil

	if model then
		local ModelInfo 		= util.GetModelInfo(model)["KeyValues"]

		-- Weight (find the first mass....)
		local ModelInfoNext001 	= string.Split(ModelInfo, [["mass"]])[2]
		local ModelInfoNext002 	= string.Split(ModelInfoNext001, [["]])[2]

		WeightFromModel		= tonumber(ModelInfoNext002)

		--- Material (find surfaceprop)
		local ModelInfoNext003 	= string.Split(ModelInfo, [["surfaceprop"]])[2]
		local ModelInfoNext004 	= string.Split(ModelInfoNext003, [["]])[2]

		MaterialFromModel	= ModelInfoNext004

		--- Shouldn't happend...
		if !WeightFromModel or !tonumber(WeightFromModel) then WeightFromModel = -1 end
		if !MaterialFromModel then MaterialFromModel = "" end
	end

	-- If PropHr is used on a prop for custom health + NPC-attack
	local mbd_PropMaterial = string.upper(MaterialFromModel)
	--
	--- -
	--
	---
	--
	--
	-- GET THE PROPS WEIGHT
	local ent_weight = WeightFromModel
	if ent_weight == -1 then print("M.B.D.: Could not get mass for a Prop.... ("..model..")") end

	--
	---- - ->==> THE MAGIC HAPPENS HEERE
	local function yeesFun(A, B) -- RETURNS A NUMBER
		if B > 3000 then B = 3000 end

		local health = (
			(B / (3 * 0.35)) * A * 2 / 8
		)
		if mbd_PropMaterial == "GLASS" then health = health / 5 end -- Glass is weird...
		--print("Health", health)

		if (health <= 0) then return 2 else return health end
	end
	--
	---- =>=> > Calculate THE PROPS HEALTH based on a simple algorithm
	if     (string.match(mbd_PropMaterial, "METAL")) 	then	calculatedHealth = yeesFun(10, ent_weight)
	elseif (string.match(mbd_PropMaterial, "CONCRETE")) then 	calculatedHealth = yeesFun(8, ent_weight)
	elseif (string.match(mbd_PropMaterial, "RUBBER")) 	then 	calculatedHealth = yeesFun(6.5, ent_weight)
	elseif (string.match(mbd_PropMaterial, "GLASS"))	then 	calculatedHealth = yeesFun(6, ent_weight)
	elseif (string.match(mbd_PropMaterial, "WOOD")) 	then 	calculatedHealth = yeesFun(5, ent_weight)
	elseif (string.match(mbd_PropMaterial, "PLASTIC")) 	then 	calculatedHealth = yeesFun(3, ent_weight)
	elseif (string.match(mbd_PropMaterial, "DIRT")) 	then 	calculatedHealth = yeesFun(3, ent_weight)
	elseif (string.match(mbd_PropMaterial, "FLESH")) 	then 	calculatedHealth = yeesFun(2, ent_weight)
	elseif (string.match(mbd_PropMaterial, "CARDBOARD"))then 	calculatedHealth = yeesFun(1.2, ent_weight)
	else calculatedHealth = yeesFun(5, ent_weight) end

	return {
		Health 		= calculatedHealth,
		Material 	= mbd_PropMaterial
	}
end
function GetDynamicPriceForThisProp(ent, model) -- : Returns Cost (number)
	local HealthData = GetDynamicHealthForThisProp(ent, model)

	local points = math.Round((
		HealthData.Health / 3.5
	), 0)
	if HealthData.Material == "GLASS" then
		points = points / 3
		
		if points < 1 then
			points = 0
		else points = math.Round(points, 0) end
	end -- Glass is weird...
	--print("Points", points)

	-- Exceptions...
	if (
		model == "models/props_c17/oildrum001_explosive.mdl"
	) then
		points = 1500
	end

	return points
end

-- Sounds
local fleshImp = CHAN_STATIC
local fleshVol = 1
local fleshLvl = 78
sound.Add({
	name = "flesh_bloody_break",
	channel = fleshImp,
	volume = fleshVol + 60,
	level = fleshLvl,
	pitch = { 95, 110 },
	sound = "fleshNew/flesh_bloody_break.wav"
})
sound.Add({
	name = "flesh_bloody_impact_hard1",
	channel = fleshImp,
	volume = fleshVol,
	level = fleshLvl,
	pitch = { 97, 103 },
	sound = "fleshNew/flesh_bloody_impact_hard1.wav"
})
sound.Add({
	name = "flesh_squishy_impact_hard1",
	channel = fleshImp,
	volume = fleshVol,
	level = fleshLvl,
	pitch = { 97, 103 },
	sound = "fleshNew/flesh_squishy_impact_hard1.wav"
})
sound.Add({
	name = "flesh_squishy_impact_hard2",
	channel = fleshImp,
	volume = fleshVol,
	level = fleshLvl,
	pitch = { 97, 103 },
	sound = "fleshNew/flesh_squishy_impact_hard2.wav"
})
sound.Add({
	name = "flesh_squishy_impact_hard3",
	channel = fleshImp,
	volume = fleshVol,
	level = fleshLvl,
	pitch = { 97, 103 },
	sound = "fleshNew/flesh_squishy_impact_hard3.wav"
})
sound.Add({
	name = "flesh_squishy_impact_hard4",
	channel = fleshImp,
	volume = fleshVol,
	level = fleshLvl,
	pitch = { 97, 103 },
	sound = "fleshNew/flesh_squishy_impact_hard4.wav"
})

-- Vehicle sound
sound.Add({
	name = "horn_jeep",
	channel = CHAN_WEAPON,
	volume = 1,
	level = 100,
	pitch = { 99.5, 100.5 },
	sound = "game/vehicle/horn_jeep.wav"
})
sound.Add({
	name = "horn_jalopy",
	channel = CHAN_WEAPON,
	volume = 1,
	level = 100,
	pitch = { 99.5, 100.5 },
	sound = "game/vehicle/horn_jalopy.wav"
})
sound.Add({
	name = "horn_jalopy2",
	channel = CHAN_WEAPON,
	volume = 1,
	level = 100,
	pitch = { 99.5, 100.5 },
	sound = "game/vehicle/horn_jalopy2.wav"
})
sound.Add({
	name = "horn_airboat",
	channel = CHAN_WEAPON,
	volume = 1,
	level = 100,
	pitch = { 99.5, 100.5 },
	sound = "game/vehicle/horn_airboat.wav"
})
sound.Add({
	name = "horn_clown",
	channel = CHAN_WEAPON,
	volume = 1,
	level = 100,
	pitch = { 99.5, 100.5 },
	sound = "game/vehicle/horn_clown.wav"
})

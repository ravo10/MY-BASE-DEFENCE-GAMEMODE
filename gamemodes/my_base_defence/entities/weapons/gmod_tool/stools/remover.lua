
TOOL.Category = "Construction"
TOOL.Name = "#tool.remover.name"

TOOL.Information = {
	{ name = "left" },
	{ name = "right" },
	{ name = "reload" }
}

local function DoRemoveEntity( ent, owner )

	if ( !IsValid( ent ) || ent:IsPlayer() ) then return false end

	-- Nothing for the client to do here
	if ( CLIENT ) then return true end

	-- Remove all constraints (this stops ropes from hanging around)
	constraint.RemoveAll( ent )

	-- Remove it properly in 0.9 second
	-- MBD:: Modded
	timer.Simple( 0.9, function() if ( IsValid( ent ) ) then undoEntityWithOwner(owner, ent, "M.B.D. Removed Entity!") end end )

	-- Make it non solid
	ent:SetNotSolid( true )
	ent:SetMoveType( MOVETYPE_NONE )
	ent:SetNoDraw( true )

	-- Send Effect
	local ed = EffectData()
		ed:SetOrigin( ent:GetPos() )
		ed:SetEntity( ent )
	util.Effect( "entity_remove", ed, true, true )

	return true

end

--
-- Remove a single entity
--
function TOOL:LeftClick( trace )

	if SERVER then trace.Entity = GetCorrectEntForProps(trace.Entity) end

	if SERVER then
		-- Hinder Removal of unwanted entites
		if HinderDuplicationOrRemovalOfEntities(self, trace.Entity, "remove") then return false end
	end

	if ( DoRemoveEntity( trace.Entity, self:GetOwner() ) ) then

		if ( !CLIENT ) then
			self:GetOwner():SendLua( "achievements.Remover()" )
		end

		return true

	end

	return false

end

--
-- Remove this entity and everything constrained
--
function TOOL:RightClick( trace )

	if SERVER then trace.Entity = GetCorrectEntForProps(trace.Entity) end

	local Entity = trace.Entity

	if ( !IsValid( Entity ) || Entity:IsPlayer() ) then return false end

	-- Client can bail out now.
	if ( CLIENT ) then return true end

	local ConstrainedEntities = constraint.GetAllConstrainedEntities( trace.Entity )
	local Count = 0

	-- Loop through all the entities in the system
	for _, Entity in pairs( ConstrainedEntities ) do

		if ( DoRemoveEntity( Entity, self:GetOwner() ) ) then
			Count = Count + 1
		end

	end

	return true

end

--
-- Reload removes all constraints on the targetted entity
--
function TOOL:Reload( trace )

	if ( !IsValid( trace.Entity ) || trace.Entity:IsPlayer() ) then return false end
	if ( CLIENT ) then return true end

	return constraint.RemoveAll( trace.Entity )

end

function TOOL.BuildCPanel( CPanel )

	CPanel:AddControl( "Header", { Description = "#tool.remover.desc" } )

end

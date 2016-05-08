hook.Add("OnPhysgunFreeze", "car_freeze_freeze", function( weapon, physobj, ent, ply )
	if(!ent:IsPlayer()) then
		if(ent:GetClass() == 'prop_vehicle_jeep') then
			timer.Simple(0.01, function()
				constraint.Weld(ent, game.GetWorld(), 0, 0, 0, false)
			end);
			-- timer.Simple(0.1, function()
				-- ent:SetMoveType(MOVETYPE_NONE);
				-- local phys = ent:GetPhysicsObject()
				-- if phys:IsValid() then phys:SetDamping(1000000, 1000000) end
				-- local ConstrainedEnts = constraint.GetAllConstrainedEntities( ent );
				-- for _, ent in pairs( ConstrainedEnts ) do
					-- if(ent.Entity:IsValid()) then
						-- ent.Entity:SetMoveType(MOVETYPE_NONE);
					-- end;
				-- end;
			-- end);
		end;
	end;
end);

hook.Add("PhysgunPickup", "car_freeze_pickup", function( ply, ent )
	if(!ent:IsPlayer()) then
		if(ent:GetClass() == 'prop_vehicle_jeep') then
			for k, v in pairs (constraint.GetTable(ent)) do
				if(v.Ent2 == game.GetWorld()) then
					v.Constraint:Remove();
				end;
			end;
			-- ent:SetMoveType(6)
			-- local phys = ent:GetPhysicsObject()
			-- if phys:IsValid() then phys:SetDamping(0, 0) end
			-- local ConstrainedEnts = constraint.GetAllConstrainedEntities( ent )
			-- for _, ent in pairs( ConstrainedEnts ) do
				-- if(ent.Entity:IsValid()) then
					-- ent.Entity:SetMoveType(6);
				-- end;
			-- end;
		end;
	end;
end);

hook.Add("PhysgunDrop", "car_freeze_drop", function( ply, ent )
	if(!ent:IsPlayer()) then
		if(ent:GetClass() == 'prop_vehicle_jeep') then
			for k, v in pairs (constraint.GetTable(ent)) do
				if(v.Ent2 == game.GetWorld()) then
					v.Constraint:Remove();
				end;
			end;
			-- ent:SetMoveType(6)
			-- local phys = ent:GetPhysicsObject()
			-- if phys:IsValid() then phys:SetDamping(0, 0) end
			-- local ConstrainedEnts = constraint.GetAllConstrainedEntities( ent )
			-- for _, ent in pairs( ConstrainedEnts ) do
				-- if(ent.Entity:IsValid()) then
					-- ent.Entity:SetMoveType(6);
				-- end;
			-- end;
		end;
	end;
end);

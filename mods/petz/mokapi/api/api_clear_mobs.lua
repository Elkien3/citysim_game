function mokapi.clear_mobs(pos, modname)
	for _, obj in ipairs(minetest.get_objects_inside_radius(pos, 100)) do
		local ent_name = obj:get_entity_name()
		if not(obj:is_player()) and minetest.registered_entities[ent_name] then
			local colon_pos = string.find(ent_name, ':')
			local ent_modname = string.sub(ent_name, 1, colon_pos-1)
			local ent = obj:get_luaentity()
			if ent_modname == modname and ent.type and not(ent.tamed) then
				mokapi.remove_mob(ent)
			end
		end
	end
end

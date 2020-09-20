local fire_enabled = minetest.settings:get_bool("enable_fire")
if fire_enabled == nil then
	-- enable_fire setting not specified, check for disable_fire
	local fire_disabled = minetest.settings:get_bool("disable_fire")
	if fire_disabled == nil then
		-- Neither setting specified, check whether singleplayer
		fire_enabled = minetest.is_singleplayer()
	else
		fire_enabled = not fire_disabled
	end
end

if fire_enabled then

	-- Ignite neighboring nodes, add basic flames

	minetest.register_abm({
		label = "Ignite flame",
		nodenames = {"group:flammable"},
		neighbors = {"group:igniter"},
		interval = 18,
		chance = 24,
		catch_up = false,
		action = function(pos, node, active_object_count, active_object_count_wider)
			local p = minetest.find_node_near(pos, 1, {"air"})
			if p and not minetest.find_node_near(p, 1, {"group:water"}) then
				minetest.set_node(p, {name = "fire:basic_flame"})
			end
		end,
	})
	
	minetest.register_abm({
		label = "Remove random flames",
		nodenames = {"fire:basic_flame"},
		interval = 12,
		chance = 4,
		catch_up = false,
		action = function(p0, node, _, _)
			minetest.remove_node(p0)
			--minetest.sound_play("fire_extinguish_flame",
				--{pos = p0, max_hear_distance = 16, gain = 0.25})
		end,
	})

	-- Remove flammable nodes around basic flame

	minetest.register_abm({
		label = "Remove flammable nodes",
		nodenames = {"fire:basic_flame"},
		neighbors = "group:flammable",
		interval = 12,
		chance = 12,
		catch_up = false,
		action = function(pos, node, active_object_count, active_object_count_wider)
			local p = minetest.find_node_near(pos, 1, {"group:flammable"})
			if p and not minetest.find_node_near(p, 1, {"group:water"}) then
				local flammable_node = minetest.get_node(p)
				local def = minetest.registered_nodes[flammable_node.name]
				if def.on_burn then
					def.on_burn(p)
				else
					minetest.remove_node(p)
					minetest.check_for_falling(p)
				end
			end
		end,
	})

end
--LAVA COOLING

if minetest.settings:get_bool("enable_lavacooling") ~= false then
	for index, abm in pairs (minetest.registered_abms) do
		if abm.label == "Lava cooling" then
			abm.neighbors = {"group:cools_lava"}
			break
		end
	end
	minetest.override_item("default:water_flowing", {groups = {water = 3, liquid = 3, not_in_creative_inventory = 1}}) --don't allow people to make a mess with water and lava as easily
	minetest.override_item("default:river_water_flowing", {groups = {water = 3, liquid = 3, not_in_creative_inventory = 1}})
	minetest.override_item("default:lava_flowing", {groups = {lava = 3, liquid = 2,not_in_creative_inventory = 1}}) --disable lava flowing from burning things
end

--FIRE

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
	
	--disable default fire ABMs
	for index, abm in pairs (minetest.registered_abms) do
		if abm.mod_origin == "fire" then
			if abm.label == "Ignite flame" then
				abm = {
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
				}
			elseif abm.label == "Remove flammable nodes" then
				abm = {
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
				}
			end
		end
	end
	
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
end

--BINOCULARS

binoculars.items = {}
binoculars.items["binoculars:binoculars"] = 10

binoculars.update_player_property = function(player)
	local creative_enabled =
		(creative_mod and creative.is_enabled_for(player:get_player_name())) or
		creative_mode_cache
	local new_zoom_fov = 0
	for name, value in pairs(binoculars.items) do
		if player:get_wielded_item():get_name() == name then
			new_zoom_fov = value
		end
	end
	
	if creative_enabled then
		new_zoom_fov = 15
	end

	-- Only set property if necessary to avoid player mesh reload
	if player:get_properties().zoom_fov ~= new_zoom_fov then
		player:set_properties({zoom_fov = new_zoom_fov})
	end
end


-- Set player property 'on joinplayer'

minetest.register_on_joinplayer(function(player)
	binoculars.update_player_property(player)
end)


-- Cyclic update of player property

local function cyclic_update()
	for _, player in ipairs(minetest.get_connected_players()) do
		binoculars.update_player_property(player)
	end
	minetest.after(.5, cyclic_update)
end

minetest.after(.5, cyclic_update)

--MUSHROOMS
for index, abm in pairs (minetest.registered_abms) do
	if abm.label == "Mushroom spread" then
		abm.interval = 60
		abm.chance = 150
		break
	end
end
local modpath = minetest.get_modpath("default_tweaks")
default_tweaks = {}
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

local function warnfarplayers()
	for i, player in pairs(minetest.get_connected_players()) do
		local p = player:get_pos()
		local a = math.abs
		local d = 2000
		if a(p.x) > d or a(p.y) > d or a(p.z) > d then
			minetest.chat_send_player(player:get_player_name(), "WARNING: the world past "..tostring(d).." may be deleted in the future.")
		end
	end
	minetest.after(30, warnfarplayers)
end
minetest.after(30, warnfarplayers)

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
				minetest.registered_abms[index] = {
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
				minetest.registered_abms[index] = {
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
	minetest.register_abm({
		label = "Remove flames near water",
		nodenames = {"fire:basic_flame"},
		neighbors = "group:water",
		interval = 4,
		chance = 3,
		catch_up = false,
		action = function(p0, node, _, _)
			minetest.remove_node(p0)
			minetest.sound_play("fire_extinguish_flame",
				{pos = p0, max_hear_distance = 16, gain = 0.25})
		end,
	})

end

--BINOCULARS
if binoculars then
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
end

minetest.register_on_mods_loaded(function()
	for nodename, def in pairs(minetest.registered_nodes) do
		if def.liquidtype and (def.liquidtype == "source" or def.liquidtype == "flowing") then
			minetest.override_item(nodename, {liquid_range = 1})
		end
	end
end)

if minetest.registered_items["xpanes:door_steel_bar"] and minetest.registered_items["doors:prison_door"] then
	minetest.clear_craft({output = "xpanes:door_steel_bar"})
	minetest.register_craft({
		type = "shapeless",
		output = "xpanes:door_steel_bar",
		recipe = {"doors:prison_door"}
	})
end

minetest.clear_craft({output = "default:bookshelf"})
minetest.register_craft({
	output = "default:bookshelf 6",
	recipe = {
		{"group:wood", "group:wood", "group:wood"},
		{"default:book", "default:book", "default:book"},
		{"group:wood", "group:wood", "group:wood"},
	}
})

dofile(modpath.."/plantrot.lua")
dofile(modpath.."/protection.lua")
dofile(modpath.."/plantgrowspeeds.lua")
dofile(modpath.."/biomeores.lua")
dofile(modpath.."/minefilling.lua")
dofile(modpath.."/morebedrock.lua")
dofile(modpath.."/stonestagedig.lua")
dofile(modpath.."/stacksize.lua")

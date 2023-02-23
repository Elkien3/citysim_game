local S = default.get_translator

local function furnace_active(fuel_percent)
	return "size[8,8.5]"..
		"list[context;fuel;2.75,2.5;1,1;]"..
		"image[2.75,1.5;1,1;default_furnace_fire_bg.png^[lowpart:"..
		(fuel_percent)..":default_furnace_fire_fg.png]"..
		"list[current_player;main;0,4.25;8,1;]"..
		"list[current_player;main;0,5.5;8,3;8]"..
		"listring[context;fuel]"..
		"listring[current_player;main]"..
		default.get_hotbar_bg(0, 4.25)
end

local function furnace_inactive()
	return "size[8,8.5]"..
		"list[context;fuel;2.75,2.5;1,1;]"..
		"image[2.75,1.5;1,1;default_furnace_fire_bg.png]"..
		"list[current_player;main;0,4.25;8,1;]"..
		"list[current_player;main;0,5.5;8,3;8]"..
		"listring[context;fuel]"..
		"listring[current_player;main]"..
		default.get_hotbar_bg(0, 4.25)
end

--
-- Node callback functions that are the same for active and inactive furnace
--

local function can_dig(pos, player)
	local meta = minetest.get_meta(pos);
	local inv = meta:get_inventory()
	return inv:is_empty("fuel")
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	if listname == "fuel" then
		if minetest.get_craft_result({method="fuel", width=1, items={stack}}).time ~= 0 then
			if inv:is_empty("src") then
				meta:set_string("infotext", S("Furnace is empty"))
			end
			return stack:get_count()
		else
			return 0
		end
	end
end

local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local stack = inv:get_stack(from_list, from_index)
	return allow_metadata_inventory_put(pos, to_list, to_index, stack, player)
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	return stack:get_count()
end

local function swap_node(pos, name)
	local node = minetest.get_node(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos, node)
end

local function vaporize(p, airabove)
	if not p then return end
	local def = minetest.registered_nodes[minetest.get_node(p).name]
	if def.gas then
		if airabove then
			minetest.add_node({x=p.x,y=p.y+1,z=p.z}, {name = def.gas})
		else
			minetest.add_node(p, {name = def.gas})
		end
	end
	if def.gas_byproduct and math.random(def.gas_byproduct_chance or 4) == 1 then
		minetest.swap_node(p, {name=def.gas_byproduct})
	elseif airabove then
		minetest.remove_node(p)
	end
end

local function furnace_node_timer(pos, elapsed)
	--
	-- Initialize metadata
	--
	local meta = minetest.get_meta(pos)
	local fuel_time = meta:get_float("fuel_time") or 0
	local fuel_totaltime = meta:get_float("fuel_totaltime") or 0

	local inv = meta:get_inventory()
	local fuellist

	local fuel

	local update = true
	while elapsed > 0 and update do
		update = false
		fuellist = inv:get_list("fuel")
		local el = math.min(elapsed, fuel_totaltime - fuel_time)
		if fuel_time < fuel_totaltime then
			-- The furnace is currently active and has enough fuel
			fuel_time = fuel_time + el
			if elapsed >= 1 and math.random(10) == 1 then
				local airabove = true
				local p = minetest.find_nodes_in_area_under_air({x=pos.x+1,y=pos.y+1,z=pos.z+1}, {x=pos.x-1,y=pos.y-1,z=pos.z-1}, "group:vaporizable")
				p = p[math.random(#p)]
				if not p then
					airabove = false
					p = minetest.find_nodes_in_area({x=pos.x+1,y=pos.y+1,z=pos.z+1}, {x=pos.x-1,y=pos.y-1,z=pos.z-1}, "group:vaporizable")
					p = p[math.random(#p)]
				end
				vaporize(p,airabove)
			end
		else
			local afterfuel
			fuel, afterfuel = minetest.get_craft_result({method = "fuel", width = 1, items = fuellist})
			fuel.time = fuel.time*2
			if fuel.time == 0 then
				-- No valid fuel in fuel list
				fuel_totaltime = 0
				fuel_time = 0
			else
				-- Take fuel from fuel list
				inv:set_stack("fuel", 1, afterfuel.items[1])
				-- Put replacements in dst list or drop them on the furnace.
				local replacements = fuel.replacements
				if replacements[1] then
					local above = vector.new(pos.x, pos.y + 1, pos.z)
					local drop_pos = minetest.find_node_near(above, 1, {"air"}) or above
					minetest.item_drop(replacements[1], nil, drop_pos)
				end
				update = true
				fuel_totaltime = fuel.time + (fuel_totaltime - fuel_time)
				fuel_time = 0
			end
		end
		elapsed = elapsed - el
	end

	if fuel and fuel_totaltime > fuel.time then
		fuel_totaltime = fuel.time
	end

	--
	-- Update formspec, infotext and node
	--
	local formspec
	local item_state

	local fuel_state = S("Empty")
	local active = false
	local result = false

	if fuel_totaltime ~= 0 then
		active = true
		local fuel_percent = 100 - math.floor(fuel_time / fuel_totaltime * 100)
		fuel_state = S("@1%", fuel_percent)
		formspec = furnace_active(fuel_percent, 0)
		swap_node(pos, "gas_lib:furnace_active")
		-- make sure timer restarts automatically
		result = true
	else
		if fuellist and not fuellist[1]:is_empty() then
			fuel_state = S("@1%", 0)
		end
		formspec = furnace_inactive()
		swap_node(pos, "gas_lib:furnace")
		-- stop timer on the inactive furnace
		minetest.get_node_timer(pos):stop()
	end


	local infotext
	if active then
		infotext = S("Furnace active")
	else
		infotext = S("Furnace inactive")
	end
	infotext = infotext .. "\n" .. S("(Fuel: @1)", fuel_state)

	--
	-- Set meta values
	--
	meta:set_float("fuel_totaltime", fuel_totaltime)
	meta:set_float("fuel_time", fuel_time)
	meta:set_string("formspec", formspec)
	meta:set_string("infotext", infotext)

	return result
end

--
-- Node definitions
--

minetest.register_node("gas_lib:furnace", {
	description = S("Vaporizer Furnace (put liquid next to it to vaporize it)"),
	tiles = {
		"gas_lib_vaporizer_top.png", "gas_lib_vaporizer_bottom.png",
		"gas_lib_vaporizer_side.png", "gas_lib_vaporizer_side.png",
		"gas_lib_vaporizer_side.png", "gas_lib_vaporizer_front.png"
	},
	paramtype2 = "facedir",
	groups = {cracky=2},
	legacy_facedir_simple = true,
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),

	can_dig = can_dig,

	on_timer = furnace_node_timer,

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size('fuel', 1)
		furnace_node_timer(pos, 0)
	end,

	on_metadata_inventory_move = function(pos)
		minetest.get_node_timer(pos):start(1.0)
	end,
	on_metadata_inventory_put = function(pos)
		-- start timer function, it will sort out whether furnace can burn or not.
		minetest.get_node_timer(pos):start(1.0)
	end,
	on_blast = function(pos)
		local drops = {}
		default.get_inventory_drops(pos, "src", drops)
		default.get_inventory_drops(pos, "fuel", drops)
		default.get_inventory_drops(pos, "dst", drops)
		drops[#drops+1] = "gas_lib:furnace"
		minetest.remove_node(pos)
		return drops
	end,

	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_move = allow_metadata_inventory_move,
	allow_metadata_inventory_take = allow_metadata_inventory_take,
})

minetest.register_node("gas_lib:furnace_active", {
	description = S("Furnace"),
	tiles = {
		"gas_lib_vaporizer_top.png", "gas_lib_vaporizer_bottom.png",
		"gas_lib_vaporizer_side.png", "gas_lib_vaporizer_side.png",
		"gas_lib_vaporizer_side.png", "gas_lib_vaporizer_front_active.png"
	},
	paramtype2 = "facedir",
	light_source = 8,
	drop = "gas_lib:furnace",
	groups = {cracky=2, not_in_creative_inventory=1, smokey = 3},
	legacy_facedir_simple = true,
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
	on_timer = furnace_node_timer,

	can_dig = can_dig,

	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_move = allow_metadata_inventory_move,
	allow_metadata_inventory_take = allow_metadata_inventory_take,
})
if minetest.get_modpath("basic_materials") then
	minetest.register_craft({
		output = "gas_lib:furnace",
		recipe = {
			{"basic_materials:copper_strip", "basic_materials:copper_strip", "basic_materials:copper_strip"},
			{"group:stone", "", "group:stone"},
			{"group:stone", "group:stone", "group:stone"},
		}
	})
else
	minetest.register_craft({
		output = "gas_lib:furnace",
		recipe = {
			{"group:stone", "default:copper_ingot", "group:stone"},
			{"group:stone", "", "group:stone"},
			{"group:stone", "group:stone", "group:stone"},
		}
	})
end

local exchangertick = 10

minetest.register_node("gas_lib:heat_exchanger", {
	description = "Heat Exchanger (Put cool liquid on top to cool a hot gas below)",
	tiles = {
		"gas_lib_exchanger_top.png", "gas_lib_exchanger_bottom.png",
		"gas_lib_exchanger_side.png", "gas_lib_exchanger_side.png",
		"gas_lib_exchanger_side.png", "gas_lib_exchanger_front.png"
	},
	groups = {cracky = 1},
	on_construct = function(pos)
		minetest.get_node_timer(pos):start(exchangertick)
	end,
	on_timer = function(pos, elapsed)
		local rn = minetest.registered_nodes
		local above = rn[minetest.get_node({x=pos.x,y=pos.y+1,z=pos.z}).name]
		local below = rn[minetest.get_node({x=pos.x,y=pos.y-1,z=pos.z}).name]
		if not above or not below then return true end
		if not above.gas then return true end
		if not below.liquid then return true end
		if math.random(3) == 3 then--heat liquid
			vaporize({x=pos.x,y=pos.y+1,z=pos.z}, minetest.get_node({x=pos.x,y=pos.y+2,z=pos.z}).name == "air")
		else --cool gas
			minetest.swap_node({x=pos.x,y=pos.y-1,z=pos.z}, {name=below.liquid})
		end
		return true
	end
})

if minetest.get_modpath("basic_materials") then
	minetest.register_craft({
		output = "gas_lib:heat_exchanger",
		recipe = {
			{"basic_materials:copper_strip", "basic_materials:copper_strip", "basic_materials:copper_strip"},
			{"group:stone", "default:copper_ingot", "group:stone"},
			{"basic_materials:copper_strip", "basic_materials:copper_strip", "basic_materials:copper_strip"},
		}
	})
else
	minetest.register_craft({
		output = "gas_lib:heat_exchanger",
		recipe = {
			{"group:stone", "default:copper_ingot", "group:stone"},
			{"group:stone", "default:copper_ingot", "group:stone"},
			{"group:stone", "default:copper_ingot", "group:stone"},
		}
	})
end

minetest.register_lbm{
	name="gas_lib:heattimer",
	nodenames= {"gas_lib:heat_exchanger", "gas_lib:furnace_active"},
	run_at_every_load = true,
	action=function(pos)
		local timer = minetest.get_node_timer(pos)
		if not timer:is_started() then
			local node = minetest.get_node(pos)
			local def = minetest.registered_nodes[node.name]
			minetest.get_node_timer(pos):start(exchangertick)
		end
	end
}

--craft guides

if craftguide then
	craftguide.register_craft_type("vaporize", {
		description = "Vaporize",
		icon = "gas_lib_vaporizer_front.png",
	})
	craftguide.register_craft_type("vaporizebyproduct", {
		description = "Vaporize Byproduct",
		icon = "gas_lib_vaporizer_front.png",
	})
	craftguide.register_craft_type("condense", {
		description = "Condense",
		icon = "gas_lib_exchanger_front.png",
	})
end
if unified_inventory then
	unified_inventory.register_craft_type("vaporize", {
		description = "Vaporize",
		width = 1,
		height = 0,
	})
	unified_inventory.register_craft_type("vaporizebyproduct", {
		description = "Vaporize Byproduct",
		width = 1,
		height = 0,
	})
	unified_inventory.register_craft_type("condense", {
		description = "Condense",
		width = 1,
		height = 0,
	})
end
local function register_craft_guides(crafttype, result, item)
	if craftguide then
		craftguide.register_craft({
			type   = crafttype,
			result = result,
			items  = {{item}},
		})
	end
	if unified_inventory then
		unified_inventory.register_craft({
			type = crafttype,
			output = result,
			items = {{item}},
		})
	end
end
minetest.register_on_mods_loaded(function()
	for name, def in pairs(minetest.registered_nodes) do
		if def.gas_byproduct then
			register_craft_guides("vaporizebyproduct", def.gas_byproduct, name)
		elseif def.gas then
			register_craft_guides("vaporize", def.gas, name)
		elseif def.liquid then
			register_craft_guides("condense", def.liquid, name)
		end
	end
end)

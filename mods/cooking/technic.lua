local S = technic.getter

local fs_helpers = pipeworks.fs_helpers
local tube_entry = "^pipeworks_tube_connection_metallic.png"

local connect_default = {"bottom", "back", "left", "right"}

local function round(v)
	return math.floor(v + 0.5)
end

local furnace_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
	local meta = minetest.get_meta(pos)
	minetest.get_node_timer(pos):start(1.0)
	local inv = meta:get_inventory()
	if not inv:is_empty("src") then return itemstack end
	local tempstack = ItemStack(itemstack)
	tempstack:set_count(1)
	inv:add_item("src", tempstack)
	itemstack:take_item(1)
	cooking.update_furnace_objects(pos)
	return itemstack
end

function register_base_machine(data)
	local typename = data.typename
	local machine_name = data.machine_name
	local machine_desc = data.machine_desc
	local tier = data.tier
	local ltier = string.lower(tier)

	data.modname = data.modname or minetest.get_current_modname()

	local groups = {cracky = 2, technic_machine = 1, ["technic_"..ltier] = 1, cookingholder = 1, furnace = 1}

	local active_groups = {not_in_creative_inventory = 1}
	for k, v in pairs(groups) do active_groups[k] = v end
	
	local on_destruct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local tbl = {}
		tbl["fuel"] = inv:get_stack("fuel", 1):to_string()
		tbl["src"] = inv:get_stack("src", 1):to_string()
		cooking.remove_items(pos, false, tbl)
	end

	local run = function(pos, node)
		local meta     = minetest.get_meta(pos)
		local inv      = meta:get_inventory()
		local eu_input = meta:get_int(tier.."_EU_input")

		local machine_desc_tier = machine_desc:format(tier)
		local machine_node      = data.modname..":"..machine_name
		local machine_demand    = data.demand

		-- Setup meta data if it does not exist.
		if not eu_input then
			meta:set_int(tier.."_EU_demand", machine_demand[1])
			meta:set_int(tier.."_EU_input", 0)
			return
		end

		local EU_upgrade, tube_upgrade = 0, 0

		local powered = eu_input >= machine_demand[EU_upgrade+1]
		if powered then
			meta:set_int("src_time", meta:get_int("src_time") + round(data.speed*10))
		end
		--while true do
			local result = cooking.get_craft_result({method = typename, width = 1, items = inv:get_list("src")})
			if not result or result.time == 0 then
				technic.swap_node(pos, machine_node)
				meta:set_string("infotext", S("%s Idle"):format(machine_desc_tier))
				meta:set_int(tier.."_EU_demand", 0)
				meta:set_int("src_time", 0)
				return
			end
			meta:set_int(tier.."_EU_demand", machine_demand[EU_upgrade+1])
			technic.swap_node(pos, machine_node.."_active")
			meta:set_string("infotext", S("%s Active"):format(machine_desc_tier))
			if meta:get_int("src_time") < round(result.time*10) then
				if not powered then
					technic.swap_node(pos, machine_node)
					meta:set_string("infotext", S("%s Unpowered"):format(machine_desc_tier))
				end
				return
			end
			--[[local output = result.output
			if type(output) ~= "table" then output = { output } end
			local output_stacks = {}
			for _, o in ipairs(output) do
				table.insert(output_stacks, ItemStack(o))
			end
			local room_for_output = true
			inv:set_size("dst_tmp", inv:get_size("dst"))
			for _, o in ipairs(output_stacks) do
				if not inv:room_for_item("dst_tmp", o) then
					room_for_output = false
					break
				end
				inv:add_item("dst_tmp", o)
			end--]]
			--[[if not room_for_output then
				technic.swap_node(pos, machine_node)
				meta:set_string("infotext", S("%s Idle"):format(machine_desc_tier))
				meta:set_int(tier.."_EU_demand", 0)
				meta:set_int("src_time", round(result.time*10))
				return
			end--]]
			meta:set_int("src_time", meta:get_int("src_time") - round(result.time*10))
			inv:set_stack("src", 1, result.item)
			cooking.update_furnace_objects(pos)
			--inv:set_list("src", result.new_input)
			--inv:set_list("dst", inv:get_list("dst_tmp"))
		--end
	end

	local tentry = tube_entry
	if ltier == "lv" then
		tentry = ""
	end

	minetest.register_node(data.modname..":"..machine_name, {
		description = machine_desc:format(tier),
		tiles = {"electric_"..typename.."_uv.png"},
		drawtype = "mesh",
		mesh = "electric_"..typename..".b3d",
		paramtype = "light",
		paramtype2 = "facedir",
		groups = groups,
		tube = data.tube and tube or nil,
		selection_box = data.selection_box,
		connect_sides = data.connect_sides or connect_default,
		legacy_facedir_simple = true,
		sounds = default.node_sound_wood_defaults(),
		on_construct = function(pos)
			local node = minetest.get_node(pos)
			local meta = minetest.get_meta(pos)

			local form_buttons = ""

			meta:set_string("infotext", machine_desc:format(tier))
			meta:set_int("tube_time",  0)
			--meta:set_string("formspec", formspec..form_buttons)
			local inv = meta:get_inventory()
			inv:set_size("src", 1)
			inv:set_size("dst", 1)
		end,
		on_destruct = on_destruct,
		on_rightclick = furnace_rightclick,
		--can_dig = technic.machine_can_dig,
		allow_metadata_inventory_put = technic.machine_inventory_put,
		allow_metadata_inventory_take = technic.machine_inventory_take,
		allow_metadata_inventory_move = technic.machine_inventory_move,
		technic_run = run,
		after_place_node = data.tube and pipeworks.after_place,
		after_dig_node = technic.machine_after_dig_node,
	})

	minetest.register_node(data.modname..":"..machine_name.."_active",{
		description = machine_desc:format(tier),
		tiles = {"electric_"..typename.."_uv.png"},
		drawtype = "mesh",
		mesh = "electric_"..typename..".b3d",
		paramtype = "light",
		paramtype2 = "facedir",
		drop = data.modname..":"..machine_name,
		groups = active_groups,
		selection_box = data.selection_box,
		connect_sides = data.connect_sides or connect_default,
		legacy_facedir_simple = true,
		sounds = default.node_sound_wood_defaults(),
		allow_metadata_inventory_put = technic.machine_inventory_put,
		allow_metadata_inventory_take = technic.machine_inventory_take,
		allow_metadata_inventory_move = technic.machine_inventory_move,
		technic_run = run,
		technic_disabled_machine_name = data.modname..":"..machine_name,
		on_rightclick = furnace_rightclick,
		on_destruct = on_destruct
	})

	technic.register_machine(tier, data.modname..":"..machine_name,            technic.receiver)
	technic.register_machine(tier, data.modname..":"..machine_name.."_active", technic.receiver)

end -- End registration

register_base_machine({
	typename = "oven",
	machine_name = "electric_oven",
	machine_desc = "Electric Oven",
	tier="LV",
	demand={50},
	speed = 1,
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.375, -0.3125, 0.5, 0.5}, -- NodeBox3
			{-0.5, -0.5, 0.375, 0.5, 0.5, 0.5}, -- NodeBox4
			{0.3125, -0.5, -0.375, 0.5, 0.5, 0.5}, -- NodeBox5
			{-0.5, 0.1875, -0.375, 0.5, 0.5, 0.5}, -- NodeBox6
			{-0.5, -0.5, -0.375, 0.5, -0.125, 0.5}, -- NodeBox7
		}
	}
})
register_base_machine({
	typename = "stove",
	machine_name = "electric_stove",
	machine_desc = "Electric Stove",
	tier="LV",
	demand={50},
	speed = 1,
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.3125, 0.5}, -- NodeBox6
		}
	}
})

minetest.register_craft({
	recipe = {
		{"default:steel_ingot", "basic_materials:heating_element", "default:steel_ingot"},
		{"default:steel_ingot", "technic:lv_cable", "default:steel_ingot"},
		{"default:steel_ingot", "technic:lv_cable", "default:steel_ingot"}
	},
	output = "cooking:electric_stove"
})
minetest.register_craft({
	recipe = {
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
		{"default:steel_ingot", "basic_materials:heating_element", "default:steel_ingot"},
		{"default:steel_ingot", "technic:lv_cable", "default:steel_ingot"}
	},
	output = "cooking:electric_oven"
})

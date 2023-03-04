local S = technic.getter
local distributor_square_radius = 10
local demand_per_light       = 5
local demand_update = {}

local function is_mesecon_operable(def)
	if def.mesecons then return true end
	local groups = def.groups
	if not groups then return false end
	for id, group in pairs(groups) do
		if string.find(id, "mesecon") then
			return true
		end
	end
	return false
end

local function update_light(pos)
	if not pos then return end
	local meta = minetest.get_meta(pos)
	local name = minetest.get_node(pos).name
	local def = table.copy(minetest.registered_nodes[name])
	if not def.groups then def.groups = {} end
	local on = true
	local node_on = def._node_on == nil
	if meta:get_string("distributor") == "" then
		on = false
		meta:set_string("infotext", "no distributor")
	else
		--[[local dist_pos = minetest.deserialize(meta:get_string("distributor"))
		if dist_pos then
			minetest.get_meta(dist_pos):set_int("update", 1)
		end--]]
		meta:set_string("infotext", "")
	end
	if is_mesecon_operable(def) and meta:get_int("mesecon") == 0 then on = false end
	if meta:get_int("switch_id") ~= 0 and meta:get_int("switch") == 0 then on = false end
	if on ~= node_on then
		if node_on then
			minetest.swap_node(pos, {name = def._node_off, param2 = minetest.get_node(pos).param2})
		else
			minetest.swap_node(pos, {name = def._node_on, param2 = minetest.get_node(pos).param2})
		end
	end
	return on
end

local function set_distributor(pos, val, force)
	if pos == nil then return 0 end
	local meta = minetest.get_meta(pos)
	if not force then
		local last_set = meta:get_int("last_set") == 1
		if last_set == val then
			return 0
		end
	end
	if val == true then
		meta:set_int("last_set", 1)
	else
		meta:set_int("last_set", 0)
	end
	local radius = distributor_square_radius
	local serialpos = minetest.serialize({x=pos.x,y=pos.y,z=pos.z})
	local pos1 = vector.add(pos, radius)
	local pos2 = vector.subtract(pos, radius)
	local distmeta = minetest.get_meta(pos)
	local lightnum = 0
	local lights = minetest.find_nodes_in_area(pos1, pos2, {"group:electric_light"})
	for i, p in pairs(lights) do
		local meta = minetest.get_meta(p)
		local parent = meta:get_string("distributor")
		if parent == "" and val then parent = serialpos meta:set_string("distributor", parent) end
		if parent == serialpos then
			if not val then
				meta:set_string("distributor", "")
			end
			if update_light(p) then
				lightnum = lightnum + 1
			end
		end
		::next::
	end
	if val then distmeta:set_int("update", 1) demand_update[minetest.hash_node_position(pos)] = lightnum*demand_per_light end
	return lightnum
end

local function light_channel_form(channel)

    local form = 
    "size[2,2]" ..
    "field[1,1;1,1;channel;channel;"..minetest.formspec_escape(channel or 0).."]"

    return form
end

function register_electrical_light(name, node_on)
	local def = table.copy(minetest.registered_nodes[name])
	local newdef = {}
	local lightval = def.light_source
	if not node_on then node_on = def._node_on end
	newdef.light_source = 0
	newdef.groups = table.copy(def.groups) or {}
	newdef.groups.electric_light = 1
	
	local switch_mesecon
	if minetest.get_modpath("mesecons") and is_mesecon_operable(def) then
		switch_mesecon = {
			effector={
			action_on = function(pos, node)
				local meta = minetest.get_meta(pos)
				meta:set_int("mesecon", 1)
				update_light(pos)
				local dist_pos = minetest.deserialize(meta:get_string("distributor"))
				if dist_pos then
					set_distributor(dist_pos, true, true)
				end
			end,
			action_off = function(pos, node)
				local meta = minetest.get_meta(pos)
				meta:set_int("mesecon", 0)
				update_light(pos)
				local dist_pos = minetest.deserialize(meta:get_string("distributor"))
				if dist_pos then
					set_distributor(dist_pos, true, true)
				end
			end,}}
		newdef.mesecons = switch_mesecon
	end
	
	local old_construct = def.on_construct
	newdef.on_construct = function(pos)
		local val
		if old_construct then val = old_construct(pos) end
		local radius = distributor_square_radius
		local pos1 = vector.add(pos, radius)
		local pos2 = vector.subtract(pos, radius)
		minetest.get_meta(pos):set_string("infotext", "no distributor")
		local distributors = minetest.find_nodes_in_area(pos1, pos2, {'nolight:distributor'})
		for i, p in pairs(distributors) do
			local meta = minetest.get_meta(p)
			if meta:get_int("active") ~= 0 then
				meta:set_int("update", 1)
				break
			end
		end
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", light_channel_form())
		update_light(pos)
		if old_construct then return val end
	end
	local old_destruct = def.on_destruct
	newdef.on_destruct = function(pos)
		local val
		if old_destruct then val = old_destruct(pos) end
		local meta = minetest.get_meta(pos)
		if meta:get_string("distributor") ~= "" then
			local dist_pos = minetest.deserialize(meta:get_string("distributor"))
			if dist_pos then
				minetest.after(0, set_distributor, dist_pos, true, true)
			end
		end
		if old_destruct then return val end
	end
	newdef.on_receive_fields = function(pos, formname, fields, sender)
		if not fields.channel or not tonumber(fields.channel) then return end
		local meta = minetest.get_meta(pos)
		fields.channel = math.floor(tonumber(fields.channel))
		meta:set_string("switch_id", fields.channel)
		meta:set_int("switch", 0)
		meta:set_string("formspec", light_channel_form(fields.channel))
		update_light(pos)
	end
	if not node_on then
		local onname = string.gsub(name, "_off", "")
		onname = string.gsub(onname, "_on", "")
		onname = onname.."_on"
		local ondef = table.copy(def)
		ondef.light_source = lightval
		ondef.groups = table.copy(def.groups) or {}
		ondef.groups.electric_light = 1
		ondef.groups.not_in_creative_inventory = 1
		ondef.mesecons = newdef.mesecons
		ondef.on_construct = newdef.on_construct
		ondef.on_destruct = newdef.on_destruct
		ondef.on_receive_fields = newdef.on_receive_fields
		ondef.drops = name
		ondef._node_off = name
		newdef._node_on = onname
		minetest.register_node(":"..onname, ondef)
	else
		local ondef = {}
		ondef.mesecons = newdef.mesecons
		ondef.on_construct = newdef.on_construct
		ondef.on_destruct = newdef.on_destruct
		ondef.on_receive_fields = newdef.on_receive_fields
		ondef.drops = name
		ondef._node_off = name
		ondef.groups = table.copy(minetest.registered_nodes[node_on].groups) or {}
		ondef.groups.electric_light = 1
		ondef.groups.not_in_creative_inventory = 1
		newdef._node_on = node_on
		minetest.override_item(node_on, ondef)
	end
	minetest.override_item(name, newdef)
end

local run = function(pos, node)
	local meta         = minetest.get_meta(pos)
	local eu_input     = meta:get_int("LV_EU_input")
	local machine_name = S("%s Distributor"):format("LV")
	local demand = meta:get_int("LV_EU_demand")
	local newdemand = demand_update[minetest.hash_node_position(pos)]
	-- Setup meta data if it does not exist.
	if not eu_input then
		meta:set_int("LV_EU_demand", 0)
		meta:set_int("LV_EU_input", 0)
		return
	end

	if meta:get_int("active") == 0 then
		meta:set_string("infotext", S("%s Idle"):format(machine_name))
		set_distributor(pos, false)
		return
	end
	if demand == 0 and not newdemand and meta:get_int("update") ~= 1 then
		meta:set_string("infotext", S("%s Idle"):format(machine_name))
		return
	end

	if eu_input < demand then
		meta:set_string("infotext", S("%s Unpowered"):format(machine_name))
		meta:set_int("update", 1)
		set_distributor(pos, false)
	elseif eu_input >= demand then
		meta:set_string("infotext", S("%s Working"):format(machine_name))
		if meta:get_int("update") == 1 then
			set_distributor(pos, true)
			meta:set_int("update", 0)
		end
	end
	if newdemand then
		meta:set_int("LV_EU_demand", newdemand)
		demand_update[minetest.hash_node_position(pos)] = nil
	end
end

minetest.register_node('nolight:distributor', {
	description = S("%s Distributor"):format("LV"),
	tiles = {"distributor_side.png", "distributor_side.png", "distributor_side.png",
	         "distributor_side.png", "distributor_side.png", "distributor_front.png"},
	groups = {snappy=2, choppy=2, oddly_breakable_by_hand=2,
		technic_machine=1, technic_lv=1},
	connect_sides = {"bottom"},
	sounds = default.node_sound_wood_defaults(),
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", S("%s Distributor"):format("LV"))
		meta:set_int("active", 1)
		meta:set_int("update", 1)
	end,
	on_receive_fields = function(pos, formanme, fields, sender)
		if fields.toggle then new_track = 0 end
	end,
	paramtype2 = "facedir",
	on_destruct = function(pos) set_distributor(pos, false, true) end,
	technic_run = run,
	technic_on_disable = function(pos, node)
		set_distributor(pos, false, true)
		local meta = minetest.get_meta(pos)
		meta:set_int("update", 1)
	end,
})

minetest.register_craft({
	output = "nolight:distributor",
	recipe = {
		{"basic_materials:copper_wire", "technic:lv_cable", "basic_materials:copper_wire"},
		{"default:cobble", "default:cobble", "default:cobble"},
	}
})

local function light_switch(pos, node, val)
	local id = minetest.get_meta(pos):get_int("switch_id")
	if id == 0 then return end
	local radius = distributor_square_radius
	local pos1 = vector.add(pos, radius)
	local pos2 = vector.subtract(pos, radius)
	local lights = minetest.find_nodes_in_area(pos1, pos2, {"group:electric_light"})
	local distlist = {}
	for i, p in pairs (lights) do
		local lightmeta = minetest.get_meta(p)
		if lightmeta:get_int("switch_id") == id then
			lightmeta:set_int("switch", val or 0)
			update_light(p)
			local dist_pos = minetest.deserialize(lightmeta:get_string("distributor"))
			if dist_pos then
				distlist[minetest.hash_node_position(dist_pos)] = true
			end
		end
	end
	for hash, val in pairs(distlist) do
		set_distributor(minetest.get_position_from_hash(hash), true, true)
	end
end

for _, onoff in ipairs ({"on", "off"}) do

	local switch_mesecon
	if minetest.get_modpath("mesecons") then
		switch_mesecon = {
			effector={
			action_on = function(pos, node)
				light_switch(pos, node, 1)
				minetest.swap_node(pos, {name = "nolight:light_switch_on", param2 = node.param2})
			end,
			action_off = function(pos, node)
				light_switch(pos, node, 0)
				minetest.swap_node(pos, {name = "nolight:light_switch_off", param2 = node.param2})
			end,
		}}
	end

	local model = {
		{ -0.125,   -0.1875, 0.4375,  0.125,   0.125,  0.5 },
		{ -0.03125,  0,      0.40625, 0.03125, 0.0625, 0.5 },
	}

	if onoff == "on" then
		model = {
			{ -0.125,   -0.1875, 0.4375,  0.125,    0.125,  0.5 },
			{ -0.03125, -0.125,  0.40625, 0.03125, -0.0625, 0.5 },
		}
	end

	minetest.register_node("nolight:light_switch_"..onoff, {
		description = "Light switch",
		drawtype = "nodebox",
		paramtype2 = "facedir",
		tiles = {
			"homedecor_light_switch_edges.png",
			"homedecor_light_switch_edges.png",
			"homedecor_light_switch_edges.png",
			"homedecor_light_switch_edges.png",
			"homedecor_light_switch_back.png",
			"homedecor_light_switch_front_"..onoff..".png"
		},
		inventory_image = "homedecor_light_switch_inv.png",
		node_box = {
			type = "fixed",
			fixed = model
		},
		selection_box = {
			type = "fixed",
			fixed = {
				{ -0.1875,   -0.25,    0.375,  0.1875,   0.1875, 0.5 },
			}
		},
		groups = {
			cracky=3, dig_immediate=2, mesecon_needs_receiver=1,
			not_in_creative_inventory = (onoff == "on") and 1 or nil
		},
		walkable = false,
		drops = "nolight:light_switch_off",
		mesecons = switch_mesecon,
		on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			meta:set_string("formspec", light_channel_form())
		end,
		on_destruct = (onoff == "on" and function(pos)
			light_switch(pos, node, 0)
		end) or nil,
		on_rightclick = (onoff == "on" and function(pos, node, clicker, itemstack, pointed_thing)
			light_switch(pos, node, 0)
			minetest.swap_node(pos, {name = "nolight:light_switch_off", param2 = node.param2})
		end) or function(pos, node, clicker, itemstack, pointed_thing)
			light_switch(pos, node, 1)
			minetest.swap_node(pos, {name = "nolight:light_switch_on", param2 = node.param2})
		end,
		on_receive_fields = function(pos, formname, fields, sender)
			if not fields.channel or not tonumber(fields.channel) or math.floor(tonumber(fields.channel)) == 0 then return end
			local meta = minetest.get_meta(pos)
			fields.channel = math.floor(tonumber(fields.channel))
			meta:set_string("switch_id", fields.channel)
			meta:set_string("formspec", "")
		end,
	})
end

if minetest.get_modpath("mesecons_walllever") then
	minetest.register_craft({
		type = "shapeless",
		output = "nolight:light_switch_off",
		recipe = {"mesecons_walllever:wall_lever_off"},
	})
	minetest.register_craft({
		type = "shapeless",
		output = "mesecons_walllever:wall_lever_off",
		recipe = {"nolight:light_switch_off"},
	})
else
	minetest.register_craft({
		output = "nolight:light_switch_off",
		recipe = {
			{"default:mese_crystal_fragment"},
			{"default:stone"},
			{"default:stick"},
		}
	})
end

minetest.register_lbm({
	label = "Ensure lights have the channel formspec",
	name = "nolight:setup_formspec",
	nodenames = {"group:electric_light"},
	run_at_every_load = false,
	action = function(pos, node)
		local meta = minetest.get_meta(pos)
		if meta:get_string("formspec") == "" then
			meta:set_string("formspec", light_channel_form())
		end
		update_light(pos)
	end,
})
technic.register_machine("LV", 'nolight:distributor', technic.receiver)
-- © 2017 numberZero
-- License: GNU Lesser General Public License, version 2 (or any later version)

local OVERLOAD_THRESHOLD = 50.0
local FILTER_FORMSPEC = "field[channel;Channel;${channel}]"
local FILTER_INFOTEXT = "Digiline Filter (channel \"%s\")"
local FILTER_INFOTEXT_DEFAULT = FILTER_INFOTEXT:format("")

local function filter_rules_in(node)
	return {
		digiline_routing.get_base_rule(3, node.param2),
	}
end

local function filter_rules_out(node)
	return {
		digiline_routing.get_base_rule(1, node.param2),
	}
end

local function filter_init(pos)
	local meta = minetest.get_meta(pos)
	meta:set_string("formspec", FILTER_FORMSPEC)
	meta:set_string("infotext", FILTER_INFOTEXT_DEFAULT)
	meta:set_string("channel", "")
end

local function filter_receive_fields(pos, formname, fields, sender)
	if minetest.is_protected(pos, sender:get_player_name()) and not minetest.check_player_privs(sender, "protection_bypass") then
		minetest.record_protection_violation(pos, sender)
		return
	end
	if not fields.channel then
		return
	end
	local meta = minetest.get_meta(pos)
	meta:set_string("channel", fields.channel)
	meta:set_string("infotext", FILTER_INFOTEXT:format(fields.channel))
end

local function filter_place(...)
	return (digiline_routing.multiblock.build2("digiline_routing:filter", "digiline_routing:filter_b", ...)) -- adjust to 1 value
end

local function filter_cleanup(pos, node)
	digiline_routing.overheat.forget(pos)
	digiline_routing.multiblock.dig2(pos, node)
end

local function filter_test(master, channel)
	if digiline_routing.overheat.heat(master) > OVERLOAD_THRESHOLD then
		minetest.dig_node(master)
		minetest.add_item(master, "digiline_routing:filter")
		return false
	end
	return channel == minetest.get_meta(master):get_string("channel")
end

local function filter_in_action(pos, node, channel, msg)
	if filter_test(pos, channel) then
		local off = minetest.facedir_to_dir(node.param2)
		local slave = vector.add(pos, off)
		digiline:receptor_send(slave, filter_rules_out(node), channel, msg)
	end
end

local function filter_out_action(pos, node, channel, msg)
	local off = minetest.facedir_to_dir(node.param2)
	local master = vector.subtract(pos, off)
	if filter_test(master, channel) then
		digiline:receptor_send(master, filter_rules_in(node), channel, msg)
	end
end

minetest.register_node("digiline_routing:filter", {
	description = "Digiline Filter",
	drawtype = "nodebox",
	tiles = {
		"digiline_routing_metal.png"
	},
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {dig_immediate=2},
	node_box = {
		type = "fixed",
		fixed = {
			{ -1/16, -8/16, -8/16, 1/16, -7/16, 24/16 },
			{ -2/16, -8/16, -4/16, 2/16, -6/16, 20/16 },

			{ -3/16, -8/16, -3/16, 3/16, -5/16, 4/16 },
			{ -4/16, -8/16, -2/16, 4/16, -5/16, 3/16 },
			{ -5/16, -8/16, -1/16, 5/16, -5/16, 2/16 },

			{ -5/16, -8/16, 7/16, 5/16, -6/16, 9/16 },
			{ -7/16, -8/16, 5/16, -5/16, -5/16, 11/16 },
			{ 5/16, -8/16, 5/16, 7/16, -5/16, 11/16 },

			{ -3/16, -8/16, 12/16, 3/16, -5/16, 19/16 },
			{ -4/16, -8/16, 13/16, 4/16, -5/16, 18/16 },
			{ -5/16, -8/16, 14/16, 5/16, -5/16, 17/16 },
		},
	},
	on_construct = filter_init,
	on_place = filter_place,
	after_destruct = filter_cleanup,
	on_receive_fields = filter_receive_fields,
	on_rotate = digiline_routing.multiblock.rotate2,
	digiline = {
		effector = {
                        action = filter_in_action,
			rules = filter_rules_in,
		},
		receptor = {
			rules = filter_rules_in,
		},
	},
})

minetest.register_node("digiline_routing:filter_b", {
	description = "<<INTERNAL>> Digiline Filter (Part B)",
	drawtype = "nodebox",
	tiles = {
		"digiline_routing_metal.png"
	},
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	pointable = false,
	groups = {dig_immediate=2, not_in_creative_inventory=1},
	node_box = {
		type = "fixed",
		fixed = {},
	},
	drop = "",
	after_destruct = digiline_routing.multiblock.dig2b,
	on_rotate = digiline_routing.multiblock.rotate2b,
	digiline = {
		effector = {
                        action = filter_out_action,
			rules = filter_rules_out,
		},
		receptor = {
			rules = filter_rules_out,
		},
	},
})

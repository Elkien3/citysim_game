
minetest.register_node("waterworks:pipe", {
	description = "Waterworks Pipe",
	tiles = {
		{name="waterworks_pipe.png^waterworks_pipe_rivets_offset.png", scale=4, align_style="world"},
		{name="waterworks_pipe.png^waterworks_pipe_rivets_offset_2.png", scale=4, align_style="world"},
		{name="waterworks_pipe.png^waterworks_pipe_rivets.png", scale=4, align_style="world"},
		{name="waterworks_pipe.png^waterworks_pipe_rivets_offset_2.png", scale=4, align_style="world"},
		{name="waterworks_pipe.png^waterworks_pipe_rivets.png", scale=4, align_style="world"},
		{name="waterworks_pipe.png^waterworks_pipe_rivets_offset_2.png", scale=4, align_style="world"},
	},
    connects_to = {"group:waterworks_pipe", "group:waterworks_connected", "group:waterworks_inert"},
    connect_sides = { "top", "bottom", "front", "left", "back", "right" },
	drawtype = "nodebox",
	node_box = {
        type = "connected",
        fixed = {-0.25,-0.25,-0.25,0.25,0.25,0.25},
        connect_top = {-0.375, 0, -0.375, 0.375, 0.5, 0.375},
        connect_bottom = {-0.375, -0.5, -0.375, 0.375, 0, 0.375},
        connect_back = {-0.375, -0.375, 0, 0.375, 0.375, 0.5},
        connect_right = {0, -0.375, -0.375, 0.5, 0.375, 0.375},
        connect_front = {-0.375, -0.375, -0.5, 0.375, 0.375, 0},
        connect_left = {-0.5, -0.375, -0.375, 0, 0.375, 0.375},
        disconnected = {-0.375,-0.375,-0.375,0.375,0.375,0.375},
    },
	paramtype = "light",

	is_ground_content = false,
	groups = {oddly_breakable_by_hand = 1, waterworks_pipe = 1},
	sounds = default.node_sound_metal_defaults(),
	on_construct = function(pos)
		waterworks.place_pipe(pos)
	end,
	on_destruct = function(pos)
		waterworks.remove_pipe(pos)
	end,
})

-----------------------------------------------------------------

minetest.register_node("waterworks:valve_on", {
	description = "Waterworks Valve (open)",
	tiles = {"waterworks_metal.png^waterworks_valve_seam.png^waterworks_valve_on.png",},	
    connects_to = {"group:waterworks_pipe", "group:waterworks_connected", "group:waterworks_inert"},
    connect_sides = { "top", "bottom", "front", "left", "back", "right" },
	drawtype = "nodebox",
	node_box = {
        type = "connected",
        fixed = {-0.4375,-0.4375,-0.4375,0.4375,0.4375,0.4375},
        connect_top = {-0.375, 0.4375, -0.375, 0.375, 0.5, 0.375},
        connect_bottom = {-0.375, -0.5, -0.375, 0.375, -0.4375, 0.375},
        connect_back = {-0.375, -0.375, 0.4375, 0.375, 0.375, 0.5},
        connect_right = {0.4375, -0.375, -0.375, 0.5, 0.375, 0.375},
        connect_front = {-0.375, -0.375, -0.5, 0.375, 0.375, -0.4375},
        connect_left = {-0.5, -0.375, -0.375, -0.4375, 0.375, 0.375},
    },
	paramtype = "light",

	is_ground_content = false,
	groups = {oddly_breakable_by_hand = 1, waterworks_pipe = 1},
	sounds = default.node_sound_metal_defaults(),
	on_construct = function(pos)
		waterworks.place_pipe(pos)
	end,
	on_destruct = function(pos)
		waterworks.remove_pipe(pos)
	end,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		node.name = "waterworks:valve_off"
		minetest.set_node(pos, node)
	end,
})

minetest.register_node("waterworks:valve_off", {
	description = "Waterworks Valve (closed)",
	tiles = {"waterworks_metal.png^waterworks_valve_seam.png^waterworks_valve_off.png",},	
    connects_to = {"group:waterworks_pipe", "group:waterworks_connected", "group:waterworks_inert"},
    connect_sides = { "top", "bottom", "front", "left", "back", "right" },
	drawtype = "nodebox",
	node_box = {
        type = "connected",
        fixed = {-0.4375,-0.4375,-0.4375,0.4375,0.4375,0.4375},
        connect_top = {-0.375, 0.4375, -0.375, 0.375, 0.5, 0.375},
        connect_bottom = {-0.375, -0.5, -0.375, 0.375, -0.4375, 0.375},
        connect_back = {-0.375, -0.375, 0.4375, 0.375, 0.375, 0.5},
        connect_right = {0.4375, -0.375, -0.375, 0.5, 0.375, 0.375},
        connect_front = {-0.375, -0.375, -0.5, 0.375, 0.375, -0.4375},
        connect_left = {-0.5, -0.375, -0.375, -0.4375, 0.375, 0.375},
    },
	paramtype = "light",
	drops = "waterworks:valve_on",

	is_ground_content = false,
	groups = {oddly_breakable_by_hand = 1, waterworks_inert = 1, not_in_creative_inventory = 1},
	sounds = default.node_sound_metal_defaults(),
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		node.name = "waterworks:valve_on"
		minetest.set_node(pos, node)
	end,
})

-----------------------------------------------------------------

local place_inlet = function(pos)
	local node = minetest.get_node(pos)
	local dir = minetest.facedir_to_dir(node.param2)
	local target = vector.subtract(pos, dir)
	waterworks.place_connected(pos, "inlet", {pos = pos, target = target, pressure = target.y})
	local meta = minetest.get_meta(pos)
	meta:set_string("infotext", "Inlet elevation " .. tostring(target.y))
end
minetest.register_node("waterworks:inlet", {
	description = "Waterworks Inlet",
	tiles = {
		"waterworks_metal.png",
		"waterworks_metal.png",
		"waterworks_metal.png",
		"waterworks_metal.png",
		"waterworks_metal.png^waterworks_connected_back.png",
		"waterworks_metal.png^waterworks_inlet.png",
	},
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {oddly_breakable_by_hand = 1, waterworks_connected = 1},
	sounds = default.node_sound_metal_defaults(),
	paramtype = "light",
	drawtype = "nodebox",
	node_box = {
        type = "fixed",
        fixed = {{-0.375, -0.375, -0.375, 0.375, 0.375, 0.5}, {-0.5, -0.5, -0.5, 0.5, 0.5, -0.375}},
    },
	_waterworks_update_connected = place_inlet,
	on_construct = function(pos)
		place_inlet(pos)
	end,
	on_destruct = function(pos)
		waterworks.remove_connected(pos, "inlet")
	end,
	on_rotate = function(pos, node, user, mode, new_param2)
		waterworks.remove_connected(pos, "inlet")
		node.param2 = new_param2
		minetest.swap_node(pos, node)
		place_inlet(pos)
		return true
	end,
})

local place_pumped_inlet = function(pos)
	local node = minetest.get_node(pos)
	local dir = minetest.facedir_to_dir(node.param2)
	local target = vector.subtract(pos, dir)
	waterworks.place_connected(pos, "inlet", {pos = pos, target = target, pressure = target.y + 100})
	local meta = minetest.get_meta(pos)
	meta:set_string("infotext", "Pump effective elevation " .. tostring(target.y + 100))
end
minetest.register_node("waterworks:pumped_inlet", {
	description = "Waterworks Pumped Inlet",
	tiles = {
		"waterworks_turbine_base.png",
		"waterworks_turbine_base.png",
		"waterworks_turbine_side.png^[transformFX",
		"waterworks_turbine_side.png",
		"waterworks_metal.png^waterworks_connected_back.png",
		"waterworks_turbine_base.png^waterworks_turbine.png",
	},
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {oddly_breakable_by_hand = 1, waterworks_connected = 1},
	sounds = default.node_sound_metal_defaults(),
	paramtype = "light",
	drawtype = "normal",
	_waterworks_update_connected = place_pumped_inlet,
	on_construct = function(pos)
		place_pumped_inlet(pos)
	end,
	on_destruct = function(pos)
		waterworks.remove_connected(pos, "inlet")
	end,
	on_rotate = function(pos, node, user, mode, new_param2)
		waterworks.remove_connected(pos, "inlet")
		node.param2 = new_param2
		minetest.swap_node(pos, node)
		place_pumped_inlet(pos)
		return true
	end,
})

local place_outlet = function(pos)
	local node = minetest.get_node(pos)
	local dir = minetest.facedir_to_dir(node.param2)
	local target = vector.subtract(pos, dir)
	waterworks.place_connected(pos, "outlet", {pos = pos, target = target, pressure = target.y})
	local meta = minetest.get_meta(pos)
	meta:set_string("infotext", "Outlet elevation " .. tostring(target.y))
end
minetest.register_node("waterworks:outlet", {
	description = "Waterworks Outlet",
	tiles = {
		"waterworks_metal.png",
		"waterworks_metal.png",
		"waterworks_metal.png",
		"waterworks_metal.png",
		"waterworks_metal.png^waterworks_connected_back.png",
		"waterworks_metal.png^waterworks_outlet.png",
	},
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {oddly_breakable_by_hand = 1, waterworks_connected = 1},
	
	paramtype = "light",
	drawtype = "nodebox",
	node_box = {
        type = "fixed",
        fixed = {{-0.375, -0.375, -0.375, 0.375, 0.375, 0.5}, {-0.5, -0.5, -0.5, 0.5, 0.5, -0.375}},
    },
	
	sounds = default.node_sound_metal_defaults(),
	_waterworks_update_connected = place_outlet,
	on_construct = function(pos)
		place_outlet(pos)
	end,
	on_destruct = function(pos)
		waterworks.remove_connected(pos, "outlet")
	end,
	on_rotate = function(pos, node, user, mode, new_param2)
		waterworks.remove_connected(pos, "outlet")
		node.param2 = new_param2
		minetest.swap_node(pos, node)
		place_outlet(pos)
		return true
	end,
})

local place_grate = function(pos)
	local node = minetest.get_node(pos)
	local dir = minetest.facedir_to_dir(node.param2)
	local target = vector.subtract(pos, dir)
	waterworks.place_connected(pos, "outlet", {pos = pos, target = target, pressure = target.y})
	local meta = minetest.get_meta(pos)
	meta:set_string("infotext", "Grate elevation " .. tostring(target.y))
end
minetest.register_node("waterworks:grate", {
	description = "Waterworks Grate",
	tiles = {
		"waterworks_metal.png",
		"waterworks_metal.png",
		"waterworks_metal.png",
		"waterworks_metal.png",
		"waterworks_metal.png^waterworks_connected_back.png",
		"waterworks_metal.png^waterworks_grate.png",
	},
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {oddly_breakable_by_hand = 1, waterworks_connected = 1},
	
	paramtype = "light",
	drawtype = "nodebox",
	node_box = {
        type = "fixed",
        fixed = {{-0.375, -0.375, -0.375, 0.375, 0.375, 0.5}, {-0.5, -0.5, -0.5, 0.5, 0.5, -0.375}},
    },
	
	sounds = default.node_sound_metal_defaults(),
	_waterworks_update_connected = place_outlet,
	on_construct = function(pos)
		place_outlet(pos)
	end,
	on_destruct = function(pos)
		waterworks.remove_connected(pos, "outlet")
		waterworks.remove_connected(pos, "inlet")
	end,
	on_rotate = function(pos, node, user, mode, new_param2)
		waterworks.remove_connected(pos, "outlet")
		waterworks.remove_connected(pos, "inlet")
		node.param2 = new_param2
		minetest.swap_node(pos, node)
		place_outlet(pos)
		return true
	end,
})
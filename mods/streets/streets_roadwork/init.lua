--[[
  ## StreetsMod 2.0 ##
  Submod: roadwork
  Optional: true
]]


-- Traffic Barrier

minetest.register_node("streets:roadwork_traffic_barrier", {
	description = "Traffic Barrier",
	paramtype = "light",
	drawtype = "nodebox",
	tiles = { streets.concrete_texture, streets.concrete_texture, streets.concrete_texture .. "^streets_roadwork_traffic_barrier.png" },
	sunlight_propagates = true,
	groups = { cracky = 1, level = 2, wall = 1 },
	node_box = {
		type = "connected",
		fixed = { { -0.35, -0.5, -0.35, 0.35, -0.4, 0.35 }, { -0.15, -0.5, -0.15, 0.15, 0.5, 0.15 } },
		connect_front = { { -0.35, -0.5, -0.5, 0.35, -0.4, 0.35 }, { -0.15, -0.5, -0.5, 0.15, 0.5, 0.15 } }, -- z-
		connect_back = { { -0.35, -0.5, -0.35, 0.35, -0.4, 0.5 }, { -0.15, -0.5, -0.15, 0.15, 0.5, 0.5 } }, -- z+
		connect_left = { { -0.5, -0.5, -0.35, 0.35, -0.4, 0.35 }, { -0.5, -0.5, -0.15, 0.15, 0.5, 0.15 } }, -- x-
		connect_right = { { -0.35, -0.5, -0.35, 0.5, -0.4, 0.35 }, { -0.15, -0.5, -0.15, 0.5, 0.5, 0.15 } }, -- x+
	},
	connects_to = { "group:wall", "group:stone", "group:wood", "group:tree", "group:concrete" },
	sound = default.node_sound_stone_defaults()
})

minetest.register_craft({
	output = "streets:roadwork_traffic_barrier 3",
	recipe = {
		{ "dye:red", "dye:white", "dye:red" },
		{ "streets:concrete_wall", "streets:concrete_wall", "streets:concrete_wall" },
	}
})


-- Barrier Tape

minetest.register_node("streets:roadwork_barrier_tape", {
	description = "Barrier Tape",
	paramtype = "light",
	drawtype = "nodebox",
	tiles = { "streets_roadwork_barrier_tape.png" },
	sunlight_propagates = true,
	groups = { choppy = 1, dig_immediate = 3, level = 1, wall = 1 },
	node_box = {
		type = "connected",
		fixed = { -1 / 16, -0.5, -1 / 16, 1 / 16, 0.5, 1 / 16 },
		connect_front = { 0, 4 / 16, -0.5, 0, 6 / 16, 0 }, -- z-
		connect_back = { 0, 4 / 16, 0, 0, 6 / 16, 0.5 }, -- z+
		connect_left = { -0.5, 4 / 16, 0, 0, 6 / 16, 0 }, -- x-
		connect_right = { 0, 4 / 16, 0, 0.5, 6 / 16, 0 }, -- x+
	},
	selection_box = {
		type = "fixed",
		fixed = { -2 / 16, -0.5, -2 / 16, 2 / 16, 0.5, 2 / 16 },
	},
	connects_to = { "group:wall", "group:stone", "group:wood", "group:tree", "group:sign", "group:concrete" },
})

minetest.register_craft({
	output = "streets:roadwork_barrier_tape 24",
	recipe = {
		{ "dye:red", "dye:white", "dye:red" },
		{ "farming:cotton", "default:stick", "farming:cotton" },
		{ "", "default:stick", "" }
	}
})


-- Traffic Fence


minetest.register_node("streets:roadwork_traffic_fence", {
	description = "Traffic Fence",
	paramtype = "light",
	drawtype = "nodebox",
	tiles = { "streets_roadwork_traffic_fence_top.png", "streets_roadwork_traffic_fence_top.png", "streets_roadwork_traffic_fence.png" },
	inventory_image = "streets_roadwork_traffic_fence.png",
	wield_image = "streets_roadwork_traffic_fence.png",
	sunlight_propagates = true,
	groups = { cracky = 1, wall = 1 },
	node_box = {
		type = "connected",
		fixed = { -1 / 16, -0.5, -1 / 16, 1 / 16, 0.5, 1 / 16 },
		connect_front = {
			{ -1 / 16, -0.5, -0.5, 1 / 16, -0.25, 1 / 16 },
			{ -1 / 16, 0.25, -0.5, 1 / 16, 0.5, 1 / 16 },
			{ -1 / 16, -0.25, -0.5, 1 / 16, 0.25, -7 / 16 },
			{ -1 / 16, -0.25, -5 / 16, 1 / 16, 0.25, -3 / 16 }
		}, -- z-
		connect_back = {
			{ -1 / 16, -0.5, -1 / 16, 1 / 16, -0.25, 0.5 },
			{ -1 / 16, 0.25, -1 / 16, 1 / 16, 0.5, 0.5 },
			{ -1 / 16, -0.25, 7 / 16, 1 / 16, 0.25, 0.5 },
			{ -1 / 16, -0.25, 3 / 16, 1 / 16, 0.25, 5 / 16 }
		}, -- z+
		connect_left = {
			{ -0.5, -0.5, -1 / 16, 1 / 16, -0.25, 1 / 16 },
			{ -0.5, 0.25, -1 / 16, 1 / 16, 0.5, 1 / 16 },
			{ -0.5, -0.25, -1 / 16, -7 / 16, 0.25, 1 / 16 },
			{ -5 / 16, -0.25, -1 / 16, -3 / 16, 0.25, 1 / 16 }
		}, -- x-
		connect_right = {
			{ -1 / 16, -0.5, -1 / 16, 0.5, -0.25, 1 / 16 },
			{ -1 / 16, 0.25, -1 / 16, 0.5, 0.5, 1 / 16 },
			{ 7 / 16, -0.25, -1 / 16, 0.5, 0.25, 1 / 16 },
			{ 3 / 16, -0.25, -1 / 16, 5 / 16, 0.25, 1 / 16 },
		} -- x+
	},
	connects_to = { "group:wall", "group:stone", "group:wood", "group:tree", "group:sign", "group:concrete" },
})

minetest.register_craft({
	output = "streets:roadwork_traffic_fence 3",
	recipe = {
		{ "dye:red", "dye:white", "dye:red" },
		{ "xpanes:bar", "xpanes:bar", "xpanes:bar" },
	}
})


-- Pylon


minetest.register_node("streets:roadwork_pylon", {
	description = "Pylon",
	paramtype = "light",
	drawtype = "nodebox",
	tiles = { "streets_roadwork_pylon_top.png", "streets_roadwork_pylon_top.png", "streets_roadwork_pylon.png" },
	sunlight_propagates = true,
	groups = { cracky = 1 },
	node_box = {
		type = "fixed",
		fixed = {
			{ -0.375, -0.5, -0.125, 0.375, -0.4375, 0.125 },
			{ -0.125, -0.5, -0.375, 0.125, -0.4375, 0.375 },
			{ -0.3125, -0.5, 0, 0.3125, 0.1875, 0 },
			{ 0, -0.5, -0.3125, 0, 0.1875, 0.3125 },
		}
	}
})

minetest.register_craft({
	output = "streets:roadwork_pylon 3",
	recipe = {
		{ "dye:orange", "", "dye:orange" },
		{ "dye:white", "default:stick", "dye:white" },
		{ "dye:orange", "default:steel_ingot", "dye:orange" },
	}
})

-- Blinking Light

minetest.register_node("streets:roadwork_blinking_light_off", {
	description = "Blinking Light",
	paramtype = "light",
	paramtype2 = "facedir",
	drawtype = "nodebox",
	tiles = { "streets_roadwork_blinking_light_top.png", "streets_roadwork_blinking_light_top.png", "streets_roadwork_blinking_light_off.png" },
	sunlight_propagates = true,
	groups = { cracky = 1 },
	node_box = {
		type = "fixed",
		fixed = {
			{ -0.1875, -0.5, -0.125, 0.1875, -0.3125, 0.125 }, -- Base
			{ -0.1875, -0.3125, 0, 0.1875, 0.0625, 0 }, -- Light
		}
	},
	on_timer = function(pos, elapsed)
		minetest.set_node(pos, { name = "streets:roadwork_blinking_light_on", param2 = minetest.get_node(pos).param2 })
	end,
	on_construct = function(pos)
		timer = minetest.get_node_timer(pos)
		timer:start(1)
	end,
})

minetest.register_node("streets:roadwork_blinking_light_on", {
	description = "Blinking Light",
	paramtype = "light",
	paramtype2 = "facedir",
	drawtype = "nodebox",
	tiles = { "streets_roadwork_blinking_light_top.png", "streets_roadwork_blinking_light_top.png", "streets_roadwork_blinking_light_on.png" },
	sunlight_propagates = true,
	groups = { cracky = 1, not_in_creative_inventory = 1 },
	node_box = {
		type = "fixed",
		fixed = {
			{ -0.1875, -0.5, -0.125, 0.1875, -0.3125, 0.125 }, -- Base
			{ -0.1875, -0.3125, 0, 0.1875, 0.0625, 0 }, -- Light
		}
	},
	light_source = 12,
	on_timer = function(pos, elapsed)
		minetest.set_node(pos, { name = "streets:roadwork_blinking_light_off", param2 = minetest.get_node(pos).param2 })
	end,
	on_construct = function(pos)
		timer = minetest.get_node_timer(pos)
		timer:start(1)
	end,
	drop = "streets:roadwork_blinking_light_off",
})

minetest.register_craft({
	output = "streets:roadwork_blinking_light_off 2",
	recipe = {
		{ "dye:red", "default:torch", "dye:red" },
		{ "dye:yellow", "default:steel_ingot", "dye:yellow" },
	}
})

minetest.register_abm({
	nodenames = {
		"streets:roadwork_blinking_light_on", "streets:roadwork_blinking_light_off",
		"streets:roadwork_delineator_light_on_top", "streets:roadwork_delineator_light_off_top"
	},
	interval = 10,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		timer = minetest.get_node_timer(pos)
		if not timer:is_started() then
			timer:start(1)
		end
	end,
})

minetest.register_node("streets:roadwork_delineator_top", {
	tile_images = {
		"streets_roadwork_delineator_top.png",
		"streets_tl_bg.png",
		"streets_transparent.png",
		"streets_transparent.png",
		"streets_roadwork_delineator_top_front_back.png^[transformFX",
		"streets_roadwork_delineator_top_front_back.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = { cracky = 1, not_in_creative_inventory = 1 },
	light_source = 5,
	node_box = {
		type = "fixed",
		fixed = {
			{ -1 / 4, -1 / 2, 0, 1 / 4, 0, 0 }
		}
	},
	selection_box = {
		type = "fixed",
		fixed = { 0, 0, 0, 0, 0, 0 }
	}
})

minetest.register_node("streets:roadwork_delineator_bottom", {
	description = "Roadwork Delineator",
	inventory_image = "streets_roadwork_delineator.png",
	wield_image = "streets_roadwork_delineator.png",
	tile_images = {
		"streets_roadwork_delineator_top.png",
		"streets_tl_bg.png",
		"streets_roadwork_delineator_bottom_side.png",
		"streets_roadwork_delineator_bottom_side.png",
		"streets_roadwork_delineator_bottom_front_back.png^[transformFX",
		"streets_roadwork_delineator_bottom_front_back.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = { cracky = 1 },
	light_source = 5,
	node_box = {
		type = "fixed",
		fixed = {
			{ -1 / 4, -7 / 32, 0, 1 / 4, 1 / 2, 0 },
			{ -1 / 16, -5 / 16, -1 / 16, 1 / 16, -7 / 32, 1 / 16 },
			{ -1 / 8, -3 / 8, -1 / 8, 1 / 8, -5 / 16, 1 / 8 },
			{ -1 / 4, -1 / 2, -1 / 2, 1 / 4, -3 / 8, 1 / 2 }
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{ -1 / 4, -7 / 32, 0, 1 / 4, 1, 0 },
			{ -1 / 16, -5 / 16, -1 / 16, 1 / 16, -7 / 32, 1 / 16 },
			{ -1 / 8, -3 / 8, -1 / 8, 1 / 8, -5 / 16, 1 / 8 },
			{ -1 / 4, -1 / 2, -1 / 2, 1 / 4, -3 / 8, 1 / 2 }
		}
	},
	after_place_node = function(pos)
		local node = minetest.env:get_node(pos)
		node.name = "streets:roadwork_delineator_bottom"
		minetest.env:add_node(pos, node)
		pos.y = pos.y + 1
		node.name = "streets:roadwork_delineator_top"
		if minetest.get_item_group(minetest.get_node(pos).name, "airlike") > 0 then
			minetest.env:add_node(pos, node)
		end
	end,
	after_dig_node = function(pos)
		pos.y = pos.y + 1
		if minetest.get_node(pos).name == "streets:roadwork_delineator_top" then
			minetest.env:remove_node(pos)
		end
	end,
})

minetest.register_alias("streets:roadwork_delineator", "streets:roadwork_delineator_bottom")

minetest.register_craft({
	output = "streets:roadwork_delineator 5",
	recipe = {
		{ "dye:red", "default:steel_ingot", "dye:red" },
		{ "dye:white", "default:steel_ingot", "dye:white" },
		{ "default:steel_ingot", "default:steel_ingot", "default:steel_ingot" },
	}
})



minetest.register_node("streets:roadwork_delineator_light_off_top", {
	tile_images = {
		"streets_roadwork_delineator_top.png",
		"streets_tl_bg.png",
		"streets_transparent.png",
		"streets_transparent.png",
		"streets_roadwork_delineator_light_off_top_front_back.png^[transformFX",
		"streets_roadwork_delineator_light_off_top_front_back.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = { cracky = 1, not_in_creative_inventory = 1 },
	light_source = 5,
	on_timer = function(pos, elapsed)
		minetest.set_node(pos, { name = "streets:roadwork_delineator_light_on_top", param2 = minetest.get_node(pos).param2 })
	end,
	on_construct = function(pos)
		timer = minetest.get_node_timer(pos)
		timer:start(1)
	end,
	node_box = {
		type = "fixed",
		fixed = {
			{ -1 / 4, -1 / 2, 0, 1 / 4, 3 / 8, 0 }
		}
	},
	selection_box = {
		type = "fixed",
		fixed = { 0, 0, 0, 0, 0, 0 }
	}
})

minetest.register_node("streets:roadwork_delineator_light_on_top", {
	tile_images = {
		"streets_roadwork_delineator_top.png",
		"streets_tl_bg.png",
		"streets_transparent.png",
		"streets_transparent.png",
		"streets_roadwork_delineator_light_on_top_front_back.png^[transformFX",
		"streets_roadwork_delineator_light_on_top_front_back.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = { cracky = 1, not_in_creative_inventory = 1 },
	light_source = 12,
	on_timer = function(pos, elapsed)
		minetest.set_node(pos, { name = "streets:roadwork_delineator_light_off_top", param2 = minetest.get_node(pos).param2 })
	end,
	on_construct = function(pos)
		timer = minetest.get_node_timer(pos)
		timer:start(1)
	end,
	drop = "streets:roadwork_delineator_light_off_top",
	node_box = {
		type = "fixed",
		fixed = {
			{ -1 / 4, -1 / 2, 0, 1 / 4, 3 / 8, 0 }
		}
	},
	selection_box = {
		type = "fixed",
		fixed = { 0, 0, 0, 0, 0, 0 }
	}
})

minetest.register_node("streets:roadwork_delineator_light_bottom", {
	description = "Roadwork Delineator with Blinking Light",
	inventory_image = "streets_roadwork_delineator_light.png",
	wield_image = "streets_roadwork_delineator_light.png",
	tile_images = {
		"streets_roadwork_delineator_top.png",
		"streets_tl_bg.png",
		"streets_roadwork_delineator_bottom_side.png",
		"streets_roadwork_delineator_bottom_side.png",
		"streets_roadwork_delineator_bottom_front_back.png^[transformFX",
		"streets_roadwork_delineator_bottom_front_back.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = { cracky = 1 },
	light_source = 5,
	node_box = {
		type = "fixed",
		fixed = {
			{ -1 / 4, -7 / 32, 0, 1 / 4, 1 / 2, 0 },
			{ -1 / 16, -5 / 16, -1 / 16, 1 / 16, -7 / 32, 1 / 16 },
			{ -1 / 8, -3 / 8, -1 / 8, 1 / 8, -5 / 16, 1 / 8 },
			{ -1 / 4, -1 / 2, -1 / 2, 1 / 4, -3 / 8, 1 / 2 }
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{ -1 / 4, -7 / 32, 0, 1 / 4, 11 / 8, 0 },
			{ -1 / 16, -5 / 16, -1 / 16, 1 / 16, -7 / 32, 1 / 16 },
			{ -1 / 8, -3 / 8, -1 / 8, 1 / 8, -5 / 16, 1 / 8 },
			{ -1 / 4, -1 / 2, -1 / 2, 1 / 4, -3 / 8, 1 / 2 }
		}
	},
	after_place_node = function(pos)
		local node = minetest.env:get_node(pos)
		node.name = "streets:roadwork_delineator_light_bottom"
		minetest.env:add_node(pos, node)
		pos.y = pos.y + 1
		node.name = "streets:roadwork_delineator_light_off_top"
		if minetest.get_item_group(minetest.get_node(pos).name, "airlike") > 0 then
			minetest.env:add_node(pos, node)
		end
	end,
	after_dig_node = function(pos)
		pos.y = pos.y + 1
		local nodename = minetest.get_node(pos).name
		if nodename == "streets:roadwork_delineator_light_on_top" or nodename == "streets:roadwork_delineator_light_off_top" then
			minetest.env:remove_node(pos)
		end
	end,
})

minetest.register_alias("streets:roadwork_delineator_light", "streets:roadwork_delineator_light_bottom")

minetest.register_craft({
	output = "streets:roadwork_delineator_light",
	recipe = {
		{ "streets:roadwork_blinking_light_off" },
		{ "streets:roadwork_delineator" }
	}
})

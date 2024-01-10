minetest.register_node("army:sandbag", {
	description = "Sandbags",
	drawtype = "normal",
	tiles = {"army_sandbag.png"},
	paramtype = "light",
	drop = "army:sandbag",
	groups = {crumbly=2, falling_node=1},

})

minetest.register_craft({
	output = "army:sandbag 12",
	recipe = {
		{"default:paper"},
		{"group:sand"},
	}
})

minetest.register_node("army:barbedwire", {
	description = "Barbed Wire",
	drawtype = "plantlike",
	visual_scale = 1.2,
	tiles = {"army_barbedwire.png"},
	inventory_image = "army_barbedwire.png",
	wield_image = "army_barbedwire.png",
	paramtype = "light",
	walkable = false,
	damage_per_second = 2,
	drop = "army:barbedwire",
	groups = {snappy=2},

})

minetest.register_craft({
	output = "army:barbedwire 12",
	recipe = {
		{"default:stick"},
		{"default:steel_ingot"},
	}
})

minetest.register_node("army:light",{
	description = "Bare Lightbulb",
	drawtype = "nodebox",
	sunlight_propagates = true,
	light_source = 13,
	tiles = {"army_bulbtop.png",
	         "army_bulbbase.png",
	         "army_bulbside.png"},
	groups = {oddly_breakable_by_hand=3},
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-1/16, 4/16, -1/16, 1/16, 8/16, 1/16}, --Screw
			{-2/16, 0/16, -2/16, 2/16, 4/16, 2/16}, --Bulb
		},
	},
})

minetest.register_craft({
	output = "army:light",
	recipe = {
		{"default:glass"},
		{"default:torch"},
		{"default:steel_ingot"},
	}
})

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

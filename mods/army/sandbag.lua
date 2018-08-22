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

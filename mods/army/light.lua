minetest.register_node("army:light",{
	description = "Bare Lightbulb",
	drawtype = "nodebox",
	sunlight_propagates = true,
	light_source = 14,
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

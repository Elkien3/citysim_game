local modpath, S = ...

minetest.register_node("petz:parchment", {
	description = S("Parchment"),
	inventory_image = "petz_parchment.png",
	tiles = {"petz_transparency.png"},
	groups = {snappy=1, bendy=2, cracky=1},
	sounds = default.node_sound_stone_defaults(),
	paramtype = "light",
	drawtype = "nodebox",
	node_box = {
		type = "wallmounted",
		wall_side= {
			{-0.5, -0.4375, 0.4375, 0.5, 0.375, 0.5},
			{-0.5, -0.4375, 0.3125, 0.5, 0.375, 0.375},
			{-0.5, -0.4375, 0.375, 0.5, -0.375, 0.4375},
			{-0.5, 0.3125, 0.375, 0.5, 0.375, 0.4375},
			{0.4375, -0.375, 0.375, 0.5, 0.3125, 0.4375},
			{-0.5, -0.375, 0.375, -0.4375, 0.3125, 0.4375},
			},
	},
	on_construct = function(pos)
		minetest.add_entity(pos, "petz:parchment_entity")
	end,
})

minetest.register_node("petz:parchment_bg", {
	tiles = {"petz_parchment_bg.png"},
	groups = {not_in_creative_inventory=1, snappy=1, bendy=2, cracky=1},
	paramtype = "light",
	drawtype = "nodebox",
	node_box = {
		type = "regular",
		wall_side= {
			{-0.5, -0.4375, 0.4375, 0.5, 0.375, 0.5},
			{-0.5, -0.4375, 0.3125, 0.5, 0.375, 0.375},
			{-0.5, -0.4375, 0.375, 0.5, -0.375, 0.4375},
			{-0.5, 0.3125, 0.375, 0.5, 0.375, 0.4375},
			{0.4375, -0.375, 0.375, 0.5, 0.3125, 0.4375},
			{-0.5, -0.375, 0.375, -0.4375, 0.3125, 0.4375},
			},
	},

})

minetest.register_entity("petz:parchment_entity", {
    physical = false,
    collisionbox = {-0.4375, -0.375, 0.5, 0.4375, 0.3125, 0.5},
    visual = "wielditem",
    visual_size = {x=1, y=1},
    mesh = "petz:parchment_bg",
    textures = {"petz_parchment_bg.png"},
    is_visible = true,
    makes_footstep_sound = false,
    automatic_rotate = 0,
})

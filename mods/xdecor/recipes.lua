minetest.register_craft({
	output = "xdecor:baricade 2",
	recipe = {
		{"group:stick", "", "group:stick"},
		{"", "default:steel_ingot", ""},
		{"group:stick", "", "group:stick"}
	}
})

minetest.register_craft({
	output = "xdecor:barrel",
	recipe = {
		{"group:wood", "group:wood", "group:wood"},
		{"default:iron_lump", "", "default:iron_lump"},
		{"group:wood", "group:wood", "group:wood"}
	}
})
--[[
minetest.register_craft({
	output = "xdecor:bowl 3",
	recipe = {
		{"group:wood", "", "group:wood"},
		{"", "group:wood", ""}
	}
})
--]]
minetest.register_craft({
	output = "xdecor:candle",
	recipe = {
		{"default:torch"}
	}
})

minetest.register_craft({
	output = "xdecor:cabinet",
	recipe = {
		{"group:wood", "group:wood", "group:wood"},
		{"doors:trapdoor", "", "doors:trapdoor"},
		{"group:wood", "group:wood", "group:wood"}
	}
})

minetest.register_craft({
	output = "xdecor:cabinet_half 2",
	recipe = {
		{"xdecor:cabinet"}
	}
})
--[[
minetest.register_craft({
	output = "xdecor:cactusbrick",
	recipe = {
		{"default:brick", "default:cactus"}
	}
})

minetest.register_craft({
	output = "xdecor:cauldron_empty",
	recipe = {
		{"default:iron_lump", "", "default:iron_lump"},
		{"default:iron_lump", "", "default:iron_lump"},
		{"default:iron_lump", "default:iron_lump", "default:iron_lump"}
	}
})--]]

minetest.register_craft({
	output = "realchess:chessboard",
	recipe = {
		{"dye:black", "dye:white", "dye:black"},
		{"stairs:slab_wood", "stairs:slab_wood", "stairs:slab_wood"}
	}
})

minetest.register_craft({
	output = "xdecor:chair",
	recipe = {
		{"group:stick", "", ""},
		{"group:stick", "default:wood", "group:stick"},
		{"group:stick", "", "group:stick"}
	}
})

minetest.register_craft({
	output = "xdecor:chair_pine",
	recipe = {
		{"group:stick", "", ""},
		{"group:stick", "default:pine_wood", "group:stick"},
		{"group:stick", "", "group:stick"}
	}
})

minetest.register_craft({
	output = "xdecor:chair_acacia",
	recipe = {
		{"group:stick", "", ""},
		{"group:stick", "default:acacia_wood", "group:stick"},
		{"group:stick", "", "group:stick"}
	}
})

minetest.register_craft({
	output = "xdecor:chair_aspen",
	recipe = {
		{"group:stick", "", ""},
		{"group:stick", "default:aspen_wood", "group:stick"},
		{"group:stick", "", "group:stick"}
	}
})

minetest.register_craft({
	output = "xdecor:chair_jungle",
	recipe = {
		{"group:stick", "", ""},
		{"group:stick", "default:junglewood", "group:stick"},
		{"group:stick", "", "group:stick"}
	}
})

minetest.register_craft({
	output = "xdecor:coalstone_tile 8",
	recipe = {
		{"default:stone", "default:stone", "default:stone"},
		{"default:stone", "default:coal_lump", "default:stone"},
		{"default:stone", "default:stone", "default:stone"}
	}
})

minetest.register_craft({
	output = "xdecor:cobweb 5",
	recipe = {
		{"farming:cotton", "", "farming:cotton"},
		{"", "farming:cotton", ""},
		{"farming:cotton", "", "farming:cotton"}
	}
})

minetest.register_craft({
	output = "xdecor:crafting_guide",
	type = "shapeless",
	recipe = {"default:book"}
})
--[[
minetest.register_craft({
	output = "xdecor:cushion 3",
	recipe = {
		{"wool:red", "wool:red", "wool:red"}
	}
})
--]]
minetest.register_craft({
	output = "xdecor:desertstone_tile 4",
	recipe = {
		{"default:desert_cobble", "default:desert_cobble"},
		{"default:desert_cobble", "default:desert_cobble"}
	}
})

minetest.register_craft({
	output = "xdecor:empty_shelf",
	recipe = {
		{"group:wood", "group:wood", "group:wood"},
		{"", "", ""},
		{"group:wood", "group:wood", "group:wood"}
	}
})
--[[
minetest.register_craft({
	output = "xdecor:enderchest",
	recipe = {
		{"", "default:obsidian", ""},
		{"default:obsidian", "default:chest", "default:obsidian"},
		{"", "default:obsidian", ""}
	}
})

minetest.register_craft({
	output = "xdecor:enchantment_table",
	recipe = {
		{"", "default:book", ""},
		{"default:diamond", "default:obsidian", "default:diamond"},
		{"default:obsidian", "default:obsidian", "default:obsidian"}
	}
})

minetest.register_craft({
	output = "xdecor:itemframe",
	recipe = {
		{"group:stick", "group:stick", "group:stick"},
		{"group:stick", "default:paper", "group:stick"},
		{"group:stick", "group:stick", "group:stick"}
	}
})

minetest.register_craft({
	output = "xdecor:hammer",
	recipe = {
		{"default:steel_ingot", "group:stick", "default:steel_ingot"},
		{"", "group:stick", ""}
	}
})
--]]
minetest.register_craft({
	output = "xdecor:hard_clay",
	recipe = {
		{"default:clay", "default:clay"},
		{"default:clay", "default:clay"}
	}
})
--[[
minetest.register_craft({
	output = "xdecor:hive",
	recipe = {
		{"group:stick", "group:stick", "group:stick"},
		{"default:paper", "default:paper", "default:paper"},
		{"group:stick", "group:stick", "group:stick"}
	}
})--]]

minetest.register_craft({
	output = "xdecor:iron_lightbox",
	recipe = {
		{"xpanes:bar_flat", "default:torch", "xpanes:bar_flat"},
		{"xpanes:bar_flat", "default:glass", "xpanes:bar_flat"},
		{"xpanes:bar_flat", "default:torch", "xpanes:bar_flat"}
	}
})

minetest.register_craft({
	output = "xdecor:ivy 4",
	recipe = {
		{"group:leaves"},
		{"group:leaves"}
	}
})

minetest.register_craft({
	output = "xdecor:lantern 2",
	recipe = {
		{"default:iron_lump"},
		{"default:torch"},
		{"default:iron_lump"}
	}
})
--[[
minetest.register_craft({
	output = "xdecor:lever_off",
	recipe = {
		{"group:stick"},
		{"group:stone"}
	}
})

minetest.register_craft({
	output = "xdecor:mailbox",
	recipe = {
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
		{"dye:red", "default:paper", "dye:red"},
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"}
	}
})
--]]
minetest.register_craft({
	output = "xdecor:smallbrick",
	recipe = {
		{"default:stonebrick"}
	}
})

minetest.register_craft({
	output = "default:stonebrick",
	recipe = {
		{"xdecor:smallbrick"}
	}
})

minetest.register_craft({
	output = "xdecor:multishelf",
	recipe = {
		{"group:wood", "group:wood", "group:wood"},
		{"group:vessel", "group:book", "group:vessel"},
		{"group:wood", "group:wood", "group:wood"}
	}
})

minetest.register_craft({
	output = "xdecor:packed_ice",
	recipe = {
		{"default:ice", "default:ice"},
		{"default:ice", "default:ice"}
	}
})

minetest.register_craft({
	output = "xdecor:painting_1",
	recipe = {
		{"default:sign_wall_wood", "dye:blue"}
	}
})
--[[
minetest.register_craft({
	output = "xdecor:pressure_stone_off",
	type = "shapeless",
	recipe = {"group:stone", "group:stone"}
})

minetest.register_craft({
	output = "xdecor:pressure_wood_off",
	type = "shapeless",
	recipe = {"group:wood", "group:wood"}
})
--]]
minetest.register_craft({
	output = "xdecor:rope 3",
	recipe = {
		{"farming:string"},
		{"farming:string"},
		{"farming:string"}
	}
})

minetest.register_craft({
	output = "xdecor:stone_tile 4",
	recipe = {
		{"default:cobble", "default:cobble"},
		{"default:cobble", "default:cobble"}
	}
})

minetest.register_craft({
	output = "xdecor:stone_rune 8",
	recipe = {
		{"default:stone", "default:stone", "default:stone"},
		{"default:stone", "", "default:stone"},
		{"default:stone", "default:stone", "default:stone"}
	}
})

minetest.register_craft({
	output = "xdecor:stonepath 16",
	recipe = {
		{"stairs:slab_cobble", "", "stairs:slab_cobble"},
		{"", "stairs:slab_cobble", ""},
		{"stairs:slab_cobble", "", "stairs:slab_cobble"}
	}
})

minetest.register_craft({
	output = "xdecor:table",
	recipe = {
		{"stairs:slab_wood", "stairs:slab_wood", "stairs:slab_wood"},
		{"", "group:stick", ""},
		{"", "group:stick", ""}
	}
})

minetest.register_craft({
	output = "xdecor:table_aspen",
	recipe = {
		{"stairs:slab_aspen_wood", "stairs:slab_aspen_wood", "stairs:slab_aspen_wood"},
		{"", "group:stick", ""},
		{"", "group:stick", ""}
	}
})

minetest.register_craft({
	output = "xdecor:table_jungle",
	recipe = {
		{"stairs:slab_junglewood", "stairs:slab_junglewood", "stairs:slab_junglewood"},
		{"", "group:stick", ""},
		{"", "group:stick", ""}
	}
})

minetest.register_craft({
	output = "xdecor:table_pine",
	recipe = {
		{"stairs:slab_pine_wood", "stairs:slab_pine_wood", "stairs:slab_pine_wood"},
		{"", "group:stick", ""},
		{"", "group:stick", ""}
	}
})

minetest.register_craft({
	output = "xdecor:table_acacia",
	recipe = {
		{"stairs:slab_acacia_wood", "stairs:slab_acacia_wood", "stairs:slab_acacia_wood"},
		{"", "group:stick", ""},
		{"", "group:stick", ""}
	}
})

minetest.register_craft({
	output = "xdecor:tatami 3",
	recipe = {
		{"farming:wheat", "farming:wheat", "farming:wheat"}
	}
})
--[[
minetest.register_craft({
	output = "xdecor:tv",
	recipe = {
		{"default:steel_ingot", "default:copper_ingot", "default:steel_ingot"},
		{"default:steel_ingot", "default:glass", "default:steel_ingot"},
		{"default:steel_ingot", "default:copper_ingot", "default:steel_ingot"}
	}
})

minetest.register_craft({
	output = "xdecor:workbench",
	recipe = {
		{"group:wood", "group:wood"},
		{"group:wood", "group:wood"}
	}
})
	--]]
minetest.register_craft({
	output = "xdecor:woodframed_glass",
	recipe = {
		{"group:stick", "group:stick", "group:stick"},
		{"group:stick", "default:glass", "group:stick"},
		{"group:stick", "group:stick", "group:stick"}
	}
})

minetest.register_craft({
	output = "xdecor:wood_tile 4",
	recipe = {
		{"", "group:wood", ""},
		{"group:wood", "", "group:wood"},
		{"", "group:wood", ""}
	}
})

minetest.register_craft({
	output = "xdecor:wooden_lightbox",
	recipe = {
		{"group:stick", "default:torch", "group:stick"},
		{"group:stick", "default:glass", "group:stick"},
		{"group:stick", "default:torch", "group:stick"}
	}
})


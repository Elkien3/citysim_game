local modpath, S = ...

--Bonemeal support

minetest.register_craft({
	type = "shapeless",
	output = "bonemeal:bonemeal",
	recipe = {"petz:bone"},
})

minetest.register_craft({
	output = "bonemeal:gelatin_powder 4",
	recipe = {
			{"petz:bone", "petz:bone", "petz:bone"},
			{"bucket:bucket_water", "bucket:bucket_water", "bucket:bucket_water"},
			{"bucket:bucket_water", "default:torch", "bucket:bucket_water"},
	},
	replacements = {
		{"bucket:bucket_water", "bucket:bucket_empty 5"},
	},
})

minetest.register_craft({
	type = "shapeless",
	output = "petz:bone 2",
	recipe = {"bonemeal:bone"},
})

minetest.register_craft({
	type = "shapeless",
	output = "bonemeal:mulch",
	recipe = {"petz:poop"},
})

-- Metal bed

beds.register_bed("bed_metal:bed", {
	description = ("Metal Bed"),
	inventory_image = "metal_bed_inv.png",
	wield_image = "metal_bed_inv.png",
	tiles = {
		bottom = {
			"metal_bed_top1.png",
			"metal_bed_under.png",
			"metal_bed_side1.png",
			"metal_bed_side1.png^[transformFX",
			"metal_bed_foot.png",
			"metal_bed_foot.png",
		},
		top = {
			"metal_bed_top2.png",
			"metal_bed_under.png",
			"metal_bed_side2.png",
			"metal_bed_side2.png^[transformFX",
			"metal_bed_head.png",
			"metal_bed_head.png",
		}
	},
	nodebox = {
		bottom = {
			{-0.5, -0.5, -0.5, -0.375, -0.065, -0.4375},
			{0.375, -0.5, -0.5, 0.5, -0.065, -0.4375},
			{-0.5, -0.375, -0.5, 0.5, -0.125, -0.4375},
			{-0.5, -0.375, -0.5, -0.4375, -0.125, 0.5},
			{0.4375, -0.375, -0.5, 0.5, -0.125, 0.5},
			{-0.4375, -0.3125, -0.4375, 0.4375, -0.0625, 0.5},
		},
		top = {
			{-0.5, -0.5, 0.4375, -0.375, 0.1875, 0.5},
			{0.375, -0.5, 0.4375, 0.5, 0.1875, 0.5},
			{-0.5, 0, 0.4375, 0.5, 0.125, 0.5},
			{-0.5, -0.375, 0.4375, 0.5, -0.125, 0.5},
			{-0.5, -0.375, -0.5, -0.4375, -0.125, 0.5},
			{0.4375, -0.375, -0.5, 0.5, -0.125, 0.5},
			{-0.4375, -0.3125, -0.5, 0.4375, -0.0625, 0.4375},
		}
	},
	selectionbox = {-0.5, -0.5, -0.5, 0.5, 0.06, 1.5},
	groups = {cracky = 1, level = 2, bed = 1},
	recipe = {
		{"", "", "default:steel_ingot"},
		{"wool:white", "wool:white", "wool:white"},
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
	},
})
minetest.override_item('bed_metal:bed_top', {
	groups = {cracky = 1, level = 2, bed = 1}
})
minetest.override_item('bed_metal:bed_bottom', {
	groups = {cracky = 1, level = 2, bed = 1}
})
minetest.register_tool("drug_wars:machete_steel", {
	description = "Steel Machete",
	inventory_image = "drugwars_steel_machete.png",
	tool_capabilities = {
		full_punch_interval = 0.7,
		max_drop_level=1,
		groupcaps={
			snappy={times={[1]=2.0, [2]=1.00, [3]=0.35}, uses=20, maxlevel=3},
			plant={times={[1]=0.40, [2]=0.20, [3]=0.10}, uses=50, maxlevel=3}
		},
		damage_groups = {fleshy=4},
	},
	sound = {breaks = "default_tool_breaks"},
})

minetest.register_craft({
	output = "drug_wars:machete_steel",
	recipe = {
        {"", "default:steel_ingot", "default:steel_ingot"},
        {"", "default:steel_ingot", ""},
        {"", "default:stick", ""}
    }
})

minetest.register_tool("drug_wars:machete_mese", {
	description = "Mese Machete",
	inventory_image = "drugwars_mese_machete.png",
	tool_capabilities = {
		full_punch_interval = 0.7,
		max_drop_level=1,
		groupcaps={
			snappy={times={[1]=1.8, [2]=0.80, [3]=0.35}, uses=30, maxlevel=3},
			plant={times={[1]=0.25, [2]=0.15, [3]=0.05}, uses=80, maxlevel=3}

		},
		damage_groups = {fleshy=5},
	},
	sound = {breaks = "default_tool_breaks"},
})

minetest.register_craft({
	output = "drug_wars:machete_mese",
	recipe = {
        {"", "default:mese_crystal", "default:mese_crystal"},
        {"", "default:mese_crystal", ""},
        {"", "default:stick", ""}
    }
})
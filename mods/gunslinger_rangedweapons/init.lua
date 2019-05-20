minetest.register_alias("shooter:rifle", "gunslinger_rangedweapons:ak47")
minetest.register_alias("shooter:pistol", "gunslinger_rangedweapons:glock17")
minetest.register_alias("shooter:shotgun", "gunslinger_rangedweapons:benelli")
minetest.register_alias("shooter:machine_gun", "gunslinger_rangedweapons:uzi")
minetest.register_alias("shooter:ammo", "default:bronze_ingot")

--Automatic Rifles

gunslinger.register_gun("gunslinger_rangedweapons:ak47", {
	itemdef = {
		description = "AK-47 Rifle",
		inventory_image = "rangedweapons_ak47.png",
		wield_image = "rangedweapons_ak47.png",
		--wield_scale = {x = 4, y = 4, z = 1}
	},

	mode = "automatic",
	base_dmg = 7,
	fire_rate = 7,
	clip_size = 30,
	range = 200,
	base_spread = 7,
	max_spread = 200,
	magazine = true,
	ammo = "gunslinger_rangedweapons:mag_ak47",
	fire_sound = "rangedweapons_smg"
})
minetest.register_craft({
	output = 'gunslinger_rangedweapons:ak47 1 65534',
	recipe = {
		{'default:diamond', 'default:steel_ingot', 'default:tree'},
		{'default:tree', 'default:mese', 'default:steel_ingot'},
		{'default:steel_ingot', '', 'default:tree'},
	}
})

gunslinger.register_gun("gunslinger_rangedweapons:g36", {
	itemdef = {
		description = "G36 Rifle",
		inventory_image = "rangedweapons_g36.png",
		wield_image = "rangedweapons_g36.png",
		--wield_scale = {x = 4, y = 4, z = 1}
	},

	mode = "automatic",
	base_dmg = 6,
	fire_rate = 8,
	clip_size = 30,
	range = 200,
	base_spread = 2,
	max_spread = 150,
	magazine = true,
	--vertical_recoil = 10,
	--horizontal_recoil = 10,
	ammo = "gunslinger_rangedweapons:mag_stanag",
	fire_sound = "rangedweapons_smg"
})
minetest.register_craft({
	output = 'gunslinger_rangedweapons:g36 1 65534',
	recipe = {
		{'default:diamond', 'default:mese', 'default:diamond'},
		{'default:steel_ingot', 'default:diamond', 'default:steel_ingot'},
		{'default:steel_ingot', '', 'default:steel_ingot'},
	}
})

gunslinger.register_gun("gunslinger_rangedweapons:m16", {
	itemdef = {
		description = "M16 Rifle",
		inventory_image = "rangedweapons_m16.png",
		wield_image = "rangedweapons_m16.png",
		--wield_scale = {x = 4, y = 4, z = 1}
	},

	mode = "automatic",
	base_dmg = 6,
	fire_rate = 8,
	clip_size = 30,
	range = 200,
	base_spread = 5,
	max_spread = 200,
	magazine = true,
	--vertical_recoil = 10,
	--horizontal_recoil = 10,
	ammo = "gunslinger_rangedweapons:mag_stanag",
	fire_sound = "rangedweapons_smg"
})
minetest.register_craft({
	output = 'gunslinger_rangedweapons:m16 1 65534',
	recipe = {
		{'default:diamond', 'default:steelblock', 'default:steel_ingot'},
		{'default:steel_ingot', 'default:diamond', 'default:steel_ingot'},
		{'default:steel_ingot', '', 'default:steel_ingot'},
	}
})

gunslinger.register_gun("gunslinger_rangedweapons:scar", {
	itemdef = {
		description = "SCAR Rifle",
		inventory_image = "rangedweapons_scar.png",
		wield_image = "rangedweapons_scar.png",
		--wield_scale = {x = 4, y = 4, z = 1}
	},

	mode = "automatic",
	base_dmg = 6,
	fire_rate = 9,
	clip_size = 30,
	range = 200,
	base_spread = 3,
	max_spread = 150,
	magazine = true,
	--vertical_recoil = 10,
	--horizontal_recoil = 10,
	ammo = "gunslinger_rangedweapons:mag_stanag",
	fire_sound = "rangedweapons_smg"
})
minetest.register_craft({
	output = 'gunslinger_rangedweapons:scar 1 65534',
	recipe = {
		{'default:diamond', 'default:mese_crystal', 'default:mese_crystal'},
		{'default:steel_ingot', 'default:steel_ingot', 'default:mese_crystal'},
		{'homedecor:plastic_sheeting', '', 'default:mese_crystal'},
	}
})

--Submachine Guns

gunslinger.register_gun("gunslinger_rangedweapons:vector", {
	itemdef = {
		description = "Vector Submachinegun",
		inventory_image = "rangedweapons_kriss_sv.png",
		wield_image = "rangedweapons_kriss_sv.png",
		--wield_scale = {x = 4, y = 4, z = 1}
	},

	mode = "automatic",
	base_dmg = 4,
	fire_rate = 10,
	clip_size = 30,
	range = 150,
	base_spread = 10,
	max_spread = 100,
	magazine = true,
	ammo = "gunslinger_rangedweapons:mag_smg",
	fire_sound = "rangedweapons_smg"
})
minetest.register_craft({
	output = 'gunslinger_rangedweapons:vector 1 65534',
	recipe = {
		{'homedecor:plastic_sheeting', 'homedecor:plastic_sheeting', 'homedecor:plastic_sheeting'},
		{'default:gold_ingot', 'default:mese_crystal', 'homedecor:plastic_sheeting'},
		{'homedecor:plastic_sheeting', 'default:gold_ingot', ''},
	}
})

gunslinger.register_gun("gunslinger_rangedweapons:mp5", {
	itemdef = {
		description = "MP5 Submachinegun",
		inventory_image = "rangedweapons_mp5.png",
		wield_image = "rangedweapons_mp5.png",
		--wield_scale = {x = 4, y = 4, z = 1}
	},

	mode = "automatic",
	base_dmg = 5,
	fire_rate = 8,
	clip_size = 30,
	range = 150,
	base_spread = 20,
	max_spread = 100,
	magazine = true,
	ammo = "gunslinger_rangedweapons:mag_smg",
	fire_sound = "rangedweapons_smg"
})
minetest.register_craft({
	output = 'gunslinger_rangedweapons:mp5 1 65534',
	recipe = {
		{'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'},
		{'default:steel_ingot', 'default:diamond', 'default:steel_ingot'},
		{'default:steel_ingot', 'homedecor:plastic_sheeting', 'dye:black'},
	}
})

gunslinger.register_gun("gunslinger_rangedweapons:mp40", {
	itemdef = {
		description = "MP40 Submachinegun",
		inventory_image = "rangedweapons_mp40.png",
		wield_image = "rangedweapons_mp40.png",
		--wield_scale = {x = 4, y = 4, z = 1}
	},

	mode = "automatic",
	base_dmg = 8,
	fire_rate = 6,
	clip_size = 30,
	range = 150,
	base_spread = 30,
	max_spread = 100,
	magazine = true,
	ammo = "gunslinger_rangedweapons:mag_smg",
	fire_sound = "rangedweapons_smg"
})
minetest.register_craft({
	output = 'gunslinger_rangedweapons:mp40 1 65534',
	recipe = {
		{'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'},
		{'default:steel_ingot', 'default:mese_crystal', 'default:steel_ingot'},
		{'default:steel_ingot', 'default:mese_crystal_fragment', ''},
	}
})

gunslinger.register_gun("gunslinger_rangedweapons:ump", {
	itemdef = {
		description = "UMP Submachinegun",
		inventory_image = "rangedweapons_ump.png",
		wield_image = "rangedweapons_ump.png",
		--wield_scale = {x = 4, y = 4, z = 1}
	},

	mode = "automatic",
	base_dmg = 4,
	fire_rate = 7,
	clip_size = 30,
	range = 150,
	base_spread = 15,
	max_spread = 120,
	magazine = true,
	ammo = "gunslinger_rangedweapons:mag_smg",
	fire_sound = "rangedweapons_smg"
})
minetest.register_craft({
	output = 'gunslinger_rangedweapons:ump 1 65534',
	recipe = {
		{'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'},
		{'default:steel_ingot', 'default:diamond', 'default:steel_ingot'},
		{'default:steel_ingot', '', 'default:steel_ingot'},
	}
})

gunslinger.register_gun("gunslinger_rangedweapons:uzi", {
	itemdef = {
		description = "UZI Submachinegun",
		inventory_image = "rangedweapons_uzi.png",
		wield_image = "rangedweapons_uzi.png",
		--wield_scale = {x = 4, y = 4, z = 1}
	},

	mode = "automatic",
	base_dmg = 4,
	fire_rate = 9,
	clip_size = 30,
	range = 150,
	base_spread = 20,
	max_spread = 80,
	magazine = true,
	magazine = true,
	ammo = "gunslinger_rangedweapons:mag_smg",
	fire_sound = "rangedweapons_smg"
})
minetest.register_craft({
	output = 'gunslinger_rangedweapons:uzi 1 65534',
	recipe = {
		{'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'},
		{'default:diamond', 'homedecor:plastic_sheeting', 'default:steel_ingot'},
		{'', 'default:steel_ingot', ''},
	}
})

--Machineguns

gunslinger.register_gun("gunslinger_rangedweapons:m60", {
	itemdef = {
		description = "M60 Machinegun",
		inventory_image = "rangedweapons_m60.png",
		wield_image = "rangedweapons_m60.png",
		--wield_scale = {x = 4, y = 4, z = 1}
	},

	mode = "automatic",
	base_dmg = 6,
	fire_rate = 7,
	clip_size = 100,
	range = 150,
	base_spread = 10,
	max_spread = 200,
	vertical_recoil = 10,
	horizontal_recoil = 4,
	magazine = true,
	ammo = "gunslinger_rangedweapons:mag_m60",
	fire_sound = "rangedweapons_machinegun"
})
minetest.register_craft({
	output = 'gunslinger_rangedweapons:m60 1 65534',
	recipe = {
		{'default:diamond', 'default:steel_ingot', 'default:mese'},
		{'default:steel_ingot', 'default:steelblock', 'default:steelblock'},
		{'dye:black', 'default:diamond', 'default:steel_ingot'},
	}
})

gunslinger.register_gun("gunslinger_rangedweapons:rpk", {
	itemdef = {
		description = "RPK Machinegun",
		inventory_image = "rangedweapons_rpk.png",
		wield_image = "rangedweapons_rpk.png",
		--wield_scale = {x = 4, y = 4, z = 1}
	},

	mode = "automatic",
	base_dmg = 6,
	fire_rate = 8,
	clip_size = 100,
	range = 150,
	base_spread = 15,
	max_spread = 200,
	vertical_recoil = 12,
	horizontal_recoil = 5,
	magazine = true,
	ammo = "gunslinger_rangedweapons:mag_rpk",
	fire_sound = "rangedweapons_machinegun"
})
minetest.register_craft({
	output = 'gunslinger_rangedweapons:rpk 1 65534',
	recipe = {
		{'default:diamond', 'default:mese', ''},
		{'default:steel_ingot', 'default:steelblock', 'default:tree'},
		{'', 'default:diamond', 'default:steel_ingot'},
	}
})

--Shotguns

gunslinger.register_gun("gunslinger_rangedweapons:benelli", {
	itemdef = {
		description = "Benelli Shotgun",
		inventory_image = "rangedweapons_benelli.png",
		wield_image = "rangedweapons_benelli.png",
		--wield_scale = {x = 4, y = 4, z = 1}
	},

	mode = "semi-automatic",
	base_dmg = 3,
	fire_rate = 4,
	clip_size = 8,
	range = 100,
	base_spread = 40,
	max_spread = 60,
	pellets = 6,
	vertical_recoil = 80,
	horizontal_recoil = 40,
	ammo = "gunslinger_rangedweapons:bullet_12g 8",
	fire_sound = "rangedweapons_shotgun_shot"
})
minetest.register_craft({
	output = "gunslinger_rangedweapons:benelli 1 65534",
	recipe = {
		{"default:steel_ingot", "default:diamond", "default:steelblock"},
		{"homedecor:plastic_sheeting", "default:diamond", "default:steel_ingot"},
	}
})

gunslinger.register_gun("gunslinger_rangedweapons:remington", {
	itemdef = {
		description = "Remington Shotgun",
		inventory_image = "rangedweapons_remington.png",
		wield_image = "rangedweapons_remington.png",
		--wield_scale = {x = 4, y = 4, z = 1}
	},

	mode = "manual",
	base_dmg = 3,
	fire_rate = 1,
	clip_size = 1,
	range = 100,
	base_spread = 50,
	max_spread = 100,
	pellets = 6,
	vertical_recoil = 80,
	horizontal_recoil = 40,
	ammo = "gunslinger_rangedweapons:bullet_12g",
	fire_sound = "rangedweapons_shotgun_shot"
})
minetest.register_craft({
	output = "gunslinger_rangedweapons:remington 1 65534",
	recipe = {
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
		{"default:tree", "default:mese_crystal", "default:tree"},
	}
})

gunslinger.register_gun("gunslinger_rangedweapons:spas12", {
	itemdef = {
		description = "SPAS12 Shotgun",
		inventory_image = "rangedweapons_spas12.png",
		wield_image = "rangedweapons_spas12.png",
		--wield_scale = {x = 4, y = 4, z = 1}
	},

	mode = "semi-automatic",
	base_dmg = 4,
	fire_rate = 4,
	clip_size = 8,
	range = 100,
	base_spread = 50,
	max_spread = 100,
	pellets = 6,
	vertical_recoil = 100,
	horizontal_recoil = 50,
	ammo = "gunslinger_rangedweapons:bullet_12g 8",
	fire_sound = "rangedweapons_shotgun_shot"
})
minetest.register_craft({
	output = "gunslinger_rangedweapons:spas12 1 65534",
	recipe = {
		{"", "default:steel_ingot", "default:steel_ingot"},
		{"default:steel_ingot", "default:mese", "default:diamond"},
		{"homedecor:plastic_sheeting", "default:diamond", "default:steel_ingot"},
	}
})

--Sniper Rifles

gunslinger.register_gun("gunslinger_rangedweapons:awp", {
	itemdef = {
		description = "AWP Sniper Rifle",
		inventory_image = "rangedweapons_awp.png",
		wield_image = "rangedweapons_awp.png",
		--wield_scale = {x = 4, y = 4, z = 1}
	},

	mode = "manual",
	base_dmg = 18,
	fire_rate = 1,
	clip_size = 1,
	range = 300,
	base_spread = 0,
	max_spread = 200,
	vertical_recoil = 100,
	horizontal_recoil = 10,
	zoom = 10,
	scope = "firearms_crosshair_sniper_scope.png",
	ammo = "gunslinger_rangedweapons:bullet_308mm",
	fire_sound = "rangedweapons_rifle_a"
})
minetest.register_craft({
	output = 'gunslinger_rangedweapons:awp 1 65534',
	recipe = {
		{'default:steel_ingot', 'default:diamondblock', 'default:steel_ingot'},
		{'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'},
		{'dye:dark_green', 'default:diamond', 'homedecor:plastic_sheeting'},
	}
})

gunslinger.register_gun("gunslinger_rangedweapons:m200", {
	itemdef = {
		description = "M200 Sniper Rifle",
		inventory_image = "rangedweapons_m200.png",
		wield_image = "rangedweapons_m200.png",
		--wield_scale = {x = 4, y = 4, z = 1}
	},

	mode = "semi-automatic",
	base_dmg = 15,
	fire_rate = 4,
	clip_size = 10,
	range = 300,
	base_spread = 1,
	max_spread = 200,
	vertical_recoil = 80,
	horizontal_recoil = 8,
	magazine = true,
	zoom = 15,
	scope = "firearms_crosshair_sniper_scope.png",
	ammo = "gunslinger_rangedweapons:mag_sniper",
	fire_sound = "rangedweapons_rifle_b"
})
minetest.register_craft({
	output = 'gunslinger_rangedweapons:m200 1 65534',
	recipe = {
		{'default:diamondblock', 'default:steel_ingot', 'default:diamondblock'},
		{'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'},
		{'default:steel_ingot', 'default:diamond', 'default:steel_ingot'},
	}
})

gunslinger.register_gun("gunslinger_rangedweapons:svd", {
	itemdef = {
		description = "SVD Sniper Rifle",
		inventory_image = "rangedweapons_svd.png",
		wield_image = "rangedweapons_svd.png",
		--wield_scale = {x = 4, y = 4, z = 1}
	},

	mode = "semi-automatic",
	base_dmg = 15,
	fire_rate = 4,
	clip_size = 10,
	range = 300,
	base_spread = 1,
	max_spread = 200,
	vertical_recoil = 80,
	horizontal_recoil = 8,
	magazine = true,
	zoom = 15,
	scope = "firearms_crosshair_sniper_scope.png",
	ammo = "gunslinger_rangedweapons:mag_sniper",
	fire_sound = "rangedweapons_rifle_b"
})
minetest.register_craft({
	output = 'gunslinger_rangedweapons:svd 1 65534',
	recipe = {
		{'default:steel_ingot', 'default:diamondblock', 'default:steel_ingot'},
		{'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'},
		{'default:tree', 'default:diamond', 'default:tree'},
	}
})

--Pistols

gunslinger.register_gun("gunslinger_rangedweapons:beretta", {
	itemdef = {
		description = "Beretta Pistol",
		inventory_image = "rangedweapons_beretta.png",
		wield_image = "rangedweapons_beretta.png",
		--wield_scale = {x = 4, y = 4, z = 1}
	},

	mode = "semi-automatic",
	base_dmg = 5,
	fire_rate = 5,
	clip_size = 15,
	range = 200,
	base_spread = 15,
	max_spread = 80,
	magazine = true,
	ammo = "gunslinger_rangedweapons:mag_9mm",
	fire_sound = "rangedweapons_beretta"
})
minetest.register_craft({
	output = 'gunslinger_rangedweapons:beretta 1 65534',
	recipe = {
		{'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'},
		{'', 'default:mese_crystal', 'homedecor:plastic_sheeting'},
		{'', '', 'homedecor:plastic_sheeting'},
	}
})

gunslinger.register_gun("gunslinger_rangedweapons:glock17", {
	itemdef = {
		description = "Glock 17 Pistol",
		inventory_image = "rangedweapons_glock17.png",
		wield_image = "rangedweapons_glock17.png",
		--wield_scale = {x = 4, y = 4, z = 1}
	},

	mode = "semi-automatic",
	base_dmg = 5,
	fire_rate = 6,
	clip_size = 15,
	range = 200,
	base_spread = 15,
	max_spread = 80,
	magazine = true,
	ammo = "gunslinger_rangedweapons:mag_9mm",
	fire_sound = "rangedweapons_glock"
})
minetest.register_craft({
	output = 'gunslinger_rangedweapons:glock17 1 65534',
	recipe = {
		{'homedecor:plastic_sheeting', 'homedecor:plastic_sheeting', 'homedecor:plastic_sheeting'},
		{'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'},
		{'', 'default:diamond', 'homedecor:plastic_sheeting'},
	}
})

gunslinger.register_gun("gunslinger_rangedweapons:makarov", {
	itemdef = {
		description = "Makarov Pistol",
		inventory_image = "rangedweapons_makarov.png",
		wield_image = "rangedweapons_makarov.png",
		--wield_scale = {x = 4, y = 4, z = 1}
	},

	mode = "semi-automatic",
	base_dmg = 4,
	fire_rate = 6,
	clip_size = 7,
	range = 200,
	base_spread = 20,
	max_spread = 80,
	magazine = true,
	ammo = "gunslinger_rangedweapons:mag_makarov",
	fire_sound = "rangedweapons_makarov"
})
minetest.register_craft({
	output = 'gunslinger_rangedweapons:makarov 1 65534',
	recipe = {
		{'', 'default:steel_ingot', 'default:steel_ingot'},
		{'', 'default:mese_crystal_fragment', 'default:tree'},
		{'', '', 'dye:black'},
	}
})

gunslinger.register_gun("gunslinger_rangedweapons:tec9", {
	itemdef = {
		description = "Tec9 Pistol",
		inventory_image = "rangedweapons_tec9.png",
		wield_image = "rangedweapons_tec9.png",
		--wield_scale = {x = 4, y = 4, z = 1}
	},

	mode = "semi-automatic",
	base_dmg = 4,
	fire_rate = 8,
	clip_size = 30,
	range = 200,
	base_spread = 30,
	max_spread = 80,
	magazine = true,
	ammo = "gunslinger_rangedweapons:mag_smg",
	fire_sound = "rangedweapons_machine_pistol"
})
minetest.register_craft({
	output = 'gunslinger_rangedweapons:tec9 1 65534',
	recipe = {
		{'homedecor:plastic_sheeting', 'homedecor:plastic_sheeting', 'homedecor:plastic_sheeting'},
		{'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'},
		{'default:steel_ingot', 'default:mese_crystal_fragment', 'default:steel_ingot'},
	}
})

gunslinger.register_gun("gunslinger_rangedweapons:luger", {
	itemdef = {
		description = "Luger Pistol",
		inventory_image = "rangedweapons_luger.png",
		wield_image = "rangedweapons_luger.png",
		--wield_scale = {x = 4, y = 4, z = 1}
	},

	mode = "semi-automatic",
	base_dmg = 4,
	fire_rate = 4,
	clip_size = 7,
	range = 200,
	base_spread = 20,
	max_spread = 80,
	magazine = true,
	ammo = "gunslinger_rangedweapons:mag_makarov",
	fire_sound = "rangedweapons_makarov"
})
minetest.register_craft({
	output = 'gunslinger_rangedweapons:luger 1 65534',
	recipe = {
		{'', 'default:steel_ingot', 'default:steel_ingot'},
		{'', '', 'default:tree'},
		{'', '', ''},
	}
})

gunslinger.register_gun("gunslinger_rangedweapons:python", {
	itemdef = {
		description = "Python Revolver",
		inventory_image = "rangedweapons_python.png",
		wield_image = "rangedweapons_python.png",
		--wield_scale = {x = 4, y = 4, z = 1}
	},

	mode = "manual",
	base_dmg = 10,
	fire_rate = 4,
	clip_size = 1,
	range = 200,
	base_spread = 15,
	max_spread = 80,
	vertical_recoil = 80,
	horizontal_recoil = 40,
	ammo = "gunslinger_rangedweapons:bullet_357",
	fire_sound = "rangedweapons_revolver"
})
minetest.register_craft({
	output = 'gunslinger_rangedweapons:python 1 65534',
	recipe = {
{'moreores:silver_ingot', 'default:diamond', 'default:mese_crystal_fragment'},
{'moreores:silver_ingot', 'default:diamond', 'moreores:silver_ingot'},
		{'', 'default:mese_crystal', 'default:tree'},
	}
})

gunslinger.register_gun("gunslinger_rangedweapons:deagle", {
	itemdef = {
		description = "Desert Eagle Pistol",
		inventory_image = "rangedweapons_deagle.png",
		wield_image = "rangedweapons_deagle.png",
		--wield_scale = {x = 4, y = 4, z = 1}
	},

	mode = "semi-automatic",
	base_dmg = 8,
	fire_rate = 4,
	clip_size = 9,
	range = 200,
	base_spread = 15,
	max_spread = 80,
	vertical_recoil = 80,
	horizontal_recoil = 40,
	magazine = true,
	ammo = "gunslinger_rangedweapons:mag_deagle",
	fire_sound = "rangedweapons_deagle"
})
minetest.register_craft({
	output = 'gunslinger_rangedweapons:deagle',
	recipe = {
		{'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'},
		{'default:steel_ingot', 'default:diamond', 'homedecor:plastic_sheeting'},
		{'', '', 'homedecor:plastic_sheeting'},
	}
})

--Bullets

minetest.register_craftitem("gunslinger_rangedweapons:bullet_556mm", {
	description = "5.56mm Rifle round",
	inventory_image = "rangedweapons_556mm.png",
})
minetest.register_craft({
	output = 'gunslinger_rangedweapons:bullet_556mm 75',
	recipe = {
		{'', 'default:gold_ingot', ''},
		{'default:gold_ingot', 'tnt:gunpowder', 'default:gold_ingot'},
		{'default:gold_ingot', 'tnt:gunpowder', 'default:gold_ingot'},
	}
})

minetest.register_craftitem("gunslinger_rangedweapons:bullet_12g", {
	description = "12 Gauge Buckshot",
	inventory_image = "rangedweapons_12g.png",
})
minetest.register_craft({
	output = 'gunslinger_rangedweapons:bullet_12g 12',
	recipe = {
		{'default:bronze_ingot', 'default:steel_ingot', 'default:bronze_ingot'},
		{'default:bronze_ingot', 'tnt:gunpowder', 'default:bronze_ingot'},
		{'default:gold_ingot', 'tnt:gunpowder', 'default:gold_ingot'},
	}
})

minetest.register_craftitem("gunslinger_rangedweapons:bullet_9mm", {
	description = "9mm Pistol round",
	inventory_image = "rangedweapons_9mm.png",
})
minetest.register_craft({
	output = 'gunslinger_rangedweapons:bullet_9mm 30',
	recipe = {
		{'default:steel_ingot', '', ''},
		{'tnt:gunpowder', '', ''},
		{'default:copper_ingot', '', ''},
	}
})

minetest.register_craftitem("gunslinger_rangedweapons:bullet_357", {
	description = ".357 Heavy Pistol round",
	inventory_image = "rangedweapons_357.png",
})
minetest.register_craft({
	output = 'gunslinger_rangedweapons:bullet_357 15',
	recipe = {
		{'default:copper_ingot', '', ''},
		{'tnt:gunpowder', '', ''},
		{'default:gold_ingot', '', ''},
	}
})

minetest.register_craftitem("gunslinger_rangedweapons:bullet_10mm", {
	description = "10mm Submachinegun round",
	inventory_image = "rangedweapons_10mm.png",
})
minetest.register_craft({
	output = 'gunslinger_rangedweapons:bullet_10mm 60',
	recipe = {
		{'', 'default:bronze_ingot', ''},
		{'default:steel_ingot', 'tnt:gunpowder', 'default:steel_ingot'},
		{'default:steel_ingot', 'tnt:gunpowder', 'default:steel_ingot'},
	}
})

minetest.register_craftitem("gunslinger_rangedweapons:bullet_762mm", {
	description = "7.62mm Heavy Rifle round",
	inventory_image = "rangedweapons_762mm.png",
})
minetest.register_craft({
	output = 'gunslinger_rangedweapons:bullet_762mm 50',
	recipe = {
		{'default:bronze_ingot', 'tnt:gunpowder', 'default:bronze_ingot'},
		{'default:gold_ingot', 'tnt:gunpowder', 'default:gold_ingot'},
		{'default:gold_ingot', 'tnt:gunpowder', 'default:gold_ingot'},
	}
})

minetest.register_craftitem("gunslinger_rangedweapons:bullet_308mm", {
	description = ".308mm Sniper Rifle round",
	inventory_image = "rangedweapons_308winchester.png",
})
minetest.register_craft({
	output = 'gunslinger_rangedweapons:bullet_308mm 15',
	recipe = {
		{'', 'default:steel_ingot', ''},
		{'default:bronze_ingot', 'tnt:gunpowder', 'default:bronze_ingot'},
		{'default:gold_ingot', 'tnt:gunpowder', 'default:gold_ingot'},
	}
})

--Magazines

minetest.register_tool("gunslinger_rangedweapons:mag_stanag", {
	description = "STANAG Magazine",
	inventory_image = "rangedweapons_stanag_mag.png",
})
gunslinger.register_magazine("gunslinger_rangedweapons:mag_stanag", "gunslinger_rangedweapons:bullet_556mm", 30)
minetest.register_craft({
	output = 'gunslinger_rangedweapons:mag_stanag 1 65534',
	recipe = {
		{'homedecor:plastic_sheeting', '', 'homedecor:plastic_sheeting'},
		{'homedecor:plastic_sheeting', 'dye:grey', 'homedecor:plastic_sheeting'},
		{'homedecor:plastic_sheeting', 'default:steel_ingot', 'homedecor:plastic_sheeting'},
	}
})

minetest.register_tool("gunslinger_rangedweapons:mag_ak47", {
	description = "AK47 Magazine",
	inventory_image = "rangedweapons_ak47_mag.png",
})
gunslinger.register_magazine("gunslinger_rangedweapons:mag_ak47", "gunslinger_rangedweapons:bullet_762mm", 30)
minetest.register_craft({
	output = 'gunslinger_rangedweapons:mag_ak47 1 65534',
	recipe = {
		{'homedecor:plastic_sheeting', '', 'homedecor:plastic_sheeting'},
		{'homedecor:plastic_sheeting', 'dye:black', 'homedecor:plastic_sheeting'},
		{'homedecor:plastic_sheeting', 'default:steel_ingot', 'homedecor:plastic_sheeting'},
	}
})

minetest.register_tool("gunslinger_rangedweapons:mag_m60", {
	description = "M60 Magazine",
	inventory_image = "rangedweapons_m60_mag.png",
})
gunslinger.register_magazine("gunslinger_rangedweapons:mag_m60", "gunslinger_rangedweapons:bullet_762mm", 100)
minetest.register_craft({
	output = 'gunslinger_rangedweapons:mag_m60 1 65534',
	recipe = {
		{'', '', ''},
		{'default:steel_ingot', 'dye:dark_green', 'default:steel_ingot'},
		{'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'},
	}
})

minetest.register_tool("gunslinger_rangedweapons:mag_rpk", {
	description = "RPK Drum Magazine",
	inventory_image = "rangedweapons_rpk_mag.png",
})
gunslinger.register_magazine("gunslinger_rangedweapons:mag_rpk", "gunslinger_rangedweapons:bullet_762mm", 100)
minetest.register_craft({
	output = 'gunslinger_rangedweapons:mag_rpk 1 65534',
	recipe = {
		{'', '', ''},
		{'default:steel_ingot', 'dye:black', 'default:steel_ingot'},
		{'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'},
	}
})

minetest.register_tool("gunslinger_rangedweapons:mag_smg", {
	description = "SMG Magazine",
	inventory_image = "rangedweapons_smg_mag.png",
})
gunslinger.register_magazine("gunslinger_rangedweapons:mag_smg", "gunslinger_rangedweapons:bullet_10mm", 30)
minetest.register_craft({
	output = 'gunslinger_rangedweapons:mag_smg 1 65534',
	recipe = {
		{'homedecor:plastic_sheeting', '', 'homedecor:plastic_sheeting'},
		{'homedecor:plastic_sheeting', 'dye:dark_grey', 'homedecor:plastic_sheeting'},
		{'homedecor:plastic_sheeting', 'default:steel_ingot', 'homedecor:plastic_sheeting'},
	}
})

minetest.register_tool("gunslinger_rangedweapons:mag_sniper", {
	description = "Sniper Magazine",
	inventory_image = "rangedweapons_sniper_mag.png",
})
gunslinger.register_magazine("gunslinger_rangedweapons:mag_sniper", "gunslinger_rangedweapons:bullet_308mm", 10)
minetest.register_craft({
	output = 'gunslinger_rangedweapons:mag_sniper 1 65534',
	recipe = {
		{'', '', ''},
		{'homedecor:plastic_sheeting', 'dye:black', 'homedecor:plastic_sheeting'},
		{'homedecor:plastic_sheeting', 'default:steel_ingot', 'homedecor:plastic_sheeting'},
	}
})

minetest.register_tool("gunslinger_rangedweapons:mag_9mm", {
	description = "9mm Pistol Magazine",
	inventory_image = "rangedweapons_9mm_mag.png",
})
gunslinger.register_magazine("gunslinger_rangedweapons:mag_9mm", "gunslinger_rangedweapons:bullet_9mm", 15)
minetest.register_craft({
	output = 'gunslinger_rangedweapons:mag_9mm 1 65534',
	recipe = {
		{'', '', ''},
		{'homedecor:plastic_sheeting', 'dye:dark_grey', 'homedecor:plastic_sheeting'},
		{'homedecor:plastic_sheeting', 'default:steel_ingot', 'homedecor:plastic_sheeting'},
	}
})

minetest.register_tool("gunslinger_rangedweapons:mag_makarov", {
	description = "Small 9mm Magazine",
	inventory_image = "rangedweapons_makarov_mag.png",
})
gunslinger.register_magazine("gunslinger_rangedweapons:mag_makarov", "gunslinger_rangedweapons:bullet_9mm", 7)
minetest.register_craft({
	output = 'gunslinger_rangedweapons:mag_makarov 1 65534',
	recipe = {
		{'', '', ''},
		{'', 'dye:dark_grey', ''},
		{'homedecor:plastic_sheeting', 'default:steel_ingot', 'homedecor:plastic_sheeting'},
	}
})

minetest.register_tool("gunslinger_rangedweapons:mag_deagle", {
	description = "Desert Eagle Magazine",
	inventory_image = "rangedweapons_deagle_mag.png",
})
gunslinger.register_magazine("gunslinger_rangedweapons:mag_deagle", "gunslinger_rangedweapons:bullet_357", 9)
minetest.register_craft({
	output = 'gunslinger_rangedweapons:mag_deagle 1 65534',
	recipe = {
		{'', '', ''},
		{'default:steel_ingot', 'dye:dark_grey', 'default:steel_ingot'},
		{'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'},
	}
})
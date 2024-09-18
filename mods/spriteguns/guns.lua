local casingmat = "default:bronze_ingot"
local bulletmat = "default:steel_ingot"
local shotguncasemat = "default:paper"
local magspringmat = "group:sapling"
local fancycrafts = minetest.get_modpath("gun_lathe") ~= nil and minetest.get_modpath("assembler") ~= nil
if minetest.get_modpath("basic_materials") then
	casingmat = "basic_materials:brass_ingot"
	shotguncasemat = "basic_materials:plastic_strip"
	magspringmat = "basic_materials:steel_wire"
end
if minetest.get_modpath("technic") then
	bulletmat = "technic:lead_ingot"
end
minetest.register_craftitem("spriteguns:bullet_45", {
	description = ".45 ACP Bullet",
	inventory_image = "rangedweapons_9mm.png",
})
minetest.register_craft({
	output = "spriteguns:bullet_45 80",
	recipe = {
		{"", bulletmat, ""},
		{casingmat, "tnt:gunpowder", casingmat},
		{casingmat, "tnt:gunpowder", casingmat},
	}
})
minetest.register_craftitem("spriteguns:bullet_762", {
	description = "7.62x39 Bullet",
	inventory_image = "rangedweapons_762mm.png",
})
if fancycrafts then
	minetest.register_craft({
		output = "spriteguns:bullet_762 60",
		recipe = {
			{"", bulletmat, ""},
			{casingmat, "tnt:gunpowder", casingmat},
			{casingmat, "tnt:gunpowder", casingmat},
			{casingmat, "tnt:gunpowder", casingmat},
		}
	})
else
	minetest.register_craft({
		output = "spriteguns:bullet_762 60",
		recipe = {
			{casingmat, bulletmat, casingmat},
			{casingmat, "tnt:gunpowder", casingmat},
			{casingmat, "tnt:gunpowder", casingmat},
		}
	})
end
minetest.register_craftitem("spriteguns:bullet_12", {
	description = "12 Gauge Buckshot",
	inventory_image = "rangedweapons_12g.png",
})
minetest.register_craft({
	output = "spriteguns:bullet_12 60",
	recipe = {
		{shotguncasemat, bulletmat, shotguncasemat},
		{shotguncasemat, "tnt:gunpowder", shotguncasemat},
		{casingmat, "tnt:gunpowder", casingmat},
	}
})

spriteguns.register_gun("spriteguns:remington870",{
	description = "Remington 870 Shotgun",
	inventory_image = "rem870_inv.png",
	zoomfov = 60,
	scale = 7.5,
	range = 100,
	fire_sound = "rem870_fire",
	fire_gain = 10,
	fire_sound_distant = "distant_hical",
	size = 8,
	loadtype = "manual",--"auto", "semi", and "manual"
	ammo = "spriteguns:bullet_12",
	firetime = .2,
	offsetrecoil = 120,
	targetrecoil = 80,
	damage = 3,
	maxdev = .16,
	maxzoomdev = .06,
	pellets = 12,
	space = 3,
	unload_amount = 1,
	concealed = false,
	spread = 35,
	textures = {
		prefix = "rem870_",
		hipidle = "hipidle.png",
		hipidlenomag = "hipidle.png",
		hipfire = "hipfireflash.png",
		hippostfire = "hipfire.png",
		aimidle = "aimidle.png",
		aimidlenomag = "aimidle.png",
		aimfire = "aimfireflash.png",
		aimpostfire = "aimfire.png",
		load = {
			length = .75,
			sounds = {nil, "rem870_rackslide"},
			frames = {"hipidle.png", "load.png"},
			zoomframes = {"aimidle.png", "loadzoom.png"}
		},
		reload = {
			length = 1.15,
			speed = .75,
			loopstart = 2,
			loopend = 5,
			sounds = {nil, nil, "rem870_loadshell"},
			frames = {"reload1.png", "reload2.png", "reload2.png", "reload3.png", "reload3.png", "reload4.png"}
		},
		unload = {
			length = .5,
			sounds = {nil, "rem870_rackslide"},
			frames = {"hipidle.png", "load.png"},
		},
	},
})
if fancycrafts then
	minetest.register_craft({
		output = "spriteguns:remington870 1 65534",
		recipe = {
			{"gun_lathe:gun_barrel_carbon_steel", "", "", "", ""},
			{"gun_lathe:gun_barrel_carbon_steel", "gun_lathe:gun_barrel_carbon_steel", "", "", ""},
			{"group:tree", "gun_lathe:gun_barrel_carbon_steel", "gun_lathe:gun_barrel_carbon_steel", "technic:carbon_steel_ingot", ""},
			{"", "group:tree", "group:tree", "moreores:mithril_ingot", ""},
			{"", "", "", "group:tree", "group:tree"},
		}
	})
else
	minetest.register_craft({
		output = "spriteguns:remington870 1 65534",
		recipe = {
			{"default:steel_ingot", "", ""},
			{"group:tree", "default:steel_ingot", "default:mese_crystal"},
			{"", "group:tree", "group:tree"},
		}
	})
end

spriteguns.register_gun("spriteguns:thompson",{
	description = "Thompson Submachine gun",
	inventory_image = "thompson_inv.png",
	zoomfov = 60,
	scale = 7.5,
	range = 200,
	fire_sound = "thompson_fire",
	fire_sound_distant = "distant_local",
	size = 30,
	loadtype = "auto",--"auto", "semi", and "manual"
	ammo = "spriteguns:mag_thompson",
	firetime = 60/700,
	offsetrecoil = 40,
	magazine = true,
	targetrecoil = 20,
	damage = 5,
	maxdev = .16,
	maxzoomdev = .06,
	unload_amount = 1,
	space = 3,
	spread = 3,
	textures = {
		prefix = "thompson_",
		hipidle = "hipidle.png",
		hipidlenomag = "hipidlenomag.png",
		hipfire = "hipfire.png",
		hippostfire = "hipfire.png",
		aimidle = "aimidle.png",
		aimidlenomag = "aimidle.png",
		aimfire = "aimfire.png",
		aimpostfire = "aimfire.png",
		load = {
			length = 1,
			sounds = {nil, "thompson_charge"},
			frames = {"load1.png", "load2.png", "load3.png", "load4.png"}
		},
		reload = {
			length = 3/2,
			speed = .75,
			sounds = {nil, nil, "thompson_load"},
			frames = {"reload3.png", "reload2.png", "reload1.png"}
		},
		unload = {
			length = 3/2,
			speed = .75,
			sounds = {"thompson_unload", nil, nil},
			frames = {"reload1.png", "reload2.png", "reload3.png"}
		},
	},
})

minetest.register_tool("spriteguns:mag_thompson", {
	description = "Thompson Magazine",
	inventory_image = "rangedweapons_smg_mag.png",
})
if fancycrafts then
	minetest.register_craft({
		output = "spriteguns:thompson 1 65534",
		recipe = {
			{"gun_lathe:gun_barrel_carbon_steel", "", "", ""},
			{"group:tree", "gun_lathe:gun_barrel_carbon_steel", "", ""},
			{"group:tree", "", "moreores:mithril_ingot", ""},
			{"", "", "group:tree", "group:tree"},
		}
	})
else
	minetest.register_craft({
		output = "spriteguns:thompson 1 65534",
		recipe = {
			{"default:steel_ingot", "default:diamond", ""},
			{"", "default:steel_ingot", "default:diamond"},
			{"", "group:tree", "group:tree"},
		}
	})
end
spriteguns.register_magazine("spriteguns:mag_thompson", "spriteguns:bullet_45", 30)
minetest.register_craft({
	output = "spriteguns:mag_thompson 1 65534",
	recipe = {
		{"default:steel_ingot"},
		{"default:steel_ingot"},
		{magspringmat},
	}
})

spriteguns.register_gun("spriteguns:cz527",{
	description = "CZ 527 Rifle",
	inventory_image = "cz527_inv.png",
	zoomfov = 20,
	scale = 7.5,
	range = 400,
	fire_sound = "cz527_fire",
	fire_gain = 10,
	fire_sound_distant = "distant_hical",
	size = 5,
	space = 5,
	loadtype = "manual",--"auto", "semi", and "manual"
	ammo = "spriteguns:mag_cz527",
	firetime = .4,
	offsetrecoil = 140,
	targetrecoil = 60,
	damage = 12,
	maxdev = .12,
	maxzoomdev = .03,
	magazine = true,
	concealed = false,
	spread = 0,
	textures = {
		prefix = "cz527_",
		hipidle = "hipidle.png",
		hipidlenomag = "hipidlenomag.png",
		hipfire = "hipfire.png",
		hippostfire = "hippostfire.png",
		aimidle = "aimidle.png",
		aimidlenomag = "aimidlenomag.png",
		aimfire = "aimfire.png",
		aimpostfire = "aimidle.png",
		load = {
			length = 1.5,
			sounds = {"cz527_openbolt", nil, "cz527_closebolt"},
			frames = {"load1.png", "load2.png", "load3.png", "load2.png", "load1.png"},
			zoomframes = {"loadzoom1.png", "loadzoom2.png", "loadzoom3.png", "loadzoom2.png", "loadzoom1.png"},
		},
		reload = {
			length = 1.5,
			speed = .75,
			sounds = {"thompson_load", nil, "cz527_closebolt"},
			frames = {"reload2.png", "reload1.png", "load3.png", "load2.png", "load1.png"}
		},
		unload = {
			length = 1.5,
			speed = .75,
			sounds = {"cz527_openbolt", nil, nil, "thompson_unload"},
			frames = {"load1.png", "load2.png", "load3.png", "reload1.png", "reload2.png"},
		},
	},
})

if fancycrafts then
	minetest.register_craft({
		output = "spriteguns:cz527 1 65534",
		recipe = {
			{"gun_lathe:gun_barrel_stainless_steel", "default:obsidian_glass", "", "", ""},
			{"", "gun_lathe:gun_barrel_stainless_steel", "default:diamondblock", "", ""},
			{"", "group:tree", "gun_lathe:gun_barrel_stainless_steel", "default:obsidian_glass", ""},
			{"", "", "group:tree", "moreores:mithril_block", ""},
			{"", "", "", "group:tree", "group:tree"},
		}
	})
else
	minetest.register_craft({
		output = "spriteguns:cz527 1 65534",
		recipe = {
			{"default:steel_ingot", "default:diamondblock", ""},
			{"group:tree", "default:steel_ingot", "default:diamondblock"},
			{"", "group:tree", "group:tree"},
		}
	})
end

minetest.register_tool("spriteguns:mag_cz527", {
	description = "CZ 527 Magazine",
	inventory_image = "rangedweapons_sniper_mag.png",
})
spriteguns.register_magazine("spriteguns:mag_cz527", "spriteguns:bullet_762", 5)
minetest.register_craft({
	output = "spriteguns:mag_cz527 1 65534",
	recipe = {
		{"default:steel_ingot", "", "default:steel_ingot"},
		{"", magspringmat, ""},
	}
})

spriteguns.register_gun("spriteguns:mini14",{
	description = "Mini-30 Rifle",
	inventory_image = "mini14_inv.png",
	zoomfov = 60,
	scale = 7.5,
	range = 300,
	fire_sound = "mini14_fire",
	fire_gain = 10,
	fire_sound_distant = "distant_hical",
	size = 15,
	space = 4,
	loadtype = "semi",--"auto", "semi", and "manual"
	ammo = "spriteguns:mag_mini14",
	firetime = .2,
	offsetrecoil = 120,
	targetrecoil = 40,
	damage = 10,
	maxdev = .12,
	maxzoomdev = .04,
	magazine = true,
	concealed = false,
	spread = 2,
	textures = {
		prefix = "mini14_",
		hipidle = "hipidle.png",
		hipidlenomag = "hipidlenomag.png",
		hipfire = "hipfire.png",
		hippostfire = "hipidle.png",
		aimidle = "aimidle.png",
		aimidlenomag = "aimidle.png",
		aimfire = "aimfire.png",
		aimpostfire = "aimidle.png",
		load = {
			length = 4*.25,
			sounds = {nil, "thompson_charge"},
			frames = {"load1.png", "load2.png", "load3.png", "load4.png"},
		},
		reload = {
			length = 8*.25,
			speed = .75,
			sounds = {"thompson_load", nil, nil, nil, nil, "thompson_charge"},
			frames = {"reload4.png", "reload3.png", "reload2.png", "reload1.png", "load1.png", "load2.png", "load3.png", "load4.png"}
		},
		unload = {
			length = 4*.25,
			speed = .75,
			sounds = {"thompson_unload"},
			frames = {"reload1.png", "reload2.png", "reload3.png", "reload4.png"},
		},
	},
})
if fancycrafts then
	minetest.register_craft({
		output = "spriteguns:mini14 1 65534",
		recipe = {
			{"gun_lathe:gun_barrel_stainless_steel", "default:diamond", "", "", ""},
			{"", "gun_lathe:gun_barrel_stainless_steel", "", "", ""},
			{"", "group:tree", "gun_lathe:gun_barrel_stainless_steel", "default:diamond", ""},
			{"", "", "group:tree", "moreores:mithril_block", ""},
			{"", "", "", "group:tree", "group:tree"},
		}
	})
else
	minetest.register_craft({
		output = "spriteguns:mini14 1 65534",
		recipe = {
			{"default:steel_ingot", "", ""},
			{"group:tree", "default:steel_ingot", "default:diamondblock"},
			{"", "group:tree", "group:tree"},
		}
	})
end

minetest.register_tool("spriteguns:mag_mini14", {
	description = "Mini-30 Magazine",
	inventory_image = "rangedweapons_ak47_mag.png",
})
spriteguns.register_magazine("spriteguns:mag_mini14", "spriteguns:bullet_762", 15)
minetest.register_craft({
	output = "spriteguns:mag_mini14 1 65534",
	recipe = {
		{"default:steel_ingot", "", "default:steel_ingot"},
		{"default:steel_ingot", "", "default:steel_ingot"},
		{"", magspringmat, ""},
	}
})

spriteguns.register_gun("spriteguns:pardini",{
	description = "Pardini Pistol",
	inventory_image = "pardini_inv.png",
	zoomfov = 60,
	scale = 7.5,
	range = 200,
	fire_sound = "pardini_fire",
	fire_gain = 10,
	fire_sound_distant = "distant_local",
	size = 10,
	loadtype = "semi",--"auto", "semi", and "manual"
	ammo = "spriteguns:mag_pardini",
	firetime = .125,
	offsetrecoil = 60,
	targetrecoil = 30,
	damage = 5,
	maxdev = .12,
	maxzoomdev = .04,
	magazine = true,
	concealed = true,
	spread = 4,
	textures = {
		prefix = "pardini_",
		hipidle = "hipidle.png",
		hipidlenomag = "hipidlenomag.png",
		hipfire = "hipfire.png",
		hippostfire = "hipidle.png",
		aimidle = "aimidle.png",
		aimidlenomag = "aimidlenomag.png",
		aimfire = "aimfire.png",
		aimpostfire = "aimidle.png",
		load = {
			length = 4*.25,
			sounds = {nil, "thompson_charge"},
			frames = {"load1.png", "load2.png", "load3.png", "load4.png"},
		},
		reload = {
			length = 4*.33,
			speed = .75,
			sounds = {"thompson_load", nil, nil, "thompson_charge"},
			frames = {"reload2.png", "reload1.png", "load3.png", "load1.png"}
		},
		unload = {
			length = 5*.33,
			speed = .75,
			sounds = {nil, "thompson_charge", nil, "thompson_unload"},
			frames = {"load1.png", "load2.png", "load3.png", "reload1.png", "reload2.png"},
		},
	},
})

minetest.register_tool("spriteguns:mag_pardini", {
	description = "Pardini Magazine",
	inventory_image = "rangedweapons_9mm_mag.png",
})
if fancycrafts then
	minetest.register_craft({
		output = "spriteguns:pardini 1 65534",
		recipe = {
			{"gun_lathe:gun_barrel_iron", "", ""},
			{"default:steel_ingot", "gun_lathe:gun_barrel_iron", ""},
			{"", "default:steel_ingot", "default:steel_ingot"},
			{"default:steel_ingot", "default:steel_ingot", ""},
		}
	})
else
	minetest.register_craft({
		output = "spriteguns:pardini 1 65534",
		recipe = {
			{"default:steel_ingot", "", ""},
			{"", "default:steel_ingot", "default:diamond"},
			{"", "default:steel_ingot", ""},
		}
	})
end
spriteguns.register_magazine("spriteguns:mag_pardini", "spriteguns:bullet_45", 10)
minetest.register_craft({
	output = "spriteguns:mag_pardini 1 65534",
	recipe = {
		{"default:steel_ingot"},
		{magspringmat},
	}
})

spriteguns.register_gun("spriteguns:coltarmy",{
	description = "Colt  Army Revolver",
	inventory_image = "coltarmy_inv.png",
	zoomfov = 60,
	scale = 7.5,
	range = 200,
	fire_sound = "coltarmy_fire",
	fire_gain = 10,
	fire_sound_distant = "distant_local",
	size = 6,
	loadtype = "semi",--"auto", "semi", and "manual"
	ammo = "spriteguns:bullet_45",
	firetime = .5,
	offsetrecoil = 100,
	targetrecoil = 40,
	damage = 8,
	maxdev = .12,
	maxzoomdev = .05,
	unload_amount = 1,
	concealed = true,
	spread = 3,
	textures = {
		prefix = "coltarmy_",
		hipidle = "hipidle.png",
		hipidlenomag = "hipidle.png",
		hipfire = "hipfire.png",
		hippostfire = "hippostfire.png",
		aimidle = "aimidle.png",
		aimidlenomag = "aimidle.png",
		aimfire = "aimfire.png",
		aimpostfire = "aimpostfire.png",
		load = {
			length = 4*.25,
			sounds = {nil, "thompson_charge"},
			frames = {"load1.png", "load2.png", "load3.png", "load4.png"},
		},
		reload = {
			length = 4*.30,
			speed = .75,
			loopstart = 2,
			loopend = 3,
			sounds = {nil, nil, "gunslinger_charge"},
			frames = {"reload1.png", "reload2.png", "reload3.png", "reload1.png"}
		},
		unload = {
			length = 4*.30,
			speed = .75,
			loopstart = 2,
			loopend = 3,
			sounds = {nil, nil, "gunslinger_charge"},
			frames = {"reload1.png", "reload3.png", "reload4.png", "reload1.png", }
		},
	},
})
if fancycrafts then
	minetest.register_craft({
		output = "spriteguns:coltarmy 1 65534",
		recipe = {
			{"gun_lathe:gun_barrel_iron", "", ""},
			{"default:steel_ingot", "gun_lathe:gun_barrel_iron", ""},
			{"", "default:steel_ingot", "group:tree"},
			{"", "group:tree", ""},
		}
	})
else
	minetest.register_craft({
		output = "spriteguns:coltarmy 1 65534",
		recipe = {
			{"default:steel_ingot", "", ""},
			{"", "default:steel_ingot", "default:mese_crystal"},
			{"", "group:tree", ""},
		}
	})
end

spriteguns.register_gun("spriteguns:binoculars",{
	description = "Binoculars",
	inventory_image = "binoculars_binoculars.png",
	zoomfov = 20,
	scale = 7.5,
	targetrecoil = 10,
	maxdev = .12,
	maxzoomdev = .01,
	concealed = true,
	textures = {
		prefix = "bino",
		hipidle = "_hipidle.png",
		aimidle = "aim_cut.png",
		load = {
			length = .1,
			frames = {"_hipidle.png"}
		},
	},
})

minetest.register_craft({
	output = "spriteguns:binoculars",
	recipe = {
		{"default:obsidian_glass", "", "default:obsidian_glass"},
		{"default:bronze_ingot", "default:bronze_ingot", "default:bronze_ingot"},
		{"default:obsidian_glass", "", "default:obsidian_glass"},
	}
})
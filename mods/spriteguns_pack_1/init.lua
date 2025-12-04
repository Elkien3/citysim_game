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

spriteguns.register_gun("spriteguns_pack_1:zastavam85",{
	description = "Zastava M85 Rifle",
	inventory_image = "zm85_inv.png",
	zoomfov = 40,
	scale = 7.5,
	range = 360,
	fire_sound = "cz527_fire",
	fire_gain = 10,
	fire_sound_distant = "distant_hical",
	size = 3,
	space = 4,
	loadtype = "manual",--"auto", "semi", and "manual"
	ammo = "spriteguns:bullet_762",
	firetime = .4,
	offsetrecoil = 140,
	targetrecoil = 60,
	damage = 10,
	maxdev = .12,
	maxzoomdev = .04,
	magazine = false,
	unload_amount = 1,
	concealed = false,
	spread = 0,
	textures = {
		prefix = "zm85_",
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
			length = 9*.40,
			speed = .50,
			loopstart = 5,
			loopend = 6,
			sounds = {nil, "cz527_openbolt", nil, nil, nil, "gunslinger_charge", nil, "cz527_closebolt", "nil"},
			frames = {"load1.png", "load2.png", "load3.png", "reload1.png", "reload2.png", "reload3.png", "reload1.png", "load3.png", "load2.png", "load1.png"}
		},
		unload = {
			length = 8*.40,
			speed = .50,
			loopstart = 5,
			loopend = 6,
			sounds = {"cz527_openbolt", nil, nil, nil, "gunslinger_charge", nil, "cz527_closebolt"},
			frames = {"load1.png", "load2.png", "load3.png", "reload1.png", "reload4.png", "reload1.png", "load3.png", "load2.png"},
		},
	},
})
if fancycrafts then
	minetest.register_craft({
		output = "spriteguns_pack_1:zastavam85 1 65534",
		recipe = {
			{"gun_lathe:gun_barrel_stainless_steel", "default:diamond", "", "", ""},
			{"", "gun_lathe:gun_barrel_stainless_steel", "default:obsidian_shard", "", ""},
			{"", "group:tree", "gun_lathe:gun_barrel_stainless_steel", "default:diamond", ""},
			{"", "", "group:tree", "moreores:mithril_block", ""},
			{"", "", "", "group:tree", "group:tree"},
		}
	})
else
	minetest.register_craft({
		output = "spriteguns_pack_1:zastavam85 1 65534",
		recipe = {
			{"default:steel_ingot", "default:diamond", ""},
			{"group:tree", "default:steel_ingot", "default:diamond"},
			{"", "group:tree", "group:tree"},
		}
	})
end

spriteguns.register_gun("spriteguns_pack_1:supershorty",{
	description = "Serbu Super Shorty Shotgun",
	inventory_image = "supershorty_inv.png",
	zoomfov = 60,
	scale = 7.5,
	range = 80,
	fire_sound = "serbu_fire",
	fire_gain = 10,
	fire_sound_distant = "distant_hical",
	size = 3,
	loadtype = "manual",--"auto", "semi", and "manual"
	ammo = "spriteguns:bullet_12",
	firetime = .2,
	offsetrecoil = 150,
	targetrecoil = 100,
	damage = 3,
	maxdev = .18,
	maxzoomdev = .07,
	pellets = 12,
	space = 2,
	unload_amount = 1,
	concealed = true,
	spread = 45,
	textures = {
		prefix = "serbuss_",
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
		output = "spriteguns_pack_1:supershorty 1 65534",
		recipe = {
			{"gun_lathe:gun_barrel_carbon_steel", "", "", ""},
			{"gun_lathe:gun_barrel_carbon_steel", "gun_lathe:gun_barrel_carbon_steel", "technic:carbon_steel_ingot", ""},
			{"technic:carbon_steel_ingot", "basic_materials:plastic_sheet", "moreores:mithril_ingot", "basic_materials:plastic_strip"},
			{"", "dye:black", "basic_materials:plastic_sheet", "dye:black"},
		}
	})
else
	minetest.register_craft({
		output = "spriteguns_pack_1:supershorty 1 65534",
		recipe = {
			{"", "", ""},
			{"default:steel_ingot", "default:steel_ingot", "default:mese_crystal"},
			{"", "group:tree", "group:tree"},
		}
	})
end

spriteguns.register_gun("spriteguns_pack_1:glock21",{
	description = "Glock 21 Pistol",
	inventory_image = "glock21_inv.png",
	zoomfov = 60,
	scale = 7.5,
	range = 180,
	fire_sound = "glock21_fire",
	fire_gain = 10,
	fire_sound_distant = "distant_local",
	size = 13,
	loadtype = "semi",--"auto", "semi", and "manual"
	ammo = "spriteguns_pack_1:mag_glock21",
	firetime = .125,
	offsetrecoil = 70,
	targetrecoil = 30,
	damage = 4,
	maxdev = .12,
	maxzoomdev = .04,
	magazine = true,
	concealed = true,
	spread = 4,
	textures = {
		prefix = "glock21_",
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

minetest.register_tool("spriteguns_pack_1:mag_glock21", {
	description = "Glock 21 Magazine",
	inventory_image = "glock21_mag.png",
})
if fancycrafts then
	minetest.register_craft({
		output = "spriteguns_pack_1:glock21 1 65534",
		recipe = {
			{"gun_lathe:gun_barrel_carbon_steel", "default:mese_crystal_fragment", "", ""},
			{"basic_materials:plastic_sheet", "gun_lathe:gun_barrel_carbon_steel", "", ""},
			{"dye:black", "technic:carbon_steel_ingot", "technic:carbon_steel_ingot", "default:mese_crystal_fragment"},
			{"technic:carbon_steel_ingot", "technic:carbon_steel_ingot", "basic_materials:plastic_sheet", "dye:black"},
		}
	})
else
	minetest.register_craft({
		output = "spriteguns_pack_1:glock21 1 65534",
		recipe = {
			{"default:steel_ingot", "", ""},
			{"", "default:steel_ingot", "default:mese_crystal"},
			{"", "default:steel_ingot", ""},
		}
	})
end
spriteguns.register_magazine("spriteguns_pack_1:mag_glock21", "spriteguns:bullet_45", 13)
	minetest.register_craft({
		output = "spriteguns_pack_1:mag_glock21 1 65534",
		recipe = {
			{"", "", ""},
			{"", "technic:carbon_steel_ingot", ""},
			{"", "basic_materials:steel_wire", ""},
	}
})

spriteguns.register_gun("spriteguns_pack_1:stevens94a",{
	description = "Stevens 94a Shotgun",
	inventory_image = "stevens94a_inv.png",
	zoomfov = 50,
	scale = 7.5,
	range = 110,
	fire_sound = "stevens94_fire",
	fire_gain = 10,
	fire_sound_distant = "distant_hical",
	size = 1,
	loadtype = "manual",--"auto", "semi", and "manual"
	ammo = "spriteguns:bullet_12",
	firetime = 1,
	offsetrecoil = 100,
	targetrecoil = 70,
	damage = 2,
	maxdev = .14,
	maxzoomdev = .06,
	pellets = 12,
	space = 3,
	magazine = false,
	unload_amount = 1,
	concealed = false,
	spread = 18,
	textures = {
		prefix = "stevens94a_",
		hipidle = "hipidle.png",
		hipidlenomag = "hipidle.png",
		hipfire = "hipfireflash.png",
		hippostfire = "hipfire.png",
		aimidle = "aimidle.png",
		aimidlenomag = "aimidle.png",
		aimfire = "aimfireflash.png",
		aimpostfire = "aimfire.png",
		load = {
			length = 1.5,
			sounds = {nil, nil, nil, "stevens94_charge", nil},
			frames = {"load1.png", "load2.png", "load3.png", "load4.png"},
		},
		reload = {
			length = 3.5,
			speed = .75,
			sounds = {nil, "gunslinger_charge", nil, nil, nil, "rem870_loadshell", nil, "gunslinger_charge", nil, "stevens94_charge"},
			frames = {"preload1.png", "preload2.png", "reload1.png", "reload2.png", "reload3.png", "reload4.png", "reload4.png", "load2.png", "load3.png", "load4.png"},
		},
		unload = {
			length = 2,
			sounds = {nil, "rem870_loadshell", nil, nil, nil, "gunslinger_charge"},
			frames = {"unload1.png", "unload2.png", "unload3.png", "unload4.png", "unload4.png", "load2.png"},
		},
	},
})
if fancycrafts then
	minetest.register_craft({
		output = "spriteguns_pack_1:stevens94a 1 65534",
		recipe = {
			{"gun_lathe:gun_barrel_carbon_steel", "", "", "", ""},
			{"", "gun_lathe:gun_barrel_carbon_steel", "", "", ""},
			{"", "group:tree", "gun_lathe:gun_barrel_carbon_steel", "technic:carbon_steel_ingot", ""},
			{"", "", "group:tree", "moreores:mithril_ingot", ""},
			{"", "", "", "group:tree", "group:tree"},
		}
	})
else
	minetest.register_craft({
		output = "spriteguns_pack_1:stevens94a 1 65534",
		recipe = {
			{"default:steel_ingot", "", ""},
			{"group:tree", "default:steel_ingot", "default:diamond"},
			{"", "group:tree", "group:tree"},
		}
	})
end

spriteguns.register_gun("spriteguns_pack_1:mac10",{
	description = "MAC-10 Submachine gun",
	inventory_image = "mac10_inv.png",
	zoomfov = 67,
	scale = 7.5,
	range = 70,
	fire_sound = "mac10_fire",
	fire_sound_distant = "distant_local",
	size = 30,
	loadtype = "auto",--"auto", "semi", and "manual"
	ammo = "spriteguns_pack_1:mag_mac10",
	firetime = .06,
	offsetrecoil = 50,
	magazine = true,
	targetrecoil = 30,
	damage = 5,
	maxdev = .14,
	maxzoomdev = .05,
	unload_amount = 1,
	space = 1,
	spread = 4,
	textures = {
		prefix = "mac10_",
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
			speed = 1.5,
			sounds = {nil, nil, "thompson_load", nil, nil, nil, "thompson_charge"},
			frames = {"reload3.png", "reload2.png", "inter.png", "load1.png", "load2.png", "load3.png", "load4.png"}
		},
		unload = {
			length = 3/2,
			speed = .75,
			sounds = {nil, "thompson_unload", nil},
			frames = {"reload1.png", "reload2.png", "reload3.png"}
		},
	},
})

minetest.register_tool("spriteguns_pack_1:mag_mac10", {
	description = "Mac-10 Magazine",
	inventory_image = "mag_mac10.png",
})
if fancycrafts then
	minetest.register_craft({
		output = "spriteguns_pack_1:mac10 1 65534",
		recipe = {
			{"gun_lathe:gun_barrel_carbon_steel", "default:steel_ingot", "", ""},
			{"basic_materials:steel_strip", "gun_lathe:gun_barrel_carbon_steel", "default:steel_ingot", "basic_materials:steel_strip"},
			{"", "basic_materials:steel_strip", "moreores:mithril_ingot", "default:steel_ingot"},
			{"basic_materials:steel_strip", "default:steel_ingot", "default:steel_ingot", "basic_materials:steel_bar"},
		}
	})
else
	minetest.register_craft({
		output = "spriteguns_pack_1:mac10 1 65534",
		recipe = {
			{"default:steel_ingot", "default:steel_ingot", ""},
			{"", "default:steel_ingot", "default:diamond"},
			{"", "default:steel_ingot", "group:tree"},
		}
	})
end

spriteguns.register_magazine("spriteguns_pack_1:mag_mac10", "spriteguns:bullet_45", 30)
	minetest.register_craft({
		output = "spriteguns_pack_1:mag_mac10 1 65534",
		recipe = {
			{"basic_materials:steel_strip", "", "basic_materials:steel_strip"},
			{"basic_materials:steel_strip", "", "basic_materials:steel_strip"},
			{"basic_materials:steel_strip", "basic_materials:steel_wire", "basic_materials:steel_strip"},
	}
})

minetest.register_node("cars:engine", {
	description = "Car Engine",
	tiles = {"engine.png"}, 
})
minetest.register_node("cars:transmission", {
	description = "Car Transmission",
	tiles = {"transmission.png"}, 
})
minetest.register_node("cars:seat", {
	description = "Car Seat",
	tiles = {"seat.png"}, 
})
minetest.register_node("cars:wheel", {
	description = "Car Wheel",
	tiles = {"wheel.png"}, 
})

if minetest.get_modpath("assembler") and minetest.get_modpath("technic") and minetest.get_modpath("mesecons_pistons") then
	minetest.register_craft({
		output = "cars:engine",
		recipe = {
			{"", "moreores:mithril_block", "pipeworks:tube_1", "moreores:mithril_block", ""},
			{"default:obsidian_shard", "mesecons_pistons:piston_normal_off", "pipeworks:tube_1", "", "default:obsidian_shard"},
			{"default:mese_crystal", "", "pipeworks:tube_1", "mesecons_pistons:piston_normal_off", "default:mese_crystal"},
			{"basic_materials:steel_bar", "basic_materials:steel_bar", "basic_materials:steel_bar", "basic_materials:steel_bar", "basic_materials:motor"},
			{"", "", "", "", "technic:lv_battery_box0"}
		}
	})
	minetest.register_craft({
		output = "cars:transmission",
		recipe = {
			{"", "", "", "basic_materials:steel_bar", ""},
			{"", "basic_materials:gear_steel", "basic_materials:steel_bar", "", "technic:control_logic_unit"},
			{"basic_materials:gear_steel", "default:obsidian", "basic_materials:gear_steel", "", "technic:control_logic_unit"},
			{"", "basic_materials:gear_steel", "", "", ""},
			{"basic_materials:steel_bar", "basic_materials:gear_steel", "basic_materials:steel_bar", "basic_materials:steel_bar", "basic_materials:steel_bar"}
		}
	})
	minetest.register_craft({
		output = "cars:seat",
		recipe = {
			{"", "group:wool"},
			{"group:wool", "group:wool"},
			{"basic_materials:steel_bar", "basic_materials:steel_bar"}
		}
	})
	minetest.register_craft({
		output = "cars:wheel",
		recipe = {
			{"technic:rubber", "technic:rubber", "technic:rubber"},
			{"technic:rubber", "default:steel_ingot", "technic:rubber"},
			{"technic:rubber", "technic:rubber", "technic:rubber"}
		}
	})
else
	minetest.register_craft({
		output = "cars:engine",
		recipe = {
			{"default:obsidian", "default:mese", "default:copper_ingot"},
			{"", "default:obsidian_shard", "default:copper_ingot"},
			{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"}
		}
	})
	minetest.register_craft({
		output = "cars:transmission",
		recipe = {
			{"", "default:obsidian_shard", ""},
			{"default:obsidian_shard", "default:obsidian", "default:obsidian_shard"},
			{"", "default:obsidian_shard", ""}
		}
	})
	minetest.register_craft({
		output = "cars:seat",
		recipe = {
			{"", "group:wool"},
			{"group:wool", "group:wool"},
			{"default:steel_ingot", "default:steel_ingot"}
		}
	})
	minetest.register_craft({
		output = "cars:wheel",
		recipe = {
			{"default:obsidian_shard", "default:obsidian_shard", "default:obsidian_shard"},
			{"default:obsidian_shard", "default:steel_ingot", "default:obsidian_shard"},
			{"default:obsidian_shard", "default:obsidian_shard", "default:obsidian_shard"}
		}
	})
end

local sedandef = {
		name = "cars:sedan",
		description = "Sedan",
		acceleration = 5,
		braking = 10,
		coasting = 2,
		gas_usage = 1,
		gas_offset = {x=-1,y=.8,z=-1.1},
		max_speed = 24.5872,
		trunksize = {x=6,y=2},
		trunkloc = {x = 0, y = 4, z = -8},
		engineloc = {x = 0, y = .6, z = 2},
		passengers = {
			{loc = {x = -4.5, y = 4, z = 5.25}, offset = {x = -4.5, y = -2, z = 5.75} },
			{loc = {x = 4.5, y = 4, z = 5.25}, offset = {x = 4.5, y = -2, z = 5.75} },
			{loc = {x = -4.5, y = 4, z = -4.5}, offset = {x = -4.5, y = -2, z = -4} },
			{loc = {x = 4.5, y = 4, z = -4.5}, offset = {x = 4.5, y = -2, z = -4} },
		},
		wheel = {
			frontright = {x=-8.88126,y=3.19412,z=17.25},
			frontleft = {x=8.88126,y=3.19412,z=17.25},
		},
		wheelname = "cars:sedanwheel",
		lights = "sedan",
		steeringwheel = {x=-4.5,y=8.63817,z=10.827},
		--licenseplate = {x = 0, y = 4.5, z = -23.3},
		horn = "horn",
		rpmvalues = {{16, 16, .5}, {10, 10, .4}, {0, 5, .3}},
		enginesound = "longerenginefaded",
		ignitionsound = "ignition",
		--[[craft = {
			{"default:steel_ingot", "default:wood", "default:steel_ingot"},
			{"default:steel_ingot", "default:mese_crystal", "default:steel_ingot"}
		},--]]
		craftschems = {"sedan", "sedan1", "sedan2", "sedan3"},
		inventory_image = "inv_car_grey.png",
		initial_properties = {
			hp_max = 20,
			physical = true,
			stepheight = 1.1,
			weight = 5,
			collisionbox = {-1, -0.05, -1, 1, 1.1, 1},
			visual = "mesh",
			visual_size = {x=1, y=1},
			mesh = "sedan2.b3d",
			textures = {'sedan2UVcombined.png', "sedan2UVcombined.png", "sedan2colored.png"},
			is_visible = true,
			makes_footstep_sound = false,
			automatic_rotate = 0,
			trunkinv = {},
		}
	}
cars_register_car(sedandef)

local policecardef = table.copy(sedandef)
sedandef = nil

policecardef.siren = "siren"
policecardef.sirenlength = 4.4
policecardef.name = "cars:police_sedan"
policecardef.description = "Police Sedan"
policecardef.horn = "uralhorn"
policecardef.lights = "police_sedan"
policecardef.acceleration = 5.5
policecardef.max_speed = 26.8224
policecardef.craftschems = {"police_sedan", "police_sedan1", "police_sedan2", "police_sedan3"}
policecardef.max_force_offroad = 2
policecardef.initial_properties.mesh = "sedan2.b3d"
policecardef.initial_properties.textures = {'sedan2UVcombined.png'}
policecardef.inventory_image = "inv_car_grey.png"
cars_register_car(policecardef)
policecardef = nil
	
minetest.register_entity("cars:sedanwheel", {
    hp_max = 1,
    physical = false,
	pointable = false,
	collide_with_objects = false,
    weight = 5,
    collisionbox = {-0.2,-0.2,-0.2, 0.2,0.2,0.2},
    visual = "mesh",
    visual_size = {x=1, y=1},
    mesh = "sedanwheel.b3d",
    textures = {"sedan2.png"}, -- number of required textures depends on visual
    is_visible = true,
    --makes_footstep_sound = false,
    --automatic_rotate = true,
	on_activate = function(self, staticdata, dtime_s)
		minetest.after(.1, function()
			if not self.object:get_attach() then
				self.object:remove()
			end
		end)
	end,
})

local uraldef = {
		name = "cars:ural",
		description = "Ural",
		acceleration = 4,
		braking = 10,
		coasting = 2,
		max_speed = 24.5872,
		axisval = 14,
		trunksize = {x=8,y=8},
		trunkloc = {x = 0, y = 9, z = -13},
		passengers = {
			-- 2 in Cab
			{loc = {x = -6.29999, y = 16.5, z = 3.36667}, offset = {x = -6.29999, y = 12, z = 3.5} },
			{loc = {x = 6.29999, y = 16.5, z = 3.36667}, offset = {x = 6.29999, y = 12, z = 3.5} },
			-- 4 on back left
			{loc = {x = -9.10001, y = 15.5, z = -42.425}, offset = {x = -9.10001, y = 11, z = -42.425}, rot = {x = 0, y = 90, z = 0} },
			{loc = {x = -9.10001, y = 15.5, z = -33.675}, offset = {x = -9.10001, y = 11, z = -33.675}, rot = {x = 0, y = 90, z = 0} },
			{loc = {x = -9.10001, y = 15.5, z = -24.925}, offset = {x = -9.10001, y = 11, z = -24.925}, rot = {x = 0, y = 90, z = 0} },
			{loc = {x = -9.10001, y = 15.5, z = -16.175}, offset = {x = -9.10001, y = 11, z = -16.175}, rot = {x = 0, y = 90, z = 0} },
			-- 4 on back right
			{loc = {x = 9.10001, y = 15.5, z = -42.425}, offset = {x = 9.10001, y = 11, z = -42.425}, rot = {x = 0, y = -90, z = 0} },
			{loc = {x = 9.10001, y = 15.5, z = -33.675}, offset = {x = 9.10001, y = 11, z = -33.675}, rot = {x = 0, y = -90, z = 0} },
			{loc = {x = 9.10001, y = 15.5, z = -24.925}, offset = {x = 9.10001, y = 11, z = -24.925}, rot = {x = 0, y = -90, z = 0} },
			{loc = {x = 9.10001, y = 15.5, z = -16.175}, offset = {x = 9.10001, y = 11, z = -16.175}, rot = {x = 0, y = -90, z = 0} },
		},
		wheel = {
			frontright = {x=-9.80003,y=5.95,z=.450006},
			frontleft = {x=9.80003,y=5.95,z=.450006},
		},
		wheelname = "cars:uralwheel",
		lights = "ural",
		steeringwheel = {x=-6.29999,y=20.3,z=7.10001},
		--licenseplate = {x = 0, y = 4.5, z = -23.3},
		horn = "uralhorn",
		rpmvalues = {{18, 48, .6}, {12, 32, .7}, {8, 20, .7}, {0, 10, .6}},
		enginesound = "uralenginefaded",
		ignitionsound = "uralignition",
		craft = {
			{"default:steel_ingot", "default:wood", "default:steel_ingot"},
			{"default:steel_ingot", "default:mese_crystal", "default:steel_ingot"}
		},
		extension = {x=0,y=0,z=-28},
		extensionname = "cars:uralextension",
		inventory_image = "inv_car_grey.png",
		initial_properties = {
			hp_max = 20,
			physical = true,
			stepheight = 1.1,
			weight = 5,
			collisionbox = {-1.2, -0.05, -1.2, 1.2, 2.2, 1.2},
			visual = "mesh",
			visual_size = {x=1, y=1},
			mesh = "ural.b3d",
			textures = { "uralUV.png" },
			--textures = {'invisible.png'},
			is_visible = true,
			makes_footstep_sound = false,
			automatic_rotate = 0,
			trunkinv = {},
		}
	}
cars_register_car(uraldef)
	
		
minetest.register_entity("cars:uralwheel", {
    hp_max = 1,
    physical = false,
	pointable = false,
	collide_with_objects = false,
    weight = 5,
    collisionbox = {-0.2,-0.2,-0.2, 0.2,0.2,0.2},
    visual = "mesh",
    visual_size = {x=1, y=1},
    mesh = "uralwheel.b3d",
    textures = {"uralUV.png"}, -- number of required textures depends on visual
    is_visible = true,
    --makes_footstep_sound = false,
    --automatic_rotate = true,
	on_activate = function(self, staticdata, dtime_s)
		minetest.after(.1, function()
			if not self.object:get_attach() then
				self.object:remove()
			end
		end)
	end,
})

minetest.register_entity("cars:uralextension", {
    hp_max = 1,
    physical = true,
    weight = 5,
    collisionbox = {-1.2, -0.05, -1.2, 1.2, 2.2, 1.2},
    visual = "mesh",
    visual_size = {x=1, y=1},
    mesh = "uralwheel.b3d",
    textures = {"invisible.png"}, -- number of required textures depends on visual
    is_visible = true,
    --makes_footstep_sound = false,
    --automatic_rotate = true,
	on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		local parent = self.object:get_attach()
		if not parent then
			self.object:remove()
			return
		end
		parent:punch(puncher, time_from_last_punch, tool_capabilities, dir)
	end,
	on_rightclick = function(self, clicker)
		local parent = self.object:get_attach()
		if not parent then
			self.object:remove()
			return
		end
		local name = clicker:get_player_name()
		parent = parent:get_luaentity()
		if false and default.player_attached[name] and clicker:get_attach() and clicker:get_attach() == parent.object then
			for id, info in pairs(parent.passengers) do
				if info.player and name == info.player:get_player_name() then
					car_rightclick(parent, clicker, id)
				end
			end
		else
			car_rightclick(parent, clicker, getClosest(clicker, parent, 1))
		end
	end,
	on_activate = function(self, staticdata, dtime_s)
		minetest.after(.1, function()
			if not self.object:get_attach() then
				self.object:remove()
				return
			end
			self.object:set_armor_groups({immortal = 1})
		end)
	end,
})

local truckdef = {
		name = "cars:truck",
		description = "Truck",
		acceleration = 4,
		braking = 10,
		axisval = 12,
		coasting = 2,
		gas_usage = 1.2,
		gas_offset = {x=-1,y=.88,z=-1.9766},
		max_speed = 24.5872,
		trunksize = {x=8,y=4},
		trunkloc = {x = 0, y = 5.2, z = -7},
		engineloc = {x = 0, y = 1.4, z = .825},
		passengers = {
			{loc = {x = -5.0625, y = 10.8, z = -4.3625}, offset = {x = -5.0625, y = 4.8, z = -3.8625} },--offset is loc - 6y +.5z
			{loc = {x = 5.0625, y = 10.8, z = -4.3625}, offset = {x = 5.0625, y = 4.8, z = -3.8625} },
		},
		max_force_offroad = 6,
		max_offroad_speed = 20,
		wheel = {
			frontright = {x=-8.77501,y=4.05,z=8.37496},
			frontleft = {x=8.77501,y=4.05,z=8.37496},
		},
		wheelname = "cars:truckwheel",
		lights = "truck",
		steeringwheel = {x=-5.0625,y=14.4542,z=1.27493},
		--licenseplate = {x = 0, y = 4.5, z = -23.3},
		horn = "horn",
		rpmvalues = {{16, 16, .5}, {10, 10, .4}, {0, 5, .3}},
		rpmvalues = {{18, 48, .6}, {12, 32, .7}, {8, 20, .7}, {0, 10, .6}},
		enginesound = "longerenginefaded",
		ignitionsound = "ignition",
		enginesound = "uralenginefaded",
		ignitionsound = "uralignition",
		--[[craft = {
			{"default:steel_ingot", "default:wood", "default:steel_ingot"},
			{"default:steel_ingot", "default:mese_crystal", "default:steel_ingot"}
		},--]]
		--craftschems = {"sedan", "sedan1", "sedan2", "sedan3"},
		inventory_image = "inv_car_grey.png",
		initial_properties = {
			hp_max = 20,
			physical = true,
			stepheight = 1.1,
			weight = 5,
			collisionbox = {-1, -0.05, -1, 1, 1.5, 1},
			visual = "mesh",
			visual_size = {x=1, y=1},
			mesh = "truck.b3d",
			textures = {'truckuvunpainted.png', "truckuv.png", "truckuvcolored.png"},
			is_visible = true,
			makes_footstep_sound = false,
			automatic_rotate = 0,
			trunkinv = {},
		}
	}
cars_register_car(table.copy(truckdef))
truckdef.mesh = "towtruck.b3d"
truckdef.name = "cars:towtruck"
truckdef.description = "Tow Truck"
truckdef.trunksize = {x=0,y=0}
truckdef.towloc = {x=0,y=25,z=-33.475}
truckdef.initial_properties.textures = {'towtruckuvunpainted.png', "towtruckuv.png", "truckuvcolored.png"}
cars_register_car(table.copy(truckdef))

minetest.register_entity("cars:truckwheel", {
    hp_max = 1,
    physical = false,
	pointable = false,
	collide_with_objects = false,
    weight = 5,
    collisionbox = {-0.2,-0.2,-0.2, 0.2,0.2,0.2},
    visual = "mesh",
    visual_size = {x=1, y=1},
    mesh = "truckwheel.b3d",
    textures = {"truckuv.png"}, -- number of required textures depends on visual
    is_visible = true,
    --makes_footstep_sound = false,
    --automatic_rotate = true,
	on_activate = function(self, staticdata, dtime_s)
		minetest.after(.1, function()
			if not self.object:get_attach() then
				self.object:remove()
			end
		end)
	end,
})

local jackhammerdef = {
		name = "cars:jackhammer",
		description = "Jackhammer Vehicle",
		acceleration = 2,
		braking = 4,
		axisval = 10,
		coasting = 2,
		gas_usage = 1.2,
		gas_offset = {x=-.35,y=1.3,z=-.7},
		max_speed = 6.7056,
		--trunksize = {x=0,y=0},
		--trunkloc = {x = 0, y = 5.2, z = -7},
		engineloc = {x = 0, y = .75, z = -1},
		passengers = {
			{loc = {x = 0, y = 7, z = -2.5}, offset = {x = 0, y = 1, z = -3} },--offset is loc - 6y +.5z
		},
		max_force_offroad = 8,
		max_offroad_speed = 6.7056,
		wheel = {
			frontright = {x=-5.525,y=2.925,z=5.85},
			frontleft = {x=5.525,y=2.925,z=5.85},
		},
		wheelname = "cars:jackhammerwheel",
		steeringwheel = {x=0,y=10.725,z=3.25},
		--licenseplate = {x = 0, y = 4.5, z = -23.3},
		horn = "horn",
		rpmvalues = {{16, 16, .5}, {10, 10, .4}, {0, 5, .3}},
		rpmvalues = {{18, 48, .6}, {12, 32, .7}, {8, 20, .7}, {0, 10, .6}},
		enginesound = "longerenginefaded",
		ignitionsound = "ignition",
		enginesound = "uralenginefaded",
		ignitionsound = "uralignition",
		--[[craft = {
			{"default:steel_ingot", "default:wood", "default:steel_ingot"},
			{"default:steel_ingot", "default:mese_crystal", "default:steel_ingot"}
		},--]]
		--craftschems = {"sedan", "sedan1", "sedan2", "sedan3"},
		inventory_image = "inv_car_grey.png",
		drill = {
			{},
			{x=0,y=.45,z=1.6},
			{x=0,y=1.45,z=1.8},
			{x=0,y=2,z=1.2},
			{x=0,y=-.15,z=1}
		},
		initial_properties = {
			hp_max = 20,
			physical = true,
			stepheight = 1.1,
			weight = 5,
			collisionbox = {-.9, -0.05, -.9, .9, 1.2, .9},
			visual = "mesh",
			visual_size = {x=1, y=1},
			mesh = "jackhammer.b3d",
			textures = {'jackhammerUV.png'},
			is_visible = true,
			makes_footstep_sound = false,
			automatic_rotate = 0,
			--trunkinv = {},
		}
	}

cars_register_car(table.copy(jackhammerdef))

minetest.register_entity("cars:jackhammerwheel", {
    hp_max = 1,
    physical = false,
	pointable = false,
	collide_with_objects = false,
    weight = 5,
    collisionbox = {-0.2,-0.2,-0.2, 0.2,0.2,0.2},
    visual = "mesh",
    visual_size = {x=1, y=1},
    mesh = "jackhammerwheel.b3d",
    textures = {"jackhammerUV.png"}, -- number of required textures depends on visual
    is_visible = true,
    --makes_footstep_sound = false,
    --automatic_rotate = true,
	on_activate = function(self, staticdata, dtime_s)
		minetest.after(.1, function()
			if not self.object:get_attach() then
				self.object:remove()
			end
		end)
	end,
})
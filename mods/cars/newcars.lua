local cars_dyes = {
	{"grey",       "8c8c8c",       "Grey"},
	{"dark_grey",  "313131",  "Dark Grey"},
	{"black",      "292929",      "Black"},
	{"violet",     "440578",     "Violet"},
	{"blue",       "003c82",       "Blue"},
	{"cyan",       "008a92",       "Cyan"},
	{"dark_green", "195600", "Dark Green"},
	{"green",      "4fbe1c",      "Green"},
	{"yellow",     "fde40f",     "Yellow"},
	{"brown",      "482300",      "Brown"},
	{"orange",     "c74410",     "Orange"},
	{"red",        "ba1414",        "Red"},
	{"magenta",    "c30469",    "Magenta"},
	{"pink",       "f57b7b",       "Pink"},
}

local sedandef = {
		name = "cars:sedan",
		description = "Sedan",
		acceleration = 3,
		braking = 10,
		coasting = 2,
		max_speed = 24.5872,
		trunksize = {x=6,y=2},
		trunkloc = {x = 0, y = 4, z = -8},
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
		lights = "cars:sedanlights",
		steeringwheel = {x=-4.5,y=8.63817,z=10.827},
		--licenseplate = {x = 0, y = 4.5, z = -23.3},
		horn = "horn",
		rpmvalues = {{16, 16, .5}, {10, 10, .4}, {0, 5, .3}},
		enginesound = "longerenginefaded",
		ignitionsound = "ignition",
		craft = {
			{"default:steel_ingot", "default:wood", "default:steel_ingot"},
			{"default:steel_ingot", "default:mese_crystal", "default:steel_ingot"}
		},
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
			textures = { "sedan3.png^(sedan3.png^[mask:sedanmask2.png^[multiply:#"..cars_dyes[math.random(14)][2]..")" },
			--textures = {'invisible.png'},
			is_visible = true,
			makes_footstep_sound = false,
			automatic_rotate = 0,
			trunkinv = {},
		}
	}
	cars_register_car(sedandef)
	
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

minetest.register_entity("cars:sedanlights",{
	hp_max = 1,
    physical = false,
	pointable = false,
	collide_with_objects = false,
    weight = 5,
    collisionbox = {-0.2,-0.2,-0.2, 0.2,0.2,0.2},
    visual = "mesh",
    visual_size = {x=1, y=1},
    is_visible = true,
	glow = 7,
    mesh = "sedanlights.b3d",
    textures = {"invisible.png"},
	on_activate = function(self, staticdata, dtime_s)
		minetest.after(.1, function()
			if not self.object:get_attach() then
				self.object:remove()
			end
		end)
	end,
	on_step = function(self, dtime)
		if not self.timer then self.timer = 0 end
		if not self.blink then self.blink = false end
		self.timer = self.timer + dtime
		local automatic = self.leftblinker or self.rightblinker or self.flashers
		if (self.timer > .5 and automatic) or self.update then
			if self.update then
				self.update = false
			else
				self.blink = not self.blink
				self.timer = 0
				if self.leftblinker or self.rightblinker or self.flashers then
					if self.blink then
						minetest.sound_play("indicator2", {
							max_hear_distance = 6,
							gain = 1,
							object = self.object
						})
					else
						minetest.sound_play("indicator1", {
							max_hear_distance = 6,
							gain = 1,
							object = self.object
						})
					end
				end
			end
			local lighttable = {headlights = self.headlights, brakelights = self.brakelights, leftblinker = self.leftblinker and self.blink, rightblinker = self.rightblinker and self.blink, rightflasher = self.flashers and self.blink, leftflasher = self.flashers and self.blink}
			
			cars.setlighttexture(self.object, lighttable, "sedan")
		end
	end,
})

local uraldef = {
		name = "cars:ural",
		description = "Ural",
		acceleration = 3,
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
		--lights = "cars:sedanlights",
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
			textures = { "uralpal.png" },
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
    textures = {"uralpal.png"}, -- number of required textures depends on visual
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
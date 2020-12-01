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
		acceleration = 4,
		braking = 10,
		coasting = 2,
		max_speed = 20,
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
		enginesound = "longerenginefaded",
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
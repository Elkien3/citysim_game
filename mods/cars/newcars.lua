local sedandef = {
		name = "cars:sedan",
		description = "sedan car",
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
			hp_max = 1,
			physical = true,
			stepheight = 1.1,
			weight = 5,
			collisionbox = {-1, -0.05, -1, 1, 1.1, 1},
			visual = "mesh",
			visual_size = {x=1, y=1},
			mesh = "sedan2.b3d",
			textures = { "sedan2.png^(sedan2.png^[mask:sedanmask2.png^[multiply:#ffb900)" }, -- number of required textures depends on visual
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
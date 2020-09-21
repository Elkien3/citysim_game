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
			{loc = {x = -4.5, y = 4, z = 4.8}, offset = {x = -4, y = -3, z = 2} },
			{loc = {x = 4.5, y = 4, z = 4.8}, offset = {x = 4, y = -3, z = 2} },
			{loc = {x = -4.5, y = 4, z = -4.8}, offset = {x = -4, y = -3, z = -2} },
			{loc = {x = 4.5, y = 4, z = -4.8}, offset = {x = 4, y = -3, z = -2} },
		},
		wheel = {
			frontright = {z=15.75,y=2.6,x=-9},
			frontleft = {z=15.75,y=2.6,x=9},
			backright = {z=-11.75,y=2.6,x=-9},
			backleft = {z=-11.75,y=2.6,x=9},
		},
		wheelsize = 1.3,
		steeringwheel = {x=-4.5,y=8.25,z=9.5},
		licenseplate = {x = -.38, y = -0.85, z = -15.51},
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
			mesh = "sedan.b3d",
			textures = {"sedanuv.png"}, -- number of required textures depends on visual
			is_visible = true,
			makes_footstep_sound = false,
			automatic_rotate = 0,
			trunkinv = {},
		}
	}
	cars_register_car(sedandef)
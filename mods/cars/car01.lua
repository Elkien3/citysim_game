local carlist = {"black", "blue", "brown", "cyan", 
"dark_green", "dark_grey", "green", "grey", "magenta", 
"orange", "pink", "red", "violet", "white", "yellow"}

for id, color in pairs (carlist) do
	local car01def = {
		name = "cars:car_"..color,
		description = color:gsub("^%l", string.upper):gsub("_", " ").." car",
		acceleration = 4,
		braking = 10,
		coasting = 2,
		max_speed = 20,
		trunksize = {x=6,y=2},
		trunkloc = {x = 0, y = 4, z = -8},
		passengers = {
			{loc = {x = -4, y = 3, z = 3}, offset = {x = -4, y = -2, z = 2} },
			{loc = {x = 4, y = 3, z = 3}, offset = {x = 4, y = -2, z = 2} },
			{loc = {x = -4, y = 3, z = -4}, offset = {x = -4, y = -2, z = -2} },
			{loc = {x = 4, y = 3, z = -4}, offset = {x = 4, y = -2, z = -2} },
		},
		wheel = {
			frontright = {z=10.75,y=2.5,x=-8.875},
			frontleft = {z=10.75,y=2.5,x=8.875},
			backright = {z=-11.75,y=2.5,x=-8.875},
			backleft = {z=-11.75,y=2.5,x=8.875},
		},
		steeringwheel = {z=5.62706,y=8.25,x=-4.0},
		licenseplate = {x = -.38, y = -0.85, z = -15.51},
		horn = "horn",
		enginesound = "longerenginefaded",
		craft = {
			{"default:steel_ingot", "wool:"..color, "default:steel_ingot"},
			{"default:steel_ingot", "default:mese_crystal", "default:steel_ingot"}
		},
		inventory_image = "inv_car_"..color..".png",
		initial_properties = {
			hp_max = 1,
			physical = true,
			stepheight = 1.1,
			weight = 5,
			collisionbox = {-0.6, -0.05, -0.6, 0.6, 1.1, 0.6},
			visual = "mesh",
			visual_size = {x=1, y=1},
			mesh = "car.x",
			textures = {"car_"..color..".png^licenseplate.png"}, -- number of required textures depends on visual
			is_visible = true,
			makes_footstep_sound = false,
			automatic_rotate = 0,
			trunkinv = {},
		}
	}
	cars_register_car(car01def)
end
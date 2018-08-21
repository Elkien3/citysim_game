
-- get mod path
local mpath = minetest.get_modpath("vehicle_mash")

-- load framework
dofile(mpath.."/framework.lua")

-- load crafts
dofile(mpath.."/crafts.lua")

-- ***********************
-- load vehicles down here
-- ***********************

--[[ ** 126r and F1 **
------------------------------------------------------------------------------
-- create Cars common def
local cars_def = {
	--adjust to change how vehicle reacts while driving
	terrain_type = 1,	-- 0 = air, 1 = land, 2 = liquid, 3 = land + liquid
	--model specific stuff
	visual = "mesh",
	visual_size = {x=1, y=1},
	wield_scale = {x=1, y=1, z=1},
	--player specific stuff
	player_rotation = {x=0,y=0,z=0},
	driver_eye_offset = {x=0, y=0, z=0},
	number_of_passengers = 0,
	passenger_attach_at = {x=0,y=0,z=0},
	passenger_eye_offset = {x=0, y=0, z=0},
	--drop and recipe
	drop_on_destroy = "",
	recipe = nil
}

-- vehicle specific values in the following files
-- you can override any common values from here
loadfile(mpath.."/126r.lua")(table.copy(cars_def))
loadfile(mpath.."/f1.lua")(table.copy(cars_def))
--]]

-- ** CAR01s **
------------------------------------------------------------------------------
-- create CAR01 common def
local car01_def = {
	--adjust to change how vehicle reacts while driving
	terrain_type = 1,
	max_speed_forward = 10,
	max_speed_reverse = 7,
	accel = 2,
	braking = 4,
	turn_speed = 2,
	stepheight = 1.1,
	--model specific stuff
	visual = "mesh",
	mesh = "car.x",
	visual_size = {x=1, y=1},
	wield_scale = {x=1, y=1, z=1},
	collisionbox = {-0.6, -0.05, -0.6, 0.6, 1, 0.6},
	onplace_position_adj = -0.45,
	--player specific stuff
	player_rotation = {x=0,y=90,z=0},
	driver_attach_at = {x=3.5,y=12,z=3.5},
	driver_eye_offset = {x=-4, y=0, z=0},
	number_of_passengers = 1,
	passenger_attach_at = {x=3.5,y=12,z=-3.5},
	passenger_eye_offset = {x=4, y=0, z=0},
	--drop and recipe
	drop_on_destroy = "",
	recipe = nil
}

-- vehicle specific values in the following files
-- you can override any common values from here
loadfile(mpath.."/black.lua")(table.copy(car01_def))
loadfile(mpath.."/blue.lua")(table.copy(car01_def))
loadfile(mpath.."/brown.lua")(table.copy(car01_def))
loadfile(mpath.."/cyan.lua")(table.copy(car01_def))
loadfile(mpath.."/dark_green.lua")(table.copy(car01_def))
loadfile(mpath.."/dark_grey.lua")(table.copy(car01_def))
loadfile(mpath.."/green.lua")(table.copy(car01_def))
loadfile(mpath.."/grey.lua")(table.copy(car01_def))
loadfile(mpath.."/magenta.lua")(table.copy(car01_def))
loadfile(mpath.."/orange.lua")(table.copy(car01_def))
loadfile(mpath.."/pink.lua")(table.copy(car01_def))
loadfile(mpath.."/red.lua")(table.copy(car01_def))
loadfile(mpath.."/violet.lua")(table.copy(car01_def))
loadfile(mpath.."/white.lua")(table.copy(car01_def))
loadfile(mpath.."/yellow.lua")(table.copy(car01_def))
--oadfile(mpath.."/hot_rod.lua")(table.copy(car01_def))
--oadfile(mpath.."/nyan_ride.lua")(table.copy(car01_def))
--oadfile(mpath.."/oerkki_bliss.lua")(table.copy(car01_def))
--oadfile(mpath.."/road_master.lua")(table.copy(car01_def))


--[[ ** MeseCars **
------------------------------------------------------------------------------
-- create Mesecar common def
local mesecar_def = {
	--adjust to change how vehicle reacts while driving
	terrain_type = 1,
	max_speed_forward = 10,
	max_speed_reverse = 7,
	accel = 3,
	braking = 6,
	turn_speed = 4,
	stepheight = 0.6,
	--model specific stuff
	visual = "cube",
	mesh = "",
	visual_size = {x=1.5, y=1.5},
	wield_scale = {x=1, y=1, z=1},
	collisionbox = {-0.75, -0.75, -0.75, 0.75, 0.75, 0.75},
	onplace_position_adj = 0.25,
	--player specific stuff
	player_rotation = {x=0,y=0,z=0},
	driver_attach_at = {x=0,y=2,z=0},
	driver_eye_offset = {x=0, y=0, z=0},
	number_of_passengers = 0,
	passenger_attach_at = {x=0,y=0,z=0},
	passenger_eye_offset = {x=0, y=0, z=0},
	--drop and recipe
	drop_on_destroy = "",
	recipe = nil
}

-- vehicle specific values in the following files
-- you can override any common values from here
loadfile(mpath.."/mese_blue.lua")(table.copy(mesecar_def))
loadfile(mpath.."/mese_pink.lua")(table.copy(mesecar_def))
loadfile(mpath.."/mese_purple.lua")(table.copy(mesecar_def))
loadfile(mpath.."/mese_yellow.lua")(table.copy(mesecar_def))


-- ** Boats **
------------------------------------------------------------------------------
-- create boats common def
local boat_def = {
	--adjust to change how vehicle reacts while driving
	terrain_type = 2,
	max_speed_forward = 3,
	max_speed_reverse = 3,
	accel = 3,
	braking = 3,
	turn_speed = 3,
	stepheight = 0,
	--model specific stuff
	visual = "mesh",
	visual_size = {x=1, y=1},
	wield_scale = {x=1, y=1, z=1},
	collisionbox = {-0.5, -0.35, -0.5, 0.5, 0.3, 0.5},
	onplace_position_adj = 0,
	textures = {"default_wood.png"},
	--player specific stuff
	player_rotation = {x=0, y=0, z=0},
	driver_attach_at = {x=0,y=11,z=-3},
	driver_eye_offset = {x=0, y=0, z=0},
	number_of_passengers = 0,
	passenger_attach_at = {x=0,y=0,z=0},
	passenger_eye_offset = {x=0, y=0, z=0}
}

-- vehicle specific values in the following files
-- you can override any common values from here
loadfile(mpath.."/boat.lua")(table.copy(boat_def))
loadfile(mpath.."/rowboat.lua")(table.copy(boat_def))


-- ** Hovercraft **
------------------------------------------------------------------------------
-- create hovercraft common def
local hover_def = {
	--adjust to change how vehicle reacts while driving
	terrain_type = 3,
	max_speed_forward = 10,
	max_speed_reverse = 0,
	accel = 3,
	braking = 1,
	turn_speed = 2,
	stepheight = 1.1,
	--model specific stuff
	visual = "mesh",
	mesh = "hovercraft.x",
	visual_size = {x=1, y=1},
	wield_scale = {x=1, y=1, z=1},
	collisionbox = {-0.8, -0.25, -0.8, 0.8, 1.2, 0.8},
	onplace_position_adj = -0.25,
	--player specific stuff
	player_rotation = {x=0,y=90,z=0},
	driver_attach_at = {x=-2,y=16.5,z=0},
	driver_eye_offset = {x=0, y=0, z=0},
	number_of_passengers = 0,
	passenger_attach_at = {x=0,y=0,z=0},
	passenger_eye_offset = {x=0, y=0, z=0},
	--drop and recipe
	drop_on_destroy = "",
	recipe = nil
}

-- vehicle specific values in the following files
-- you can override any common values from here
loadfile(mpath.."/hover_blue.lua")(table.copy(hover_def))

-- free unneeded global(s)
core.after(10, function()
	vehicle_mash.register_vehicle = nil
end)
--]]
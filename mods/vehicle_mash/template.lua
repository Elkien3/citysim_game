local name = "car_template"				-- mod name of vehicle

local definition = {
	description = "Template car",			-- name as seen in inventory
	collisionbox = {0, 0, 0, 0, 0, 0},		-- back, bottom, starboard, front, top, port
	onplace_position_adj = 0,			-- adjust placement position up/down
	is_boat = false,				-- does vehicle travel on water?
	player_rotation = {x=0,y=0,z=0},		-- rotate player so they sit facing the correct direction
	driver_attach_at = {x=0,y=0,z=0},		-- attach the driver at
	driver_eye_offset = {x=0, y=0, z=0},	-- offset for first person driver view
	number_of_passengers = 0,			-- testing: 0 for none, do not increase at this time!
	passenger_attach_at = {x=0,y=0,z=0},		-- attach the passenger, if applicable, at
	passenger_eye_offset = {x=0, y=0, z=0},		-- offset for first person passenger view
	inventory_image = "filename.png",		-- image to use in inventory
	wield_image = "filename.png",			-- image to use in hand
	wield_scale = {x=1, y=1, z=1},			--
	visual = "mesh",				-- what type of object (mesh, cube, etc...)
	mesh = "filename.ext",				-- mesh model to use
	textures = {"filename.png"},			-- mesh texture(s)
	visual_size = {x=1, y=1},			-- adjust vehicle size
	stepheight = 0,					-- what can the vehicle climb over?, 0.6 = climb slabs, 1.1 = climb nodes
	max_speed_forward = 10,				-- vehicle maximum forward speed
	max_speed_reverse = 5,				-- vehicle maximum reverse speed
	accel = 1,					-- how fast vehicle accelerates
	braking = 2,					-- how fast can the vehicle stop
	turn_speed = 2,					-- how quick can the vehicle turn
	drop_on_destroy = "",				-- what gets dropped when vehicle is destroyed
	recipe = {}					-- crafting recipe
}

-- nothing to change down here
vehicle_mash.register_vehicle("vehicle_mash:"..name, definition)

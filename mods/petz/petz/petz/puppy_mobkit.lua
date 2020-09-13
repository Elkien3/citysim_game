--
--PUPPY
--
local S = ...

local pet_name = "puppy"
local scale_model = 2.25
local mesh = 'petz_puppy.b3d'
local textures= {"petz_puppy.png", "petz_puppy2.png", "petz_puppy3.png"}
local p1 = {x= -0.0625, y = -0.5, z = -0.125}
local p2 = {x= 0.125, y = -0.1875, z = 0.25}
local collisionbox, collisionbox_baby = petz.get_collisionbox(p1, p2, scale_model, nil)

minetest.register_entity("petz:"..pet_name, {
	--Petz specifics
	type = "puppy",
	init_tamagochi_timer = true,
	is_pet = true,
	has_affinity = true,
	is_wild = false,
	give_orders = true,
	can_be_brushed = true,
	capture_item = "lasso",
	follow = petz.settings.puppy_follow,
	sleep_at_night = true,
	sleep_ratio = 0.3,
	rotate = petz.settings.rotate,
	physical = true,
	stepheight = 0.1,	--EVIL!
	collide_with_objects = true,
	collisionbox = collisionbox,
	visual = petz.settings.visual,
	mesh = mesh,
	textures = textures,
	visual_size = {x=petz.settings.visual_size.x*scale_model, y=petz.settings.visual_size.y*scale_model},
	static_save = true,
	get_staticdata = mobkit.statfunc,
	-- api props
	springiness= 0,
	buoyancy = 0.5, -- portion of hitbox submerged
	max_speed = 2,
	jump_height = 1.5,
	view_range = 10,
	lung_capacity = 10, -- seconds
	max_hp = 8,
	makes_footstep_sound = false,

	--head = {
		--position = vector.new(0, 0.0969, 0.1939),
		--rotation_origin = vector.new(-90, -90, 0), --in degrees, normally values are -90, 0, 90
	--},

	attack={range=0.5, damage_groups={fleshy=3}},
	animation = {
		walk={range={x=1, y=12}, speed=25, loop=true},
		run={range={x=13, y=25}, speed=25, loop=true},
		stand={
			{range={x=26, y=46}, speed=5, loop=true},
			{range={x=47, y=59}, speed=5, loop=true},
			{range={x=81, y=94}, speed=5, loop=true},
		},
		sit = {range={x=60, y=65}, speed=5, loop=false},
		sleep = {range={x=94, y=113}, speed=10, loop=false},
	},
	sounds = {
		misc = {"petz_puppy_bark", "petz_puppy_bark_2", "petz_puppy_bark_3"},
		moaning = "petz_puppy_moaning",
	},

	logic = petz.herbivore_brain,

	on_activate = function(self, staticdata, dtime_s) --on_activate, required
		mobkit.actfunc(self, staticdata, dtime_s)
		petz.set_initial_properties(self, staticdata, dtime_s)
	end,

	on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		petz.on_punch(self, puncher, time_from_last_punch, tool_capabilities, dir)
	end,

	on_rightclick = function(self, clicker)
		petz.on_rightclick(self, clicker)
	end,

	on_step = function(self, dtime)
		mobkit.stepfunc(self, dtime) -- required
		petz.on_step(self, dtime)
	end,
})

petz:register_egg("petz:puppy", S("Puppy"), "petz_spawnegg_puppy.png", true)

local S = ...

local pet_name = "moth"
local scale_model = 1.0
local mesh = 'petz_moth.b3d'
local textures= {"petz_moth.png"}
local p1 = {x= -0.25, y = -0.5, z = -0.4375}
local p2 = {x= 0.3125, y = -0.1875, z = 0.1875}
local collisionbox, collisionbox_baby = petz.get_collisionbox(p1, p2, scale_model, nil)

minetest.register_entity("petz:"..pet_name,{
	--Petz specifics
	type = "moth",
	init_tamagochi_timer = false,
	is_pet = false,
	can_fly = true,
	lay_eggs = true,
	lay_eggs_in_nest = false,
	type_of_egg = "node",
	bottled = "petz:bottle_moth",
	max_height = 3,
	spawn_at_night = true,
	die_at_daylight = true,
	max_daylight_level = 8,
	has_affinity = false,
	is_wild = false,
	give_orders = false,
	can_be_brushed = false,
	capture_item = "net",
	follow = petz.settings.moth_follow,
	--automatic_face_movement_dir = 0.0,
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
	max_speed = 2.5,
	jump_height = 2.0,
	view_range = 10,
	lung_capacity = 10, -- seconds
	max_hp = 4,

	attack={range=0.5, damage_groups={fleshy=3}},
	animation = {
		walk={range={x=1, y=12}, speed=25, loop=true},
		run={range={x=13, y=25}, speed=25, loop=true},
		stand={
			{range={x=26, y=46}, speed=5, loop=true},
			{range={x=47, y=59}, speed=5, loop=true},
			{range={x=60, y=70}, speed=5, loop=true},
			{range={x=71, y=91}, speed=5, loop=true},
		},
		fly={range={x=92, y=98}, speed=25, loop=true},
		stand_fly={range={x=92, y=98}, speed=25, loop=true},
	},
	sounds = {
		misc = "petz_moth_chirp",
		moaning = "petz_moth_moaning",
	},

	logic = petz.herbivore_brain,

	on_activate = function(self, staticdata, dtime_s) --on_activate, required
		mobkit.actfunc(self, staticdata, dtime_s)
		petz.set_initial_properties(self, staticdata, dtime_s)
		petz.init_lay_eggs(self)
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

petz:register_egg("petz:moth", S("Moth"), "petz_spawnegg_moth.png", true)

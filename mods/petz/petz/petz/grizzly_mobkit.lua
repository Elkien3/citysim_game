--
--GRIZZLY
--
local S = ...

local pet_name = "grizzly"
local scale_model = 2.2
petz.grizzly = {}
local mesh = 'petz_grizzly.b3d'
local textures= {"petz_grizzly.png", "petz_grizzly2.png"}
local p1 = {x= -0.25, y = -0.5, z = -0.4375}
local p2 = {x= 0.25, y = 0.25, z = 0.4375}
local collisionbox, collisionbox_baby = petz.get_collisionbox(p1, p2, scale_model, nil)

minetest.register_entity("petz:"..pet_name,{
	--Petz specifics
	type = "grizzly",
	init_tamagochi_timer = true,
	is_pet = true,
	has_affinity = true,
	is_wild = true,
	attack_player = true,
	give_orders = true,
	can_be_brushed = true,
	capture_item = "lasso",
	follow = petz.settings.grizzly_follow,
	drops = {
		{name = "petz:bone", chance = 5, min = 1, max = 1,},
	},
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
	max_speed = 2.3,
	jump_height = 1.5,
	view_range = 10,
	lung_capacity = 10, -- seconds
	max_hp = 25,

	attack={range=0.5, damage_groups={fleshy=7}},
	animation = {
		walk={range={x=1, y=12}, speed=25, loop=true},
		run={range={x=13, y=25}, speed=25, loop=true},
		stand={
			{range={x=26, y=46}, speed=5, loop=true},
			{range={x=47, y=59}, speed=5, loop=true},
			{range={x=82, y=94}, speed=5, loop=true},
		},
		sit = {range={x=60, y=65}, speed=5, loop=false},
	},
	sounds = {
		misc = "petz_grizzly_growl",
		moaning = "petz_grizzly_moaning",
	},

	--punch_start = 83, stand4_end = 95,

	logic = petz.predator_brain,

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

petz:register_egg("petz:grizzly", S("Grizzly"), "petz_spawnegg_grizzly.png", true)

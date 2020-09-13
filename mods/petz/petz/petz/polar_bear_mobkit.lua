--
--POLAR BEAR
--
local S = ...

local pet_name = "polar_bear"
local scale_model = 2.25
petz.polar_bear = {}
local mesh = 'petz_polar_bear.b3d'
local textures= {"petz_polar_bear.png"}
local p1 = {x= -0.25, y = -0.5, z = -0.4375}
local p2 = {x= 0.25, y = 0.125, z = 0.5}
local collisionbox, collisionbox_baby = petz.get_collisionbox(p1, p2, scale_model, nil)

minetest.register_entity("petz:"..pet_name,{
	--Petz specifics
	type = "polar_bear",
	init_tamagochi_timer = false,
	is_pet = false,
	has_affinity = false,
	is_wild = true,
	attack_player = true,
	give_orders = false,
	can_be_brushed = false,
	capture_item = "lasso",
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
	max_hp = 30,

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
		misc = "petz_polar_bear_growl",
		attack = "petz_polar_bear_attack",
	},

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

petz:register_egg("petz:polar_bear", S("Polar Bear"), "petz_spawnegg_polar_bear.png", true)

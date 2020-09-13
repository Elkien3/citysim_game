--
--CHICKEN
--
local S = ...

local pet_name = "chicken"
local scale_model = 2.1
local mesh = 'petz_chicken.b3d'
local textures= {"petz_chicken.png", "petz_chicken2.png", "petz_chicken3.png"}
local p1 = {x= -0.0625, y = -0.5, z = -0.125}
local p2 = {x= 0.125, y = -0.125, z = 0.1875}
local collisionbox, collisionbox_baby = petz.get_collisionbox(p1, p2, scale_model, nil)

minetest.register_entity("petz:"..pet_name,{
	--Petz specifics
	type = "chicken",
	init_tamagochi_timer = false,
	is_pet = true,
	has_affinity = false,
	is_wild = false,
	give_orders = false,
	feathered = true,
	can_be_brushed = false,
	capture_item = "net",
	lay_eggs = true,
	lay_eggs_in_nest = true,
	type_of_egg = "item",
	follow = petz.settings.chicken_follow,
	drops = {
		{name = "petz:raw_chicken", chance = 3, min = 1, max = 1,},
		{name = "petz:bone", chance = 6, min = 1, max = 1,},
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
	max_speed = 2,
	jump_height = 1.5,
	view_range = 10,
	lung_capacity = 10, -- seconds
	max_hp = 8,

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
	},
	sounds = {
		misc = {"petz_chicken_cluck", "petz_chicken_cluck_2", "petz_chicken_cluck_3"},
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

petz:register_egg("petz:chicken", S("Chicken"), "petz_spawnegg_chicken.png", true)

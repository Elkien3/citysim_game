--
--TURTLE
--
local S = ...

local pet_name = "turtle"
local scale_model = 2.0
petz.turtle = {}
local mesh = 'petz_turtle.b3d'
local textures= {"petz_turtle.png", "petz_turtle2.png", "petz_turtle3.png",}
local p1 = {x= -0.1875, y = -0.5, z = -0.1875}
local p2 = {x= 0.1875, y = 0.01, z = 0.25}
local collisionbox, collisionbox_baby = petz.get_collisionbox(p1, p2, scale_model, nil)

minetest.register_entity("petz:"..pet_name,{
	--Petz specifics
	type = "turtle",
	is_pet = false,
	has_affinity = false,
	is_wild = false,
	attack_player = false,
	give_orders = false,
	can_be_brushed = false,
	capture_item = "net",
	follow = petz.settings.turtle_follow,
	drops = {
		{name = "petz:turtle_shell", chance = 3, min = 1, max = 1,},
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
	buoyancy = 1.1, -- portion of hitbox submerged
	max_speed = 0.35,
	jump_height = 1.5,
	view_range = 10,
	max_hp = 25,

	attack={range=0.5, damage_groups={fleshy=7}},
	animation = {
		walk={range={x=1, y=12}, speed=10, loop=true},
		run={range={x=13, y=25}, speed=20, loop=true},
		stand={
			{range={x=26, y=46}, speed=5, loop=true},
			{range={x=47, y=59}, speed=5, loop=true},
		},
		def = {range={x=101, y=113}, speed=5, loop=true},
	},

	logic = petz.semiaquatic_brain,

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

petz:register_egg("petz:turtle", S("Turtle"), "petz_spawnegg_turtle.png", true)

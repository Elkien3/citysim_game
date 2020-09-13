--
--BEAVER
--
local S = ...

local pet_name = "beaver"
local scale_model = 1.8
petz.beaver = {}
local mesh = 'petz_beaver.b3d'
local textures= {"petz_beaver.png"}
local p1 = {x= -0.125, y = -0.5, z = -0.1875}
local p2 = {x= 0.1875, y = -0.0625, z = 0.375}
local collisionbox, collisionbox_baby = petz.get_collisionbox(p1, p2, scale_model, nil)

minetest.register_entity("petz:"..pet_name,{
	--Petz specifics
	type = "beaver",
	is_pet = false,
	can_swin = true,
	has_affinity = false,
	is_wild = false,
	attack_player = false,
	give_orders = false,
	can_be_brushed = false,
	capture_item = "lasso",
	follow = petz.settings.beaver_follow,
	drops = {
		{name = "petz:bone", chance = 5, min = 1, max = 1,},
		{name = "petz:beaver_fur", chance = 1, min = 1, max = 1,},
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
	max_speed = 1.0,
	jump_height = 1.5,
	view_range = 10,
	max_hp = 15,

	attack={range=0.5, damage_groups={fleshy=7}},
	animation = {
		walk={range={x=1, y=12}, speed=25, loop=true},
		run={range={x=13, y=25}, speed=25, loop=true},
		stand={
			{range={x=26, y=46}, speed=5, loop=true},
			{range={x=46, y=60}, speed=5, loop=true},
			{range={x=82, y=95}, speed=5, loop=true},
		},
		sit = {range={x=60, y=81}, speed=5, loop=false},
		def = {range={x=96, y=116}, speed=25, loop=true},
	},
	sounds = {
		misc = "petz_beaver_sound",
		moaning = "petz_beaver_moaning",
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

petz:register_egg("petz:beaver", S("Beaver"), "petz_spawnegg_beaver.png", true)

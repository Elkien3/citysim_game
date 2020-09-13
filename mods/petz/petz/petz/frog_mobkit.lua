--
--FROG
--
local S = ...

local pet_name = "frog"
local scale_model = 1.2
local mesh = 'petz_frog.b3d'
local textures= {"petz_frog.png", "petz_frog2.png", "petz_frog3.png"}
local p1 = {x= -0.125, y = -0.5, z = -0.25}
local p2 = {x= 0.1875, y = -0.1875, z = 0.1875}
local collisionbox, collisionbox_baby = petz.get_collisionbox(p1, p2, scale_model, nil)

minetest.register_entity("petz:"..pet_name,{
	--Petz specifics
	type = "frog",
	is_pet = false,
	has_affinity = false,
	is_wild = false,
	attack_player = false,
	give_orders = false,
	can_be_brushed = false,
	capture_item = "net",
	follow = petz.settings.frog_follow,
	drops = {
		{name = "petz:frog_leg", chance = 1, min = 1, max = 1,},
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
	jump_height = 3.0,
	view_range = 10,
	max_hp = 15,

	attack={range=0.5, damage_groups={fleshy=7}},
	animation = {
		walk={range={x=26, y=38}, speed=25, loop=true},
		run={range={x=26, y=38}, speed=30, loop=true},
		stand={
			{range={x=0, y=12}, speed=5, loop=true},
		},
		def = {range={x=39, y=51}, speed=15, loop=true},
	},
	sounds = {
		misc = "petz_frog_croak",
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

petz:register_egg("petz:frog", S("Frog"), "petz_spawnegg_frog.png", true)

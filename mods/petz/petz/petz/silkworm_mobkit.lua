--
--SILKWORM
--
local S = ...

local pet_name = "silkworm"
local scale_model = 0.75
local mesh = 'petz_silkworm.b3d'
local textures= {"petz_silkworm.png", "petz_silkworm2.png", "petz_silkworm3.png"}
local p1 = {x= -0.125, y = -0.5, z = -0.3125}
local p2 = {x= 0.0625, y = -0.25, z = 0.3125}
local collisionbox, collisionbox_baby = petz.get_collisionbox(p1, p2, scale_model, nil)

minetest.register_entity("petz:"..pet_name,{
	--Petz specifics
	type = "silkworm",
	init_tamagochi_timer = false,
	is_pet = false,
	has_affinity = false,
	is_wild = false,
	give_orders = false,
	can_be_brushed = false,
	capture_item = "net",
	follow = petz.settings.silkworm_follow,
	drops = {
	},
	replace_rate = 10,
	replace_offset = 0,
    replace_what = {
		{"group:leaves", "air", -1},
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
	max_speed = 0.25,
	jump_height = 1.0,
	view_range = 10,
	lung_capacity = 10, -- seconds
	max_hp = 2,

	attack={range=0.5, damage_groups={fleshy=3}},
	animation = {
		walk={range={x=0, y=12}, speed=10, loop=true},
		run={range={x=0, y=12}, speed=10, loop=true},
		stand={
			{range={x=12, y=24}, speed=5, loop=true},
			{range={x=24, y=31}, speed=5, loop=true},
		},
	},
	sounds = {
	},

	logic = petz.herbivore_brain,

	on_activate = function(self, staticdata, dtime_s) --on_activate, required
		mobkit.actfunc(self, staticdata, dtime_s)
		petz.set_initial_properties(self, staticdata, dtime_s)
		petz.init_convert_to_chrysalis(self)
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

petz:register_egg("petz:silkworm", S("Silkworm"), "petz_spawnegg_silkworm.png", true)

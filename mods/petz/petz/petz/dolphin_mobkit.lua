--
--DOLPHIN
--
local S = ...

local pet_name = "dolphin"
local scale_model = 2.0
local mesh = 'petz_dolphin.b3d'
local textures= {"petz_dolphin_bottlenose.png"}
local p1 = {x= -0.25, y = -0.5, z = -0.3125}
local p2 = {x= 0.1875, y = -0.125, z = 0.3125}
local collisionbox, collisionbox_baby = petz.get_collisionbox(p1, p2, scale_model, nil)

minetest.register_entity("petz:"..pet_name,{
	--Petz specifics
	type = "dolphin",
	can_swin = true,
	can_jump = true,
	groups = {fish= 1},
	is_mammal = true,
	--attack_player = true,
	--attack = {range = 0.8, damage_groups={fleshy=3}},
	init_tamagochi_timer = false,
	is_pet = true,
	has_affinity = true,
	is_wild = false,
	give_orders = true,
	can_be_brushed = false,
	capture_item = "lasso",
	follow = petz.settings.dolphin_follow,
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
	view_range = 12,
	lung_capacity = 32767, -- seconds
	max_hp = 12,
	max_height = -2,

	animation = {
		def={range={x=1, y=13}, speed=20, loop=true},
		stand={
			{range={x=13, y=25}, speed=5, loop=true},
			{range={x=28, y=43}, speed=5, loop=true},
		},
	},

	sounds = {
		misc = "petz_dolphin_clicking",
		moaning = "petz_dolphin_moaning",
	},

	drops = {
		{name = "default:coral_cyan", chance = 5, min = 1, max = 1,},
	},

	logic = petz.aquatic_brain,

	on_activate = function(self, staticdata, dtime_s) --on_activate, required
		mobkit.actfunc(self, staticdata, dtime_s)
		petz.set_initial_properties(self, staticdata, dtime_s)
	end,

	on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		petz.on_punch(self, puncher, time_from_last_punch, tool_capabilities, dir)
	end,

	on_step = function(self, dtime)
		mobkit.stepfunc(self, dtime) -- required
		petz.on_step(self, dtime)
	end,

	on_rightclick = function(self, clicker)
		petz.on_rightclick(self, clicker)
	end,
})

petz:register_egg("petz:dolphin", S("Dolphin"), "petz_spawnegg_dolphin.png", true)

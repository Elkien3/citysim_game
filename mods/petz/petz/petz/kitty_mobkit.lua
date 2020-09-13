--
--KITTY
--
local S = ...

local pet_name = "kitty"
local scale_model = 1.5
local mesh = 'petz_kitty.b3d'
local textures= {"petz_kitty.png", "petz_kitty2.png", "petz_kitty3.png", "petz_kitty4.png", "petz_kitty5.png", "petz_kitty6.png"}
local p1 = {x= -0.0625, y = -0.5, z = -0.3125}
local p2 = {x= 0.125, y = -0.0625, z = 0.3125}
local collisionbox, collisionbox_baby = petz.get_collisionbox(p1, p2, scale_model, nil)

minetest.register_entity("petz:"..pet_name, {
	--Petz specifics
	type = "kitty",
	init_tamagochi_timer = true,
	is_pet = true,
	has_affinity = true,
	is_wild = false,
	give_orders = true,
	can_be_brushed = true,
	capture_item = "net",
	follow = petz.settings.kitty_follow,
	rotate = petz.settings.rotate,
	physical = true,
	sleep_at_day = true,
	sleep_ratio = 0.3,
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
	jump_height = 3.0,
	view_range = 10,
	lung_capacity = 10, -- seconds
	max_hp = 10,
	makes_footstep_sound = false,
	head = {
		position = vector.new(0, 0.2908, -0.2908),
		rotation_origin = vector.new(-90, 0, 0), --in degrees, normally values are -90, 0, 90
		eye_offset = -0.2,
	},
	attack={range=0.5, damage_groups={fleshy=3}},
	animation = {
		idle = {range={x=0, y=0}, speed=25, loop=false},
		walk={range={x=1, y=12}, speed=25, loop=true},
		run={range={x=13, y=25}, speed=25, loop=true},
		stand={
			{range={x=26, y=46}, speed=5, loop=true},
			{range={x=47, y=59}, speed=5, loop=true},
		},
		sit = {range={x=60, y=65}, speed=5, loop=false},
		sleep = {range={x=81, y=93}, speed=10, loop=false},
	},
	sounds = {
		misc = {"petz_kitty_meow", "petz_kitty_meow2", "petz_kitty_meow3"},
		moaning = "petz_kitty_moaning",
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

petz:register_egg("petz:kitty", S("Kitty"), "petz_spawnegg_kitty.png", true)


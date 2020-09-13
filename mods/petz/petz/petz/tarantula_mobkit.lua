--
--TARANTULA
--
local S = ...

local pet_name = "tarantula"
local scale_model = 1.85
local mesh = 'petz_tarantula.b3d'
local textures = {"petz_tarantula_orange.png", "petz_tarantula_black.png"}
local visual_size = {x=petz.settings.visual_size.x*scale_model, y=petz.settings.visual_size.y*scale_model}
local p1 = {x= -0.25, y = -0.5, z = -0.25}
local p2 = {x= 0.3125, y = -0.25, z = 0.3125}
local collisionbox, collisionbox_baby = petz.get_collisionbox(p1, p2, scale_model, nil)

minetest.register_entity("petz:"..pet_name, {
	--Petz specifics
	type = "tarantula",
	init_tamagochi_timer = false,
	is_pet = false,
	is_monster = true,
	is_boss = true,
	has_affinity = false,
	is_wild = true,
	attack_player = true,
	give_orders = false,
	can_be_brushed = false,
	capture_item = nil,
	follow = petz.settings.tarantula_follow,
	drops = {
		{name = "farming:string", chance = 3, min = 1, max = 1,},
		{name = "petz:spider_eye", chance = 3, min = 1, max = 1,},
	},
	rotate = petz.settings.rotate,
	physical = true,
	stepheight = 0.1,	--EVIL!
	collide_with_objects = true,
	collisionbox = collisionbox,
	visual = petz.settings.visual,
	mesh = mesh,
	textures = textures,
	visual_size = visual_size,
	static_save = true,
	get_staticdata = mobkit.statfunc,
	-- api props
	springiness= 0,
	buoyancy = 0.5, -- portion of hitbox submerged
	max_speed = 1.5,
	jump_height = 2.1,
	view_range = 10,
	lung_capacity = 10, -- seconds
	max_hp = 30,

	attack={range=0.5, damage_groups={fleshy=9}},
	animation = {
		walk= {range={x=1, y=21}, speed=30, loop=true},
		stand= {range={x=23, y=34}, speed=5, loop=true},
		attack= {range={x=34, y=40}, speed=30, loop=false},
	},
	sounds = {
		attack = "petz_spider_attack",
	},

	logic = petz.monster_brain,

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

petz:register_egg("petz:tarantula", S("Tarantula"), "petz_spawnegg_tarantula.png", false)

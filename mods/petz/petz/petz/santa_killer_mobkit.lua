--
--SANTA KILLER
--
local S = ...

local pet_name = "santa_killer"
local scale_model = 1.0
petz.santa_killer = {}
local mesh = 'character.b3d'
local textures = {"petz_santa_killer.png"}
local collisionbox = {-0.3, 0.0, -0.3, 0.3, 1.7, 0.3}

minetest.register_entity("petz:"..pet_name,{
	--Petz specifics
	type = "santa_killer",
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
	follow = petz.settings.santa_killer_follow,
	drops = {
		{name = "petz:christmas_present", chance = 3, min = 1, max = 1,},
		{name = "petz:gingerbread_cookie", chance = 1, min = 1, max = 6,},
		{name = "petz:candy_cane", chance = 1, min = 1, max = 6,},
	},
	rotate = petz.settings.rotate,
	physical = true,
	stepheight = 0.1,	--EVIL!
	collide_with_objects = true,
	collisionbox = collisionbox,
	visual = petz.settings.visual,
	mesh = mesh,
	textures = textures,
	visual_size = {x=1.0*scale_model, y=1.0*scale_model},
	static_save = true,
	get_staticdata = mobkit.statfunc,
	-- api props
	springiness= 0,
	buoyancy = 0.5, -- portion of hitbox submerged
	max_speed = 1.5,
	jump_height = 1.5,
	view_range = 20,
	lung_capacity = 10, -- seconds
	max_hp = 50,

	attack={range=0.5, damage_groups={fleshy=9}},
	animation = {
		walk={range={x=168, y=187}, speed=30, loop=true},
		stand={
			{range={x=0, y=79}, speed=5, loop=true},
		},
		sit = {range={x=81, y=160}, speed=5, loop=false},
	},
	sounds = {
		misc = "petz_merry_christmas",
		attack = "petz_ho_ho_ho",
		laugh = "petz_ho_ho_ho",
		die = "petz_monster_die",
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

petz:register_egg("petz:santa_killer", S("Santa Killer"), "petz_spawnegg_santa_killer.png", false)

--
--MR_PUMPKIN
--
local S = ...

local pet_name = "mr_pumpkin"
local scale_model = 1.0
petz.mr_pumpkin = {}
local mesh = 'character.b3d'
local textures = {"petz_mr_pumpkin.png"}
local collisionbox = {-0.3, 0.0, -0.3, 0.3, 1.7, 0.3}
local drops = {
		{name = "petz:jack_o_lantern", chance = 3, min = 1, max = 1,},
}
if minetest.get_modpath("3d_armor") ~= nil then
	table.insert(drops, {name = "petz:pumpkin_hood", chance = 4, min = 1, max = 1,})
end

minetest.register_entity("petz:"..pet_name,{
	--Petz specifics
	type = "mr_pumpkin",
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
	follow = petz.settings.mr_pumpkin_follow,
	drops = drops,
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
	max_hp = 45,

	attack={range=0.5, damage_groups={fleshy=9}},
	animation = {
		walk={range={x=168, y=187}, speed=30, loop=true},
		stand={
			{range={x=0, y=79}, speed=5, loop=true},
		},
		sit = {range={x=81, y=160}, speed=5, loop=false},
	},
	sounds = {
		misc = "petz_monster_misc",
		attack = "petz_zombie_noise",
		laugh = "petz_monster_laugh",
		die = "petz_monster_die",
	},

	--punch_start = 83, stand4_end = 95,

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

petz:register_egg("petz:mr_pumpkin", S("Mr Pumpkin"), "petz_spawnegg_mr_pumpkin.png", false)

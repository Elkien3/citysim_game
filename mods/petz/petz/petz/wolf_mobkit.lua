--
--WOLF
--
local S = ...

local pet_name = "wolf"
local scale_model = 1.8
local scale_baby = 0.5
local visual_size = {x=petz.settings.visual_size.x*scale_model, y=petz.settings.visual_size.y*scale_model}
local visual_size_baby = {x=petz.settings.visual_size.x*scale_model*scale_baby, y=petz.settings.visual_size.y*scale_model*scale_baby}
local mesh = 'petz_wolf.b3d'
local skin_colors = {"grey", "dark_grey", "brown", "black"}
local textures = {}
for n = 1, #skin_colors do
	textures[n] = "petz_"..pet_name.."_"..skin_colors[n]..".png"
end
local p1 = {x= -0.125, y = -0.5, z = -0.3125}
local p2 = {x= 0.1875, y = 0.0625, z = 0.375}
local collisionbox, collisionbox_baby = petz.get_collisionbox(p1, p2, scale_model, scale_baby)

minetest.register_entity("petz:"..pet_name,{
	--Petz specifics
	type = "wolf",
	init_tamagochi_timer = true,
	is_pet = true,
	has_affinity = true,
	is_wild = true,
	breed = true,
	attack_player = false,
	attack_pack = true,
	avoid_player = true,
	give_orders = true,
	can_be_brushed = true,
	capture_item = "lasso",
	follow = petz.settings.wolf_follow,
	rotate = petz.settings.rotate,
	physical = true,
	stepheight = 0.1,	--EVIL!
	collide_with_objects = true,
	collisionbox = collisionbox,
	collisionbox_baby = collisionbox_baby,
	visual = petz.settings.visual,
	mesh = mesh,
	textures = textures,
	visual_size = visual_size,
	visual_size_baby = visual_size_baby,
	skin_colors = skin_colors,
	mutation = 1,
	static_save = true,
	get_staticdata = mobkit.statfunc,
	-- api props
	springiness= 0,
	buoyancy = 0.5, -- portion of hitbox submerged
	max_speed = 2.3,
	jump_height = 2.0,
	view_range = 10,
	lung_capacity = 10, -- seconds
	max_hp = 20,

	attack={range=0.5, damage_groups={fleshy=7}},
	animation = {
		walk={range={x=1, y=12}, speed=25, loop=true},
		run={range={x=13, y=25}, speed=25, loop=true},
		stand={
			{range={x=26, y=46}, speed=5, loop=true},
			{range={x=47, y=59}, speed=5, loop=true},
			{range={x=82, y=94}, speed=5, loop=true},
		},
	},
	sounds = {
		misc = "petz_wolf_howl",
		moaning = "petz_wolf_moaning",
	},
	drops = {
		{name = "petz:wolf_fur", chance = 5, min = 1, max = 1,},
		{name = "petz:wolf_jaw", chance = 5, min = 1, max = 1,},
	},

	--punch_start = 83, stand4_end = 95,

	logic = petz.predator_brain,

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

petz:register_egg("petz:wolf", S("Wolf"), "petz_spawnegg_wolf.png", true)

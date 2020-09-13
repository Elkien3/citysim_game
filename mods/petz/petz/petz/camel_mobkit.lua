--
--CAMEL
--
local S = ...

local pet_name = "camel"
local scale_model = 2.7
local visual_size = {x=petz.settings.visual_size.x*scale_model, y=petz.settings.visual_size.y*scale_model}
local scale_baby = 0.5
local visual_size_baby = {x=petz.settings.visual_size.x*scale_model*scale_baby, y=petz.settings.visual_size.y*scale_model*scale_baby}
petz.camel = {}
local mesh = 'petz_camel.b3d'
local skin_colors = {"camel", "dark_camel", "white"}
local textures = {}
for n = 1, #skin_colors do
	textures[n] = "petz_"..pet_name.."_"..skin_colors[n]..".png"
end
local textures_baby = {"petz_camel_baby.png"}
local p1 = {x= -0.125, y = -0.5, z = -0.4375}
local p2 = {x= 0.25, y = 0.375, z = 0.375}
local collisionbox, collisionbox_baby = petz.get_collisionbox(p1, p2, scale_model, scale_baby)

minetest.register_entity("petz:"..pet_name, {
	--Petz specifics
	type = pet_name,
	is_mountable = true,
	driver = nil,
	has_saddlebag = true,
	init_tamagochi_timer = true,
	is_pet = true,
	has_affinity = true,
	milkable = true,
	breed = true,
	mutation = 1,
	is_wild = false,
	give_orders = true,
	can_be_brushed = true,
	capture_item = "lasso",
	--Camel specific
	terrain_type = 3,
	scale_model = scale_model,
	scale_baby =scale_baby,
	driver_scale = {x = 1/visual_size.x, y = 1/visual_size.y},
	driver_attach_at = {x = 0.0625, y = 0.25, z = -0.3},
	driver_eye_offset = {x = 0, y = 0, z = 0},
	pregnant_count = 5,
	follow = petz.settings.camel_follow,
	drops = {
		{name = "petz:bone", chance = 5, min = 1, max = 1,},
	},
	rotate = petz.settings.rotate,
	physical = true,
	stepheight = 0.1,	--EVIL!
	collide_with_objects = true,
	collisionbox = collisionbox,
	collisionbox_baby = collisionbox_baby,
	visual = petz.settings.visual,
	mesh = mesh,
	textures = textures,
	skin_colors = skin_colors,
	visual_size = visual_size,
	visual_size_baby = visual_size_baby,
	static_save = true,
	get_staticdata = mobkit.statfunc,
	-- api props
	springiness= 0,
	buoyancy = 0.5, -- portion of hitbox submerged
	max_speed = 2,
	jump_height = 1.5,
	view_range = 10,
	lung_capacity = 10, -- seconds
	max_hp = 15,
	makes_footstep_sound = false,

	attack={range=0.5, damage_groups={fleshy=3}},

	animation = {
		walk={range={x=1, y=12}, speed=25, loop=true},
		run={range={x=13, y=25}, speed=25, loop=true},
		stand={
			{range={x=26, y=46}, speed=5, loop=true},
			{range={x=47, y=59}, speed=5, loop=true},
		},
	},
	sounds = {
		misc = "petz_camel_grunting",
		moaning = "petz_camel_moaning",
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

petz:register_egg("petz:camel", S("Camel"), "petz_spawnegg_camel.png", true)

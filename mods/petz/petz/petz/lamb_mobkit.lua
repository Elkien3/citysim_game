--
--LAMB
--
local S = ...

local pet_name = "lamb"
local scale_model = 2.5
local scale_baby = 0.5
local visual_size = {x=petz.settings.visual_size.x*scale_model, y=petz.settings.visual_size.y*scale_model}
local visual_size_baby = {x=petz.settings.visual_size.x*scale_model*scale_baby, y=petz.settings.visual_size.y*scale_model*scale_baby}
mesh = 'petz_lamb.b3d'
local skin_colors = {"white", "grey", "dark_grey", "brown", "vanilla"}
local textures = {}
for n = 1, #skin_colors do
	textures[n] = "petz_"..pet_name.."_"..skin_colors[n]..".png"
end
local p1 = {x= -0.0625, y = -0.5, z = -0.125}
local p2 = {x= 0.125, y = -0.125, z = 0.1875}
local collisionbox, collisionbox_baby = petz.get_collisionbox(p1, p2, scale_model, scale_baby)

minetest.register_entity("petz:"..pet_name,{
	--Petz specifics
	type = "lamb",
	init_tamagochi_timer = false,
	is_pet = true,
	has_affinity = false,
	breed = true,
	is_wild = false,
	give_orders = false,
	herd = true,
	can_be_brushed = true,
	capture_item = "lasso",
	mutation = 1,
	follow = petz.settings.lamb_follow,
	drops = {
		{name = "petz:mini_lamb_chop", chance = 1, min = 1, max = 1,},
		{name = "petz:bone", chance = 5, min = 1, max = 1,},
	},
	replace_rate = 10,
	replace_offset = 0,
    replace_what = {
        {"group:grass", "air", -1},
        {"default:dirt_with_grass", "default:dirt", -2}
    },
    poop = true,
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
	max_hp = 8,

	head = {
		position = vector.new(-0.1939, 0.2908, 0),
		rotation_origin = vector.new(-90, 90, 0), --in degrees, normally values are -90, 0, 90
		eye_offset = -0.3,
	},

	attack={range=0.5, damage_groups={fleshy=3}},
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
		misc = "petz_lamb_bleat",
		moaning = "petz_lamb_moaning",
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

	on_replace = function(self, pos, oldnode, newnode)
		petz.lamb_wool_regrow(self)
    end,

    on_step = function(self, dtime)
		mobkit.stepfunc(self, dtime) -- required
		petz.on_step(self, dtime)
	end,

})

petz:register_egg("petz:lamb", S("Lamb"), "petz_spawnegg_lamb.png", true)

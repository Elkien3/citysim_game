local S = ...

local pet_name = "butterfly"
local scale_model = 1.0
local mesh = 'petz_butterfly.b3d'
local textures= {"petz_butterfly.png","petz_butterfly2.png", "petz_butterfly3.png", "petz_butterfly4.png", "petz_butterfly5.png", "petz_butterfly6.png"}
local p1 = {x= -0.1875, y = -0.5, z = -0.0625}
local p2 = {x= 0.25, y = 0.0, z = 0.0}
local collisionbox, collisionbox_baby = petz.get_collisionbox(p1, p2, scale_model, nil)

minetest.register_entity("petz:"..pet_name,{
	--Petz specifics
	type = "butterfly",
	init_tamagochi_timer = false,
	is_pet = false,
	can_fly = true,
	max_height = 4,
	has_affinity = false,
	bottled = "petz:bottle_butterfly",
	is_wild = false,
	give_orders = false,
	can_be_brushed = false,
	capture_item = "net",
	follow = petz.settings.butterfly_follow,
	--automatic_face_movement_dir = 0.0,
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
	view_range = 10,
	lung_capacity = 10, -- seconds
	max_hp = 4,

	attack={range=0.5, damage_groups={fleshy=3}},
	animation = {
		walk={range={x=0, y=6}, speed=25, loop=true},
		run={range={x=0, y=6}, speed=25, loop=true},
		stand={
			{range={x=0, y=0}, speed=5, loop=true},
		},
		fly={range={x=0, y=6}, speed=25, loop=true},
		stand_fly={range={x=0, y=6}, speed=25, loop=true},
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

petz:register_egg("petz:butterfly", S("Butterfly"), "petz_spawnegg_butterfly.png", true)

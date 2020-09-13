--
--LEOPARD
--
local S = ...

local scale_model = 2.0
local mesh = 'petz_leopard.b3d'
local p1 = {x= -0.0625, y = -0.5, z = -0.375}
local p2 = {x= 0.125, y = 0.0, z = 0.375}
local collisionbox, collisionbox_baby = petz.get_collisionbox(p1, p2, scale_model, nil)

for i=1, 2 do
	local type
	local description
	local textures = {}
	if i == 1 then --if male
		type = "leopard"
		description = "Leopard"
		textures = {"petz_leopard.png", "petz_leopard2.png"}
	else
		type = "snow_leopard"
		description = "Snow Leopard"
		textures = {"petz_snow_leopard.png", "petz_snow_leopard2.png"}
	end

	minetest.register_entity("petz:"..type, {
		--Petz specifics
		type = type,
		init_tamagochi_timer = true,
		is_pet = true,
		has_affinity = true,
		is_wild = true,
		attack_player = true,
		give_orders = true,
		can_be_brushed = true,
		capture_item = "lasso",
		follow = petz.settings.leopard_follow,
		drops = {
			{name = "petz:bone", chance = 5, min = 1, max = 1,},
			{name = "petz:leopard_skin", chance = 3, min = 1, max = 1,},
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
		max_speed = 4.0,
		jump_height = 1.5,
		view_range = 10,
		lung_capacity = 10, -- seconds
		max_hp = 25,

		attack = {range=0.5, damage_groups= {fleshy = 9}},
		animation = {
			walk={range={x=1, y=12}, speed=25, loop=true},
			run={range={x=13, y=25}, speed=25, loop=true},
			stand={
				{range={x=26, y=46}, speed=5, loop=true},
				{range={x=47, y=59}, speed=5, loop=true},
				{range={x=82, y=94}, speed=5, loop=true},
			},
			sit = {range={x=60, y=65}, speed=5, loop=false},
			attack = {range={x=72, y=84}, speed=5, loop=false},
		},
		sounds = {
			misc = "petz_leopard_roar",
			moaning = "petz_leopard_moaning",
			attack = "petz_leopard_attack",
		},

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
	petz:register_egg("petz:"..type, S(description), "petz_spawnegg_"..type..".png", true)
end


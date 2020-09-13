local S = ...

for i=1, 2 do
	local pet_name
	local queen
	local scale_model
	local description
	local textures
	if i == 1 then
		queen = false
		pet_name = "bee"
		description = "Worker Bee"
		scale_model = 0.375
		textures= {"petz_bee.png"}
	else
		queen = true
		pet_name = "queen_bee"
		description = "Queen Bee"
		scale_model = 0.5
		textures= {"petz_queen_bee.png"}
	end
	local mesh = 'petz_bee.b3d'
	local p1 = {x= -0.1875, y = -0.5, z = -0.3125}
	local p2 = {x= 0.25, y = 0.0625, z = 0.3125}
	local collisionbox, collisionbox_baby = petz.get_collisionbox(p1, p2, scale_model, nil)

	minetest.register_entity("petz:"..pet_name,{
		--Petz specifics
		type = "bee",
		queen = queen,
		init_tamagochi_timer = false,
		is_pet = false,
		description = description,
		can_fly = true,
		lay_eggs = false,
		lay_eggs_in_nest = false,
		type_of_egg = "node",
		max_height = 5,
		has_affinity = false,
		give_orders = false,
		can_be_brushed = false,
		capture_item = "net",
		is_wild = true,
		attack_player = false,
		attack_kamikaze = true,
		avoid_player = false,
		follow = petz.settings.bee_follow,
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
		max_speed = 2,
		jump_height = 2.0,
		view_range = 10,
		lung_capacity = 10, -- seconds
		max_hp = 2,

		attack={range=0.5, damage_groups={fleshy=3}},
		animation = {
			walk={range={x=1, y=12}, speed=20, loop=true},
			run={range={x=13, y=25}, speed=20, loop=true},
			stand={
				{range={x=26, y=46}, speed=5, loop=true},
				{range={x=47, y=59}, speed=5, loop=true},
				{range={x=60, y=70}, speed=5, loop=true},
				{range={x=71, y=91}, speed=5, loop=true},
			},
			fly={range={x=92, y=98}, speed=30, loop=true},
			stand_fly={range={x=92, y=98}, speed=30, loop=true},
		},
		drops = {
			{name = "petz:pollen", chance = 3, min = 1, max = 3,},
			{name = "petz:bee_sting", chance = 3, min = 1, max = 1,},
		},
		sounds = {
			misc = "petz_bee_hum",
		},

		logic = petz.bee_brain,

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
	petz:register_egg("petz:"..pet_name, S(description), "petz_spawnegg_"..pet_name..".png", false)
end

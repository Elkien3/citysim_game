--
--ELEPHANT
--
local S = ...

petz.elephant = {}

for i=1, 2 do
	local pet_name
	local scale_model
	local scale_baby = 0.5
	local skin_colors
	local textures = {}
	local is_male
	local mesh
	local collisionbox
	local description
	if i == 1 then --if male
		pet_name= "elephant"
		description = "Elephant"
		is_male = true
		mesh = "petz_elephant.b3d"
		scale_model = 4.5
		skin_colors = {"gray", "white"}
	else --if female
		pet_name= "elephant_female"
		description = "Elephant (Female)"
		mesh = "petz_elephant_female.b3d"
		is_male = false
		scale_model = 3.75
		skin_colors = {"brown", "white"}
	end
	for n = 1, #skin_colors do
		textures[n] = "petz_"..pet_name.."_"..skin_colors[n]..".png"
	end
	local p1 = {x= -0.125, y = -0.5, z = -0.3125}
	local p2 = {x= 0.1875, y = -0.0625, z = 0.25}
	local collisionbox, collisionbox_baby = petz.get_collisionbox(p1, p2, scale_model, scale_baby)
	local visual_size_baby = {x=petz.settings.visual_size.x*scale_model*scale_baby, y=petz.settings.visual_size.y*scale_model*scale_baby}
	minetest.register_entity("petz:"..pet_name,{
		--Petz specifics
		type = "elephant",
		is_male = is_male,
		init_tamagochi_timer = true,
		is_pet = true,
		breed = true,
		has_affinity = true,
		is_wild = false,
		attack_player = true,
		give_orders = true,
		can_be_brushed = true,
		mutation = 1,
		--breed = true,
		capture_item = "lasso",
		follow = petz.settings.elephant_follow,
		drops = {
			{name = "petz:elephant_tusk", chance = 1, min = 2, max = 2,},
			{name = "petz:bone", chance = 3, min = 1, max = 2,},
		},
		replace_rate = 10,
		replace_offset = 0,
		replace_what = {
			{"group:grass", "air", -1},
			{"default:dirt_with_dry_grass", "default:dirt", -2}
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
		visual_size = {x=petz.settings.visual_size.x*scale_model, y=petz.settings.visual_size.y*scale_model},
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
		max_hp = 40,
		makes_footstep_sound = true,

		attack={range=0.5, damage_groups={fleshy=3}},
		animation = {
			walk={range={x=1, y=12}, speed=20, loop=true},
			run={range={x=13, y=25}, speed=20, loop=true},
			stand={
				{range={x=26, y=46}, speed=5, loop=true},
				{range={x=47, y=59}, speed=5, loop=true},
				{range={x=81, y=101}, speed=5, loop=true},
				{range={x=101, y=121}, speed=5, loop=true},
			},
		},
		sounds = {
			misc = "petz_elephant_trumpeting",
			moaning = "petz_elephant_moaning",
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
	petz:register_egg("petz:"..pet_name, S(description), "petz_spawnegg_"..pet_name..".png", true)
end

--
--TROPICALFISH
--
local S = ...

local pet_name = "tropicalfish"
local scale_model = 1.5
local mesh = 'petz_tropicalfish.b3d'
local textures= {"petz_tropicalfish.png", "petz_tropicalfish2.png", "petz_tropicalfish3.png"}
local p1 = {x= -0.125, y = -0.5, z = -0.1875}
local p2 = {x= 0.1875, y = 0.1875, z = 0.375}
local collisionbox, collisionbox_baby = petz.get_collisionbox(p1, p2, scale_model, nil)

minetest.register_entity("petz:"..pet_name,{
	--Petz specifics
	type = "tropicalfish",
	can_swin = true,
	can_jump = false,
	groups = {fish= 1, fishtank = 1},
	is_mammal = false,
	init_tamagochi_timer = false,
	is_pet = false,
	has_affinity = false,
	is_wild = false,
	give_orders = false,
	can_be_brushed = false,
	capture_item = "net",
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
	buoyancy = 1.1, -- portion of hitbox submerged
	max_speed = 1.5,
	jump_height = 0.0,
	view_range = 10,
	max_hp = 4,
	max_height = -2,

	animation = {
		def={range={x=1, y=13}, speed=20, loop=true},
		stand={
			{range={x=13, y=25}, speed=5, loop=true},
		},
	},

	drops = {
		{name = "default:coral_brown", chance = 5, min = 1, max = 1,},
	},

	logic = petz.aquatic_brain,

	on_activate = function(self, staticdata, dtime_s) --on_activate, required
		mobkit.actfunc(self, staticdata, dtime_s)
		petz.set_initial_properties(self, staticdata, dtime_s)
	end,

	on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		petz.on_punch(self, puncher, time_from_last_punch, tool_capabilities, dir)
	end,

	on_step = function(self, dtime)
		mobkit.stepfunc(self, dtime) -- required
		petz.on_step(self, dtime)
	end,

	on_rightclick = function(self, clicker)
		petz.on_rightclick(self, clicker)
	end,
})

petz:register_egg("petz:tropicalfish", S("Tropicalfish"), "petz_spawnegg_tropicalfish.png", true)

minetest.register_entity("petz:tropicalfish_entity_sprite", {
	visual = "sprite",
	spritediv = {x = 1, y = 16},
	initial_sprite_basepos = {x = 0, y = 0},
	visual_size = {x=0.8, y=0.8},
	collisionbox = {0},
	physical = false,
	textures = {"petz_tropicalfish_spritesheet.png"},
	groups = {fishtank = 1},
	on_activate = function(self, staticdata)
		local pos = self.object:getpos()
		if minetest.get_node(pos).name ~= "petz:fishtank" then
			mokapi.remove_mob(self)
		end
	end,
})

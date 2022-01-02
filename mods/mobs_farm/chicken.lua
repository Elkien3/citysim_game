local S = mobs.intllib

local time_speed = minetest.settings:get("time_speed") or 72
time_speed = tonumber(time_speed)
if time_speed < 1 then
	time_speed = 1
end

local orig_func = farming.place_seed
farming.place_seed = function(itemstack, placer, pointed_thing, plantname)
	if minetest.is_protected(pointed_thing.above, placer:get_player_name()) then return itemstack end
	minetest.set_node(pointed_thing.above, {name = itemstack:get_name(), param2 = 1})
	if not minetest.is_creative_enabled(placer:get_player_name()) then
		itemstack:take_item()
	end
	orig_func(itemstack, placer, pointed_thing, plantname)
	return itemstack
end

--how much hunger should go down per ingame day
local hungerrate = 5/time_speed
local thirstrate = 5/time_speed

local chicken_max_yield = 3

mobs:register_mob("mobs_farm:chicken", {
	stepheight = .5,
	type = "animal",
	passive = true,
	pushable = true,
	hp_min = 5,
	hp_max = 10,
	armor = 200,
	collisionbox = {-0.2, -0.01, -0.2, 0.2, 0.69, 0.2},
	visual = "mesh",
	mesh = "mobs_mc_chicken.b3d",
	textures = {
		{"mobs_mc_chicken.png"},
	},
	visual_size = {x=2.2, y=2.2},
	makes_footstep_sound = true,
	sounds = {
		random = "mobs_chicken",
	},
	walk_velocity = 1,
	run_velocity = 3,
	runaway = true,
	runaway_from = {"player", "mobs_farm:pumba"},
	drops = {
		{name = "mobs:chicken_raw", chance = 1, min = chicken_max_yield-1, max = chicken_max_yield},
		--{name = "mobs:chicken_feather", chance = 1, min = 0, max = 2},
	},
	water_damage = 0,
	lava_damage = 5,
	light_damage = 0,
	fall_damage = 0,
	fall_speed = -4,
	fear_height = 5,
	animation = {
		stand_speed = 25, walk_speed = 25, run_speed = 50,
		stand_start = 0,		stand_end = 0,
		walk_start = 0,		walk_end = 40,
		run_start = 0,		run_end = 40,
	},
	follow = {
		"farming:seed_wheat", "farming:seed_cotton", "farming:seed_barley",
		"farming:seed_oat", "farming:seed_rye"
	},
	runaway_from = {"mobs_farm:wolf", "mobs_farm:kitten"},
	view_range = 8,
	replace_rate = 4,--10,
	replace_what = {
		{"group:seed", "air", 0},
		{"default:water_source", "air", 0},
		{"default:water_source", "air", -1},
		{"static_ocean:water_source", "air", 0},
		{"static_ocean:water_source", "air", -1},
	},
	--stay_near = {{"group:seed", "default:water_source", "static_ocean:water_source"}, 10},
	fear_height = 2,
	after_activate = function(self, staticdata, def, dtime)
		if not self.food then
			self.food = 0
		end
		if not self.water then
			self.water = 0
		end
		self.stay_near = mobs_farm.get_stay_near(self, {"group:seed"})
		self.chickentimer = 30
	end,
	on_rightclick = function(self, clicker)
		--original for chicken
		--[[if mobs:feed_tame(self, clicker, 8, true, true) then return end
		if mobs:protect(self, clicker) then return end
		if mobs:capture_mob(self, clicker, 30, 50, 80, false, nil) then return end--]]
		
		-- feed or tame
		if mobs:feed_tame(self, clicker, 4, false, true) then return	end
		if mobs:feed_tame(self, clicker, 20, true, false) then return	end

		--if mobs:protect(self, clicker) then return end
		--if mobs:capture_mob(self, clicker, 0, 5, 60, false, nil) then return end
	end,

	on_replace = function(self, pos, oldnode, newnode)
		if not self.owner or self.owner == "" then return false end
		local name = oldnode or ""
		local value = 0
		local nodetype = "food"
		if string.find(name, "water") then
			nodetype = "water"
			value = 20
		elseif name == "farming:straw" then
			value = 10
			if self[nodetype] + value > 22 then--don't waste too much straw
				return false
			end
		elseif name == "default:dirt_with_grass" and (self.food or 0) < 5 then
			value = 0--.1
		elseif string.find(name, "seed") then
			value = 6
		end
		self.stay_near = mobs_farm.get_stay_near(self, {"group:seed"})
		if mobs_farm.round(self[nodetype]) >= 20 then
			return false
		end
		local newval = (self[nodetype] or 0) + value
		if newval >= 20 then
			newval = 20
		end
		self[nodetype] = newval
		return true
	end,
	on_grown = function(self)
		self.food = self.food - 8
		self.water = self.water - 8
		self.drops[1].max = 1
		self.drops[1].min = clamp(self.drops[1].max-1, 0)
	end,
	do_custom = function(self, dtime)
		local pos = self.object:get_pos()
		self.chickentimer = (self.chickentimer or 0) + dtime
		if self.chickentimer > 30 then
			if self.lastday then
				local dayspassed = minetest.get_day_count() - self.lastday
				if dayspassed > 0 then
					self.food = self.food - hungerrate*dayspassed
					self.water = self.water - thirstrate*dayspassed
					if self.food <= 0 or self.water <= 0 then
						if self.food <= 0 then
							self.drops[1].max = clamp(self.drops[1].max-dayspassed, 0, chicken_max_yield)
							self.drops[1].min = clamp(self.drops[1].max-1, 0)
						end
						if self.water <= 0 then
							self.drops[1].max = clamp(self.drops[1].max-dayspassed, 0)
							self.drops[1].min = clamp(self.drops[1].max-1, 0)
						end
						--self.health = math.floor(self.health)
					else
						self.health = self.health+dayspassed
						if self.health > self.hp_max then
							self.health = self.hp_max
						end
						self.object:set_hp(self.health)
						self.drops[1].max = clamp(self.drops[1].max+dayspassed, 0, chicken_max_yield)
						self.drops[1].min = clamp(self.drops[1].max-1, 0)
						self.gotten = false
						if self.horny or self.child then
							self.hornytimer = self.hornytimer + dayspassed
						end
					end
					if self.food < 0 then self.food = 0 end
					if self.water < 0 then self.water = 0 end
					self.stay_near = mobs_farm.get_stay_near(self, {"group:seed"})
					self.lastday = minetest.get_day_count()
				end
				if dayspassed < 0 then
					self.lastday = minetest.get_day_count()
				end
			else
				self.lastday = minetest.get_day_count()
			end
			self.chickentimer = math.random(5)
			if not self.child and not self.gotten and mobs_farm.round(self.food) >= 10 and mobs_farm.round(self.water) >= 10 and minetest.get_node(pos).name == "air" then
				self.gotten = true
				self.food = self.food - 4
				self.water = self.water - 4
				minetest.set_node(pos, {name = "mobs:egg"})
			end
			local objects = minetest.get_objects_inside_radius(pos, 30)
			local chickenposlist = {}
			self.herdpos = {x=0,y=0,z=0}
			for i, obj in pairs(objects) do
				local name
				if obj:get_luaentity() then name = obj:get_luaentity().name end
				if (name == "mobs_farm:chicken" and obj:get_luaentity().owner == self.owner) or (obj:is_player() and obj:get_player_name() == self.owner) then
					table.insert(chickenposlist, obj:get_pos())
					self.herdpos = vector.add(self.herdpos, obj:get_pos())
				end
			end
			if #chickenposlist == 1 then
				self.herdpos = nil
			else
				self.herdpos = vector.divide(self.herdpos, #chickenposlist)
			end
		end
	end,
	on_die = mobs_farm.on_die,
})

if not mobs.custom_spawn_animal then
mobs:spawn({
	name = "mobs_farm:chicken",
	nodes = {"default:dirt", "default:dirt_with_grass", "default:dirt_with_coniferous_litter"},
	neighbors = {"default:tree", "default:pine_tree", "default:aspen_tree"},
	--min_light = 14,
	interval = 60,
	chance = 8000, -- 15000
	min_height = 5,
	max_height = 200,
	day_toggle = true,
	--active_object_count = 4,
})
end


mobs:register_egg("mobs_farm:chicken", S("Chicken"), "mobs_mc_spawn_icon_chicken.png", 0)


mobs:alias_mob("mobs:chicken", "mobs_farm:chicken") -- compatibility

--[[
-- egg entity

mobs:register_arrow("mobs_farm:egg_entity", {
	visual = "sprite",
	visual_size = {x=.5, y=.5},
	textures = {"mobs_chicken_egg.png"},
	velocity = 6,

	hit_player = function(self, player)
		player:punch(minetest.get_player_by_name(self.playername) or self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = 1},
		}, nil)
	end,

	hit_mob = function(self, player)
		player:punch(self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = 1},
		}, nil)
	end,

	hit_node = function(self, pos, node)

		if math.random(1, 10) > 1 then
			return
		end

		pos.y = pos.y + 1

		local nod = minetest.get_node_or_nil(pos)

		if not nod
		or not minetest.registered_nodes[nod.name]
		or minetest.registered_nodes[nod.name].walkable == true then
			return
		end

		local mob = minetest.add_entity(pos, "mobs_farm:chicken")
		local ent2 = mob:get_luaentity()

		mob:set_properties({
			textures = ent2.child_texture[1],
			visual_size = {
				x = ent2.base_size.x / 2,
				y = ent2.base_size.y / 2
			},
			collisionbox = {
				ent2.base_colbox[1] / 2,
				ent2.base_colbox[2] / 2,
				ent2.base_colbox[3] / 2,
				ent2.base_colbox[4] / 2,
				ent2.base_colbox[5] / 2,
				ent2.base_colbox[6] / 2
			},
		})

		ent2.child = true
		ent2.tamed = true
		ent2.owner = self.playername
	end
})


-- egg throwing item

local egg_GRAVITY = 9
local egg_VELOCITY = 19

-- shoot egg
local mobs_shoot_egg = function (item, player, pointed_thing)

	local playerpos = player:get_pos()

	minetest.sound_play("default_place_node_hard", {
		pos = playerpos,
		gain = 1.0,
		max_hear_distance = 5,
	})

	local obj = minetest.add_entity({
		x = playerpos.x,
		y = playerpos.y +1.5,
		z = playerpos.z
	}, "mobs_farm:egg_entity")

	local ent = obj:get_luaentity()
	local dir = player:get_look_dir()

	ent.velocity = egg_VELOCITY -- needed for api internal timing
	ent.switch = 1 -- needed so that egg doesn't despawn straight away
	ent._is_arrow = true -- tell advanced mob protection this is an arrow

	obj:setvelocity({
		x = dir.x * egg_VELOCITY,
		y = dir.y * egg_VELOCITY,
		z = dir.z * egg_VELOCITY
	})

	obj:setacceleration({
		x = dir.x * -3,
		y = -egg_GRAVITY,
		z = dir.z * -3
	})

	-- pass player name to egg for chick ownership
	local ent2 = obj:get_luaentity()
	ent2.playername = player:get_player_name()

	item:take_item()

	return item
end--]]


-- egg
minetest.register_node(":mobs:egg", {
	description = S("Chicken Egg"),
	tiles = {"mobs_chicken_egg.png"},
	inventory_image  = "mobs_chicken_egg.png",
	visual_scale = 0.7,
	drawtype = "plantlike",
	wield_image = "mobs_chicken_egg.png",
	paramtype = "light",
	walkable = false,
	is_ground_content = true,
	sunlight_propagates = true,
	floodable = true,
	selection_box = {
		type = "fixed",
		fixed = {-0.2, -0.5, -0.2, 0.2, 0, 0.2}
	},
	groups = {food_egg = 1, snappy = 2, dig_immediate = 3, falling_node = 1},
	after_place_node = function(pos, placer, itemstack)
		if placer:is_player() then
			minetest.set_node(pos, {name = "mobs:egg", param2 = 1})
		end
	end,
	on_flood = function(pos, oldnode, newnode)
		minetest.add_item(pos, ItemStack("mobs:egg"))
	end
	--on_use = mobs_shoot_egg
})


-- fried egg
minetest.register_craftitem(":mobs:chicken_egg_fried", {
	description = S("Fried Egg"),
	inventory_image = "mobs_chicken_egg_fried.png",
	on_use = minetest.item_eat(2),
	groups = {food_egg_fried = 1, flammable = 2},
})

minetest.register_craft({
	type  =  "cooking",
	recipe  = "mobs:egg",
	output = "mobs:chicken_egg_fried",
})

-- raw chicken
minetest.register_craftitem(":mobs:chicken_raw", {
description = S("Raw Chicken"),
	inventory_image = "mobs_chicken_raw.png",
	on_use = minetest.item_eat(2),
	groups = {food_meat_raw = 1, food_chicken_raw = 1, flammable = 2},
})

-- cooked chicken
minetest.register_craftitem(":mobs:chicken_cooked", {
description = S("Cooked Chicken"),
	inventory_image = "mobs_chicken_cooked.png",
	on_use = minetest.item_eat(6),
	groups = {food_meat = 1, food_chicken = 1, flammable = 2},
})

minetest.register_craft({
	type  =  "cooking",
	recipe  = "mobs:chicken_raw",
	output = "mobs:chicken_cooked",
})
--[[
-- feather
minetest.register_craftitem(":mobs:chicken_feather", {
	description = S("Feather"),
	inventory_image = "mobs_chicken_feather.png",
	groups = {flammable = 2, feather = 1},
})

minetest.register_craft({
	type = "fuel",
	recipe = "mobs:chicken_feather",
	burntime = 1,
})--]]


local S = mobs.intllib

local time_speed = minetest.settings:get("time_speed") or 72
time_speed = tonumber(time_speed)
if time_speed < 1 then
	time_speed = 1
end
--how much hunger should go down per ingame day
local hungerrate = 5/time_speed
local thirstrate = 5/time_speed

local water = {"default:water_source", "static_ocean:water_source", "mobs_farm:pet_bowl_water"}
local food = {"group:grass", "mobs_farm:pet_bowl_grass"}

-- Bunny by ExeterDad

mobs:register_mob("mobs_farm:bunny", {
stepheight = 0.6,
	type = "animal",
	passive = true,
	pushable = true,
	reach = 1,
	hp_min = 1,
	hp_max = 4,
	armor = 200,
	collisionbox = {-0.268, -0.5, -0.268,  0.268, 0.167, 0.268},
	visual = "mesh",
	mesh = "mobs_bunny.b3d",
	drawtype = "front",
	textures = {
		{"mobs_bunny_grey.png"},
		{"mobs_bunny_brown.png"},
		{"mobs_bunny_white.png"},
	},
	sounds = {},
	makes_footstep_sound = false,
	walk_velocity = 1,
	run_velocity = 5,
	runaway = true,
	jump = true,
	jump_height = 6,
	drops = {
		{name = "mobs:meat_raw", chance = 1, min = 1, max = 1},
		--{name = "mobs:rabbit_hide", chance = 1, min = 0, max = 1},
	},
	water_damage = 0,
	lava_damage = 4,
	light_damage = 0,
	fear_height = 3,
	animation = {
		speed_normal = 15,
		stand_start = 1,
		stand_end = 15,
		walk_start = 16,
		walk_end = 24,
		punch_start = 16,
		punch_end = 24,
	},
	follow = {"farming:carrot", "farming_plus:carrot_item", "default:grass_1"},
	runaway_from = {"mobs_farm:wolf", "player"},
	view_range = 8,
	replace_rate = 4,--10,
	replace_what = {
		{"group:grass", "air", 0},
		{"default:water_source", "air", 0},
		{"default:water_source", "air", -1},
		{"static_ocean:water_source", "air", 0},
		{"static_ocean:water_source", "air", -1},
		{"mobs_farm:pet_bowl_water", "mobs_farm:pet_bowl", 0},
		{"mobs_farm:pet_bowl_water", "mobs_farm:pet_bowl", -1},
		{"mobs_farm:pet_bowl_grass", "mobs_farm:pet_bowl", 0},
		{"mobs_farm:pet_bowl_grass", "mobs_farm:pet_bowl", -1},
	},
	on_replace = function(self, pos, oldnode, newnode)
		if not self.owner or self.owner == "" then return false end
		local name = oldnode or ""
		local value = 20
		local nodetype = "food"
		if string.find(name, "water") then
			nodetype = "water"
		end
		self.stay_near = mobs_farm.get_stay_near(self, food, water)
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
	--stay_near = {{"group:grass", "default:water_source", "static_ocean:water_source", "mobs_farm:pet_bowl_grass", "mobs_farm:pet_bowl_water"}, 10},
	on_rightclick = function(self, clicker)
		-- feed or tame
		if not self.tamed and mobs:feed_tame(self, clicker, 4, false, true) then self.runaway_from = {"mobs_farm:wolf"} return end
		--if mobs:protect(self, clicker) then return end
		--if mobs:capture_mob(self, clicker, 30, 50, 80, false, nil) then return end

		-- Monty Python tribute
		local item = clicker:get_wielded_item()

		local name = clicker:get_player_name()
		if self.owner and name and self.owner == name and clicker:get_player_control().sneak then
				minetest.show_formspec(name, "mobs_farm_changeowner", "size[5,2]field[1,1;4,1;changeowner;Change Owner;]field_close_on_enter[changeowner;false]")
				mobs_farm.form[name] = self
		elseif item:get_name() == "mobs:lava_orb" then

			if not mobs.is_creative(clicker:get_player_name()) then
				item:take_item()
				clicker:set_wielded_item(item)
			end

			self.object:set_properties({
				textures = {"mobs_bunny_evil.png"},
			})

			self.type = "monster"
			self.health = 20
			self.passive = false

			return
		end
	end,
	on_spawn = function(self)

		local pos = self.object:get_pos() ; pos.y = pos.y - 1

		-- white snowy bunny
		if minetest.find_node_near(pos, 1,
				{"default:snow", "default:snowblock", "default:dirt_with_snow"}) then
			self.base_texture = {"mobs_bunny_white.png"}
			self.object:set_properties({textures = self.base_texture})
		-- brown desert bunny
		elseif minetest.find_node_near(pos, 1,
				{"default:desert_sand", "default:desert_stone"}) then
			self.base_texture = {"mobs_bunny_brown.png"}
			self.object:set_properties({textures = self.base_texture})
		-- grey stone bunny
		elseif minetest.find_node_near(pos, 1,
				{"default:stone", "default:gravel"}) then
			self.base_texture = {"mobs_bunny_grey.png"}
			self.object:set_properties({textures = self.base_texture})
		end

		return true -- run only once, false/nil runs every activation
	end,
	attack_type = "dogfight",
	damage = 5,
	after_activate = function(self, staticdata, def, dtime)
		if not self.food then
			self.food = 0
		end
		if not self.water then
			self.water = 0
		end
		self.animaltimer = 30
		self.stay_near = mobs_farm.get_stay_near(self, food, water)
	end,
	do_custom = function(self, dtime)
		local pos = self.object:get_pos()
		self.animaltimer = (self.animaltimer or 0) + dtime
		if self.animaltimer > 30 then
			if self.lastday then
				local dayspassed = minetest.get_day_count() - self.lastday
				if dayspassed > 0 then
					self.food = self.food - hungerrate*dayspassed
					self.water = self.water - thirstrate*dayspassed
					if self.food > 0 and self.water > 0 then
						self.health = self.health+dayspassed
						if self.health > self.hp_max then
							self.health = self.hp_max
						end
						self.object:set_hp(self.health)
					end
					if self.food < 0 then self.food = 0 end
					if self.water < 0 then self.water = 0 end
					self.stay_near = mobs_farm.get_stay_near(self, food, water)
					self.lastday = minetest.get_day_count()
				end
				if dayspassed < 0 then
					self.lastday = minetest.get_day_count()
				end
			else
				self.lastday = minetest.get_day_count()
			end
			self.animaltimer = math.random(5)
			local objects = minetest.get_objects_inside_radius(pos, 30)
			local animalposlist = {}
			self.herdpos = {x=0,y=0,z=0}
			for i, obj in pairs(objects) do
				local name
				if obj:get_luaentity() then name = obj:get_luaentity().name end
				if (name == "mobs_farm:bunny" and obj:get_luaentity().owner == self.owner) or (obj:is_player() and obj:get_player_name() == self.owner) then
					table.insert(animalposlist, obj:get_pos())
					self.herdpos = vector.add(self.herdpos, obj:get_pos())
				end
			end
			if #animalposlist == 1 then
				self.herdpos = nil
			else
				self.herdpos = vector.divide(self.herdpos, #animalposlist)
			end
		end
	end,
	on_die = mobs_farm.on_die,
})


if not mobs.custom_spawn_animal then
mobs:spawn({
	name = "mobs_farm:bunny",
	nodes = {"default:dirt_with_grass", "default:dry_dirt_with_dry_grass", "default:dirt_with_dry_grass", "group:snowy"},
	neighbors = {"group:grass"},
	min_light = 14,
	interval = 60,
	chance = 8000, -- 15000
	min_height = 5,
	max_height = 200,
	day_toggle = true,
	--active_object_count = 4,
})
end


mobs:register_egg("mobs_farm:bunny", S("Bunny"), "mobs_bunny_inv.png", 0)


mobs:alias_mob("mobs:bunny", "mobs_farm:bunny") -- compatibility
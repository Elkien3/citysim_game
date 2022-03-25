
local S = mobs.intllib
local hairball = minetest.settings:get("mobs_hairball")

local time_speed = minetest.settings:get("time_speed") or 72
time_speed = tonumber(time_speed)
if time_speed < 1 then
	time_speed = 1
end
--how much hunger should go down per ingame day
local hungerrate = 5/time_speed
local thirstrate = 5/time_speed

local food = {"mobs_farm:pet_bowl_fish"}
local water = {"default:water_source", "static_ocean:water_source", "mobs_farm:pet_bowl_water"}

-- Kitten by Jordach / BFD

mobs:register_mob("mobs_farm:kitten", {
	stepheight = 0.6,
	type = "animal",
	--specific_attack = {"mobs_farm:rat"},
	damage = 1,
	attack_type = "dogfight",
	--attack_animals = true, -- so it can attack rat
	--attack_players = false,
	reach = 1,
	stepheight = 1.1,
	passive = false,
	pushable = true,
	hp_min = 5,
	hp_max = 10,
	armor = 200,
	collisionbox = {-0.3, -0.3, -0.3, 0.3, 0.1, 0.3},
	visual = "mesh",
	visual_size = {x = 0.5, y = 0.5},
	mesh = "mobs_kitten.b3d",
	textures = {
		{"mobs_kitten_striped.png"},
		{"mobs_kitten_splotchy.png"},
		{"mobs_kitten_ginger.png"},
		{"mobs_kitten_sandy.png"},
	},
	makes_footstep_sound = false,
	sounds = {
		random = "mobs_kitten",
	},
	walk_velocity = 0.6,
	--walk_chance = 15,
	run_velocity = 4,
	runaway = true,
	runaway_from = {"mobs_farm:wolf", "mobs_farm:dog"},
	jump = false,
	--[[drops = {
		{name = "farming:string", chance = 1, min = 0, max = 1},
	},--]]
	water_damage = 0,
	lava_damage = 5,
	fear_height = 3,
	animation = {
		speed_normal = 42,
		stand_start = 97,
		stand_end = 192,
		walk_start = 0,
		walk_end = 96,
		stoodup_start = 0,
		stoodup_end = 0,
	},
	follow = {
		"mobs_farm:rat", "group:food_fish_raw",
		"mobs_fish:tropical", "xocean:fish_edible", "fishing:fish_raw"
	},
	view_range = 8,
	replace_rate = 4,--10,
	replace_what = {
		{"default:water_source", "air", 0},
		{"default:water_source", "air", -1},
		{"static_ocean:water_source", "air", 0},
		{"static_ocean:water_source", "air", -1},
		{"mobs_farm:pet_bowl_water", "mobs_farm:pet_bowl", 0},
		{"mobs_farm:pet_bowl_water", "mobs_farm:pet_bowl", -1},
		{"mobs_farm:pet_bowl_fish", "mobs_farm:pet_bowl", 0},
		{"mobs_farm:pet_bowl_fish", "mobs_farm:pet_bowl", -1},
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
	--stay_near = {{"default:water_source", "static_ocean:water_source", "mobs_farm:pet_bowl_fish", "mobs_farm:pet_bowl_water"}, 10},
	on_rightclick = function(self, clicker)

		if not self.tamed and mobs:feed_tame(self, clicker, 4, false, true) then return end
		--if mobs:protect(self, clicker) then return end
		--if mobs:capture_mob(self, clicker, 50, 50, 90, false, nil) then return end

		-- by right-clicking owner can switch between staying and walking
		if self.owner and self.owner == clicker:get_player_name() then

			if self.order ~= "stand" then
				self.order = "stand"
				self.state = "stand"
				self.object:set_velocity({x = 0, y = 0, z = 0})
				mobs:set_animation(self, "stand")
			else
				self.order = ""
				mobs:set_animation(self, "stoodup")
			end
		end
	end,

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
				if (name == "mobs_farm:kitten" and obj:get_luaentity().owner == self.owner) or (obj:is_player() and obj:get_player_name() == self.owner) then
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
	name = "mobs_farm:kitten",
	nodes = {"group:soil"},
	neighbors = {"default:junglegrass", "default:jungletree", "group:dry_grass", "default:acacia_tree", "default:acacia_bush_leaves"},
	--min_light = 14,
	interval = 60,
	chance = 8000, -- 22000
	min_height = 5,
	max_height = 200,
	day_toggle = nil,
	--active_object_count = 4,
})
end


mobs:register_egg("mobs_farm:kitten", S("Kitten"), "mobs_kitten_inv.png", 0)


mobs:alias_mob("mobs:kitten", "mobs_farm:kitten") -- compatibility

--[[
local hairball_items = {
	"default:stick", "default:coal_lump", "default:dry_shrub", "flowers:rose",
	"mobs_farm:rat", "default:grass_1", "farming:seed_wheat", "dye:green", "",
	"farming:seed_cotton", "default:flint", "default:sapling", "dye:white", "",
	"default:clay_lump", "default:paper", "default:dry_grass_1", "dye:red", "",
	"farming:string", "mobs:chicken_feather", "default:acacia_bush_sapling", "",
	"default:bush_sapling", "default:copper_lump", "default:iron_lump", "",
	"dye:black", "dye:brown", "default:obsidian_shard", "default:tin_lump"
}

minetest.register_craftitem(":mobs:hairball", {
	description = S("Hairball"),
	inventory_image = "mobs_hairball.png",
	on_use = function(itemstack, user, pointed_thing)

		local pos = user:get_pos()
		local dir = user:get_look_dir()
		local newpos = {x = pos.x + dir.x, y = pos.y + dir.y + 1.5, z = pos.z + dir.z}
		local item = hairball_items[math.random(1, #hairball_items)]

		if item ~= ""
		and minetest.registered_items[item] then
			minetest.add_item(newpos, {name = item})
		end

		minetest.sound_play("default_place_node_hard", {
			pos = newpos,
			gain = 1.0,
			max_hear_distance = 5,
		})

		itemstack:take_item()

		return itemstack
	end,
})
--]]
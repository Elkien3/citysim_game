
local S = mobs.intllib

local time_speed = minetest.settings:get("time_speed") or 72
time_speed = tonumber(time_speed)
if time_speed < 1 then
	time_speed = 1
end
--how much hunger should go down per ingame day
local hungerrate = 5/time_speed
local thirstrate = 5/time_speed

for i, name in pairs({"default:grass_", "default:dry_grass_", "default:marram_grass_", "default:fern_"}) do
	for i = 1, 5 do
		if minetest.registered_nodes[name.. i] then
				local groups = minetest.registered_nodes[name.. i].groups
				groups.level = 1
				local newdrop = {items = {{tools = {"~sword"}, items = {name.."1"}}}}
				if name == "default:grass_" then
					table.insert(newdrop.items, {items = {"farming:seed_wheat"}, rarity = 5})
				end
				minetest.override_item(name..i, {groups = groups, drop = newdrop})
		end
	end
end
if minetest.registered_nodes["default:junglegrass"] then
	minetest.override_item("default:junglegrass", {drop = {items = {{items = {"farming:seed_cotton"}, rarity = 8}, {tools = {"~sword"}, items = {"default:junglegrass"}}}}})
end

if flowers then
	minetest.register_abm({
		label = "Grass spread catch up",
		nodenames = {"group:grass"},
		interval = 13,
		chance = 300,
		catch_up = true,
		action = function(...)
			flowers.flower_spread(...)
		end,
	})
end

-- Cow by sirrobzeroone (edited by Elkien3)

local cow_max_yield = 5

local function clamp(num, min, max)
	if not num then return end
	if max and num > max then num = max end
	if min and num < min then num = min end
	return num
end

mobs:register_mob("mobs_farm:cow", {
	type = "animal",
	passive = false,
	attack_type = "dogfight",
	attack_npcs = false,
	group_attack = true,
	reach = 2,
	damage = 4,
	hp_min = 5,
	hp_max = 20,
	armor = 200,
	collisionbox = {-0.45, -0.01, -0.45, 0.45, 1.39, 0.45},
	visual = "mesh",
	visual_size = {x=2.8, y=2.8},
	mesh = "mobs_mc_cow.b3d",
	textures = { {
		"mobs_mc_cow.png",
		"blank.png",
	}, },
	makes_footstep_sound = true,
	sounds = {
		random = "mobs_mc_cow",
	},
	walk_velocity = 1,
	run_velocity = 2,
	jump = true,
	jump_height = 6,
	pushable = true,
	drops = {
		{name = "mobs:meat_raw", chance = 1, min = cow_max_yield - 1, max = cow_max_yield},
	},
	water_damage = 0,
	lava_damage = 5,
	light_damage = 0,
	animation = {
		stand_speed = 25, walk_speed = 25, run_speed = 50,
		stand_start = 0,		stand_end = 0,
		walk_start = 0,		walk_end = 40,
		run_start = 0,		run_end = 40,
	},
	follow = {
		"farming:wheat", "default:grass_1", "farming:barley",
		"farming:oat", "farming:rye"
	},
	view_range = 8,
	replace_rate = 4,--10,
	replace_what = {
		{"group:grass", "air", 0},
		{"default:water_source", "air", 0},
		{"default:water_source", "air", -1},
		{"static_ocean:water_source", "air", 0},
		{"static_ocean:water_source", "air", -1},
		{"farming:straw", "air", 0},
		{"farming:straw", "air", 1},
		--{"default:dirt_with_grass", "default:dirt", -1}
	},
	--stay_near = {{"farming:straw", "group:grass", "default:water_source", "static_ocean:water_source"}, 10},
	fear_height = 2,
	after_activate = function(self, staticdata, def, dtime)
		if not self.food then
			self.food = 0
		end
		if not self.water then
			self.water = 0
		end
		self.stay_near = mobs_farm.get_stay_near(self, {"farming:straw", "group:grass"})
		self.cowtimer = 30
	end,
	on_rightclick = function(self, clicker)

		-- feed or tame
		if mobs:feed_tame(self, clicker, 4, false, true) then return end
		if mobs:feed_tame(self, clicker, 20, true, false) then return end

		--if mobs:protect(self, clicker) then return end
		--if mobs:capture_mob(self, clicker, 0, 5, 60, false, nil) then return end

		local tool = clicker:get_wielded_item()
		local name = clicker:get_player_name()

		-- milk cow with empty bucket
		if tool:get_name() == "bucket:bucket_empty" then

			if self.gotten == true
			or self.child == true then
				return
			end

			if mobs_farm.round(self.food) < 16 or mobs_farm.round(self.water) < 16 or self.health < 16 then
				minetest.chat_send_player(name,
					S("Cow must have at least 16 food, water and health to be milked"))
				return
			end
			
			local inv = clicker:get_inventory()

			tool:take_item()
			clicker:set_wielded_item(tool)

			if inv:room_for_item("main", {name = "mobs:bucket_milk"}) then
				clicker:get_inventory():add_item("main", "mobs:bucket_milk")
			else
				local pos = self.object:get_pos()
				pos.y = pos.y + 0.5
				minetest.add_item(pos, {name = "mobs:bucket_milk"})
			end
			self.food = 12
			self.water = 12
			self.stay_near = mobs_farm.get_stay_near(self, {"farming:straw", "group:grass"})
			self.gotten = true -- milked

			return
		end
	end,

	on_replace = function(self, pos, oldnode, newnode)
		if not self.owner or self.owner == "" then return false end
		local name = oldnode or ""
		local value = 0
		local nodetype = "food"
		if string.find(name, "water") then
			nodetype = "water"
			value = 10
		elseif name == "farming:straw" then
			value = 10
			if self[nodetype] + value > 22 then--don't waste too much straw
				return false
			end
		elseif name == "default:dirt_with_grass" and (self.food or 0) < 5 then
			value = 0--.1
		elseif name == "default:junglegrass" or string.find(name, "fern") then
			value = 6
		elseif string.find(name, "grass") then
			value = 4
		end
		self.stay_near = mobs_farm.get_stay_near(self, {"farming:straw", "group:grass"})
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
		self.drops[1].max = 2
		self.drops[1].min = clamp(self.drops[1].max-1, 0)
	end,
	do_custom = function(self, dtime)
		local pos = self.object:get_pos()
		self.cowtimer = (self.cowtimer or 0) + dtime
		if self.cowtimer > 30 then
			if self.lastday then
				local dayspassed = minetest.get_day_count() - self.lastday
				if dayspassed > 0 then
					self.food = self.food - hungerrate*dayspassed
					self.water = self.water - thirstrate*dayspassed
					if self.food <= 0 or self.water <= 0 then
						if self.food <= 0 then
							self.drops[1].max = clamp(self.drops[1].max-dayspassed, 0, cow_max_yield)
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
						self.drops[1].max = clamp(self.drops[1].max+dayspassed, 0, cow_max_yield)
						self.drops[1].min = clamp(self.drops[1].max-1, 0)
						self.gotten = false
						if self.horny or self.child then
							self.hornytimer = self.hornytimer + dayspassed
						end
					end
					if self.food < 0 then self.food = 0 end
					if self.water < 0 then self.water = 0 end
					self.stay_near = mobs_farm.get_stay_near(self, {"farming:straw", "group:grass"})
					self.lastday = minetest.get_day_count()
				end
				if dayspassed < 0 then
					self.lastday = minetest.get_day_count()
				end
			else
				self.lastday = minetest.get_day_count()
			end
			self.cowtimer = math.random(5)
			local objects = minetest.get_objects_inside_radius(pos, 30)
			local cowposlist = {}
			self.herdpos = {x=0,y=0,z=0}
			for i, obj in pairs(objects) do
				local name
				if obj:get_luaentity() then name = obj:get_luaentity().name end
				if (name == "mobs_farm:cow" and obj:get_luaentity().owner == self.owner) or (obj:is_player() and obj:get_player_name() == self.owner) then
					table.insert(cowposlist, obj:get_pos())
					self.herdpos = vector.add(self.herdpos, obj:get_pos())
				end
			end
			if #cowposlist == 1 then
				self.herdpos = nil
			else
				self.herdpos = vector.divide(self.herdpos, #cowposlist)
			end
			--[[for i, player in pairs(minetest.get_connected_players()) do
				local marker = player:hud_add({
						hud_elem_type = "waypoint",
						name = "",
						number = 0xFF0000,
						world_pos = self.herdpos
					})
				minetest.after(5, function() player:hud_remove(marker) end, player, marker)
			end--]]
		end
	end,
	on_die = function(self, pos)
		return mobs_farm.on_die(self, pos, "Cow")
	end,
})


if not mobs.custom_spawn_animal then
mobs:spawn({
	name = "mobs_farm:cow",
	nodes = {"default:dirt_with_grass"},
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


mobs:register_egg("mobs_farm:cow", S("Cow"), "mobs_mc_spawn_icon_cow.png")


mobs:alias_mob("mobs:cow", "mobs_farm:cow") -- compatibility


-- bucket of milk
minetest.register_craftitem(":mobs:bucket_milk", {
	description = S("Bucket of Milk"),
	inventory_image = "mobs_bucket_milk.png",
	stack_max = 1,
	on_use = minetest.item_eat(8, "bucket:bucket_empty"),
	groups = {food_milk = 1, flammable = 3, drink = 1},
})

-- glass of milk
minetest.register_craftitem(":mobs:glass_milk", {
	description = S("Glass of Milk"),
	inventory_image = "mobs_glass_milk.png",
	on_use = minetest.item_eat(2, "vessels:drinking_glass"),
	groups = {food_milk_glass = 1, flammable = 3, vessel = 1, drink = 1},
})

minetest.register_craft({
--	type = "shapeless",
	output = "mobs:glass_milk 4",
	recipe = {
		{"vessels:drinking_glass", "vessels:drinking_glass"},
		{"vessels:drinking_glass", "vessels:drinking_glass"},
		{"mobs:bucket_milk", ""}
	},
	replacements = { {"mobs:bucket_milk", "bucket:bucket_empty"} }
})

minetest.register_craft({
--	type = "shapeless",
	output = "mobs:bucket_milk",
	recipe = {
		{"group:food_milk_glass", "group:food_milk_glass"},
		{"group:food_milk_glass", "group:food_milk_glass"},
		{"bucket:bucket_empty", ""}
	},
	replacements = {
		{"group:food_milk_glass", "vessels:drinking_glass 4"}
	}
})


-- butter
minetest.register_craftitem(":mobs:butter", {
	description = S("Butter"),
	inventory_image = "mobs_butter.png",
	on_use = minetest.item_eat(1),
	groups = {food_butter = 1, flammable = 2}
})

if minetest.get_modpath("farming") and farming and farming.mod then
minetest.register_craft({
	type = "shapeless",
	output = "mobs:butter",
	recipe = {"mobs:bucket_milk", "farming:salt"},
	replacements = {{ "mobs:bucket_milk", "bucket:bucket_empty"}}
})
else -- some saplings are high in sodium so makes a good replacement item
minetest.register_craft({
	type = "shapeless",
	output = "mobs:butter",
	recipe = {"mobs:bucket_milk", "default:sapling"},
	replacements = {{ "mobs:bucket_milk", "bucket:bucket_empty"}}
})
end

-- cheese wedge
minetest.register_craftitem(":mobs:cheese", {
	description = S("Cheese"),
	inventory_image = "mobs_cheese.png",
	on_use = minetest.item_eat(4),
	groups = {food_cheese = 1, flammable = 2},
})

minetest.register_craft({
	type = "cooking",
	output = "mobs:cheese",
	recipe = "mobs:bucket_milk",
	cooktime = 5,
	replacements = {{ "mobs:bucket_milk", "bucket:bucket_empty"}}
})
--[[
-- cheese block
minetest.register_node(":mobs:cheeseblock", {
	description = S("Cheese Block"),
	tiles = {"mobs_cheeseblock.png"},
	is_ground_content = false,
	groups = {oddly_breakable_by_hand = 3},
	sounds = default.node_sound_dirt_defaults()
})

minetest.register_craft({
	output = "mobs:cheeseblock",
	recipe = {
		{"group:food_cheese", "group:food_cheese", "group:food_cheese"},
		{"group:food_cheese", "group:food_cheese", "group:food_cheese"},
		{"group:food_cheese", "group:food_cheese", "group:food_cheese"},
	}
})

minetest.register_craft({
	output = "mobs:cheese 9",
	recipe = {
		{"mobs:cheeseblock"},
	}
})
--]]
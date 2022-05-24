--[[
mobs:register_spawn("mobs_farm:wolf", {"default:dirt_with_grass","default:dirt"}, 10, -1, 11000, 3, 31000)
mobs:register_egg("mobs_farm:wolf", "Wolf", "mobs_mc_spawn_icon_wolf.png", 0)--]]

local time_speed = minetest.settings:get("time_speed") or 72
time_speed = tonumber(time_speed)
if time_speed < 1 then
	time_speed = 1
end
--how much hunger should go down per ingame day
local hungerrate = 5/time_speed
local thirstrate = 5/time_speed

local food = {"mobs_farm:pet_bowl_meat"}
local water = {"default:water_source", "static_ocean:water_source", "mobs_farm:pet_bowl_water"}

--License for code WTFPL and otherwise stated in readmes

-- intllib
local MP = minetest.get_modpath(minetest.get_current_modname())
local S = mobs.intllib

local default_walk_chance = 50

local pr = PseudoRandom(os.time()*10)

-- Wolf
local wolf = {
	type = "animal",

	hp_min = 8,
	hp_max = 8,
	passive = false,
	pushable = true,
	group_attack = true,
	collisionbox = {-0.3, -0.01, -0.3, 0.3, 0.84, 0.3},
	visual = "mesh",
	mesh = "mobs_mc_wolf.b3d",
	textures = {
		{"mobs_mc_wolf.png"},
	},
	visual_size = {x=3, y=3},
	makes_footstep_sound = true,
	sounds = {
		war_cry = "mobs_wolf_attack",
		distance = 16,
	},
	--pathfinding = 1,
	floats = 1,
	view_range = 16,
	--walk_chance = default_walk_chance,
	walk_velocity = 2,
	run_velocity = 3,
	stepheight = 1.1,
	damage = 4,
	reach = 2,
	attack_players = true,
	attack_animals = true,
	--specific_attack = {"player", "mobs_farm:chicken", "mobs_farm:cow", "mobs_farm:bunny", "mobs_farm:kitten"},
	attack_type = "dogfight",
	fear_height = 4,
	water_damage = 0,
	lava_damage = 4,
	light_damage = 0,
	follow = "mobs:meat_raw",--mobs_mc.follow.wolf,
	on_rightclick = function(self, clicker)
		if mobs:feed_tame(self, clicker, 4, false, true) then
			local dog, ent
			local yaw = self.object:get_yaw()
			dog = minetest.add_entity(self.object:getpos(), "mobs_farm:dog")
			dog:set_yaw(yaw)
			ent = dog:get_luaentity()
			ent.owner = clicker:get_player_name()
			ent.health = self.health
			ent.food = self.food
			self.object:remove()
		end
	end,
	animation = {
		speed_normal = 50,		speed_run = 100,
		stand_start = 40,		stand_end = 45,
		walk_start = 0,		walk_end = 40,
		run_start = 0,		run_end = 40,
	},
	jump = true,
	attacks_monsters = true,
	do_custom = function(self, dtime)
		local pos = self.object:get_pos()
		self.wolftimer = (self.wolftimer or 0) + dtime
		if self.wolftimer >= 1 then
			self.wolftimer = 0
			local p, sp, dist, min_player
			local min_dist = self.view_range + 1
			local s = self.object:get_pos()
			local max_speed = tonumber((minetest.settings:get("movement_speed_walk") or 4))
			for _, player in pairs(minetest.get_connected_players()) do
				p = player:get_pos()
				sp = s
				dist = vector.distance(p, s)
				-- aim higher to make looking up hills more realistic
				p.y = p.y + 1
				sp.y = sp.y + 1
				-- choose closest player to attack that isnt self
				if dist ~= 0
				and dist < min_dist
				and self:line_of_sight(sp, p, 2) == true
				and not mobs.is_peaceful_player(player)
				and (player:get_hp() <= 8
				or ((vector.distance(s, vector.add(p, player:get_velocity())) - dist) > (max_speed-1)--player is moving away quickly
				and vector.distance(player:get_look_dir(), vector.direction(s, p)) < 1 --and looking away
				))
				then
					min_dist = dist
					min_player = player
				end
			end

			if min_player and math.random(100) > self.attack_chance then
				local val = mobs:do_attack(self, min_player)
			end
		end
	end
}

mobs:register_mob("mobs_farm:wolf", wolf)

-- Tamed wolf

-- Collar colors
local colors = {
	["unicolor_black"] = "#000000",
	["unicolor_blue"] = "#0000BB",
	["unicolor_dark_orange"] = "#663300", -- brown
	["unicolor_cyan"] = "#01FFD8",
	["unicolor_dark_green"] = "#005B00",
	["unicolor_grey"] = "#C0C0C0",
	["unicolor_darkgrey"] = "#303030",
	["unicolor_green"] = "#00FF01",
	["unicolor_red_violet"] = "#FF05BB", -- magenta
	["unicolor_orange"] = "#FF8401",
	["unicolor_light_red"] = "#FF65B5", -- pink
	["unicolor_red"] = "#FF0000",
	["unicolor_violet"] = "#5000CC",
	["unicolor_white"] = "#FFFFFF",
	["unicolor_yellow"] = "#FFFF00",

	["unicolor_light_blue"] = "#B0B0FF",
}

local get_dog_textures = function(color)
	if colors[color] then
		return {"mobs_mc_wolf_tame.png^(mobs_mc_wolf_collar.png^[colorize:"..colors[color]..":192)"}
	else
		return nil
	end
end

-- Tamed wolf (aka “dog”)
local dog = table.copy(wolf)
--dog.passive = false
dog.hp_min = 20
dog.hp_max = 20
dog.specific_attack = {"mobs_farm:wolf"}
-- Tamed wolf texture + red collar
dog.textures = get_dog_textures("unicolor_red")
dog.owner = ""
-- TODO: Start sitting by default
dog.order = "roam"
dog.owner_loyal = true
dog.replace_rate = 4--10,
dog.replace_what = {
	{"default:water_source", "air", 0},
	{"default:water_source", "air", -1},
	{"static_ocean:water_source", "air", 0},
	{"static_ocean:water_source", "air", -1},
	{"mobs_farm:pet_bowl_water", "mobs_farm:pet_bowl", 0},
	{"mobs_farm:pet_bowl_water", "mobs_farm:pet_bowl", -1},
	{"mobs_farm:pet_bowl_meat", "mobs_farm:pet_bowl", 0},
	{"mobs_farm:pet_bowl_meat", "mobs_farm:pet_bowl", -1},
}
dog.on_replace = function(self, pos, oldnode, newnode)
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
end
-- Automatically teleport dog to owner
--dog.do_custom = mobs_mc.make_owner_teleport_function(12)
dog.after_activate = function(self, staticdata, def, dtime)
	if not self.food then
		self.food = 0
	end
	if not self.water then
		self.water = 0
	end
	self.animaltimer = 30
	self.stay_near = mobs_farm.get_stay_near(self, food, water)
end
dog.do_custom = function(self, dtime)
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
			if (name == "mobs_farm:dog" and obj:get_luaentity().owner == self.owner) or (obj:is_player() and obj:get_player_name() == self.owner) then
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
end
dog.on_die = mobs_farm.on_die
dog.follow = "mobs:meat_raw"
dog.on_rightclick = function(self, clicker)
	local item = clicker:get_wielded_item()

	--if mobs:protect(self, clicker) then return end
	--if item:get_name() ~= "" and mobs:capture_mob(self, clicker, 0, 2, 80, false, nil) then return end
	local name = clicker:get_player_name()
	if self.owner and name and self.owner == name and clicker:get_player_control().sneak then
			minetest.show_formspec(name, "mobs_farm_changeowner", "size[5,2]field[1,1;4,1;changeowner;Change Owner;]field_close_on_enter[changeowner;false]")
			mobs_farm.form[name] = self
	elseif false and item:get_name() == "mobs:meat_raw" then
		-- Feed to increase health
		local hp = self.health
		local hp_add = 0
		-- Use eatable group to determine health boost
		local eatable = minetest.get_item_group(item, "eatable")
		if eatable > 0 then
			hp_add = eatable
		else
			hp_add = 4
		end
		local new_hp = hp + hp_add
		if new_hp > self.hp_max then
			new_hp = self.hp_max
		end
		if not minetest.settings:get_bool("creative_mode") then
			item:take_item()
			clicker:set_wielded_item(item)
		end
		self.health = new_hp
		return
	elseif minetest.get_item_group(item:get_name(), "dye") == 1 then
		-- Dye (if possible)
		for group, _ in pairs(colors) do
			-- Check if color is supported
			if minetest.get_item_group(item:get_name(), group) == 1 then
				-- Dye collar
				local tex = get_dog_textures(group)
				if tex then
					self.base_texture = tex
					self.object:set_properties({
						textures = self.base_texture
					})
					if not minetest.settings:get_bool("creative_mode") then
						item:take_item()
						clicker:set_wielded_item(item)
					end
					break
				end
			end
		end
	else
		-- Toggle sitting order

		if not self.owner or self.owner == "" then
			-- Huh? This wolf has no owner? Let's fix this! This should never happen.
			self.owner = clicker:get_player_name()
		end

		if not self.order or self.order == "" or self.order == "sit" then
			self.order = "roam"
			self.walk_chance = default_walk_chance
			self.jump = true
		elseif self.order == "roam" then
			-- TODO: Add sitting model
			self.order = "sit"
			self.walk_chance = 0
			self.jump = false
		--[[else
			self.following = clicker
			self.order = "follow"
			self.walk_chance = 0
			--self.jump = true--]]
		end
		--minetest.chat_send_player(self.owner, self.order)
	end
end

mobs:register_mob("mobs_farm:dog", dog)
mobs:register_egg("mobs_farm:wolf", S("Wolf"), "mobs_mc_spawn_icon_wolf.png", 0)
mobs:spawn({
	name = "mobs_farm:wolf",
	nodes = {"default:dirt", "default:dirt_with_grass", "default:dirt_with_coniferous_litter", "group:snowy"},
	neighbors = {"default:tree", "default:pine_tree", "default:aspen_tree"},
	--min_light = 14,
	interval = 60,
	chance = 8000, -- 15000
	min_height = 5,
	max_height = 200,
	day_toggle = nil,
	--active_object_count = 4,
})
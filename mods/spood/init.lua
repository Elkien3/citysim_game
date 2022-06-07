local storage = minetest.get_mod_storage()
local spoodtbl = minetest.deserialize(storage:get_string("data")) or {}

local function calceffect(name, forced)
	local speed = 1
	local sideeffect = 0
	for id, effect in pairs(spoodtbl[name]) do
		if not forced then
			effect.timer = effect.timer + 1
		end
		if effect.timer == 300 then--effects end after 300 minutes (5 hours) of playtime
			spoodtbl[name][id] = nil
			if next(spoodtbl[name]) == nil then
			   return nil, nil
			end
		else
			speed = speed *(math.sin((.33*effect.timer)^.4)*((10*effect.mutli)/(effect.timer+100))+1)
			--speed over time, effect goes down depending on how many timers are in the player's name
			sideeffect = sideeffect + math.sin(.01*effect.timer)
			--side effects over time, peaking halfway through, not caring about how many timers there are
		end
	end
	return speed, sideeffect
end

function spood_get_effect(name)
	local speed, sideeffect = calceffect(name, true)
	return speed, sideeffect
end

local function play_footsteps(player, name, pos)
	local r = math.random
	local name = player:get_player_name()
	pos = vector.add(pos, {x=r(-40, 40), y=r(-20, 20), z=r(-40, 40)})
	local velocity = vector.normalize({x=r(-30, 30), y=r(-10, 10), z=r(-30, 30)})
	local footsteps = {"glass", "grass", "gravel", "hard", "ice", "metal", "sand", "snow", "water", "wood"}
	local stepsound = "default_"..footsteps[r(10)].."_footstep"
	local stepnum = r(1, 10)
	local stepspeed = r(33, 200)/100
	for i = 1, stepnum do
		local newpos = vector.add(pos, vector.multiply(velocity, i))
		minetest.after(stepspeed*i, minetest.sound_play, stepsound, {to_player = name, pos = newpos}, true)
	end
end
local function spawn_eyes(player, name, pos)
	local r = math.random
	minetest.add_particle({
		pos = vector.add(pos, {x=r(-40, 40), y=r(-20, 20), z=r(-40, 40)}),
		velocity = vector.normalize({x=r(-30, 30), y=r(-10, 10), z=r(-30, 30)}),
		expirationtime = math.random(4),
		size = 10,
		texture = "eyes.png",
		playername = name,
		glow = 6
	})
end

local function spoodtick()
	for i, player in pairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		if spoodtbl[name] then
			local speed, sideeffect = calceffect(name)
			if sideeffect and sideeffect > 0 then
				local pos = player:get_pos()
				if math.random(math.ceil(10/sideeffect)) == 1 then
					minetest.after(math.random(60), play_footsteps, player, name, pos)
				end
				if math.random(math.ceil(3/sideeffect)) == 1 then
					minetest.after(math.random(60), spawn_eyes, player, name, pos)
				end
			end
			playercontrol.set_effect(name, "wag", sideeffect, "spood", true)
			playercontrol.set_effect(name, "speed", speed, "spood", true)
			if charactercreation_update then charactercreation_update(player) end
			if not sideeffect and not speed then
				spoodtbl[name] = nil
			end
		end
	end
	storage:set_string("data", minetest.serialize(spoodtbl))
	minetest.after(1, spoodtick)
end
spoodtick()

minetest.register_on_dieplayer(function(player, reason)
	local name = player:get_player_name()
	spoodtbl[name] = nil
	playercontrol.set_effect(name, "wag", nil, "spood", true)
	playercontrol.set_effect(name, "speed", nil, "spood", true)
	storage:set_string("data", minetest.serialize(spoodtbl))
end)

minetest.register_on_joinplayer(function(player, last_login)
	local name = player:get_player_name()
	if spoodtbl[name] then
		local speed, sideeffect = calceffect(name, true)
		playercontrol.set_effect(name, "wag", sideeffect, "spood", true)
		playercontrol.set_effect(name, "speed", speed, "spood", true)
	end
end)

minetest.register_node("spood:spood_refined", {
	description = "Refined Spood",
	groups = {oddly_breakable_by_hand = 3},
	tiles = {
		"default_snow.png",
		"default_snow.png",
		"default_snow.png",
		"default_snow.png",
		"default_snow.png",
		"default_snow.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.375, -0.5, -0.25, 0.1875, -0.4375, 0.375}, -- NodeBox1
			{-0.125, -0.5, -0.3125, 0.3125, -0.375, 0.1875}, -- NodeBox2
			{-0.1875, -0.5, -0.125, 0.0625, -0.3125, 0.1875}, -- NodeBox3
		}
	},
	 selection_box = {
		type = "fixed",
		fixed = {
			{-0.375, -0.5, -0.375, 0.375, -0.3125, 0.375}, -- selectionbox
			-- Node box format: see [Node boxes]
		},
	},
	on_use = function(itemstack, player, pointed_thing)
		local name = player:get_player_name()
		if not spoodtbl[name] then spoodtbl[name] = {} end
		local multi = 1-(#spoodtbl[name]*.1)
		if multi < 0 then multi = 0 end
		table.insert(spoodtbl[name], {timer = 0, mutli = multi})
		storage:set_string("data", minetest.serialize(spoodtbl))
		itemstack:take_item()
		return itemstack
	end
})

minetest.register_node("spood:spood_source", {
	description = "Spood Source",
	drawtype = "liquid",
	waving = 3,
	tiles = {
		{
			name = "spood_source.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0,
			},
		},
		{
			name = "spood_source.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0,
			},
		},
	},
	use_texture_alpha = "blend",
	paramtype = "light",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	drop = "",
	drowning = 1,
	liquidtype = "source",
	liquid_alternative_flowing = "spood:spood_flowing",
	liquid_alternative_source = "spood:spood_source",
	liquid_viscosity = 1,
	post_effect_color = {a = 103, r = 50, g = 70, b = 90},
	groups = {water = 3, liquid = 3, cools_lava = 1, vaporizable = 1},
	sounds = default.node_sound_water_defaults(),
	gas="gas_lib:steam",
	gas_byproduct = "spood:spood_refined",
	gas_byproduct_chance = 1
})

minetest.register_node("spood:spood_flowing", {
	description = "Flowing Spood",
	drawtype = "flowingliquid",
	waving = 3,
	tiles = {"spood_water.png"},
	special_tiles = {
		{
			name = "spood_flowing.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 0.5,
			},
		},
		{
			name = "spood_flowing.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 0.5,
			},
		},
	},
	use_texture_alpha = "blend",
	paramtype = "light",
	paramtype2 = "flowingliquid",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	drop = "",
	drowning = 1,
	liquidtype = "flowing",
	liquid_alternative_flowing = "spood:spood_flowing",
	liquid_alternative_source = "spood:spood_source",
	liquid_viscosity = 1,
	post_effect_color = {a = 103, r = 50, g = 70, b = 90},
	groups = {water = 3, liquid = 3, not_in_creative_inventory = 1,
		cools_lava = 1},
	sounds = default.node_sound_water_defaults(),
})

minetest.register_node("spood:seed_spood", {
	description = "Spood Seed",
	tiles = {"drugwars_coca_seed.png"},
	inventory_image = "drugwars_coca_seed.png",
	wield_image = "drugwars_coca_seed.png",
	drawtype = "signlike",
	groups = {seed = 1, snappy = 3, attached_node = 1, flammable = 4},
	paramtype = "light",
	paramtype2 = "wallmounted",
	walkable = false,
	sunlight_propagates = true,
	selection_box = farming.select,
	on_place = function(itemstack, placer, pointed_thing)
		return farming.place_seed(itemstack, placer, pointed_thing, "farming:spood_1")
	end,
})

minetest.register_craftitem("spood:raw_spood", {
	description = "Raw Spood",
	inventory_image = "drugwars_coca_leaf.png",
	groups = {flammable = 4},
})

local crop_def = {
	drawtype = "plantlike",
	tiles = {"drugwars_coca_1.png"},
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	buildable_to = true,
	drop =  "",
	selection_box = farming.select,
	groups = {
		snappy = 3, flammable = 4, plant = 1, attached_node = 1,
		not_in_creative_inventory = 1, growing = 1, rainy = 1
	},
	sounds = default.node_sound_leaves_defaults()
}

-- stage 1
minetest.register_node(":farming:spood_1", table.copy(crop_def))

-- stage 2
crop_def.tiles = {"drugwars_coca_2.png"}
minetest.register_node(":farming:spood_2", table.copy(crop_def))

-- stage 3
crop_def.tiles = {"drugwars_coca_3.png"}
minetest.register_node(":farming:spood_3", table.copy(crop_def))

-- stage 4
crop_def.tiles = {"drugwars_coca_4.png"}
minetest.register_node(":farming:spood_4", table.copy(crop_def))

-- stage 5
crop_def.tiles = {"drugwars_coca_5.png"}
crop_def.drop = {
	items = {
		{items = {"spood:seed_spood"}, rarity = 1},
	}
}
minetest.register_node(":farming:spood_5", table.copy(crop_def))

-- stage 6
crop_def.tiles = {"drugwars_coca_6.png"}
crop_def.drop = {
	items = {
		{items = {"spood:raw_spood"}, rarity = 1},
		{items = {"spood:raw_spood"}, rarity = 2},
	}
}
minetest.register_node(":farming:spood_6", table.copy(crop_def))

-- stage 7
crop_def.tiles = {"drugwars_coca_7.png"}
crop_def.drop = {
	items = {
		{items = {"spood:raw_spood"}, rarity = 1},
		{items = {"spood:raw_spood"}, rarity = 2},
		{items = {"spood:seed_spood"}, rarity = 1},
		{items = {"spood:seed_spood"}, rarity = 2},
	}
}
minetest.register_node(":farming:spood_7", table.copy(crop_def))

-- stage 8 (final)
crop_def.tiles = {"drugwars_coca_8.png"}
crop_def.groups.growing = 0
crop_def.drop = {
	items = {
		{items = {"spood:raw_spood"}, rarity = 1},
		{items = {"spood:raw_spood"}, rarity = 2},
		{items = {"spood:raw_spood"}, rarity = 3},
		{items = {"spood:seed_spood"}, rarity = 1},
		{items = {"spood:seed_spood"}, rarity = 2},
		{items = {"spood:seed_spood"}, rarity = 3},
	}
}
minetest.register_node(":farming:spood_8", table.copy(crop_def))

-- add to registered_plants
farming.registered_plants["spood:spood"] = {
	crop = "spood:raw_spood",
	seed = "spood:seed_spood",
	minlight = 15,
	maxlight = 15,
	steps = 8
}

bucket.register_liquid(
	"spood:spood_source",
	"spood:spood_flowing",
	"spood:bucket_spood",
	"bucket_spood.png",
	"Bucket of Spood",
	{tool = 1,}
)

minetest.register_craft({
	recipe = {
		{"spood:raw_spood", "spood:raw_spood", "spood:raw_spood"},
		{"spood:raw_spood", "bucket:bucket_water", "spood:raw_spood"},
		{"spood:raw_spood", "spood:raw_spood", "spood:raw_spood"},
	},
	output = "spood:bucket_spood"
})
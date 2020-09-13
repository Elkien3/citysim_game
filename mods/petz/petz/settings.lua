local modpath = ...

local settings = Settings(modpath .. "/petz.conf")
local user = Settings(modpath .. "/user.conf")

-- All the settings definitions
local settings_def = {
	{
	name = "petz_list",
	type = "string",
	split = true,
	default = "",
	},
	{
	name = "disable_monsters",
	type = "boolean",
	default = false,
	},
	--Tamagochi Mode
	{
	name = "tamagochi_mode",
	type = "boolean",
	default = true,
	},
	{
	name = "tamagochi_check_time",
	type = "number",
	default = 2400,
	},
	{
	name = "tamagochi_reduction_factor",
	type = "number",
	default = 0.3,
	},
	{
	name = "tamagochi_punch_rate",
	type = "number",
	default = 0.3,
	},
	{
	name = "tamagochi_feed_hunger_rate",
	type = "number",
	default = 0.3,
	},
	{
	name = "tamagochi_brush_rate",
	type = "number",
	default = 0.2,
	},
	{
	name = "tamagochi_beaver_oil_rate",
	type = "number",
	default = 0.2,
	},
	{
	name = "tamagochi_lashing_rate",
	type = "number",
	default = 0.2,
	},
	{
	name = "tamagochi_hungry_warning",
	type = "number",
	default = 0.5,
	},
	{
	name = "tamagochi_check_if_player_online",
	type = "boolean",
	default = true,
	},
	{
	name = "tamagochi_safe_nodes",
	type = "string",
	split = true,
	default = "",
	},
	--Enviromental Damage
	{
	name = "air_damage",
	type = "number",
	default = 1,
	},
	{
	name = "igniter_damage",
	type = "number",
	default = 1,
	},
	--Capture Mobs
	{
	name = "lasso",
	type = "string",
	split = false,
	default = "petz:lasso",
	},
	{
	name = "rob_mobs",
	type = "boolean",
	default = false,
	},
	--Shears
	{
	name = "shears",
	type = "string",
	split = false,
	default = "petz:shears",
	},
	--Look at
	{
	name = "look_at",
	type = "boolean",
	default = true,
	},
	--Selling
	{
	name = "selling",
	type = "boolean",
	default = true,
	},
	--Spawn
	{
	name = "spawn_interval",
	type = "number",
	default = 30,
	},
	{
	name = "spawn_chance",
	type = "number",
	default = 0.3,
	},
	{
	name = "max_mobs",
	type = "number",
	default = 60,
	},
	{
	name = "spawn_peaceful_monsters_ratio",
	type = "number",
	default = 0.7,
	delimit =
		{
		min = 0.0,
		max = 1.0,
		}
	},
	{
	name = "no_spawn_in_protected",
	type = "boolean",
	default = false,
	},
	--Lifetime
	{
	name = "lifetime",
	type = "number",
	default = -1,
	},
	{
	name = "lifetime_variability",
	type = "number",
	default = 0.2,
	},
	{
	name = "lifetime_only_non_tamed",
	type = "boolean",
	default = false,
	},
	{
	name = "lifetime_avoid_non_breedable",
	type = "boolean",
	default = false,
	},
	--Lay Eggs
	{
	name = "lay_egg_chance",
	type = "number",
	default = 90000,
	},
	{
	name = "max_laid_eggs",
	type = "number",
	default = 10,
	},
	--Misc Random Sound Chance
	{
	name = "misc_sound_chance",
	type = "number",
	default = 50,
	},
	{
	name = "max_hear_distance",
	type = "number",
	default = 8,
	},
	--Fly Behaviour
	{
	name = "fly_check_time",
	type = "number",
	default = 3,
	},
	--Breed Engine
	{
	name = "pregnant_count",
	type = "number",
	default = 5,
	},
	{
	name = "pregnancy_time",
	type = "number",
	default = 300,
	},
	{
	name = "growth_time",
	type = "number",
	default = 1200,
	},
	--Punch Effect
	{
	name = "colorize_punch",
	type = "boolean",
	default = true,
	},
	{
	name = "punch_color",
	type = "string",
	split = false,
	default = "#FF0000",
	},
	--Blood
	{
	name = "blood",
	type = "boolean",
	default = false,
	},
	--Blood
	{
	name = "poop",
	type = "boolean",
	default = true,
	},
	{
	name = "poop_rate",
	type = "number",
	default = 600,
	},
	{
	name = "poop_decay",
	type = "number",
	default = 1200,
	},
	--Smoke particles when die
	{
	name = "death_effect",
	type = "boolean",
	default = true,
	},
	--Look_at
	{
	name = "look_at",
	type = "boolean",
	default = true,
	},
	{
	name = "look_at_random",
	type = "number",
	default = 10,
	},
	--Cobweb
	{
	name = "cobweb_decay",
	type = "number",
	default = 1200,
	},
	--Mount
	{
	name = "pointable_driver",
	type = "boolean",
	default = true,
	},
	{
	name = "gallop_time",
	type = "number",
	default = 20,
	},
	{
	name = "gallop_recover_time",
	type = "number",
	default = 60,
	},
	--Sleeping
	{
	name = "sleeping",
	type = "boolean",
	default = true,
	},
	--Herding
	{
	name = "herding",
	type = "boolean",
	default = true,
	},
	{
	name = "herding_timing",
	type = "number",
	default = 3,
	},
	{
	name = "herding_members_distance",
	type = "number",
	default = 5,
	},
	{
	name = "herding_shepherd_distance",
	type = "number",
	default = 5,
	},
	--Lashing
	{
	name = "lashing_tame_count",
	type = "number",
	default = 3,
	},
	--Bee Stuff
	{
	name = "initial_honey_behive",
	type = "number",
	default = 3,
	},
	{
	name = "max_honey_behive",
	type = "number",
	default = 10,
	},
	{
	name = "max_bees_behive",
	type = "number",
	default = 3,
	},
	{
	name = "bee_outing_ratio",
	type = "number",
	default = 20,
	},
	{
	name = "worker_bee_delay",
	type = "number",
	default = 300,
	},
	--Weapons
	{
	name = "pumpkin_grenade_damage",
	type = "number",
	default = 8,
	},
	--Horseshoes
	{
	name = "horseshoe_speedup",
	type = "number",
	default = 0.2,
	},
	--Population Control
	{
	name = "max_tamed_by_owner",
	type = "number",
	default = -1,
	},
	--Lycanthropy
	{
	name = "lycanthropy",
	type = "boolean",
	default = true,
	},
	{
	name = "lycanthropy_infection_chance_by_wolf",
	type = "number",
	default = 200,
	},
	{
	name = "lycanthropy_infection_chance_by_werewolf",
	type = "number",
	default = 10,
	},
	--Server Cron Tasks
	{
	name = "clear_mobs_time",
	type = "number",
	default = 0,
	},
}

for key, value in ipairs(settings_def) do
	if value.type == "string" then
		if not(value.default) then
			value.default = ''
		end
		local str = user:get(value.name) or settings:get(value.name, value.default)
		if value.split then
			str = string.split(str)
		end
		petz.settings[value.name] = str
	elseif value.type == "number" then
		if not(value.default) then
			value.default = -1
		end
		local number = tonumber(user:get(value.name) or settings:get(value.name, value.default))
		if value.delimit then
			number = mokapi.delimit_number(number, {min=value.delimit.min, max=value.delimit.max})
		end
		petz.settings[value.name] = number
	elseif value.type == "boolean" then
		if not(value.default) then
			value.default = false
		end
		petz.settings[value.name] = user:get_bool(value.name) or settings:get_bool(value.name, value.default)
	end
end

--Selling
petz.settings.selling_exchange_items = string.split(user:get("selling_exchange_items") or settings:get("selling_exchange_items", ""), ",")
petz.settings.selling_exchange_items_list = {}
for i = 1, #petz.settings.selling_exchange_items do
	local exchange_item = petz.settings.selling_exchange_items[i]
	local exchange_item_description = minetest.registered_items[exchange_item].description
	local exchange_item_inventory_image = minetest.registered_items[exchange_item].inventory_image
	if exchange_item_description then
		petz.settings.selling_exchange_items_list[i] = {name = exchange_item, description = exchange_item_description, inventory_image = exchange_item_inventory_image}
	end
end

--Mobs Specific
for i = 1, #petz.settings["petz_list"] do --load the settings
	local petz_type = petz.settings["petz_list"][i]
	petz.settings[petz_type.."_spawn"]  = user:get_bool(petz_type.."_spawn", false) or settings:get_bool(petz_type.."_spawn", false)
	petz.settings[petz_type.."_spawn_chance"]  = tonumber(user:get(petz_type.."_spawn_chance") or settings:get(petz_type.."_spawn_chance")) or 0.0
	petz.settings[petz_type.."_spawn_nodes"]  = user:get(petz_type.."_spawn_nodes", "") or settings:get(petz_type.."_spawn_nodes", "")
	petz.settings[petz_type.."_spawn_biome"]  = user:get(petz_type.."_spawn_biome", "default") or settings:get(petz_type.."_spawn_biome", "default")
	petz.settings[petz_type.."_spawn_herd"] = tonumber(user:get(petz_type.."_spawn_herd") or settings:get(petz_type.."_spawn_herd")) or 1
	petz.settings[petz_type.."_seasonal"] = user:get(petz_type.."_seasonal", "") or settings:get(petz_type.."_seasonal", "")
	petz.settings[petz_type.."_follow"] = user:get(petz_type.."_follow", "") or settings:get(petz_type.."_follow", "")
	petz.settings[petz_type.."_breed"]  = user:get(petz_type.."_breed", "") or settings:get(petz_type.."_breed", "")
	petz.settings[petz_type.."_predators"]  = user:get(petz_type.."_predators", "") or settings:get(petz_type.."_predators", "")
	petz.settings[petz_type.."_preys"] = user:get(petz_type.."_preys", "") or settings:get(petz_type.."_preys", "")
	petz.settings[petz_type.."_colorized"] = user:get_bool(petz_type.."_colorized", false) or settings:get_bool(petz_type.."_colorized", false)
	petz.settings[petz_type.."_copulation_distance"] = tonumber(user:get(petz_type.."_copulation_distance") or settings:get(petz_type.."_copulation_distance")) or 0.0
	petz.settings[petz_type.."_convert"] = user:get(petz_type.."_convert", nil) or settings:get(petz_type.."_convert", nil)
	petz.settings[petz_type.."_convert_to"] = user:get(petz_type.."_convert_to", nil) or settings:get(petz_type.."_convert_to", nil)
	petz.settings[petz_type.."_convert_count"] = tonumber(user:get(petz_type.."_convert_count") or settings:get(petz_type.."_convert_count")) or nil
	petz.settings[petz_type.."_lifetime"] = tonumber(user:get(petz_type.."_lifetime") or settings:get(petz_type.."_lifetime")) or nil
	if petz_type == "beaver" then
		petz.settings[petz_type.."_create_dam"] = user:get_bool(petz_type.."_create_dam", false) or settings:get_bool(petz_type.."_create_dam", false)
	elseif petz_type == "silkworm" then
		petz.settings[petz_type.."_lay_egg_on_node"] = user:get(petz_type.."_lay_egg_on_node", "") or settings:get(petz_type.."_lay_egg_on_node", "")
	end
end

petz.settings.visual = "mesh"
petz.settings.visual_size = {x=10, y=10}
petz.settings.rotate = 0

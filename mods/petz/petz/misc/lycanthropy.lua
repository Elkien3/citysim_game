local modpath, S = ...

local lycanthropy = {}
lycanthropy.werewolf = {}
lycanthropy.werewolf.model = "petz_werewolf.b3d"
lycanthropy.werewolf.model_3d = "3d_armor_werewolf.b3d"
lycanthropy.werewolf.textures = {"petz_werewolf_dark_gray.png", "petz_werewolf_gray.png", "petz_werewolf_brown.png", "petz_werewolf_black.png"}
lycanthropy.werewolf.collisionbox = {-0.3, 0.0, -0.3, 0.3, 1.7, 0.3}
lycanthropy.werewolf.animation_speed = 30
lycanthropy.werewolf.animations = {
	stand = {x = 0,   y = 79},
	lay = {x = 162, y = 166},
	walk = {x = 168, y = 187},
	mine = {x = 189, y = 198},
	walk_mine = {x = 200, y = 219},
	sit = {x = 81,  y = 160},
}
lycanthropy.werewolf.override_table = {
	speed = 1.5,
	jump = 1.5,
	gravity = 0.95,
    sneak = true,
	sneak_glitch = false,
	new_move = true,
}
lycanthropy.clans = {
	{
		name = S("The Savage Stalkers"),
		texture = lycanthropy.werewolf.textures[1],
	},
	{
		name = S("The Bravehide Pride"),
		texture = lycanthropy.werewolf.textures[2]
	},
	{
		name = S("The Hidden Tails"),
		texture = lycanthropy.werewolf.textures[3],
	},
	{
		name = S("The Fierce Manes"),
		texture = lycanthropy.werewolf.textures[4],
	},
}

player_api.register_model(lycanthropy.werewolf.model, {
	textures = lycanthropy.werewolf.textures,
	animation_speed = lycanthropy.werewolf.animation_speed,
	animations = lycanthropy.werewolf.animations,
	collisionbox = lycanthropy.werewolf.collisionbox ,
	stepheight = 0.6,
	eye_height = 1.47,
})

---
--- Helper Functions
---

function petz.is_werewolf(player)
	local meta = player:get_meta()
	if meta:get_int("petz:werewolf") == 1 then
		return true
	else
		return false
	end
end

function petz.has_lycanthropy(player)
	local meta = player:get_meta()
	if meta:get_int("petz:lycanthropy") == 1 then
		return true
	else
		return false
	end
end

function petz.set_old_override_table(player)
	local meta = player:get_meta()
	local override_table = meta:get_string("petz:old_override_table")
	if override_table then
		player:set_physics_override(minetest.deserialize(override_table))
	end
end

function petz.show_werewolf_vignette(player)
	local hud_id = player:hud_add({
		hud_elem_type = "image",
		text = "petz_werewolf_vignette.png",
		position = {x=0, y=0},
		scale = {x=-100, y=-100},
		alignment = {x=1, y=1},
		offset = {x=0, y=0}
	})
	local meta = player:get_meta()
	meta:set_int("petz:werewolf_vignette_id", hud_id)
end

function petz.remove_werewolf_vignette(player)
	local meta = player:get_meta()
	local hud_id = meta:get_int("petz:werewolf_vignette_id")
	if hud_id then
		player:hud_remove(hud_id)
	end
end

---
--- Set, Unset & Reset Functions
---

petz.set_lycanthropy = function(player)
	local meta = player:get_meta()
	local player_name = player:get_player_name()
	local model
	if minetest.get_modpath("3d_armor") ~= nil then
		model = lycanthropy.werewolf.model_3d
	else
		model = lycanthropy.werewolf.model
	end
	player_api.set_model(player, model)
	player:set_local_animation(
		{x = 0,   y = 79},
		{x = 168, y = 187},
		{x = 189, y = 198},
		{x = 200, y = 219},
		30
	)
	local werewolf_texture
	if not(petz.has_lycanthropy(player)) then
		meta:set_int("petz:lycanthropy", 1)
		local clan_index = math.random(1, #lycanthropy.clans)
		meta:set_int("petz:werewolf_clan_idx", clan_index)
		werewolf_texture = lycanthropy.werewolf.textures[clan_index]
		minetest.chat_send_player(player_name, S("You've fallen ill with Lycanthropy!"))
		local override_table = player:get_physics_override()
		if override_table then
			meta:set_string("petz:old_override_table", minetest.serialize(override_table))
		end
	else
		werewolf_texture = lycanthropy.werewolf.textures[meta:get_int("petz:werewolf_clan_idx")]
	end
	player:set_physics_override(lycanthropy.werewolf.override_table)
	petz.show_werewolf_vignette(player)
	meta:set_int("petz:werewolf", 1)
	if minetest.get_modpath("3d_armor") ~= nil then
		petz.set_3d_armor_lycanthropy(player)
	else
		player_api.set_textures(player, {werewolf_texture})
	end
	--petz.set_properties(player, {textures = {werewolf_texture}})
	--player:set_properties({textures = {werewolf_texture}})
end

petz.unset_lycanthropy = function(player)
	local meta = player:get_meta()
	if minetest.get_modpath("3d_armor") ~= nil then
		player_api.set_model(player, "3d_armor_character.b3d")
	else
		player_api.set_model(player, "character.b3d")
	end
	petz.set_old_override_table(player)
	petz.remove_werewolf_vignette(player)
	meta:set_int("petz:werewolf", 0)
	if minetest.get_modpath("3d_armor") ~= nil then
		petz.unset_3d_armor_lycanthropy(player)
	else
		player_api.set_textures(player, {"character.png"})
	end
end

petz.reset_lycanthropy = function(player)
	local player_name = player:get_player_name()
	local meta = player:get_meta()
	if petz.is_werewolf(player) then
		petz.unset_lycanthropy(player)
	else
		petz.remove_werewolf_vignette(player)
		petz.set_old_override_table(player)
	end
	meta:set_int("petz:lycanthropy", 0)
	minetest.chat_send_player(player_name, S("You've cured of Lycanthropy"))
end

---
--- Register Functions
---

---
--- On_punch: Infection Engine here.
---

minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
	if hitter:is_player() or petz.is_werewolf(player) then -- a hitter-player cannot infect and the player should not be a werewolf yet
		return
	end
	local hitter_ent = hitter:get_luaentity() --the hitter is an entity, not a player
	if not(hitter_ent.type == "wolf") and not(hitter_ent.type == "werewolf") then --thse can infect
		return
	end
	if (hitter_ent.type == "wolf" and hitter_ent.texture_no == (#hitter_ent.skin_colors-hitter_ent.mutation+1))
		or (hitter_ent.type == "wolf" and (math.random(1, petz.settings.lycanthropy_infection_chance_by_wolf) == 1))
			or (hitter_ent.type == "werewolf" and (math.random(1, petz.settings.lycanthropy_infection_chance_by_werewolf) == 1)) then
				--Conditions to infect: black wolf or get the chance of another wolf or werewolf
				petz.set_lycanthropy(player)
	end
end)

---
--- On_punch: Less damage if you were a werewolf
---

minetest.register_on_punchplayer(
	function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
		if not(petz.is_werewolf(player)) or not(hitter) then
			return
		end
		local hp = player:get_hp()
		if hp - damage > 0 or hp <= 0 then
			return
		end
		local werewolf_damage_reduction = 0.5
		local overrided_damage = (tool_capabilities.damage_groups.fleshy or 1) * werewolf_damage_reduction
		hp = hp - overrided_damage
		--minetest.chat_send_player(hitter:get_player_name(), tostring(overrided_damage))
		player:set_hp(hp)
		return true
	end
)

---
--- Cycle day/night to change
---

local timer = 0
local last_period_of_day

minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	if timer >= 5 then --only check each 30 seconds
		timer = 0
		local current_period_of_day = petz.is_night()
		--minetest.chat_send_player("singleplayer", "current="..tostring(current_period_of_day))
		--minetest.chat_send_player("singleplayer", "last="..tostring(last_period_of_day))
		if (current_period_of_day ~= last_period_of_day) then --only continue if there is a change day-night or night-day
			last_period_of_day = current_period_of_day
			for _, player in pairs(minetest.get_connected_players()) do
				local player_name = player:get_player_name()
				local msg = ""
				if petz.has_lycanthropy(player) then
					if petz.is_night() == true then
						if not(petz.is_werewolf(player)) then
							petz.set_lycanthropy(player)
							msg = S("You are now a werewolf")
						end
					else
						if petz.is_werewolf(player) then
							petz.unset_lycanthropy(player)
							msg = S("You are now a human")
						end
					end
				end
				minetest.chat_send_player(player_name, msg)
			end
		end
	end
end)

--
-- On_JoinPlayer: Check if werewolf and act in consequence
--

minetest.register_on_joinplayer(
	function(player)
		if petz.has_lycanthropy(player) then
			if petz.is_night() and not(petz.is_werewolf(player)) then
				petz.set_lycanthropy(player)
			elseif not(petz.is_night()) and petz.is_werewolf(player) then
				petz.unset_lycanthropy(player)
			end
		end
	end
)

--
-- A werewolf only can eat raw meat
--

if minetest.get_modpath("hbhunger") == nil then
	minetest.register_on_item_eat(
		function(hp_change, replace_with_item, itemstack, user, pointed_thing)
			if petz.is_werewolf(user) and (minetest.get_item_group(itemstack:get_name(), "food_meat_raw") == 0) then
				local user_name = user:get_player_name()
				--minetest.chat_send_player(user_name, itemstack:get_name())
				minetest.chat_send_player(user_name, S("Werewolves only can eat raw meat!"))
				return itemstack
			end
    end
	)
end

---
--- Set & Unset for 3D Armor
---

petz.set_3d_armor_lycanthropy = function(player)
	local player_name = player:get_player_name()
	local meta = player:get_meta()
	default.player_set_textures(player, {
		lycanthropy.werewolf.textures[meta:get_int("petz:werewolf_clan_idx")],
		armor.textures[player_name].armor,
		armor.textures[player_name].wielditem,
	})
end

petz.unset_3d_armor_lycanthropy = function(player)
	local player_name = player:get_player_name()
	default.player_set_textures(player, {
		armor.textures[player_name].skin,
		armor.textures[player_name].armor,
		armor.textures[player_name].wielditem,
	})
end

if minetest.get_modpath("3d_armor") ~= nil then --Armors (optional)
	armor:register_on_update(function(player)
		if petz.is_werewolf(player) then
			petz.set_3d_armor_lycanthropy(player)
		end
	end)

	default.player_register_model(lycanthropy.werewolf.model_3d, {
	animation_speed = 30,
	textures = {
		lycanthropy.werewolf.textures[1],
		"3d_armor_trans.png",
		"3d_armor_trans.png",
	},
	animations = {
		stand = {x=0, y=79},
		lay = {x=162, y=166},
		walk = {x=168, y=187},
		mine = {x=189, y=198},
		walk_mine = {x=200, y=219},
		sit = {x=81, y=160},
	},
})
end

--
--CHAT COMMANDS
--

minetest.register_chatcommand("werewolf", {
	description = "Convert a player into a werewolf",
	privs = {
        server = true,
    },
    func = function(name, param)
		local subcommand, player_name = string.match(param, "([%a%d_-]+) ([%a%d_-]+)")
		if not(subcommand == "set") and not(subcommand == "unset") and not(subcommand == "reset") and not(subcommand == "clan") then
			return true, "Error: The subcomands for the werewolf command are 'set' / 'unset' / 'reset' / 'clan'"
		end
		if player_name then
			local player = minetest.get_player_by_name(player_name)
			if player then
				if subcommand == "set" then
					petz.set_lycanthropy(player)
					return true, player_name .." ".."set to werewolf!"
				elseif subcommand == "unset" then
					petz.unset_lycanthropy(player)
					return true, "The werewolf".." "..player_name .." ".."set to human!"
				elseif subcommand == "reset" then
					petz.reset_lycanthropy(player)
					return true, "The lycanthropy of".." "..player_name .." ".."was cured!"
				elseif subcommand == "clan" then
					local meta = player:get_meta()
					local clan_name = lycanthropy.clans[meta:get_int("petz:werewolf_clan_idx")].name
					return true, "The clan of".." "..player_name .." ".."is".." '"..clan_name.."'"
				end
			else
				return false, player_name .." ".."not online!"
			end
		else
			return true, "Not a player name in command"
		end
    end,
})

minetest.register_chatcommand("howl", {
	description = "Do a howl sound",
    func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if player then
			if petz.is_werewolf(player) then
				local pos = player:get_pos()
				mokapi.make_sound("pos", pos, "petz_werewolf_howl", petz.settings.max_hear_distance)
			else
				return false, "Error: You are not a werewolf."
			end
		else
			return false, name .." ".."not online!"
		end
    end,
})

--
-- Lycanthropy Items
--

minetest.register_craftitem("petz:lycanthropy_remedy", {
    description = S("Lycanthropy Remedy"),
    inventory_image = "petz_lycanthropy_remedy.png",
    wield_image = "petz_lycanthropy_remedy.png",
    on_use = function (itemstack, user, pointed_thing)
		if petz.has_lycanthropy(user) then
			petz.reset_lycanthropy(user)
		end
        return minetest.do_item_eat(0, "vessels:glass_bottle", itemstack, user, pointed_thing)
    end,
})

minetest.register_craft({
    type = "shaped",
    output = "petz:lycanthropy_remedy",
    recipe = {
        {"", "petz:wolf_jaw", ""},
        {"dye:white", "petz:wolf_fur", "dye:violet"},
        {"", "petz:beaver_oil", ""},
    }
})

--
-- WEREWOLF MONSTER
--

local pet_name = "werewolf"
local scale_model = 1.0
local mesh = lycanthropy.werewolf.model
local textures = lycanthropy.werewolf.textures
local collisionbox = lycanthropy.werewolf.collisionbox

minetest.register_entity("petz:"..pet_name,{
	--Petz specifics
	type = "werewolf",
	init_tamagochi_timer = false,
	is_pet = false,
	is_monster = true,
	is_boss = true,
	has_affinity = false,
	is_wild = true,
	attack_player = true,
	give_orders = false,
	can_be_brushed = false,
	capture_item = nil,
	follow = petz.settings.werewolf_follow,
	drops = {
		{name = "petz:wolf_fur", chance = 5, min = 1, max = 1,},
		{name = "petz:wolf_jaw", chance = 5, min = 1, max = 1,},
	},
	rotate = petz.settings.rotate,
	physical = true,
	stepheight = 0.1,	--EVIL!
	collide_with_objects = true,
	collisionbox = collisionbox,
	visual = petz.settings.visual,
	mesh = mesh,
	textures = textures,
	visual_size = {x=1.0*scale_model, y=1.0*scale_model},
	static_save = true,
	get_staticdata = mobkit.statfunc,
	-- api props
	springiness= 0,
	buoyancy = 0.5, -- portion of hitbox submerged
	max_speed = 1.5,
	jump_height = 1.5,
	view_range = 20,
	lung_capacity = 10, -- seconds
	max_hp = 50,

	attack={range=0.5, damage_groups={fleshy=9}},
	animation = {
		walk={range={x=168, y=187}, speed=30, loop=true},
		run={range={x=168, y=187}, speed=30, loop=true},
		stand={range={x=0, y=79}, speed=30, loop=true},
	},
	sounds = {
		misc = "petz_werewolf_howl",
		attack = "petz_monster_roar",
		die = "petz_monster_die",
	},

	logic = petz.monster_brain,

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

petz:register_egg("petz:werewolf", S("Werewolf"), "petz_spawnegg_werewolf.png", false)

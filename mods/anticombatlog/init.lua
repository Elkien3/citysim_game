-- How long in seconds until a battle ends (times since last hit)
local battletimeout = 15
local armor_installed = minetest.get_modpath("3d_armor")
-- Fight start message
local FightMessage = "You entered a Fight!"

-- Fight end message
local EndFightMessage = "The Fight is Over!"

local playerinpvp = {}

minetest.register_privilege("combatlog", {
	description = "Used to kill a combat logger when he joins.",
	give_to_singleplayer= false,
})

local incombat_hud = {}

local function setplayerpvp(playername)
	if not playerinpvp[playername] then
		playerinpvp[playername] = 0
		local player = minetest.get_player_by_name(playername)
		incombat_hud[playername] = player:hud_add({
			hud_elem_type = "image",
			position  = {x = 1, y = .75},
			offset    = {x = -220, y = 0},
			text      = "incombat.png",
			scale     = { x = 10, y = 10},
			alignment = { x = 1, y = 0 },
		})
		--minetest.chat_send_player(playername, FightMessage)
	end
end

local function resettime(playername)
	if playerinpvp[playername] ~= nil then
		playerinpvp[playername] = 0
	end
end

local function endtimer(playername)
	if playerinpvp[playername] ~= nil then
		local player = minetest.get_player_by_name(playername)
		if player then
			player:hud_remove(incombat_hud[playername])
		end
		--minetest.chat_send_player(playername, EndFightMessage)
		playerinpvp[playername] = nil
	end
end
local drop = function(pos, itemstack)
	local obj = minetest.add_item(pos, itemstack:take_item(itemstack:get_count()))
	if obj then
		obj:setvelocity({
			x = math.random(-10, 10) / 9,
			y = 5,
			z = math.random(-10, 10) / 9,
		})
	end
end
local function dropinventory(invref, pos)
	for i = 1, invref:get_size("main") do
		drop(pos, invref:get_stack("main", i))
	end
end

local function killcombatlogger(player)
	local player_inv = player:get_inventory()
	local armor_inv = minetest.get_inventory({type="detached", name=player:get_player_name().."_armor"})
	player_inv:set_list("main", {})
	player_inv:set_list("craft", {})
	if armor_installed then
		player_inv:set_list("armor", {})
		armor_inv:set_list("armor", {})
		armor:save_armor_inventory(player)
	end
	player:set_hp(0)
	local privs = minetest.get_player_privs(player:get_player_name())
	privs.combatlog = nil
	privs.interact = true
	minetest.set_player_privs(player:get_player_name(), privs)
	minetest.chat_send_player(player:get_player_name(), "You died after combat logging.")
	
end
local ghost_player = {}
local function on_combatlog(player, playername)
	--minetest.chat_send_all("*** "..tostring(playername).." Combat Logged!")
	local skin = "character.png"
	local armortex = ""
	if armor_installed then
		skin = armor.textures[playername].skin or "character.png"
		armortex = armor.textures[playername].armor
	end
	local pos = player:getpos()
	pos.y = pos.y + 1
	local obj = minetest.add_entity(pos, "anticombatlog:ghost")
	ghost_player[playername] = obj
	if obj then
		obj:set_armor_groups(player:get_armor_groups())
		obj:set_properties({nametag = playername})
		obj:set_hp(player:get_hp())
		obj:set_wielded_item(player:get_wielded_item())
		obj:setyaw(player:get_look_horizontal())
		if armor_installed then
			obj:set_properties({textures = {skin.."^"..armortex}})
		else
			obj:set_properties({textures = {skin}})
		end
	end
	local ghost_inv = minetest.create_detached_inventory(playername.."_ghost", {})
	local player_inv = player:get_inventory()
	local armor_inv = minetest.get_inventory({type="detached", name=playername.."_armor"})
	for i = 1, player_inv:get_size("main") do
		ghost_inv:set_size("main", (ghost_inv:get_size("main")+1))
		ghost_inv:add_item("main", player_inv:get_stack("main", i))
	end
	for i = 1, player_inv:get_size("craft") do
		ghost_inv:set_size("main", (ghost_inv:get_size("main")+1))
		ghost_inv:add_item("main", player_inv:get_stack("craft", i))
	end
	if armor_installed and armor_inv then
		for i = 1, armor_inv:get_size("armor") do
			ghost_inv:set_size("main", (ghost_inv:get_size("main")+1))
			ghost_inv:add_item("main", armor_inv:get_stack("armor", i))
		end
	end
	minetest.after((battletimeout - playerinpvp[playername]) or battletimeout, function(obj) 
    obj:remove()
	end, obj)

end

minetest.register_on_punchplayer(function(player, hitter)
	if not (player:is_player() and hitter:is_player() ) then
		return
	end
	
	local hittername = hitter:get_player_name()
	local victimname = player:get_player_name()

	setplayerpvp(hittername)
	setplayerpvp(victimname) -- moved OPCE check

	resettime(hittername)
	resettime(victimname) -- won't affect non-registered victims
end)

minetest.register_globalstep(function(dtime)
	for fighter,oldtime in pairs(playerinpvp) do
		if playerinpvp[fighter] then
			local newtime = oldtime + dtime
			playerinpvp[fighter] = newtime
			if newtime >= battletimeout then
				endtimer(fighter)
			end
		end
	end
end)
minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	if playerinpvp[name] and playerinpvp[name] > 0 then
		on_combatlog(player, name)
		--endtimer(name)
	end
end)
minetest.register_on_dieplayer(function(player)
	local name = player:get_player_name()
	endtimer(name)
end)
minetest.register_on_joinplayer(function(player)
	local playername = player:get_player_name()
	if ghost_player[playername] and ghost_player[playername]:get_luaentity() then
		player:set_hp(ghost_player[playername]:get_hp())
		ghost_player[playername]:remove()
		incombat_hud[playername] = player:hud_add({
			hud_elem_type = "image",
			position  = {x = 1, y = .75},
			offset    = {x = -220, y = 0},
			text      = "incombat.png",
			scale     = { x = 10, y = 10},
			alignment = { x = 1, y = 0 },
		})
	end
	local privs = minetest.get_player_privs(playername)
	if privs.combatlog and not privs.ban then
		minetest.after(.1, killcombatlogger, player)
	end
end)

minetest.register_entity("anticombatlog:ghost",
{
    hp_max = 20,
    physical = false,
    collisionbox = {-0.35,-1.0,-0.35, 0.35,0.8,0.35},
    visual = "mesh",
    visual_size = {x=1, y=1},
    mesh = "character.b3d",
    textures = {"character.png"}, -- number of required textures depends on visual
    is_visible = true,
	on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		if tool_capabilities then
			-- Get tool-based damage
			local current_damage = tool_capabilities.damage_groups.fleshy
			-- Check if player is punching before full punch interval
			if time_from_last_punch < tool_capabilities.full_punch_interval then
				-- Calculate damage for current tool based on the time from last punch
				current_damage = 
					math.floor( 
						(time_from_last_punch / tool_capabilities.full_punch_interval) * current_damage 
					)
			end
			-- Remove guard if killed
			if self.object:get_hp() - current_damage <= 0 then
				local playername = self.object:get_properties().nametag
				local invref = minetest.get_inventory({type="detached", name=playername.."_ghost"})
				local pos = self.object:get_pos()
				dropinventory(invref, pos)
				local privs = minetest.get_player_privs(playername)
				privs.combatlog = true
				privs.interact = nil
				minetest.set_player_privs(playername, privs)
				self.object:remove()
			end
		end
	end,
	on_activate = function(self, staticdata, dtime_s)
		if staticdata == "expired" then
			self.object:remove()
		end
	end,
	get_staticdata = function(self)
		return "expired"
	end,
})
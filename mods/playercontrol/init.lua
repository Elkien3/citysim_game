local storage = minetest.get_mod_storage()

local postable = {}
local timertable = {}
local timerfunctions = {}
playercontrol = {}

local function update()
	for i, player in pairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		if timertable[name] then
			local pos = player:get_pos()
			if vector.distance(pos, postable[name]) > .1 then
				postable[name] = pos
				for id, timer in pairs(timertable[name]) do
					if id == "playtime" then
						timertable[name][id] = timer + 1
					else
						timer = timer - 1
						if timer <= 0 then
							timertable[name][id] = nil
							if timerfunctions[id] then
								timerfunctions[id](name)
							end
						else
							timertable[name][id] = timer
						end
					end
				end
			end
			storage:set_string(name, minetest.serialize(timertable[name]))
		end
	end
	minetest.after(60, update)
end
update()

function get_player_playtime(name)
	if not minetest.player_exists(name) then return 0 end
	if not timertable[name] or not timertable[name]["playtime"] then return 0 end
	return timertable[name]["playtime"]/60
end

local function set_timer(name, id, val)
	local tbl = timertable[name] or minetest.deserialize(storage:get_string(name)) or {}
	tbl[id] = val
	storage:set_string(name, minetest.serialize(tbl))
	if timertable[name] then
		timertable[name][id] = val
	end
end

playercontrol_set_timer = set_timer

minetest.register_on_joinplayer(function(player, last_login)
	local name = player:get_player_name()
	timertable[name] = minetest.deserialize(storage:get_string(name))
	if timertable[name] then
		postable[name] = player:get_pos()
	end
end)

minetest.register_on_leaveplayer(function(player, timed_out)
	local name = player:get_player_name()
	timertable[name] = nil
	postable[name] = nil
end)

minetest.register_privilege("pvp", {
    description = "Can do full pvp damage",
    give_to_singleplayer = false
})

minetest.register_on_newplayer(function(player)
	local name = player:get_player_name()
	set_timer(name, "playtime", 0)
	set_timer(name, "pvp", 2*60)
	set_timer(name, "lockpick", 2*60)
	set_timer(name, "griefing", 2*60)
	set_timer(name, "voting", 2*60)
end)

minetest.register_chatcommand("set_playercontrol_timer", {
    privs = {
        ban = true,
    },
    func = function(name, param)
        if not param or param == "" then return false, "No param specified" end
		params = {}
		for word in param:gmatch("%w+") do table.insert(params, word) end
		if #params ~= 3 then return false, "Invalid syntax. must be /set_playercontrol_timer <name> <id> <time>" end
		set_timer(params[1], params[2], params[3])
		return true, "Timer set."
    end,
})

minetest.register_chatcommand("get_playercontrol_timer", {
    func = function(name, param)
		if not param or param == "" then param = name end
		if not timertable[param] then return false, "No timers found for '"..param.."'" end
		local str = "Timers for '"..param.."': "
		for id, timer in pairs(timertable[name]) do
			str = str.."["..id.."] = "..timer.." minutes "
		end
		return true, str
    end,
})

minetest.register_chatcommand("get_playtime", {
    func = function(name, param)
        if not param or param == "" then param = name end
		if not timertable[param] or not timertable[param]["playtime"] then return false, "No playtime found for '"..param.."'" end
		local playtime = timertable[param]["playtime"]/60
		playtime = math.floor(playtime*100)/100
		return true, "'"..param.."' has "..tostring(playtime).." hours of playtime"
    end,
})

timerfunctions["pvp"] = function(name)
	if not minetest.registered_privileges["pvp"] then return end
	local privs = minetest.get_player_privs(name)
	if privs.pvp then return end
	privs.pvp = true
	minetest.set_player_privs(name, privs)
	minetest.chat_send_player(name, "[playercontrol] You have been granted the 'pvp' privilege.")
end
timerfunctions["lockpick"] = function(name)
	if not minetest.registered_privileges["lockpick"] then return end
	local privs = minetest.get_player_privs(name)
	if privs.lockpick then return end
	privs.lockpick = true
	minetest.set_player_privs(name, privs)
	minetest.chat_send_player(name, "[playercontrol] You have been granted the 'lockpick' privilege.")
end
timerfunctions["griefing"] = function(name)
	if not minetest.registered_privileges["griefing"] then return end
	local privs = minetest.get_player_privs(name)
	if privs.griefing then return end
	privs.griefing = true
	minetest.set_player_privs(name, privs)
	minetest.chat_send_player(name, "[playercontrol] You have been granted the 'griefing' privilege.")
end
timerfunctions["voting"] = function(name)
	if not minetest.registered_privileges["vote"] then return end
	local privs = minetest.get_player_privs(name)
	if privs.vote then return end
	privs.vote = true
	minetest.set_player_privs(name, privs)
	minetest.chat_send_player(name, "[playercontrol] You have been granted the 'vote' privilege.")
end
--if you havent logged in a month no voting for 2 hours of playtime to prevent dormant voting alts
minetest.register_on_joinplayer(function(player, last_login)
	if not minetest.registered_privileges["vote"] then return end
	local name = player:get_player_name()
	local privs = minetest.get_player_privs(name)
	if (privs.vote or (timertable[name] and timertable[name]["voting"])) and os.time()-last_login > 30*60*60*24 then
		set_timer(name, "voting", 2*60)
		privs.vote = nil
		minetest.set_player_privs(name, privs)
	end
end)

local waspunched = {}
minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
	local name = hitter:get_player_name()
	local plName = player:get_player_name()
	if not name or not plName then return end
	if not minetest.check_player_privs(name, {pvp=true}) and not waspunched[name] then
		damage = damage/3
		player:set_hp(player:get_hp()-damage, "punch")
		return true
	elseif not minetest.check_player_privs(plName, {pvp=true}) then
		waspunched[plName] = (waspunched[plName] or 0) + 1
		minetest.after(60, function()
			if waspunched[plName] then
				waspunched[plName] = waspunched[plName] - 1
				if waspunched[plName] <= 0 then
					waspunched[plName] = nil
				end
			end
		end)
	end
end)

player_effects = {}
playercontrol.set_effect = function(name, effect, value, modname, apply)
	local player = minetest.get_player_by_name(name)
	if not player then player_effects[name] = nil return end
	if not player_effects[name] then player_effects[name] = {} end
	local effects = player_effects[name]
	if not effects[effect] then
		effects[effect] = {}
	end
	effects[effect][modname] = value
	if effect == "speed" then
			finalval = 1
			for i, val in pairs(effects[effect]) do
				finalval = finalval*val
			end
			if apply then
				player:set_physics_override({speed = finalval})
			end
			return finalval
	elseif effect == "jump" then
		finalval = 1
		for i, val in pairs(effects[effect]) do
			finalval = finalval*val
		end
		if apply then
			player:set_physics_override({jump = finalval})
		end
		return finalval
	elseif effect == "fov" then
		finalval = 72--assuming client's default fov is 72, meh.
		for i, val in pairs(effects[effect]) do
			finalval = finalval*(val/72)
		end
		if finalval == 72 then finalval = 0 end
		if apply then
			player:set_fov(finalval, false, .5)
		end
		return finalval
	elseif effect == "gunwag" then
		finalval = 1
		for i, val in pairs(effects[effect]) do
			finalval = finalval*(val/1)
		end
		if finalval == 1 then finalval = nil end
		if apply then
			spriteguns.set_wag(name, finalval)
		end
		return finalval
	end
end
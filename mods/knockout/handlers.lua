-- Create formspec structure
local function getFs(name)
	return "size[5,3]label[1.4,1;You are unconscious!]label[0.8,2;Time remaining: " .. tostring(knockout.knocked_out[name]) .. " seconds]"
end

-- Globalstep to revive players
local gs_time = 0
minetest.register_globalstep(function(dtime)
	-- Decrease knockout time
	gs_time = gs_time + dtime
	if gs_time >= 1 then
		gs_time = 0
		for name, _ in pairs(knockout.knocked_out) do
			local p = minetest.get_player_by_name(name)
			if p ~= nil then
				if p:get_hp() > 0 then
					knockout.decrease_knockout_time(name, 1)
					minetest.show_formspec(name, "knockout:fs", getFs(name))
				end
			end
		end
		knockout.save()
	end
	for name, carried in pairs(knockout.carrying) do
		-- Check for player drop
		local p = minetest.get_player_by_name(name)
		if p:get_player_control().jump then
			knockout.carrier_drop(name)
		end
		-- Set the look direction to make it more realistic
		local c = minetest.get_player_by_name(carried)
		c:set_look_horizontal(p:get_look_horizontal())
	end
end)

-- Oh no you don't. I like that formspec open
minetest.register_on_player_receive_fields(function(player, fName, _)
	if player:get_hp() <= 0 then return false end
	if fName == "knockout:fs" then
		local name = player:get_player_name()
		minetest.show_formspec(name, fName, getFs(name))
		return true
	end
end)

-- If the player is killed, they "wake up"
minetest.register_on_dieplayer(function(p)
	local pName = p:get_player_name()
	knockout.wake_up(pName)
	-- If the player is carrying another player, drop them
	knockout.carrier_drop(pName)
end)

-- If the player was carrying another player, drop them
minetest.register_on_leaveplayer(function(p, _)
	knockout.carrier_drop(p:get_player_name())
end)

-- Catch those pesky players that try to leave/join to get un-knocked out
minetest.register_on_joinplayer(function(p)
	local koed = false
	local name = p:get_player_name()
	if knockout.knocked_out[name] ~= nil then
		minetest.after(1, knockout.knockout, name)
	end
end)

-- Catch whacks with various tools and calculate if the victim should be knocked out
minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
	local victim = player:get_player_name()
	local currHp = player:get_hp()
	if knockout.knocked_out[victim] ~= nil then return end
	if currHp <= 0 then return end
	local tool = hitter:get_wielded_item():get_name() -- Get tool used
	local def = knockout.tools[tool]
	if def == nil then return end
	-- Calculate
	if currHp <= def.max_health then
		local chanceMult = time_from_last_punch / tool_capabilities.full_punch_interval -- You can't knock people out with lots of love taps
		if chanceMult > 1 then chanceMult = 1 end
		if math.random() < def.chance * chanceMult then
			-- Knocked out
			local koTime = math.floor(def.max_time * (1 - currHp / (def.max_health * 2)))
			knockout.knockout(victim, koTime)
		end
	end
end)

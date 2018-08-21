--[[ privileges ]]
minetest.register_privilege("heal",{description = "Allows player to set own health with /sethp and /sethealth.", give_to_singleplayer = false})
minetest.register_privilege("physics",{description = "Allows player to set own gravity, jump height and movement speed with /setgravity, /setjump and /setspeed, respectively.", give_to_singleplayer = false})
minetest.register_privilege("hotbar",{description = "Allows player to set the number of slots of the hotbar with /sethotbarsize.", give_to_singleplayer = false})

--[[ informational commands ]]
minetest.register_chatcommand("whoami", {
	params = "",
	description = "Shows your name.",
	privs = {},
	func = function(name)
		minetest.chat_send_player(name, "Your name is \""..name.."\".")
	end,
})

minetest.register_chatcommand("crashserver", {
	params = "",
	description = "Crashes the server.",
	privs = {server=true},
	func = function(name)
		minetest.log(name .. " is crashing the server.")
		crash_server_now.boi = name
	end,
})

minetest.register_chatcommand("ip", {
	params = "",
	description = "Shows your IP address.",
	privs = {},
	func = function(name)
		minetest.chat_send_player(name, "Your IP address is \""..minetest.get_player_ip(name).."\".")
	end
})

--[[ HUD commands ]]
minetest.register_chatcommand("sethotbarsize", {
	params = "<1...23>",
	description = "Sets the size of your hotbar to the provided number of slots. The number must be between 1 and 23.",
	privs = {hotbar=true},
	func = function(name, slots)
		if slots == "" then
			minetest.chat_send_player(name, "You did not specify the parameter.")
			return
		end
		if type(tonumber(slots)) ~= "number" then
			minetest.chat_send_player(name, "This is not a number.")
			return
		end
		if tonumber(slots) < 1 or tonumber(slots) > 23 then
			minetest.chat_send_player(name, "Number of slots out of bounds. The number of slots must be between 1 and 23.")
			return
		end
		local player = minetest.get_player_by_name(name)
		player:hud_set_hotbar_itemcount(tonumber(slots))
	end,
})

--[[ health commands ]]
minetest.register_chatcommand("sethp", {
	params = "<hp>",
	description = "Sets your health to <hp> HP (=hearts/2).",
	privs = {heal=true},
	func = function(name, hp)
		if(minetest.setting_getbool("enable_damage")==true) then
			local player = minetest.get_player_by_name(name)
			if not player then
				return
			end
			if hp == "" then
				minetest.chat_send_player(name, "You did not specify the parameter.")
				return
			end
			if type(tonumber(hp)) ~= "number" then
				minetest.chat_send_player(name, "This is not a number.")
				return
			end
			hp = math.floor(hp+0.5)	-- round the number
			player:set_hp(tonumber(hp))
		else
			minetest.chat_send_player(name, "Damage is disabled on this server. This command does not work when damage is disabled.")
		end
	end,
})

minetest.register_chatcommand("sethealth", {
	params = "<hearts>",
	description = "Sets your health to <hearts> hearts.",
	privs = {heal=true},
	func = function(name, hearts)
		if(minetest.setting_getbool("enable_damage")==true) then
			local player = minetest.get_player_by_name(name)
			if not player then
				return
			end
			if hearts == "" then
				minetest.chat_send_player(name, "You did not specify the parameter.")
				return
			end
			if type(tonumber(hearts)) ~= "number" then
				minetest.chat_send_player(name, "This is not a number.")
				return
			end
			local hp = tonumber(hearts) * 2
			hp = math.floor(hp+0.5)	-- round the number
			player:set_hp(hp)
		else
			minetest.chat_send_player(name, "Damage is disabled on this server. This command does not work when damage is disabled.")
		end
	end,
})


minetest.register_chatcommand("killme", {
	params = "",
	description = "Kills yourself.",
	func = function(name, param)
		if(minetest.setting_getbool("enable_damage")==true) then
			local player = minetest.get_player_by_name(name)
			if not player then
				return
			end
			player:set_hp(0)
		else
			minetest.chat_send_player(name, "Damage is disabled on this server. This command does not work when damage is disabled.")
		end
	end,
})

--[[ Player physics commands ]]

-- speed
minetest.register_chatcommand("setspeed", {
	params = "[<speed>]",
	description = "Sets your movement speed to <speed> (default: 1).",
	privs={physics=true},
	func = function(name, speed)
		local player = minetest.get_player_by_name(name)
		if not player then
			return
		end
		if speed == "" then
			speed=1
		end
		if type(tonumber(speed)) ~= "number" then
			minetest.chat_send_player(name, "This is not a number.")
			return
		end

		player:set_physics_override(tonumber(speed), nil, nil)
	end,
})

-- gravity
minetest.register_chatcommand("setgravity", {
	params = "[<gravity>]",
	description = "Sets your gravity to [<gravity>] (default: 1).",
	privs={physics=true},
	func = function(name, gravity)
		local player = minetest.get_player_by_name(name)
		if not player then
			return
		end
		if gravity == "" then
			gravity=1
		end
		if type(tonumber(gravity)) ~= "number" then
			minetest.chat_send_player(name, "This is not a number.")
			return
		end
		player:set_physics_override(nil, tonumber(gravity), nil)
	end,
})

-- jump height
minetest.register_chatcommand("setjump", {
	params = "[<jump height>]",
	description = "Sets your jump height to [<jump height>] (default: 1).",
	privs = {physics=true},
	func = function(name, jump_height)
		local player = minetest.get_player_by_name(name)
		if not player then
			return
		end
		if jump_height == "" then
			jump_height=1
		end
		if type(tonumber(jump_height)) ~= "number" then
			minetest.chat_send_player(name, "This is not a number.")
			return
		end
		player:set_physics_override(nil, nil, jump_height)
	end,
})

minetest.register_chatcommand("pulverizeall", {
	params = "",
	description = "Destroys all items in your player inventory and crafting grid.",
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if not player then
			return
		end
		local inv = player:get_inventory()
		inv:set_list("main", {})
		inv:set_list("craft", {})
	end,
})

minetest.register_chatcommand("grief_check", {
	params = "[<range>] [<hours>] [<limit>]",
	description = "Check who last touched a node or a node near it"
			.. " within the time specified by <hours>. Default: range = 0,"
			.. " hours = 24 = 1d, limit = 5",
	privs = {interact=true},
	func = function(name, param)
		if not minetest.setting_getbool("enable_rollback_recording") then
			return false, "Rollback functions are disabled."
		end
		local range, hours, limit =
			param:match("(%d+) *(%d*) *(%d*)")
		range = tonumber(range) or 0
		hours = tonumber(hours) or 24
		limit = tonumber(limit) or 5
		if range > 10 then
			return false, "That range is too high! (max 10)"
		end
		if hours > 168 then
			return false, "That time limit is too high! (max 168: 7 days)"
		end
		if limit > 100 then
			return false, "That limit is too high! (max 100)"
		end
		local seconds = (hours*60)*60
		minetest.rollback_punch_callbacks[name] = function(pos, node, puncher)
			local name = puncher:get_player_name()
			minetest.chat_send_player(name, "Checking " .. minetest.pos_to_string(pos) .. "...")
			local actions = minetest.rollback_get_node_actions(pos, range, seconds, limit)			
			if not actions then
				minetest.chat_send_player(name, "Rollback functions are disabled")
				return
			end
			local num_actions = #actions
			if num_actions == 0 then
				minetest.chat_send_player(name, "Nobody has touched"
						.. " the specified location in " .. hours .. " hour(s)")
				return
			end
			local time = os.time()
			for i = num_actions, 1, -1 do
				local action = actions[i]
				minetest.chat_send_player(name,
					("%s %s %s -> %s %d seconds ago.")
						:format(
							minetest.pos_to_string(action.pos),
							action.actor,
							action.oldnode.name,
							action.newnode.name,
							time - action.time))
			end
		end

		return true, "Punch a node (range=" .. range .. ", hours="
				.. hours .. "s, limit=" .. limit .. ")"
	end,
})
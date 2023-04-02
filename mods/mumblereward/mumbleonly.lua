local function minute_timeofday()
	local date = os.date("*t")
	local minutes = date.min + (date.hour*60)
	return minutes, date.sec
end

local function send_chat_all(message)
	minetest.chat_send_all(message)
	if irc then
		irc.send(message)
	end
end

local function readable_minutes(minutes)
	local hours = 0
	while minutes >= 60 do
		minutes = minutes - 60
		hours = hours + 1
	end
	if hours > 0 then
		return hours.." hours, "..minutes.." minutes"
	else
		return minutes.." minutes"
	end
end

--local mumbleonly_periods = {{14*60, 30}, {2*60, 30}}
local manual_mumbleonly = false

function is_mumbleonly()
	local timetil
	local minutes = minute_timeofday()
	local length
	if mumbleonly_periods then
		for k, period in pairs(mumbleonly_periods) do
			local til = period[1]-minutes
			local sign = 0
			if til ~= 0 then sign = til/math.abs(til) end
			if til == 0 or (sign == -1 and til + period[2] > 0) then -- youre within the period
				return true, -1*(til + period[2]), period[2] -- return time remaining as negative
			end
			if (not timetil or timetil > til) and sign ~= -1 then
				timetil = til
				length = period[2]
			end
		end
		if not timetil then -- none left today, look at earliest one tomorrow
			for k, period in pairs(mumbleonly_periods) do
				local til = period[1]
				if not timetil or timetil > til then
					timetil = til
					length = period[2]
				end
			end
			timetil = timetil + (24*60-minutes)
		end
	end
	if manual_mumbleonly then
		return true
	end
	return false, timetil, length
end

local function kick_nonmumble(length)
	for _, player in pairs (minetest.get_connected_players()) do
		local name = player:get_player_name()
		if not mumblereward_players[name] and not minetest.get_player_privs(name).ban then
			if length then
				minetest.kick_player(name, "Server is in a mumble-only period, set up minetest with mumble PA or come back in ".. length .." minutes.")
			else
				minetest.kick_player(name, "Server is in a mumble-only period, set up minetest with mumble PA or come back later.")
			end
		end
	end
end

local function do_chats()
	local val, timetil, length = is_mumbleonly()
	if not timetil or not length then return end
	local minutes, sec = minute_timeofday()
	if val then --currently in a period
		send_chat_all("*!Mumblerewards!* Mumble only period going on, ending in "..readable_minutes(math.abs(timetil)))
		minetest.after((math.abs(timetil)*60)-sec, function() do_chats() local til, tim = is_mumbleonly() send_chat_all("*!Mumblerewards!* Mumble only period over, next one in "..readable_minutes(tim)) end)
	else
		minetest.after((math.abs(timetil)*60)-sec, function() kick_nonmumble(length) send_chat_all("*!Mumblerewards!* Mumble only period starting, ending in "..readable_minutes(length)) end)
		if timetil >= 10 then
			minetest.after((math.abs(timetil-1)*60)-sec, function() send_chat_all("*!Mumblerewards!* Mumble only period starting in 1 minute.") end)
		end
		if timetil >= 5 then
			minetest.after((math.abs(timetil-5)*60)-sec, function() send_chat_all("*!Mumblerewards!* Mumble only period starting in 5 minute.") end)
		end
		if timetil >= 1 then
			minetest.after((math.abs(timetil-1)*60)-sec, function() send_chat_all("*!Mumblerewards!* Mumble only period starting in 1 minute.") end)
			minetest.after(((math.abs(timetil-1)*60)-sec)+50, function() send_chat_all("*!Mumblerewards!* Mumble only period starting in 10 seconds.") end)
		end
		minetest.after((math.abs(timetil+length)*60)-sec, function() do_chats() local til, tim = is_mumbleonly() send_chat_all("*!Mumblerewards!* Mumble only period over, next one in "..readable_minutes(tim)) end)
	end
end

minetest.after(10, do_chats)

minetest.register_chatcommand("mumbleonly", {func = function(name, param)
	if param ~= "" then
		if not minetest.check_player_privs(name, {server = true}) then
			return false, "You do not have the privs to change the mumbleonly mode."
		end
		if param == "true" then
			manual_mumbleonly = true
			kick_nonmumble()
			send_chat_all("A manual mumbleonly period has been started!")
			return true, "manual mumble only period enabled"
		elseif param == "false" then
			manual_mumbleonly = false
			send_chat_all("A manual mumbleonly period has been ended.")
			return true, "manual mumble only period disabled"
		else
			return false, "must be true of false"
		end
	end
	local val, timetil, length = is_mumbleonly()
	if timetil and length then
		if val then
			return true, "*!Mumblerewards!* Currently in mumble only period, over in "..readable_minutes(-timetil)
		else
			return true, "*!Mumblerewards!* Next mumble only period is in "..readable_minutes(timetil)
		end
	else
		if val then
			return true, "*!Mumblerewards!* Currently in a manual mumble only period"
		else
			return true, "*!Mumblerewards!* No defined mumbleonly periods"
		end
	end
end})
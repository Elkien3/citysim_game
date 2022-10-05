medical.timers = {}

function medical.start_timer(name, length, loop, arg, func, stoparg, stopfunc, cancel_on_release, cancel_owner)
	local index
	if name then
		index = name
	else 
		local i = 0
		while true do
			if not medical.timers[i] then
				index = i
				break			
			end
			i = i + 1
		end
	end
	medical.timers[index] = {}
	medical.timers[index].length = length
	medical.timers[index].timeleft = length
	medical.timers[index].loop = loop
	medical.timers[index].arg = arg
	medical.timers[index].func = func
	medical.timers[index].stoparg = stoparg
	medical.timers[index].stopfunc = stopfunc
	if cancel_owner and cancel_on_release then
		medical.timers[index].cancel_on_release = cancel_on_release
		medical.timers[index].cancel_owner = cancel_owner
		local player = minetest.get_player_by_name(cancel_owner)
		if player and not medical.lookingplayer[cancel_owner] then medical.lookingplayer[cancel_owner] = {dir = player:get_look_dir(), pos = player:get_pos()} end
	end
	return index
end

function medical.stop_timer(name, runonce)
	local timer = medical.timers[name]
	if runonce then
		if type(timer.arg) == "table" then
			timer.func(unpack(timer.arg))
		else
			timer.func(timer.arg)
		end
	end
	if timer.stopfunc then
		if type(timer.stoparg) == "table" then
			timer.stopfunc(unpack(timer.stoparg))
		else
			timer.stopfunc(timer.stoparg)
		end
	end
	medical.timers[name] = nil
end
	
minetest.register_globalstep(function(dtime)
	for index, timer in pairs (medical.timers) do
		timer.timeleft = timer.timeleft - dtime
		if timer.timeleft <= 0 then
			if type(timer.arg) == "table" then
				timer.func(unpack(timer.arg))
			else
				timer.func(timer.arg)
			end
			if timer.loop then
				medical.start_timer(index, timer.length, timer.loop, timer.arg, timer.func, timer.stoparg, timer.stopfunc, timer.cancel_on_release, timer.cancel_owner)
			else
				medical.stop_timer(index)
			end
		end
	end
end)

controls.register_on_release(function(player, key, time)
	local name = player:get_player_name()
	for index, timer in pairs (medical.timers) do
		if name == timer.cancel_owner and timer.cancel_on_release == key then
			medical.stop_timer(index)
		end
	end
end)
medical.register_on_lookaway(function(player, name)
	for index, timer in pairs (medical.timers) do
		if name == timer.cancel_owner and timer.cancel_on_release then
			medical.stop_timer(index)
		end
	end
end)
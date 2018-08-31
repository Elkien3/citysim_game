local deadbanned = {}
local deathlength = 900
local message = "You must wait 15 minutes after dying before joining again."

local world_path = minetest.get_worldpath()
local file = world_path .. "/deadpeople.txt"

local function banondie_read()
	local input = io.open(file, "r")
	if input then
		repeat
		local name, deathtime = string.match(input:read("*l"), "(%D+) (%d+)")
		if name and deathtime then
			deadbanned[name] = deathtime
		end
		until input:read(0) == nil
		io.close(input)
	end
end

minetest.after(5, banondie_read)

local function banondie_save()
	if not deadbanned then
		return
	end
	local data = {}
	local output = io.open(file, "w")
	for name, deathtime in pairs(deadbanned) do
		table.insert(data, string.format("%s %s\n", name, deathtime))
	end
	table.insert(data, string.format("%s", "end"))
	output:write(table.concat(data))
	io.close(output)
end

minetest.register_on_dieplayer(function(player)
	if minetest.get_player_privs(player:get_player_name()).ban == nil then
		deadbanned[player:get_player_name()] = os.time()
		banondie_save()
	end
end)

minetest.register_on_respawnplayer(function(player)
	if minetest.get_player_privs(player:get_player_name()).ban == nil then
		minetest.kick_player(player:get_player_name(), message)
	end
end)

minetest.register_on_prejoinplayer(function(name, ip)
	if deadbanned[name] then
		if (os.time() - deadbanned[name]) > deathlength then
			deadbanned[name] = nil
			banondie_save()
		elseif minetest.get_player_privs(name).ban == nil then
			return message
		end
	end
end)
local marker = {}
minetest.register_chatcommand("mrkr", {
	params = "[<x>], [<y>], [<z>]",
	description = "Adds a waypoint marker at the selected position.",
	privs = {},
	func = function(name, param)
		local x, y, z = string.match(param, "^([%d.-]+)[, ] *([%d.-]+)[, ] *([%d.-]+)$")
		local player = minetest.get_player_by_name(name)
		if not z then
			minetest.chat_send_player(name, "You must have 3 coordinates!")
			return
		end
		if marker[name] then
			player:hud_remove(marker[name])
		end
		marker[name] = player:hud_add({
			hud_elem_type = "waypoint",
			name = x..", "..y..", "..z,
			number = 0xFF0000,
			world_pos = {x=x, y=y, z=z}
		})
	end
})
minetest.register_chatcommand("marker", {
	params = "[<x>], [<y>], [<z>]",
	description = "Adds a waypoint marker at the selected position.",
	privs = {},
	func = function(name, param)
		local x, y, z = string.match(param, "^([%d.-]+)[, ] *([%d.-]+)[, ] *([%d.-]+)$")
		local player = minetest.get_player_by_name(name)
		if not z then
			minetest.chat_send_player(name, "You must have 3 coordinates!")
			return
		end
		if marker[name] then
			player:hud_remove(marker[name])
		end
		marker[name] = player:hud_add({
			hud_elem_type = "waypoint",
			name = x..", "..y..", "..z,
			number = 0xFF0000,
			world_pos = {x=x, y=y, z=z}
		})
	end
})
minetest.register_chatcommand("clrmrkr", {
	params = "",
	description = "Removes the marker waypoint.",
	privs = {},
	func = function(name)
		local player = minetest.get_player_by_name(name)
		if marker[name] then
			if player:hud_remove(marker[name]) then
				marker[name] = nil
			end
		end
	end
})
minetest.register_chatcommand("clearmarker", {
	params = "",
	description = "Removes the marker waypoint.",
	privs = {},
	func = function(name)
		local player = minetest.get_player_by_name(name)
		if marker[name] then
			if player:hud_remove(marker[name]) then
				marker[name] = nil
			end
		end
	end
})
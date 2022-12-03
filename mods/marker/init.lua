-- Credit to Elkin for the original source that this was based off.
-- Credit to LMD for their multi-command registration function. :D
local function register_chatcommands(names, def)
    for _, name in ipairs(names) do
        minetest.register_chatcommand(name, def)
    end
end

local marker = {}
register_chatcommands({"mrkr", "marker"}, {
	params = "[<x>], [<y>], [<z>]",
	description = "Adds a waypoint marker at the selected position.",
	privs = {},
	func = function(name, param)
		-- Get the player name
		local player = minetest.get_player_by_name(name)
		-- Position storage
		local poslist = {}
		local pos
		local i = 0

		-- Read the players input and store it in a list.
		for coord in param:gmatch"%S+" do
			i = i+1
			poslist[i] = tonumber(coord:match"-?[%d.?]+")
		end

		-- Turn the list of positions into a vector.
		if i == 3 then
			pos = vector.new(unpack(poslist))
		end

		-- If the user input was blank, use the players position.
		if i == 0 then
			pos = player:get_pos():floor()
			i = 3
		end

		-- If the user entered anything other than three coordinates display an error.
		if i ~= 3 then
			return false, "You must have 3 coordinates!"
		end

		-- If the player already has a marker, remove it.
		if marker[name] then
			player:hud_remove(marker[name])
		end

		-- Create the waypoint.
		marker[name] = player:hud_add({
			hud_elem_type = "waypoint",
			name = pos[1]..", "..pos[2]..", "..pos[3],
			number = 0xFF0000,
			world_pos = pos
		})

		-- If everything went well this will display :D
		return true, "Waypoint Set!"
	end
})

register_chatcommands({"clrmrkr", "clearmarker"}, {
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

		return true, "Waypoint Removed!"
	end
})

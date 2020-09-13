minetest.register_chatcommand("clear_mobs", {
	description = "Clear all non-tamed mobs",
	privs = {
        server = true,
    },
    func = function(name, param)
		local modname = string.match(param, "([%a%d_-]+)")
		if not modname then
			return true, "Error: You have to specifiy a namespace (mod name)"
		end
		local player_pos = minetest.get_player_by_name(name):get_pos()
		if not player_pos then
			return
		end
		mokapi.clear_mobs(player_pos, modname)
    end,
})

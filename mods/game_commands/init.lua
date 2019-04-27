minetest.register_chatcommand("killme", {
	description = "Kill yourself to respawn",
	func = function(name)
		return false, "/killme is disabled."
	end
})

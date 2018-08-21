local function setflags(player)
	player:hud_set_flags({crosshair=false})
end
minetest.register_on_joinplayer(function(player)

	local hud = player:hud_add({
		hud_elem_type = "image",
		position  = {x = .5, y = .5},
		offset    = {x = 0, y = 0},
		text      = "crosshair.png",
		scale     = { x = 1, y = 1},
		alignment = { x = 0, y = 0 },
	})
	minetest.after(0, setflags, player)

end)
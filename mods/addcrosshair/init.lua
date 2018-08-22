local function setflags(player)
	player:hud_set_flags({crosshair=false})
	local hud = player:hud_add({
		hud_elem_type = "image",
		position  = {x = .5, y = .5},
		offset    = {x = 0, y = 0},
		text      = "crosshair.png",
		scale     = { x = 1, y = 1},
		alignment = { x = 0, y = 0 },
	})
end
minetest.register_on_joinplayer(function(player)
	minetest.after(.5, setflags, player)

end)
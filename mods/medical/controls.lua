
medical.lookingplayer = {}

medical.registered_on_lookaway = {}
function medical.register_on_lookaway(func)
	medical.registered_on_lookaway[#medical.registered_on_lookaway+1] = func
end
minetest.register_globalstep(function(dtime)
	for name, tbl in pairs(medical.lookingplayer) do
		local originaldir = tbl.dir
		local originalpos = tbl.pos
		local player = minetest.get_player_by_name(name)
		if not player then medical.lookingplayer[name] = nil return end
		local dir = player:get_look_dir()
		local pos = player:get_pos()
		local targetlookaway = false
		if tbl.tplayer then
			local targetplayer = minetest.get_player_by_name(tbl.tplayer)
			if not targetplayer then targetlookaway = true else
				local newtdir = targetplayer:get_look_dir()
				local newtpos = targetplayer:get_pos()
				if vector.distance(tbl.tpos, newtpos) > .1 or vector.distance(tbl.tdir, newtdir) > .05 then
					targetlookaway = true
				end
			end
		end
		if targetlookaway or (vector.distance(originalpos, pos) > .1 or vector.distance(originaldir, dir) > .05) then --gives just a little bit of room that player can look around
			for _, func in pairs(medical.registered_on_lookaway) do
				func(player, name)
			end
			medical.lookingplayer[name] = nil
		end
	end
end)
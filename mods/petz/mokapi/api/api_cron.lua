function mokapi.cron_clear(cron_time, modname)
	if cron_time > 0 then
		minetest.after(cron_time, function(cron_time, modname)
			mokapi.cron_clear_mobs(cron_time, modname)
		end, cron_time, modname)
	end
end

function mokapi.cron_clear_mobs(cron_time, modname)
	for _, player in ipairs(minetest.get_connected_players()) do
		local player_pos = player:get_pos()
		mokapi.clear_mobs(player_pos, modname)
	end
	mokapi.cron_clear(cron_time, modname)
end

-- Log accesses to driver stands and changes to switches

advtrains.log = function() end

if minetest.settings:get_bool("advtrains_enable_logging") then
	advtrains.logfile = advtrains.fpath .. "_log"

	local log = io.open(advtrains.logfile, "a+")
	
	function advtrains.log (event, player, pos, data)
	   log:write(os.date()..": "..event.." by "..player.." at "..minetest.pos_to_string(pos).." -- "..(data or "").."\n")
	end
	
	minetest.register_on_shutdown(function()
		log:close()
	end)
end

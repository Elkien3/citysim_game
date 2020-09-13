-- Advtrains line automation system

advtrains.lines = {
	-- [station code] = {name=..., owner=...}
	stations = {},
	
	--[[ [new pos hash] = {
		stn = <station code>,
		track = <platform identifier>,
		doors = <door side L,R,C>
		wait = <least wait time>
		reverse = <boolean>
		signal = <position of signal that is the "exit signal" for this platform>
	}]]
	stops = {},
}


local modpath = minetest.get_modpath(minetest.get_current_modname()) .. DIR_DELIM

dofile(modpath.."railwaytime.lua")
dofile(modpath.."scheduler.lua")
dofile(modpath.."stoprail.lua")


function advtrains.lines.load(data)
	if data then
		advtrains.lines.stations = data.stations or {}
		advtrains.lines.stops = data.stops or {}
		advtrains.lines.rwt.set_time(data.rwt_time)
		advtrains.lines.sched.load(data.scheduler_queue)
	end
end

function advtrains.lines.save()
	return {
		stations = advtrains.lines.stations,
		stops = advtrains.lines.stops,
		rwt_time = advtrains.lines.rwt.get_time(),
		scheduler_queue = advtrains.lines.sched.save()
	}
end

function advtrains.lines.step(dtime)
	advtrains.lines.rwt.step(dtime)
	advtrains.lines.sched.run()
end

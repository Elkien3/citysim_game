-- Advtrains interlocking system
-- See database.lua for a detailed explanation

advtrains.interlocking = {}

advtrains.SHUNT_SPEED_MAX = 6

function advtrains.interlocking.sigd_equal(sigd, cmp)
	return vector.equals(sigd.p, cmp.p) and sigd.s==cmp.s
end


local modpath = minetest.get_modpath(minetest.get_current_modname()) .. DIR_DELIM

dofile(modpath.."database.lua")
dofile(modpath.."signal_api.lua")
dofile(modpath.."demosignals.lua")
dofile(modpath.."train_sections.lua")
dofile(modpath.."route_prog.lua")
dofile(modpath.."routesetting.lua")
dofile(modpath.."tcb_ts_ui.lua")
dofile(modpath.."route_ui.lua")
dofile(modpath.."tool.lua")

dofile(modpath.."approach.lua")
dofile(modpath.."ars.lua")
dofile(modpath.."tsr_rail.lua")


minetest.register_privilege("interlocking", {description = "Can set up track sections, routes and signals.", give_to_singleplayer = true})

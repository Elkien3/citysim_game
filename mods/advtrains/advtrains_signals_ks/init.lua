-- Ks signals
-- Can display main aspects (no Zs) + Sht

-- Note that the group value of advtrains_signal is 2, which means "step 2 of signal capabilities"
-- advtrains_signal=1 is meant for signals that do not implement set_aspect.

local setaspectf = function(rot)
 return function(pos, node, asp)
	if not asp.main.free then
		if asp.shunt.free then
			advtrains.ndb.swap_node(pos, {name="advtrains_signals_ks:hs_shunt_"..rot, param2 = node.param2})
		else
			advtrains.ndb.swap_node(pos, {name="advtrains_signals_ks:hs_danger_"..rot, param2 = node.param2})
		end
	else
		if asp.dst.free and asp.main.speed == -1 then
			advtrains.ndb.swap_node(pos, {name="advtrains_signals_ks:hs_free_"..rot, param2 = node.param2})
		else
			advtrains.ndb.swap_node(pos, {name="advtrains_signals_ks:hs_slow_"..rot, param2 = node.param2})
		end
	end
 end
end

local suppasp = {
		main = {
			free = nil,
			speed = {6, -1},
		},
		dst = {
			free = nil,
			speed = nil,
		},
		shunt = {
			free = nil,
			proceed_as_main = true,
		},
		info = {
			call_on = false,
			dead_end = false,
			w_speed = nil,
		}
}

--Rangiersignal
local setaspectf_ra = function(rot)
 return function(pos, node, asp)
	if asp.shunt.free then
		advtrains.ndb.swap_node(pos, {name="advtrains_signals_ks:ra_shuntd_"..rot, param2 = node.param2})
	else
		advtrains.ndb.swap_node(pos, {name="advtrains_signals_ks:ra_danger_"..rot, param2 = node.param2})
	end
	local meta = minetest.get_meta(pos)
	if meta then
		meta:set_string("infotext", minetest.serialize(asp))
	end
 end
end

local suppasp_ra = {
		main = {
			free = true,
		},
		dst = {
			free = nil,
			speed = nil,
		},
		shunt = {
			free = nil,
			proceed_as_main = false,
		},
		info = {
			call_on = false,
			dead_end = false,
			w_speed = nil,
		}
}

advtrains.trackplacer.register_tracktype("advtrains_signals_ks:hs")
advtrains.trackplacer.register_tracktype("advtrains_signals_ks:ra")
advtrains.trackplacer.register_tracktype("advtrains_signals_ks:sign")
advtrains.trackplacer.register_tracktype("advtrains_signals_ks:mast")

for _, rtab in ipairs({
		{rot =  "0", sbox = {-1/8, -1/2, -1/2,  1/8, 1/2, -1/4}, ici=true},
		{rot = "30", sbox = {-3/8, -1/2, -1/2, -1/8, 1/2, -1/4},},
		{rot = "45", sbox = {-1/2, -1/2, -1/2, -1/4, 1/2, -1/4},},
		{rot = "60", sbox = {-1/2, -1/2, -3/8, -1/4, 1/2, -1/8},},
	}) do
	local rot = rtab.rot
	for typ, prts in pairs({
			danger = {asp = advtrains.interlocking.DANGER, n = "slow", ici=true},
			slow   = {asp = { main = { free = true, speed = 6 }, shunt = {proceed_as_main = true}} , n = "free"},
			free   = {asp = { main = { free = true, speed = -1 }, shunt = {proceed_as_main = true}} , n = "shunt"},
			shunt  = {asp = { main = {free = false}, shunt = {free = true} } , n = "danger"},
		}) do
		minetest.register_node("advtrains_signals_ks:hs_"..typ.."_"..rot, {
			description = "Ks Main Signal",
			drawtype = "mesh",
			mesh = "advtrains_signals_ks_main_smr"..rot..".obj",
			tiles = {"advtrains_signals_ks_mast.png", "advtrains_signals_ks_head.png", "advtrains_signals_ks_head.png", "advtrains_signals_ks_ltm_"..typ..".png"},
			
			paramtype="light",
			sunlight_propagates=true,
			light_source = 4,
			
			paramtype2 = "facedir",
			selection_box = {
				type = "fixed",
				fixed = {rtab.sbox, {-1/4, -1/2, -1/4, 1/4, -7/16, 1/4}}
			},
			groups = {
				cracky = 2,
				advtrains_signal = 2,
				not_blocking_trains = 1,
				save_in_at_nodedb = 1,
				not_in_creative_inventory = (rtab.ici and prts.ici) and 0 or 1,
			},
			drop = "advtrains_signals_ks:hs_danger_0",
			inventory_image = "advtrains_signals_ks_hs_inv.png",
			sounds = default.node_sound_stone_defaults(),
			advtrains = {
				set_aspect = setaspectf(rot),
				supported_aspects = suppasp,
				get_aspect = function(pos, node)
					return prts.asp
				end,
			},
			on_rightclick = advtrains.interlocking.signal_rc_handler,
			can_dig = advtrains.interlocking.signal_can_dig,
		})
		-- rotatable by trackworker
		advtrains.trackplacer.add_worked("advtrains_signals_ks:hs", typ, "_"..rot, prts.n)
	end
	
	
	--Rangiersignale:
	for typ, prts in pairs({
			danger = {asp = { main = {free = true}, shunt = {free = false} }, n = "shuntd", ici=true},
			shuntd = {asp = { main = {free = true}, shunt = {free = true} } , n = "danger"},
		}) do
		minetest.register_node("advtrains_signals_ks:ra_"..typ.."_"..rot, {
			description = "Ks Shunting Signal",
			drawtype = "mesh",
			mesh = "advtrains_signals_ks_sht_smr"..rot..".obj",
			tiles = {"advtrains_signals_ks_mast.png", "advtrains_signals_ks_head.png", "advtrains_signals_ks_head.png", "advtrains_signals_ks_ltm_"..typ..".png"},
			
			paramtype="light",
			sunlight_propagates=true,
			light_source = 4,
			
			paramtype2 = "facedir",
			selection_box = {
				type = "fixed",
				fixed = {-1/4, -1/2, -1/4, 1/4, 0, 1/4}
			},
			groups = {
				cracky = 2,
				advtrains_signal = 2,
				not_blocking_trains = 1,
				save_in_at_nodedb = 1,
				not_in_creative_inventory = (rtab.ici and prts.ici) and 0 or 1,
			},
			drop = "advtrains_signals_ks:ra_danger_0",
			inventory_image = "advtrains_signals_ks_ra_inv.png",
			sounds = default.node_sound_stone_defaults(),
			advtrains = {
				set_aspect = setaspectf_ra(rot),
				supported_aspects = suppasp_ra,
				get_aspect = function(pos, node)
					return prts.asp
				end,
			},
			on_rightclick = advtrains.interlocking.signal_rc_handler,
			can_dig = advtrains.interlocking.signal_can_dig,
		})
		-- rotatable by trackworker
		advtrains.trackplacer.add_worked("advtrains_signals_ks:ra", typ, "_"..rot, prts.n)
	end
	
	--Schilder:
	for typ, prts in pairs({
			-- Speed restrictions:
			["8"] = {asp = { main = {free = true, speed = 8}, shunt = {free = true} }, n = "12", ici=true},
			["12"] = {asp = { main = {free = true, speed = 12}, shunt = {free = true} }, n = "16"},
			["16"] = {asp = { main = {free = true, speed = 16}, shunt = {free = true} }, n = "e"},
			-- Speed restriction lifted
			["e"] = {asp = { main = {free = true, speed = -1}, shunt = {free = true} }, n = "hfs"},
			-- Halt for shunt moves:
			["hfs"] = {asp = { main = {free = true}, shunt = {free = false} }, n = "8"},
		}) do
		minetest.register_node("advtrains_signals_ks:sign_"..typ.."_"..rot, {
			description = "Signal Sign",
			drawtype = "mesh",
			mesh = "advtrains_signals_ks_sign_smr"..rot..".obj",
			tiles = {"advtrains_signals_ks_signpost.png", "advtrains_signals_ks_sign_"..typ..".png"},
			
			paramtype="light",
			sunlight_propagates=true,
			light_source = 4,
			
			paramtype2 = "facedir",
			selection_box = {
				type = "fixed",
				fixed = {rtab.sbox, {-1/4, -1/2, -1/4, 1/4, -7/16, 1/4}}
			},
			groups = {
				cracky = 2,
				advtrains_signal = 2,
				not_blocking_trains = 1,
				save_in_at_nodedb = 1,
				not_in_creative_inventory = (rtab.ici and prts.ici) and 0 or 1,
			},
			drop = "advtrains_signals_ks:sign_e_0",
			inventory_image = "advtrains_signals_ks_sign_8.png",
			sounds = default.node_sound_stone_defaults(),
			advtrains = {
				-- This is a static signal! No set_aspect
				get_aspect = function(pos, node)
					return prts.asp
				end,
			},
			on_rightclick = advtrains.interlocking.signal_rc_handler,
			can_dig = advtrains.interlocking.signal_can_dig,
		})
		-- rotatable by trackworker
		advtrains.trackplacer.add_worked("advtrains_signals_ks:sign", typ, "_"..rot, prts.n)
	end
	
	minetest.register_node("advtrains_signals_ks:mast_mast_"..rot, {
		description = "Ks Mast",
		drawtype = "mesh",
		mesh = "advtrains_signals_ks_mast_smr"..rot..".obj",
		tiles = {"advtrains_signals_ks_mast.png"},
		
		paramtype="light",
		sunlight_propagates=true,
		--light_source = 4,
		
		paramtype2 = "facedir",
		selection_box = {
			type = "fixed",
			fixed = {rtab.sbox, {-1/4, -1/2, -1/4, 1/4, -7/16, 1/4}}
		},
		groups = {
			cracky = 2,
			not_blocking_trains = 1,
			not_in_creative_inventory = (rtab.ici) and 0 or 1,
		},
		drop = "advtrains_signals_ks:mast_mast_0",
		sounds = default.node_sound_stone_defaults(),
	})
	advtrains.trackplacer.add_worked("advtrains_signals_ks:mast","mast", "_"..rot)
end


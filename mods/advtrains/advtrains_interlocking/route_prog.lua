-- Route programming system

--[[
Progamming routes:
1. Select "program new route" in the signalling dialog
-> route_start marker will appear to designate route-program mode
2. Do those actions in any order:
A. punch a TCB marker node to proceed route along this TCB. This will only work if
	this is actually a TCB bordering the current TS, and will place a
	route_set marker and shift to the next TS
B. right-click a turnout to switch it (no impact to route programming
C. punch a turnout (or some other passive component) to fix its state (toggle)
	for the route. A sprite telling "Route Fix" will show that fact.
3. To complete route setting, use the chat command '/at_program_route <route name>'.
	The last punched TCB will get a 'route end' marker
	The end of a route should be at another signal facing the same direction as the entrance signal,
	however this is not enforced and left up to the signal engineer (the programmer)
	
The route visualization will also be used to visualize routes after they have been programmed.
]]--


-- table with objectRefs
local markerent = {}

minetest.register_entity("advtrains_interlocking:routemarker", {
	visual = "mesh",
	mesh = "trackplane.b3d",
	textures = {"at_il_route_set.png"},
	collisionbox = {-1,-0.5,-1, 1,-0.4,1},
	visual_size = {x=10, y=10},
	on_punch = function(self)
		self.object:remove()
	end,
	get_staticdata = function() return "STATIC" end,
	on_activate = function(self, sdata) if sdata=="STATIC" then self.object:remove() end end,
	static_save = false,
})


-- Spawn or update a route marker entity
-- pos: position where this is going to be
-- key: something unique to determine which entity to remove if this was set before
-- img: texture
local function routemarker(context, pos, key, img, yaw, itex)
	if not markerent[context] then
		markerent[context] = {}
	end
	if markerent[context][key] then
		markerent[context][key]:remove()
	end
	
	local obj = minetest.add_entity(vector.add(pos, {x=0, y=0.3, z=0}), "advtrains_interlocking:routemarker")
	if not obj then return end
	obj:set_yaw(yaw)
	obj:set_properties({
		infotext = itex,
		textures = {img},
	})
	
	markerent[context][key] = obj
end

minetest.register_entity("advtrains_interlocking:routesprite", {
	visual = "sprite",
	textures = {"at_il_turnout_free.png"},
	collisionbox = {-0.2,-0.2,-0.2, 0.2,0.2,0.2},
	visual_size = {x=1, y=1},
	on_punch = function(self)
		if self.callback then
			self.callback()
		end
		self.object:remove()
	end,
	get_staticdata = function() return "STATIC" end,
	on_activate = function(self, sdata) if sdata=="STATIC" then self.object:remove() end end,
	static_save = false,
})


-- Spawn or update a route sprite entity
-- pos: position where this is going to be
-- key: something unique to determine which entity to remove if this was set before
-- img: texture
local function routesprite(context, pos, key, img, itex, callback)
	if not markerent[context] then
		markerent[context] = {}
	end
	if markerent[context][key] then
		markerent[context][key]:remove()
	end
	
	local obj = minetest.add_entity(vector.add(pos, {x=0, y=0, z=0}), "advtrains_interlocking:routesprite")
	if not obj then return end
	obj:set_properties({
		infotext = itex,
		textures = {img},
	})
	
	if callback then
		obj:get_luaentity().callback = callback
	end
	
	markerent[context][key] = obj
end

--[[
Route definition:
route = {
	name = <string>
	[n] = {
		next = <sigd>, -- of the next (note: next) TCB on the route
		locks = {<pts> = "state"} -- route locks of this route segment
	}
	terminal = 
}
The first item in the TCB path (namely i=0) is always the start signal of this route,
so this is left out.
All subsequent entries, starting from 1, contain:
- all route locks of the segment on TS between the (i-1). and the i. TCB
- the next TCB signal describer in proceeding direction of the route.
'Terminal' once again repeats the "next" entry of the last route segment.
It is needed for distant signal aspect determination. If it is not set,
the distant signal aspect is determined as DANGER.
]]--

local function chat(pname, message)
	minetest.chat_send_player(pname, "[Route programming] "..message)
end
local function clear_lock(locks, pname, pts)
	locks[pts] = nil
	chat(pname, pts.." is no longer affected when this route is set.")
end

local function otherside(s)
	if s==1 then return 2 else return 1 end
end

function advtrains.interlocking.clear_visu_context(context)
	if not markerent[context] then return end
	for key, obj in pairs(markerent[context]) do
		obj:remove()
	end
	markerent[context] = nil
end

-- visualize route. 'context' is a string that identifies the context of this visualization
-- e.g. prog_<player> or vis_<pts> for later visualizations
-- last 2 parameters are only to be used in the context of route programming!
function advtrains.interlocking.visualize_route(origin, route, context, tmp_lcks, pname)
	advtrains.interlocking.clear_visu_context(context)
	
	local oyaw = 0
	local onode_ok, oconns, orhe = advtrains.get_rail_info_at(origin.p, advtrains.all_tracktypes)
	if onode_ok then
		oyaw = advtrains.dir_to_angle(oconns[origin.s].c)
	end
	routemarker(context, origin.p, "rte_origin", "at_il_route_start.png", oyaw, route.name)
	
	local c_sigd = origin
	for k,v in ipairs(route) do
		c_sigd = v.next
		-- display route path
		-- Final "next" marker can be EOI, thus undefined. This is legitimate.
		if c_sigd then
			local yaw = 0
			local node_ok, conns, rhe = advtrains.get_rail_info_at(c_sigd.p, advtrains.all_tracktypes)
			if node_ok then
				yaw = advtrains.dir_to_angle(conns[c_sigd.s].c)
			end
			local img = "at_il_route_set.png"
			if k==#route and not tmp_lcks then
				img = "at_il_route_end.png"
			end
			routemarker(context, c_sigd.p, "rte"..k, img, yaw, route.name.." #"..k)
		end
		-- display locks
		for pts, state in pairs(v.locks) do
			local pos = minetest.string_to_pos(pts)
			routesprite(context, pos, "fix"..k..pts, "at_il_route_lock.png", "Fixed in state '"..state.."' by route "..route.name.." until segment #"..k.." is freed.")
		end
	end
	
	-- The presence of tmp_lcks tells us that we are displaying during route programming.
	if tmp_lcks then
		-- display route end markers at appropriate places (check next TS, if it exists)
		local terminal = c_sigd
		if terminal then
			local term_tcbs = advtrains.interlocking.db.get_tcbs(terminal)
			if term_tcbs.ts_id then
				local over_ts = advtrains.interlocking.db.get_ts(term_tcbs.ts_id)
				for i, sigd in ipairs(over_ts.tc_breaks) do
					if not vector.equals(sigd.p, terminal.p) then
						local yaw = 0
						local node_ok, conns, rhe = advtrains.get_rail_info_at(sigd.p, advtrains.all_tracktypes)
						if node_ok then
							yaw = advtrains.dir_to_angle(conns[otherside(sigd.s)].c)
						end
						routemarker(context, sigd.p, "rteterm"..i, "at_il_route_end.png", yaw, route.name.." Terminal "..i)
					end
				end
			end
		end
	-- display locks set by player		
		for pts, state in pairs(tmp_lcks) do
			local pos = minetest.string_to_pos(pts)
			routesprite(context, pos, "fixp"..pts, "at_il_route_lock_edit.png", "Fixed in state '"..state.."' by route "..route.name.." (punch to unfix)",
				function() clear_lock(tmp_lcks, pname, pts) end)
		end
	end
end


local player_rte_prog = {}

function advtrains.interlocking.init_route_prog(pname, sigd)
	if not minetest.check_player_privs(pname, "interlocking") then
		minetest.chat_send_player(pname, "Insufficient privileges to use this!")
		return
	end
	player_rte_prog[pname] = {
		origin = sigd,
		route = {
			name = "PROG["..pname.."]",
		},
		tmp_lcks = {},
	}
	advtrains.interlocking.visualize_route(sigd, player_rte_prog[pname].route, "prog_"..pname, player_rte_prog[pname].tmp_lcks, pname)
	minetest.chat_send_player(pname, "Route programming mode active. Punch TCBs to add route segments, punch turnouts to lock them.")
end

local function get_last_route_item(origin, route)
	if #route == 0 then
		return origin
	end
	return route[#route].next
end

local function do_advance_route(pname, rp, sigd, tsname)
	table.insert(rp.route, {next = sigd, locks = rp.tmp_lcks})
	rp.tmp_lcks = {}
	chat(pname, "Added track section '"..tsname.."' to the route.")
end

local function finishrpform(pname)
	local rp = player_rte_prog[pname]
	if not rp then return end
	
	local form = "size[7,6]label[0.5,0.5;Finish programming route]"
	local terminal = get_last_route_item(rp.origin, rp.route)
	if terminal then
		local term_tcbs = advtrains.interlocking.db.get_tcbs(terminal)
		
		if term_tcbs.signal then
			form = form .. "label[0.5,1.5;Route ends at signal:]"
			form = form .. "label[0.5,2  ;"..term_tcbs.signal_name.."]"
		else
			form = form .. "label[0.5,1.5;WARNING: Route does not end at a signal.]"
			form = form .. "label[0.5,2  ;Routes should in most cases end at signals.]"
			form = form .. "label[0.5,2.5;Cancel if you are unsure!]"
		end
	else
		form = form .. "label[0.5,1.5;Route leads into]"
		form = form .. "label[0.5,2  ;non-interlocked area]"
	end
	form = form.."field[0.8,3.5;5.2,1;name;Enter Route Name;]"
	form = form.."button_exit[0.5,4.5;  5,1;save;Save Route]"
	
	
	minetest.show_formspec(pname, "at_il_routepf", form)
end


local function check_advance_valid(tcbpos, rp)
	-- track circuit break, try to advance route over it
	local lri = get_last_route_item(rp.origin, rp.route)
	if not lri then
		return false, false
	end
	
	local is_endpoint = false
	
	local this_sigd, this_ts, adv_side
	
	if vector.equals(lri.p, tcbpos) then
		-- If the player just punched the last TCB again, it's of course possible to
		-- finish the route here (although it can't be advanced by here.
		-- Fun fact: you can now program routes that end exactly where they begin :)
		is_endpoint = true
		this_sigd = lri
	else
		-- else, we need to check whether this TS actually borders
		local start_tcbs = advtrains.interlocking.db.get_tcbs(lri)
		if not start_tcbs.ts_id then
			return false, false
		end
		
		this_ts = advtrains.interlocking.db.get_ts(start_tcbs.ts_id)
		for _,sigd in ipairs(this_ts.tc_breaks) do
			if vector.equals(sigd.p, tcbpos) then
				adv_side = otherside(sigd.s)
			end
		end
		if not adv_side then
			-- this TCB is not bordering to the section
			return false, false
		end
		this_sigd = {p=tcbpos, s=adv_side}
	end
	
	-- check whether the ts at the other end is capable of "end over"
	local adv_tcbs = advtrains.interlocking.db.get_tcbs(this_sigd)
	local next_tsid = adv_tcbs.ts_id
	local can_over, over_ts, next_tc_bs = false, nil, nil
	local cannotover_rsn = "Next section is diverging (>2 TCBs)"
	if next_tsid then
		-- you may not advance over EOI. While this is technically possible,
		-- in practise this just enters an unnecessary extra empty route item.
		over_ts = advtrains.interlocking.db.get_ts(adv_tcbs.ts_id)
		next_tc_bs = over_ts.tc_breaks
		can_over = #next_tc_bs <= 2
	else
		cannotover_rsn = "End of interlocking"
	end
	
	local over_sigd = nil
	if can_over then
		if next_tc_bs and #next_tc_bs == 2 then
			local sdt
			if vector.equals(next_tc_bs[1].p, tcbpos) then
				sdt = next_tc_bs[2]
			end
			if vector.equals(next_tc_bs[2].p, tcbpos) then
				sdt = next_tc_bs[1]
			end
			if not sdt then
				error("Inconsistency: "..dump(next_ts))
			end
			-- swap TCB direction
			over_sigd = {p = sdt.p, s = otherside(sdt.s) }
		end
	end
	
	return is_endpoint, true, this_sigd, this_ts, can_over, over_ts, over_sigd, cannotover_rsn
end

local function show_routing_form(pname, tcbpos, message)

	local rp = player_rte_prog[pname]
	
	if not rp then return end
	
	local is_endpoint, advance_valid, this_sigd, this_ts, can_over, over_ts, over_sigd, cannotover_rsn = check_advance_valid(tcbpos, rp)
	
	-- at this place, advance_valid shows whether the current route can be advanced
	-- over this TCB.
	-- If it can: 
	--  Advance over (continue programming)
	--  End here
	--  Advance and end (only <=2 TCBs, terminal signal needs to be known)
	-- if not:
	--  show nothing at all
	-- In all cases, Discard and Backtrack buttons needed.
	
	local form = "size[7,9.5]label[0.5,0.5;Advance/Complete Route]"
	if message then
		form = form .. "label[0.5,1;"..message.."]"
	end
	
	if advance_valid and not is_endpoint then
		form = form.. "label[0.5,1.8;Advance to next route section]"
		form = form.."image_button[0.5,2.2;  5,1;at_il_routep_advance.png;advance;]"
		
		form = form.. "label[0.5,3.5;-------------------------]"
	else
		form = form.. "label[0.5,2.3;This TCB is not suitable as]"
		form = form.. "label[0.5,2.8;route continuation.]"
	end
	if advance_valid or is_endpoint then
		form = form.. "label[0.5,3.8;Finish route HERE]"
		form = form.."image_button[0.5,  4.2;  5,1;at_il_routep_end_here.png;endhere;]"
		if can_over then
			form = form.. "label[0.5,5.3;Finish route at end of NEXT section]"
			form = form.."image_button[0.5,5.7;  5,1;at_il_routep_end_over.png;endover;]"
		else
			form = form.. "label[0.5,5.3;Advancing over next section is]"
			form = form.. "label[0.5,5.8;impossible at this place.]"
			if cannotover_rsn then
				form = form.. "label[0.5,6.3;"..cannotover_rsn.."]"
			end
		end
	end
	
	form = form.. "label[0.5,7;-------------------------]"
	if #rp.route > 0 then
		form = form.."button[0.5,7.4;  5,1;retract;Step back one section]"
	end
	form = form.."button[0.5,8.4;  5,1;cancel;Cancel route programming]"
	
	minetest.show_formspec(pname, "at_il_rprog_"..minetest.pos_to_string(tcbpos), form)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local pname = player:get_player_name()
	
	local tcbpts = string.match(formname, "^at_il_rprog_([^_]+)$")
	local tcbpos
	if tcbpts then
		tcbpos = minetest.string_to_pos(tcbpts)
	end
	if tcbpos then
		-- RPROG form
		local rp = player_rte_prog[pname]
		if not rp then
			minetest.close_formspec(pname, formname)
			return
		end
		
		local is_endpoint, advance_valid, this_sigd, this_ts, can_over, over_ts, over_sigd = check_advance_valid(tcbpos, rp)
		
		if advance_valid then
			if fields.advance then
				-- advance route
				if not is_endpoint then
					do_advance_route(pname, rp, this_sigd, this_ts.name)
				end
			end
			if fields.endhere then
				if not is_endpoint then
					do_advance_route(pname, rp, this_sigd, this_ts.name)
				end
				finishrpform(pname)
			end
			if can_over and fields.endover then
				if not is_endpoint then
					do_advance_route(pname, rp, this_sigd, this_ts.name)
				end
				do_advance_route(pname, rp, over_sigd, over_ts and over_ts.name or "--EOI--")
				finishrpform(pname)
			end
		end
		if fields.retract then
			if #rp.route <= 0 then
				minetest.close_formspec(pname, formname)
				return
			end
			rp.tmp_locks = rp.route[#rp.route].locks
			rp.route[#rp.route] = nil
			chat(pname, "Route section "..(#rp.route+1).." removed.") 
		end
		if fields.cancel then
			player_rte_prog[pname] = nil
			advtrains.interlocking.clear_visu_context("prog_"..pname)
			chat(pname, "Route discarded.")
			minetest.close_formspec(pname, formname)
			return
		end
		
		advtrains.interlocking.visualize_route(rp.origin, rp.route, "prog_"..pname, rp.tmp_lcks, pname)
		minetest.close_formspec(pname, formname)
		return
	end
	
	if formname == "at_il_routepf" then
		if not fields.save or not fields.name then return end
		if fields.name == "" then
			-- show form again
			finishrpform(pname)
			return
		end
		
		local rp = player_rte_prog[pname]
		if rp then
			if #rp.route <= 0 then
				chat(pname, "Cannot program route without a target")
				return
			end
			
			local tcbs = advtrains.interlocking.db.get_tcbs(rp.origin)
			if not tcbs then
				chat(pname, "The origin TCB has become unknown during programming. Try again.")
				return
			end
			
			local terminal = get_last_route_item(rp.origin, rp.route)
			rp.route.terminal = terminal
			rp.route.name = fields.name
			
			table.insert(tcbs.routes, rp.route)
			
			advtrains.interlocking.clear_visu_context("prog_"..pname)
			player_rte_prog[pname] = nil
			chat(pname, "Successfully programmed route.")
			
			advtrains.interlocking.show_route_edit_form(pname, rp.origin, #tcbs.routes)
			return
		end
	end 
end)


-- Central route programming punch callback
minetest.register_on_punchnode(function(pos, node, player, pointed_thing)
	local pname = player:get_player_name()
	if not minetest.check_player_privs(pname, "interlocking") then
		return
	end
	local rp = player_rte_prog[pname]
	if rp then
		-- determine what the punched node is
		if minetest.get_item_group(node.name, "at_il_track_circuit_break") >= 1 then
			-- get position of the assigned tcb
			local meta = minetest.get_meta(pos)
			local tcbpts = meta:get_string("tcb_pos")
			if tcbpts == "" then 
				chat(pname, "This TCB is unconfigured, you first need to assign it to a rail")
				return
			end
			local tcbpos = minetest.string_to_pos(tcbpts)
			
			-- show formspec
			
			show_routing_form(pname, tcbpos)
			
			advtrains.interlocking.visualize_route(rp.origin, rp.route, "prog_"..pname, rp.tmp_lcks, pname)
			
			return
		end
		if advtrains.is_passive(pos) then
			local pts = advtrains.roundfloorpts(pos)
			if rp.tmp_lcks[pts] then
				clear_lock(rp.tmp_lcks, pname, pts)
			else
				local state = advtrains.getstate(pos)
				rp.tmp_lcks[pts] = state
				chat(pname, pts.." is held in "..state.." position when this route is set and freed ")
			end
			advtrains.interlocking.visualize_route(rp.origin, rp.route, "prog_"..pname, rp.tmp_lcks, pname)
			return
		end
		
	end
end)


--TODO on route setting
-- routes should end at signals. complete route setting by punching a signal, and command as exceptional route completion
-- Create simpler way to advance a route to the next tcb/signal on simple sections without turnouts

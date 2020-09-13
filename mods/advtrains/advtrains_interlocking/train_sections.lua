-- train_related.lua
-- Occupation of track sections - mainly implementation of train callbacks

--[[
Track section occupation is saved as follows

In train:
train.il_sections = {
	[n] = {ts_id = <...> (origin = <sigd>)}
}
-- "origin" is the TCB (signal describer) the train initially entered this section

In track section
ts.trains = {
	[n] = <train_id>
}

When any inconsistency is detected, we will assume the most restrictive setup.
It will be possible to indicate a section "free" via the GUI.
]]

local ildb = advtrains.interlocking.db

local sigd_equal = advtrains.interlocking.sigd_equal

local function itexist(tbl, com)
	for _,item in ipairs(tbl) do
		if (item==com) then
			return true
		end
	end
	return false
end
local function itkexist(tbl, ikey, com)
	for _,item in ipairs(tbl) do
		if item[ikey] == com then
			return true
		end
	end
	return false
end

local function itremove(tbl, com)
	local i=1
	while i <= #tbl do
		if tbl[i] == com then
			table.remove(tbl, i)
		else
			i = i + 1
		end
	end
end
local function itkremove(tbl, ikey, com)
	local i=1
	while i <= #tbl do
		if tbl[i][ikey] == com then
			table.remove(tbl, i)
		else
			i = i + 1
		end
	end
end

local function setsection(tid, train, ts_id, ts, sigd)
	-- train
	if not train.il_sections then train.il_sections = {} end
	if not itkexist(train.il_sections, "ts_id", ts_id) then
		table.insert(train.il_sections, {ts_id = ts_id, origin = sigd})
	end
	
	-- ts
	if not ts.trains then ts.trains = {} end
	if not itexist(ts.trains, tid) then
		table.insert(ts.trains, tid)
	end
	
	-- routes
	local tcbs = advtrains.interlocking.db.get_tcbs(sigd)
	
	-- route setting - clear route state
	if ts.route then
		--atdebug(tid,"enters",ts_id,"examining Routestate",ts.route)
		if not sigd_equal(ts.route.entry, sigd) then
			-- Train entered not from the route. Locate origin and cancel route!
			atwarn("Train",tid,"hit route",ts.route.rsn,"!")
			advtrains.interlocking.route.cancel_route_from(ts.route.origin)
			atwarn("Route was cancelled.")
		else
			-- train entered route regularily. Reset route and signal
			tcbs.route_committed = nil
			tcbs.route_comitted = nil -- TODO compatibility cleanup
			tcbs.aspect = nil
			tcbs.route_origin = nil
			advtrains.interlocking.update_signal_aspect(tcbs)
			if tcbs.signal and sigd_equal(ts.route.entry, ts.route.origin) then
				if tcbs.route_auto and tcbs.routeset then
					--atdebug("Resetting route (",ts.route.origin,")")
					advtrains.interlocking.route.update_route(ts.route.origin, tcbs)
				else
					tcbs.routeset = nil
				end
			end
		end
		ts.route = nil
	end
	if tcbs.signal then
		advtrains.interlocking.route.update_route(sigd, tcbs)
	end
end

local function freesection(tid, train, ts_id, ts)
	-- train
	if not train.il_sections then train.il_sections = {} end
	itkremove(train.il_sections, "ts_id", ts_id)
	
	-- ts
	if not ts.trains then ts.trains = {} end
	itremove(ts.trains, tid)
	
	if ts.route_post then
		advtrains.interlocking.route.free_route_locks(ts_id, ts.route_post.locks)
		if ts.route_post.next then
			--this does nothing when the train went the right way, because
			-- "route" info is already cleared.
			advtrains.interlocking.route.cancel_route_from(ts.route_post.next)
		end
		ts.route_post = nil
	end
	-- This must be delayed, because this code is executed in-between a train step
	-- TODO use luaautomation timers?
	minetest.after(0, advtrains.interlocking.route.update_waiting, "ts", ts_id)
end


-- This is regular operation
-- The train is on a track and drives back and forth

-- This sets the section for both directions, to be failsafe
advtrains.tnc_register_on_enter(function(pos, id, train, index)
	local tcb = ildb.get_tcb(pos)
	if tcb then
		for connid=1,2 do
			local ts = tcb[connid].ts_id and ildb.get_ts(tcb[connid].ts_id)
			if ts then
				setsection(id, train, tcb[connid].ts_id, ts, {p=pos, s=connid})
			end
		end
	end
end)


-- this time, of course, only clear the backside (cp connid)
advtrains.tnc_register_on_leave(function(pos, id, train, index)
	local tcb = ildb.get_tcb(pos)
	if tcb and train.path_cp[index] then
		local connid = train.path_cp[index]
		local ts = tcb[connid].ts_id and ildb.get_ts(tcb[connid].ts_id)
		if ts then
			freesection(id, train, tcb[connid].ts_id, ts)
		end
	end
end)

-- those callbacks are needed to account for created and removed trains (also regarding coupling)

advtrains.te_register_on_create(function(id, train)
	-- let's see what track sections we find here
	local index = atround(train.index)
	local pos = advtrains.path_get(train, index)
	local ts_id, origin = ildb.get_ts_at_pos(pos)
	if ts_id then
		local ts = ildb.get_ts(ts_id)
		if ts then
			setsection(id, train, ts_id, ts, origin)
		else
			atwarn("ILDB corruption: TCB",origin," has invalid TS reference")
		end
		-- Make train a shunt move
		train.is_shunt = true
	elseif ts_id==nil then
		atlog("Train",id,": Unable to determine whether to block a track section!")
	else
		--atdebug("Train",id,": Outside of interlocked area!")
	end
end)

advtrains.te_register_on_remove(function(id, train)
	if train.il_sections then
		for idx, item in ipairs(train.il_sections) do
			
			local ts = item.ts_id and ildb.get_ts(item.ts_id)
			
			if ts and ts.trains then
				itremove(ts.trains, id)
			end
		end
		train.il_sections = nil
	end
end)

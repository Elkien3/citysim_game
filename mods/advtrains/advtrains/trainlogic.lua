--trainlogic.lua
--controls train entities stuff about connecting/disconnecting/colliding trains and other things

local setting_overrun_mode = minetest.settings:get("advtrains_overrun_mode")

local benchmark=false
local bm={}
local bmlt=0
local bmsteps=0
local bmstepint=200
atprintbm=function(action, ta)
	if not benchmark then return end
	local t=(os.clock()-ta)*1000
	if not bm[action] then
		bm[action]=t
	else
		bm[action]=bm[action]+t
	end
	bmlt=bmlt+t
end
function endstep()
	if not benchmark then return end
	bmsteps=bmsteps-1
	if bmsteps<=0 then
		bmsteps=bmstepint
		for key, value in pairs(bm) do
			minetest.chat_send_all(key.." "..(value/bmstepint).." ms avg.")
		end
		minetest.chat_send_all("Total time consumed by all advtrains actions per step: "..(bmlt/bmstepint).." ms avg.")
		bm={}
		bmlt=0
	end
end

--acceleration for lever modes (trainhud.lua), per wagon
local t_accel_all={
	[0] = -10,
	[1] = -3,
	[2] = -0.5,
	[4] = 0.5,
}
--acceleration per engine
local t_accel_eng={
	[0] = 0,
	[1] = 0,
	[2] = 0,
	[4] = 1.5,
}

tp_player_tmr = 0

advtrains.mainloop_trainlogic=function(dtime)
	--build a table of all players indexed by pts. used by damage and door system.
	advtrains.playersbypts={}
	for _, player in pairs(minetest.get_connected_players()) do
		if not advtrains.player_to_train_mapping[player:get_player_name()] then
			--players in train are not subject to damage
			local ptspos=minetest.pos_to_string(vector.round(player:getpos()))
			advtrains.playersbypts[ptspos]=player
		end
	end
	
	if tp_player_tmr<=0 then
		-- teleport players to their train every 2 seconds
		for _, player in pairs(minetest.get_connected_players()) do
			advtrains.tp_player_to_train(player)
		end
		tp_player_tmr = 2
	else
		tp_player_tmr = tp_player_tmr - dtime
	end
	--regular train step
	--[[ structure:
	1. make trains calculate their occupation windows when needed (a)
	2. when occupation tells us so, restore the occupation tables (a)
	4. make trains move and update their new occupation windows and write changes
	   to occupation tables (b)
	5. make trains do other stuff (c)
	]]--
	local t=os.clock()
	
	for k,v in pairs(advtrains.trains) do
		advtrains.atprint_context_tid=k
		advtrains.train_ensure_init(k, v)
	end
	
	advtrains.lock_path_inval = true
	
	for k,v in pairs(advtrains.trains) do
		advtrains.atprint_context_tid=k
		advtrains.train_step_b(k, v, dtime)
	end
	
	for k,v in pairs(advtrains.trains) do
		advtrains.atprint_context_tid=k
		advtrains.train_step_c(k, v, dtime)
	end
	
	advtrains.lock_path_inval = false
	
	advtrains.atprint_context_tid=nil
	
	atprintbm("trainsteps", t)
	endstep()
end

function advtrains.tp_player_to_train(player)
	local pname = player:get_player_name()
	local id=advtrains.player_to_train_mapping[pname]
	if id then
		local train=advtrains.trains[id]
		if not train then advtrains.player_to_train_mapping[pname]=nil return end
		--set the player to the train position.
		--minetest will emerge the area and load the objects, which then will call reattach_all().
		--because player is in mapping, it will not be subject to dying.
		player:setpos(train.last_pos)
	end
end
minetest.register_on_joinplayer(function(player)
	return advtrains.pcall(function()
		advtrains.hud[player:get_player_name()] = nil
		advtrains.hhud[player:get_player_name()] = nil
		--independent of this, cause all wagons of the train which are loaded to reattach their players
		--needed because already loaded wagons won't call reattach_all()
		for _,wagon in pairs(minetest.luaentities) do
			if wagon.is_wagon and wagon.initialized and wagon.train_id==id then
				wagon:reattach_all()
			end
		end
	end)
end)


minetest.register_on_dieplayer(function(player)
	return advtrains.pcall(function()
		local pname=player:get_player_name()
		local id=advtrains.player_to_train_mapping[pname]
		if id then
			local train=advtrains.trains[id]
			if not train then advtrains.player_to_train_mapping[pname]=nil return end
			for _,wagon in pairs(minetest.luaentities) do
				if wagon.is_wagon and wagon.initialized and wagon.train_id==id then
					--when player dies, detach him from the train
					--call get_off_plr on every wagon since we don't know which one he's on.
					wagon:get_off_plr(pname)
				end
			end
		end
	end)
end)

--[[

Zone diagram of a train (copy from occupation.lua!):
              |___| |___| --> Direction of travel
              oo oo+oo oo
=|=======|===|===========|===|=======|===================|========|===
 |SafetyB|CpB|   Train   |CpF|SafetyF|        Brake      |Aware   |
[1]     [2] [3]         [4] [5]     [6]                 [7]      [8]
This mapping from indices in occwindows to zone ids is contained in WINDOW_ZONE_IDS


The occupation system has been abandoned. The constants will still be used
to determine the couple distance
(because of the reverse lookup, the couple system simplifies a lot...)

]]--
-- unless otherwise stated, in meters.
local SAFETY_ZONE = 10
local COUPLE_ZONE = 2 --value in index positions!
local BRAKE_SPACE = 10
local AWARE_ZONE = 10
local WINDOW_ZONE_IDS = {
	2, -- 1 - SafetyB
	4, -- 2 - CpB
	1, -- 3 - Train
	5, -- 4 - CpF
	3, -- 5 - SafetyF
	6, -- 6 - Brake
	7, -- 7 - Aware
}


-- If a variable does not exist in the table, it is assigned the default value
local function assertdef(tbl, var, def)
	if not tbl[var] then
		tbl[var] = def
	end
end

function advtrains.get_acceleration(train, lever)
	local acc_all = t_accel_all[lever]
	local acc_eng = t_accel_eng[lever]
	local nwagons = #train.trainparts
	if nwagons == 0 then
		-- empty train! avoid division through zero
		return -1
	end
	local acc = acc_all + (acc_eng*train.locomotives_in_train)/nwagons
	return acc
end

-- Small local util function to recalculate train's end index
local function recalc_end_index(train)
	train.end_index = advtrains.path_get_index_by_offset(train, train.index, -train.trainlen)
end

-- Occupation Callback system
-- see occupation.lua
-- signature is advtrains.te_register_on_<?>(function(id, train) ... end)

local function mkcallback(name)
	local callt = {}
	advtrains["te_register_on_"..name] = function(func)
		assertt(func, "function")
		table.insert(callt, func)
	end
	return callt, function(id, train)
		for _,f in ipairs(callt) do
			f(id, train)
		end
	end
end

local callbacks_new_path, run_callbacks_new_path = mkcallback("new_path")
local callbacks_update, run_callbacks_update = mkcallback("update")
local callbacks_create, run_callbacks_create = mkcallback("create")
local callbacks_remove, run_callbacks_remove = mkcallback("remove")


-- train_ensure_init: responsible for creating a state that we can work on, after one of the following events has happened:
-- - the train's path got cleared
-- - save files were loaded
-- Additionally, this gets called outside the step cycle to initialize and/or remove a train, then occ_write_mode is set.
function advtrains.train_ensure_init(id, train)
	if not train then
		atwarn("train_ensure_init: Called with id =",id,"but a nil train!")
		atwarn(debug.traceback())
		return nil
	end
	
	train.dirty = true
	if train.no_step then return nil end

	assertdef(train, "velocity", 0)
	--assertdef(train, "tarvelocity", 0)
	assertdef(train, "acceleration", 0)
	assertdef(train, "id", id)
	assertdef(train, "ctrl", {})
	
	
	if not train.drives_on or not train.max_speed then
		advtrains.update_trainpart_properties(id)
	end
	
	--restore path
	if not train.path then
		if not train.last_pos then
			atlog("Train",id,": Restoring path failed, no last_pos set! Train will be disabled. You can try to fix the issue in the save file.")
			train.no_step = true
			return nil
		end
		if not train.last_connid then
			atwarn("Train",id,": Restoring path: no last_connid set! Will assume 1")
			train.last_connid = 1
			--[[
			Why this fix was necessary:
			Issue: Migration problems on Grand Theft Auto Minetest
			1. Run of this code, warning printed.
			2. path_create failed with result==nil (there was an unloaded node, wait_for_path set)
			3. in consequence, the supposed call to path_setrestore does not happen
			4. train.last_connid is still unset
			5. next step, warning is printed again
			Result: log flood.
			]]
		end
		
		local result = advtrains.path_create(train, train.last_pos, train.last_connid or 1, train.last_frac or 0)
		
		if result==false then
			atlog("Train",id,": Restoring path failed, node at",train.last_pos,"is gone! Train will be disabled. You can try to place a rail at this position and restart the server.")
			train.no_step = true
			return nil
		elseif result==nil then
			if not train.wait_for_path then
				atlog("Train",id,": Can't initialize: Waiting for the (yet unloaded) node at",train.last_pos," to be loaded.")
			end
			train.wait_for_path = true
			return false
		end
		-- by now, we should have a working initial path
		train.wait_for_path = false
		
		advtrains.update_trainpart_properties(id)
		recalc_end_index(train)
		
		--atdebug("Train",id,": Successfully restored path at",train.last_pos," connid",train.last_connid," frac",train.last_frac)
		
		-- run on_new_path callbacks
		run_callbacks_new_path(id, train)
	end
	
	train.dirty = false -- TODO einbauen!
	return true
end

function advtrains.train_step_b(id, train, dtime)
	if train.no_step or train.wait_for_path or not train.path then return end
	
	-- in this code, we check variables such as path_trk_? and path_dist. We need to ensure that the path is known for the whole 'Train' zone
	advtrains.path_get(train, atfloor(train.index + 2))
	advtrains.path_get(train, atfloor(train.end_index - 1))
	
	--- 3. handle velocity influences ---
	local train_moves=(train.velocity~=0)
	local tarvel_cap = train.speed_restriction
	
	if train.recently_collided_with_env then
		tarvel_cap=0
		if not train_moves then
			train.recently_collided_with_env=nil--reset status when stopped
		end
	end
	if train.locomotives_in_train==0 then
		tarvel_cap=0
	end
	
	--- 3a. this can be useful for debugs/warnings and is used for check_trainpartload ---
	local t_info, train_pos=sid(id), advtrains.path_get(train, atfloor(train.index))
	if train_pos then
		t_info=t_info.." @"..minetest.pos_to_string(train_pos)
		--atprint("train_pos:",train_pos)
	end
	
	--apply off-track handling:
	local front_off_track = train.index>train.path_trk_f
	local back_off_track=train.end_index<train.path_trk_b
	train.off_track = front_off_track or back_off_track
	
	if front_off_track then
		tarvel_cap=0
	end
	if back_off_track then -- eventually overrides front_off_track restriction
		tarvel_cap=1
	end
	
	-- Driving control rework:
	--[[
	Items are only defined when something is controlling them.
	In order of precedence.
	train.ctrl = {
		lzb  = restrictive override from LZB
		user = User input from driverstand
		atc  = ATC command override (determined here)
	}
	The code here determines the precedence and writes the final control into train.lever
	]]
	
	--interpret ATC command and apply auto-lever control when not actively controlled
	local trainvelocity = train.velocity
	
	if train.ctrl.user then
		advtrains.atc.train_reset_command(train)
	else
		local braketar = train.atc_brake_target
		local emerg = false -- atc_brake_target==-1 means emergency brake (BB command)
		if braketar == -1 then
			braketar = 0
			emerg = true
		end
		if braketar and braketar>=trainvelocity then
			train.atc_brake_target=nil
			braketar = nil
		end
		--if train.tarvelocity and train.velocity==train.tarvelocity then
		--	train.tarvelocity = nil
		--end
		if train.atc_wait_finish then
			if not train.atc_brake_target and (not train.tarvelocity or train.velocity==train.tarvelocity) then
				train.atc_wait_finish=nil
			end
		end
		if train.atc_command then
			if (not train.atc_delay or train.atc_delay<=0) and not train.atc_wait_finish then
				advtrains.atc.execute_atc_command(id, train)
			else
				train.atc_delay=train.atc_delay-dtime
			end
		elseif train.atc_delay then
			train.atc_delay = nil
		end
		
		train.ctrl.atc = nil
		if train.tarvelocity and train.tarvelocity>trainvelocity then
			train.ctrl.atc=4
		end
		if train.tarvelocity and train.tarvelocity<trainvelocity then
			if (braketar and braketar<trainvelocity) then
				if emerg then
					train.ctrl.atc = 0
				else
					train.ctrl.atc=1
				end
			else
				train.ctrl.atc=2
			end
		end
	end
	
	--if tarvel_cap and train.tarvelocity and tarvel_cap<train.tarvelocity then
	--	train.tarvelocity=tarvel_cap
	--end
	
	local tmp_lever
	
	for _, lev in pairs(train.ctrl) do
		-- use the most restrictive of all control overrides
		tmp_lever = math.min(tmp_lever or 4, lev)
	end
	
	if not tmp_lever then
		-- if there was no control at all, default to 3
		tmp_lever = 3
	end
	
	if tarvel_cap and trainvelocity>tarvel_cap then
		tmp_lever = 0
	end
	
	train.lever = tmp_lever
	
	--- 3a. actually calculate new velocity ---
	if tmp_lever~=3 then
		local accel = advtrains.get_acceleration(train, tmp_lever)
		local vdiff = accel*dtime
		
		-- This should only be executed when we are accelerating
		-- I suspect that this causes the braking bugs
		if tmp_lever == 4 then
		
			-- ATC control exception: don't cross tarvelocity if
			-- atc provided a target_vel
			if train.tarvelocity then
				local tvdiff = train.tarvelocity - trainvelocity
				if tvdiff~=0 and math.abs(vdiff) > math.abs(tvdiff) then
					--applying this change would cross tarvelocity
					--atdebug("In Tvdiff condition, clipping",vdiff,"to",tvdiff)
					--atdebug("vel=",trainvelocity,"tvel=",train.tarvelocity)
					vdiff=tvdiff
				end
			end
			if tarvel_cap and trainvelocity<=tarvel_cap and trainvelocity+vdiff>tarvel_cap then
				vdiff = tarvel_cap - train.velocity
			end
			local mspeed = (train.max_speed or 10)
			if trainvelocity+vdiff > mspeed then
				vdiff = mspeed - trainvelocity
			end
		end
		
		if trainvelocity+vdiff < 0 then
			vdiff = - trainvelocity
		end


		train.acceleration=vdiff
		train.velocity=train.velocity+vdiff
		--if train.ctrl.user then
		--	train.tarvelocity = train.velocity
		--end
	else
		train.acceleration = 0
	end
	
	--- 4. move train ---
	
	local idx_floor = math.floor(train.index)
	local pdist = (train.path_dist[idx_floor+1] - train.path_dist[idx_floor])
	local distance = (train.velocity*dtime) / pdist
	
	--debugging code
	--train.debug = atdump(train.ctrl).."step_dist: "..math.floor(distance*1000)
	
	train.index=train.index+distance
	
	recalc_end_index(train)

end

function advtrains.train_step_c(id, train, dtime)
	if train.no_step or train.wait_for_path or not train.path then return end
	
	-- all location/extent-critical actions have been done.
	-- calculate the new occupation window
	run_callbacks_update(id, train)
	
	-- Return if something(TM) damaged the path
	if train.no_step or train.wait_for_path or not train.path then return end
	
	advtrains.path_clear_unused(train)
	
	advtrains.path_setrestore(train)
	
	-- less important stuff
	
	train.check_trainpartload=(train.check_trainpartload or 0)-dtime
	if train.check_trainpartload<=0 then
		advtrains.spawn_wagons(id)
		train.check_trainpartload=2
	end
	
	--- 8. check for collisions with other trains and damage players ---
	
	local train_moves=(train.velocity~=0)
	
	--- Check whether this train can be coupled to another, and set couple entities accordingly
	if not train.was_standing and not train_moves then
		advtrains.train_check_couples(train)
	end
	train.was_standing = not train_moves
	
	if train_moves then
		
		local collided = false
		local coll_grace=1
		local collindex = advtrains.path_get_index_by_offset(train, train.index, -coll_grace)
		local collpos = advtrains.path_get(train, atround(collindex))
		if collpos then
			local rcollpos=advtrains.round_vector_floor_y(collpos)
			local is_loaded_area = minetest.get_node_or_nil(rcollpos) ~= nil
			for x=-train.extent_h,train.extent_h do
				for z=-train.extent_h,train.extent_h do
					local testpos=vector.add(rcollpos, {x=x, y=0, z=z})
					--- 8a Check collision ---
					if not collided then

						local col_tr = advtrains.occ.check_collision(testpos, id)
						if col_tr then
							advtrains.train_check_couples(train)
							train.velocity = 0
							advtrains.atc.train_reset_command(train)
							collided = true
						end

						--- 8b damage players ---
						if is_loaded_area and train.velocity > 3 and (setting_overrun_mode=="drop" or setting_overrun_mode=="normal") then
							local testpts = minetest.pos_to_string(testpos)
							local player=advtrains.playersbypts[testpts]
							if player and player:get_hp()>0 and advtrains.is_damage_enabled(player:get_player_name()) then
								--atdebug("damage found",player:get_player_name())
								if setting_overrun_mode=="drop" then
									--instantly kill player
									--drop inventory contents first, to not to spawn bones
									local player_inv=player:get_inventory()
									for i=1,player_inv:get_size("main") do
										minetest.add_item(testpos, player_inv:get_stack("main", i))
									end
									for i=1,player_inv:get_size("craft") do
										minetest.add_item(testpos, player_inv:get_stack("craft", i))
									end
									-- empty lists main and craft
									player_inv:set_list("main", {})
									player_inv:set_list("craft", {})
								end
								player:set_hp(0)
							end
						end
					end
				end
			end
			--- 8c damage other objects ---
			if is_loaded_area then
				local objs = minetest.get_objects_inside_radius(rcollpos, 2)
				for _,obj in ipairs(objs) do
					if not obj:is_player() and obj:get_armor_groups().fleshy and obj:get_armor_groups().fleshy > 0 
							and obj:get_luaentity() and obj:get_luaentity().name~="signs:text" then
						obj:punch(obj, 1, { full_punch_interval = 1.0, damage_groups = {fleshy = 1000}, }, nil)
					end
				end
			end
		end
	end
end

-- Default occupation callbacks for node callbacks
-- (remember, train.end_index is set separately because callbacks are
--  asserted to rely on this)

local function mknodecallback(name)
	local callt = {}
	advtrains["tnc_register_on_"..name] = function(func, prio)
		assertt(func, "function")
		if prio then
			table.insert(callt, 1, func)
		else
			table.insert(callt, func)
		end
	end
	return callt, function(pos, id, train, index, paramx1, paramx2, paramx3)
		for _,f in ipairs(callt) do
			f(pos, id, train, index, paramx1, paramx2, paramx3)
		end
	end
end

-- enter/leave-node callbacks
-- signature is advtrains.tnc_register_on_enter/leave(function(pos, id, train, index) ... end)
local callbacks_enter_node, run_callbacks_enter_node = mknodecallback("enter")
local callbacks_leave_node, run_callbacks_leave_node = mknodecallback("leave")

-- Node callback for approaching
-- Might be called multiple times, whenever path is recalculated
-- signature is function(pos, id, train, index, lzbdata)
-- lzbdata: arbitrary data (shared between all callbacks), deleted when LZB is restarted.
-- These callbacks are called in order of distance as train progresses along tracks, so lzbdata can be used to
-- keep track of a train's state once it passes this point
local callbacks_approach_node, run_callbacks_approach_node = mknodecallback("approach")


local function tnc_call_enter_callback(pos, train_id, train, index)
	--atdebug("tnc enter",pos,train_id)
	local node = advtrains.ndb.get_node(pos) --this spares the check if node is nil, it has a name in any case
	local mregnode=minetest.registered_nodes[node.name]
	if mregnode and mregnode.advtrains and mregnode.advtrains.on_train_enter then
		mregnode.advtrains.on_train_enter(pos, train_id, train, index)
	end

	-- call other registered callbacks
	run_callbacks_enter_node(pos, train_id, train, index)
	
	-- check for split points
	if mregnode and mregnode.at_conns and #mregnode.at_conns == 3 and train.path_cp[index] == 3 then
		-- train came from connection 3 of a switch, so it split points.
		if not train.points_split then
			train.points_split = {}
		end
		train.points_split[advtrains.encode_pos(pos)] = true
		--atdebug(train_id,"split points at",pos)
	end
end
local function tnc_call_leave_callback(pos, train_id, train, index)
	--atdebug("tnc leave",pos,train_id)
	local node = advtrains.ndb.get_node(pos) --this spares the check if node is nil, it has a name in any case
	local mregnode=minetest.registered_nodes[node.name]
	if mregnode and mregnode.advtrains and mregnode.advtrains.on_train_leave then
		mregnode.advtrains.on_train_leave(pos, train_id, train, index)
	end
	
	-- call other registered callbacks
	run_callbacks_leave_node(pos, train_id, train, index)
	
	-- split points do not matter anymore. clear them
	if train.points_split then
		if train.points_split[advtrains.encode_pos(pos)] then
			train.points_split[advtrains.encode_pos(pos)] = nil
			--atdebug(train_id,"has passed split points at",pos)
		end
		-- any entries left?
		for _,_ in pairs(train.points_split) do
			return
		end
		train.points_split = nil
	end
	-- WARNING possibly unreachable place!
end

function advtrains.tnc_call_approach_callback(pos, train_id, train, index, lzbdata)
	--atdebug("tnc approach",pos,train_id, lzbdata)
	local node = advtrains.ndb.get_node(pos) --this spares the check if node is nil, it has a name in any case
	local mregnode=minetest.registered_nodes[node.name]
	if mregnode and mregnode.advtrains and mregnode.advtrains.on_train_approach then
		mregnode.advtrains.on_train_approach(pos, train_id, train, index, lzbdata)
	end
	
	-- call other registered callbacks
	run_callbacks_approach_node(pos, train_id, train, index, lzbdata)
end


advtrains.te_register_on_new_path(function(id, train)
	train.tnc = {
		old_index = atround(train.index),
		old_end_index = atround(train.end_index),
	}
	--atdebug(id,"tnc init",train.index,train.end_index)
end)

advtrains.te_register_on_update(function(id, train)
	local new_index = atround(train.index)
	local new_end_index = atround(train.end_index)
	local old_index = train.tnc.old_index
	local old_end_index = train.tnc.old_end_index
	while old_index < new_index do
		old_index = old_index + 1
		local pos = advtrains.round_vector_floor_y(advtrains.path_get(train,old_index))
		tnc_call_enter_callback(pos, id, train, old_index)
	end
	while old_end_index < new_end_index do
		local pos = advtrains.round_vector_floor_y(advtrains.path_get(train,old_end_index))
		tnc_call_leave_callback(pos, id, train, old_end_index)
		old_end_index = old_end_index + 1
	end
	train.tnc.old_index = new_index
	train.tnc.old_end_index = new_end_index
end)

advtrains.te_register_on_create(function(id, train)
	local index = atround(train.index)
	local end_index = atround(train.end_index)
	while end_index <= index do
		local pos = advtrains.round_vector_floor_y(advtrains.path_get(train,end_index))
		tnc_call_enter_callback(pos, id, train, end_index)
		end_index = end_index + 1
	end
	--atdebug(id,"tnc create",train.index,train.end_index)
end)

advtrains.te_register_on_remove(function(id, train)
	local index = atround(train.index)
	local end_index = atround(train.end_index)
	while end_index <= index do
		local pos = advtrains.round_vector_floor_y(advtrains.path_get(train,end_index))
		tnc_call_leave_callback(pos, id, train, end_index)
		end_index = end_index + 1
	end
	--atdebug(id,"tnc remove",train.index,train.end_index)
end)

--returns new id
function advtrains.create_new_train_at(pos, connid, ioff, trainparts)
	local new_id=advtrains.random_id()
	while advtrains.trains[new_id] do new_id=advtrains.random_id() end--ensure uniqueness
	
	local t={}
	t.id = new_id
	
	t.last_pos=pos
	t.last_connid=connid
	t.last_frac=ioff
	
	--t.tarvelocity=0
	t.velocity=0
	t.trainparts=trainparts
	
	advtrains.trains[new_id] = t
	--atdebug("Created new train:",t)
	
	if not advtrains.train_ensure_init(new_id, advtrains.trains[new_id]) then
		atwarn("create_new_train_at",pos,connid,"failed! This might lead to temporary bugs.")
		return
	end
	
	run_callbacks_create(new_id, advtrains.trains[new_id])
	
	return new_id
end

function advtrains.remove_train(id)
	local train = advtrains.trains[id]
	
	if not advtrains.train_ensure_init(id, train) then
		atwarn("remove_train",id,"failed! This might lead to temporary bugs.")
		return
	end
	
	run_callbacks_remove(id, train)
	
	advtrains.path_invalidate(train)
	advtrains.couple_invalidate(train)
	
	local tp = train.trainparts
	--atdebug("Removing train",id,"leftover trainparts:",tp)
	
	advtrains.trains[id] = nil
	
	return tp
	
end


function advtrains.add_wagon_to_train(wagon_id, train_id, index)
	local train=advtrains.trains[train_id]
	
	if not advtrains.train_ensure_init(train_id, train) then
		atwarn("Train",train_id,"is not initialized! Operation aborted!")
		return
	end
	
	if index then
		table.insert(train.trainparts, index, wagon_id)
	else
		table.insert(train.trainparts, wagon_id)
	end
	
	advtrains.update_trainpart_properties(train_id)
	recalc_end_index(train)
	run_callbacks_update(train_id, train)
end

-- Note: safe_decouple_wagon() has been moved to wagons.lua

-- this function sets wagon's pos_in_train(parts) properties and train's max_speed and drives_on (and more)
function advtrains.update_trainpart_properties(train_id, invert_flipstate)
	local train=advtrains.trains[train_id]
	train.drives_on=advtrains.merge_tables(advtrains.all_tracktypes)
	--FIX: deep-copy the table!!!
	train.max_speed=20
	train.extent_h = 0;
	
	local rel_pos=0
	local count_l=0
	local shift_dcpl_lock=false
	for i, w_id in ipairs(train.trainparts) do
		
		local data = advtrains.wagons[w_id]
		
		-- 1st: update wagon data (pos_in_train a.s.o)
		if data then
			local wagon = advtrains.wagon_prototypes[data.type or data.entity_name]
			if not wagon then
				atwarn("Wagon '",data.type,"' couldn't be found. Please check that all required modules are loaded!")
				wagon = advtrains.wagon_prototypes["advtrains:wagon_placeholder"]

			end
			rel_pos=rel_pos+wagon.wagon_span
			data.train_id=train_id
			data.pos_in_train=rel_pos
			data.pos_in_trainparts=i
			if wagon.is_locomotive then
				count_l=count_l+1
			end
			if invert_flipstate then
				data.wagon_flipped = not data.wagon_flipped
				shift_dcpl_lock, data.dcpl_lock = data.dcpl_lock, shift_dcpl_lock
			end
			rel_pos=rel_pos+wagon.wagon_span
			
			if wagon.drives_on then
				for k,_ in pairs(train.drives_on) do
					if not wagon.drives_on[k] then
						train.drives_on[k]=nil
					end
				end
			end
			train.max_speed=math.min(train.max_speed, wagon.max_speed)
			train.extent_h = math.max(train.extent_h, wagon.extent_h or 1);
		end
	end
	train.trainlen = rel_pos
	train.locomotives_in_train = count_l
end


local ablkrng = advtrains.wagon_load_range
-- This function checks whether entities need to be spawned for certain wagons, and spawns them.
-- Called from train_step_*(), not required to check init.
function advtrains.spawn_wagons(train_id)
	local train = advtrains.trains[train_id]
	
	for i = 1, #train.trainparts do
		local w_id = train.trainparts[i]
		local data = advtrains.wagons[w_id]
		if data then
			if data.train_id ~= train_id then
				atwarn("Train",train_id,"Wagon #",i,": Saved train ID",data.train_id,"did not match!")
				data.train_id = train_id
			end
			if not advtrains.wagon_objects[w_id] or not advtrains.wagon_objects[w_id]:getyaw() then
				-- eventually need to spawn new object. check if position is loaded.
				local index = advtrains.path_get_index_by_offset(train, train.index, -data.pos_in_train)
				local pos   = advtrains.path_get(train, atfloor(index))
				
				local spawn = false
				for _,p in pairs(minetest.get_connected_players()) do
					if vector.distance(p:get_pos(),pos)<=ablkrng then
						spawn = true
					end
				end
				
				if spawn then
					--atdebug("wagon",w_id,"spawning")
					local wt = advtrains.get_wagon_prototype(data)
					local wagon = minetest.add_entity(pos, wt):get_luaentity()
					wagon:set_id(w_id)
				end
			end
		else
			atwarn("Train",train_id,"Wagon #",1,": A wagon with id",w_id,"does not exist! Wagon will be removed from train.")
			table.remove(train.trainparts, i)
			i = i - 1
		end
	end
end

function advtrains.split_train_at_index(train, index)
	-- this function splits a train at index, creating a new train from the back part of the train.

	local train_id=train.id
	if index > #train.trainparts then
		-- index specified too long
		return
	end
	local w_id = train.trainparts[index]
	local data = advtrains.wagons[w_id]
	local _, wagon = advtrains.get_wagon_prototype(data)
	if not advtrains.train_ensure_init(train_id, train) then
		atwarn("Train",train_id,"is not initialized! Operation aborted!")
		return
	end

	local p_index=advtrains.path_get_index_by_offset(train, train.index, - data.pos_in_train + wagon.wagon_span)
	local pos, connid, frac = advtrains.path_getrestore(train, p_index)
	local tp = {}
	for k,v in ipairs(train.trainparts) do
		if k >= index then
			table.insert(tp, v)
			train.trainparts[k] = nil
		end
	end
	advtrains.update_trainpart_properties(train_id)
	recalc_end_index(train)
	run_callbacks_update(train_id, train)
	
	--create subtrain
	local newtrain_id=advtrains.create_new_train_at(pos, connid, frac, tp)
	local newtrain=advtrains.trains[newtrain_id]
	
	newtrain.velocity=train.velocity
	return newtrain_id -- return new train ID, so new train can be manipulated

end

function advtrains.split_train_at_wagon(wagon_id)
	--get train
	local data = advtrains.wagons[wagon_id]
	advtrains.split_train_at_index(advtrains.trains[data.train_id], data.pos_in_trainparts)
end

-- coupling
local CPL_CHK_DST = -1
local CPL_ZONE = 2

-- train.couple_* contain references to ObjectRefs of couple objects, which contain all relevant information
-- These objectRefs will delete themselves once the couples no longer match
local function createcouple(pos, train1, t1_is_front, train2, t2_is_front)
	local id1 = train1.id
	local id2 = train2.id
	if train1.autocouple or train2.autocouple then
		-- couple trains
		train1.autocouple = nil
		train2.autocouple = nil		
		minetest.after(0, advtrains.safe_couple_trains, id1, id2, t1_is_front, t2_is_front, false, false, train1.velocity, train2.velocity)
		return
	end
	
	local obj=minetest.add_entity(pos, "advtrains:couple")
	if not obj then error("Failed creating couple object!") return end
	local le=obj:get_luaentity()
	le.train_id_1=id1
	le.train_id_2=id2
	le.t1_is_front=t1_is_front
	le.t2_is_front=t2_is_front
	--atdebug("created couple between",train1.id,t1_is_front,train2.id,t2_is_front)
	if t1_is_front then
		train1.cpl_front = obj
	else
		train1.cpl_back = obj
	end
	if t2_is_front then
		train2.cpl_front = obj
	else
		train2.cpl_back = obj
	end
	
end

function advtrains.train_check_couples(train)
	--atdebug("rechecking couples")
	if train.cpl_front then
		if not train.cpl_front:getyaw() then
			-- objectref is no longer valid. reset.
			train.cpl_front = nil
		end
	end
	if not train.cpl_front then
		-- recheck front couple
		local front_trains, pos = advtrains.occ.get_occupations(train, atround(train.index) + CPL_CHK_DST)
		if minetest.get_node_or_nil(pos) then -- if the position is loaded...
			for tid, idx in pairs(front_trains) do
				local other_train = advtrains.trains[tid]
				if not advtrains.train_ensure_init(tid, other_train) then
					atwarn("Train",tid,"is not initialized! Couldn't check couples!")
					return
				end
				--atdebug(train.id,"front: ",idx,"on",tid,atround(other_train.index),atround(other_train.end_index))
				if other_train.velocity == 0 then
					if idx>=other_train.index and idx<=other_train.index + CPL_ZONE then
						createcouple(pos, train, true, other_train, true)
						break
					end
					if idx<=other_train.end_index and idx>=other_train.end_index - CPL_ZONE then
						createcouple(pos, train, true, other_train, false)
						break
					end
				end
			end
		end
	end
	if train.cpl_back then
		if not train.cpl_back:getyaw() then
			-- objectref is no longer valid. reset.
			train.cpl_back = nil
		end
	end
	if not train.cpl_back then
		-- recheck back couple
		local back_trains, pos = advtrains.occ.get_occupations(train, atround(train.end_index) - CPL_CHK_DST)
		if minetest.get_node_or_nil(pos) then -- if the position is loaded...
			for tid, idx in pairs(back_trains) do
				local other_train = advtrains.trains[tid]
				if not advtrains.train_ensure_init(tid, other_train) then
					atwarn("Train",tid,"is not initialized! Couldn't check couples!")
					return
				end
				if other_train.velocity == 0 then
					if idx>=other_train.index and idx<=other_train.index + CPL_ZONE then
						createcouple(pos, train, false, other_train, true)
						break
					end
					if idx<=other_train.end_index and idx>=other_train.end_index - CPL_ZONE then
						createcouple(pos, train, false, other_train, false)
						break
					end
				end
			end
		end
	end
end

function advtrains.couple_invalidate(train)
	if train.cpl_back then
		train.cpl_back:remove()
		train.cpl_back = nil
	end
	if train.cpl_front then
		train.cpl_front:remove()
		train.cpl_front = nil
	end
	train.was_standing = nil
end

-- relevant code for this comment is in couple.lua

--there are 4 cases:
--1/2. F<->R F<->R regular, put second train behind first
--->frontpos of first train will match backpos of second
--3.   F<->R R<->F flip one of these trains, take the other as new train
--->backpos's will match
--4.   R<->F F<->R flip one of these trains and take it as new parent
--->frontpos's will match


function advtrains.do_connect_trains(first_id, second_id, vel)
	local first, second=advtrains.trains[first_id], advtrains.trains[second_id]
	
	if not advtrains.train_ensure_init(first_id, first) then
		atwarn("Train",first_id,"is not initialized! Operation aborted!")
		return
	end
	if not advtrains.train_ensure_init(second_id, second) then
		atwarn("Train",second_id,"is not initialized! Operation aborted!")
		return
	end
	
	local first_wagoncnt=#first.trainparts
	local second_wagoncnt=#second.trainparts
	
	for _,v in ipairs(second.trainparts) do
		table.insert(first.trainparts, v)
	end
	
	advtrains.remove_train(second_id)
	
	first.velocity= vel or 0
	
	advtrains.update_trainpart_properties(first_id)
	advtrains.couple_invalidate(first)
	return true
end

function advtrains.invert_train(train_id)
	local train=advtrains.trains[train_id]
	
	if not advtrains.train_ensure_init(train_id, train) then
		atwarn("Train",train_id,"is not initialized! Operation aborted!")
		return
	end
	
	advtrains.path_setrestore(train, true)
	
	-- rotate some other stuff
	if train.door_open then
		train.door_open = - train.door_open
	end
	if train.atc_command then
		train.atc_arrow = not train.atc_arrow
	end
	
	advtrains.path_invalidate(train, true)
	advtrains.couple_invalidate(train)
	
	local old_trainparts=train.trainparts
	train.trainparts={}
	for k,v in ipairs(old_trainparts) do
		table.insert(train.trainparts, 1, v)--notice insertion at first place
	end
	advtrains.update_trainpart_properties(train_id, true)
	
	-- recalculate path
	advtrains.train_ensure_init(train_id, train)
	
	-- If interlocking present, check whether this train is in a section and then set as shunt move after reversion
	if advtrains.interlocking and train.il_sections and #train.il_sections > 0 then
		train.is_shunt = true
		train.speed_restriction = advtrains.SHUNT_SPEED_MAX
	else
		train.is_shunt = false
		train.speed_restriction = nil
	end
end

-- returns: train id, index of one of the trains that stand at this position.
function advtrains.get_train_at_pos(pos)
	local t = advtrains.occ.get_trains_at(pos)
	for tid,idx in pairs(t) do
		return tid, idx
	end
end


-- ehm... I never adapted this function to the new path system ?!
function advtrains.invalidate_all_paths(pos)
	local tab
	if pos then
		-- if position given, check occupation system
		tab = advtrains.occ.get_trains_over(pos)
	else
		tab = advtrains.trains
	end
	
	for id, _ in pairs(tab) do
		advtrains.invalidate_path(id)
	end
end
function advtrains.invalidate_path(id)
	--atdebug("Path invalidate:",id)
	local v=advtrains.trains[id]
	if not v then return end
	advtrains.path_invalidate(v)
	advtrains.couple_invalidate(v)
	v.dirty = true
end

--not blocking trains group
function advtrains.train_collides(node)
	if node and minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].walkable then
		if not minetest.registered_nodes[node.name].groups.not_blocking_trains then
			return true
		end
	end
	return false
end

local nonblocknodes={
	"default:fence_wood",
	"default:fence_acacia_wood",
	"default:fence_aspen_wood",
	"default:fence_pine_wood",
	"default:fence_junglewood",
	"default:torch",
	"bones:bones",
	
	"default:sign_wall",
	"signs:sign_wall",
	"signs:sign_wall_blue",
	"signs:sign_wall_brown",
	"signs:sign_wall_orange",
	"signs:sign_wall_green",
	"signs:sign_yard",
	"signs:sign_wall_white_black",
	"signs:sign_wall_red",
	"signs:sign_wall_white_red",
	"signs:sign_wall_yellow",
	"signs:sign_post",
	"signs:sign_hanging",
	
	
}
minetest.after(0, function()
	for _,name in ipairs(nonblocknodes) do
		if minetest.registered_nodes[name] then
			minetest.registered_nodes[name].groups.not_blocking_trains=1
		end
	end
end)

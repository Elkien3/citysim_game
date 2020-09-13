
--[[
Advanced Trains - Minetest Mod

Copyright (C) 2016-2020  Moritz Blei (orwell96) and contributors

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as
    published by the Free Software Foundation, either version 3 of the
    License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

]]

local lot = os.clock()
minetest.log("action", "[advtrains] Loading...")

-- There is no need to support 0.4.x anymore given that the compatitability with it is already broken by 1bb1d825f46af3562554c12fba35a31b9f7973ff
attrans = minetest.get_translator ("advtrains")

--advtrains

DUMP_DEBUG_SAVE = false
GENERATE_ATRICIFIAL_LAG = false

--Constant for maximum connection value/division of the circle
AT_CMAX = 16

advtrains = {trains={}, player_to_train_mapping={}}

-- get wagon loading range
advtrains.wagon_load_range = tonumber(minetest.settings:get("advtrains_wagon_load_range"))
if not advtrains.wagon_load_range then
	advtrains.wagon_load_range = tonumber(minetest.settings:get("active_block_range"))*16
end

--pcall
local no_action=false

local function reload_saves()
	atwarn("Restoring saved state in 1 second...")
	no_action=true
	advtrains.lock_path_inval = false
	--read last save state and continue, as if server was restarted
	for aoi, le in pairs(minetest.luaentities) do
		if le.is_wagon then
			le.object:remove()
		end
	end
	minetest.after(1, function()
		advtrains.load()
		atwarn("Reload successful!")
		advtrains.ndb.restore_all()
	end)
end

function advtrains.pcall(fun)
	if no_action then return end
	
	local succ, return1, return2, return3, return4=xpcall(fun, function(err)
			atwarn("Lua Error occured: ", err)
			atwarn(debug.traceback())
			if advtrains.atprint_context_tid then
				advtrains.path_print(advtrains.trains[advtrains.atprint_context_tid], atdebug)
				atwarn(advtrains.trains[advtrains.atprint_context_tid].debug)
			end
		end)
	if not succ then
		reload_saves()
	else
		return return1, return2, return3, return4
	end
end


advtrains.modpath = minetest.get_modpath("advtrains")

--Advtrains dump (special treatment of pos and sigd)
function atdump(t, intend)
	local str
	if type(t)=="table" then
		if t.x and t.y and t.z then
			str=minetest.pos_to_string(t)
		elseif t.p and t.s then -- interlocking sigd
			str="S["..minetest.pos_to_string(t.p).."/"..t.s.."]"
		elseif advtrains.lines and t.s and t.m then -- RwT
			str=advtrains.lines.rwt.to_string(t)
		else
			str="{"
			local intd = (intend or "") .. "  "
			for k,v in pairs(t) do
				if type(k)~="string" or not string.match(k, "^path[_]?") then
					-- do not print anything path-related
					str = str .. "\n" .. intd .. atdump(k, intd) .. " = " ..atdump(v, intd)
				end
			end
			str = str .. "\n" .. (intend or "") .. "}"
		end
	elseif type(t)=="boolean" then
		if t then
			str="true"
		else
			str="false"
		end
	elseif type(t)=="function" then
		str="<function>"
	elseif type(t)=="userdata" then
		str="<userdata>"
	else
		str=""..t
	end
	return str
end

function advtrains.print_concat_table(a)
	local str=""
	local stra=""
	local t
	for i=1,20 do
		t=a[i]
		if t==nil then
			stra=stra.."nil "
		else
			str=str..stra
			stra=""
			str=str..atdump(t).." "
		end
	end
	return str
end

atprint=function() end
atlog=function(t, ...)
	local text=advtrains.print_concat_table({t, ...})
	minetest.log("action", "[advtrains]"..text)
end
atwarn=function(t, ...)
	local text=advtrains.print_concat_table({t, ...})
	minetest.log("warning", "[advtrains]"..text)
	minetest.chat_send_all("[advtrains] -!- "..text)
end
sid=function(id) if id then return string.sub(id, -6) end end


--ONLY use this function for temporary debugging. for consistent debug prints use atprint
atdebug=function(t, ...)
	local text=advtrains.print_concat_table({t, ...})
	minetest.log("action", "[advtrains]"..text)
	minetest.chat_send_all("[advtrains]"..text)
end

if minetest.settings:get_bool("advtrains_enable_debugging") then
	atprint=function(t, ...)
		local context=advtrains.atprint_context_tid or ""
		if not context then return end
		local text=advtrains.print_concat_table({t, ...})
		advtrains.drb_record(context, text)
		
		--atlog("@@",advtrains.atprint_context_tid,t,...)
	end
	dofile(advtrains.modpath.."/debugringbuffer.lua")
	
end

function assertt(var, typ)
	if type(var)~=typ then
		error("Assertion failed, variable has to be of type "..typ)
	end
end

dofile(advtrains.modpath.."/helpers.lua");
--dofile(advtrains.modpath.."/debugitems.lua");

advtrains.meseconrules = 
{{x=0,  y=0,  z=-1},
 {x=1,  y=0,  z=0},
 {x=-1, y=0,  z=0},
 {x=0,  y=0,  z=1},
 {x=1,  y=1,  z=0},
 {x=1,  y=-1, z=0},
 {x=-1, y=1,  z=0},
 {x=-1, y=-1, z=0},
 {x=0,  y=1,  z=1},
 {x=0,  y=-1, z=1},
 {x=0,  y=1,  z=-1},
 {x=0,  y=-1, z=-1},
 {x=0, y=-2, z=0}}

advtrains.fpath=minetest.get_worldpath().."/advtrains"

dofile(advtrains.modpath.."/path.lua")
dofile(advtrains.modpath.."/trainlogic.lua")
dofile(advtrains.modpath.."/trainhud.lua")
dofile(advtrains.modpath.."/trackplacer.lua")
dofile(advtrains.modpath.."/copytool.lua")
dofile(advtrains.modpath.."/tracks.lua")
dofile(advtrains.modpath.."/occupation.lua")
dofile(advtrains.modpath.."/atc.lua")
dofile(advtrains.modpath.."/wagons.lua")
dofile(advtrains.modpath.."/protection.lua")

dofile(advtrains.modpath.."/trackdb_legacy.lua")
dofile(advtrains.modpath.."/nodedb.lua")
dofile(advtrains.modpath.."/couple.lua")

dofile(advtrains.modpath.."/signals.lua")
dofile(advtrains.modpath.."/misc_nodes.lua")
dofile(advtrains.modpath.."/crafting.lua")
dofile(advtrains.modpath.."/craft_items.lua")

dofile(advtrains.modpath.."/log.lua")
dofile(advtrains.modpath.."/passive.lua")
if mesecon then
	dofile(advtrains.modpath.."/p_mesecon_iface.lua")
end


dofile(advtrains.modpath.."/lzb.lua")


--load/save

-- backup variables, used if someone should accidentally delete a sub-mod
local MDS_interlocking, MDS_lines


advtrains.fpath=minetest.get_worldpath().."/advtrains"
dofile(advtrains.modpath.."/log.lua")
function advtrains.read_component(name)
	local path = advtrains.fpath.."_"..name
	minetest.log("action", "[advtrains] loading "..path)
	local file, err = io.open(path, "r")
	if not file then
		minetest.log("warning", " Failed to read advtrains save data from file "..path..": "..(err or "Unknown Error"))
		minetest.log("warning", " (this is normal when first enabling advtrains on this world)")
		return
	end
	local tbl =  minetest.deserialize(file:read("*a"))
	file:close()
	return tbl
end

function advtrains.avt_load()
	-- check for new, split advtrains save file
	
	local version = advtrains.read_component("version")
	local tbl
	if version and version == 3 then
		-- we are dealing with the new, split-up system
		minetest.log("action", "[advtrains] loading savefiles version 3")
		local il_save = {
			tcbs = true,
			ts = true,
			signalass = true,
			rs_locks = true,
			rs_callbacks = true,
			influence_points = true,
			npr_rails = true,
		}
		tbl={
			trains = true,
			wagon_save = true,
			ptmap = true,
			atc = true,
			ndb = true,		
			lines = true,
			version = 2,
		}
		for i,k in pairs(il_save) do
			il_save[i] = advtrains.read_component("interlocking_"..i)
		end
		for i,k in pairs(tbl) do
			tbl[i] = advtrains.read_component(i)
		end
		tbl["interlocking"] = il_save
	else	
		local file, err = io.open(advtrains.fpath, "r")
		if not file then
			minetest.log("warning", " Failed to read advtrains save data from file "..advtrains.fpath..": "..(err or "Unknown Error"))
			minetest.log("warning", " (this is normal when first enabling advtrains on this world)")
			return
		else
			tbl = minetest.deserialize(file:read("*a"))
			file:close()
		end
	end
	if type(tbl) == "table" then
		if tbl.version then
			--congrats, we have the new save format.
			advtrains.trains = tbl.trains
			--Save the train id into the train table to avoid having to pass id around
			for id, train in pairs(advtrains.trains) do
				train.id = id
			end
			advtrains.wagons = tbl.wagon_save
			advtrains.player_to_train_mapping = tbl.ptmap or {}
			advtrains.ndb.load_data(tbl.ndb)
			advtrains.atc.load_data(tbl.atc)
			if advtrains.interlocking then
				advtrains.interlocking.db.load(tbl.interlocking)
			else
				MDS_interlocking = tbl.interlocking
			end
			if advtrains.lines then
				advtrains.lines.load(tbl.lines)
			else
				MDS_lines = tbl.lines
			end
			--remove wagon_save entries that are not part of a train
			local todel=advtrains.merge_tables(advtrains.wagon_save)
			for tid, train in pairs(advtrains.trains) do
				train.id = tid
				for _, wid in ipairs(train.trainparts) do
					todel[wid]=nil
				end
			end
			for wid, _ in pairs(todel) do
				atwarn("Removing unused wagon", wid, "from wagon_save table.")
				advtrains.wagon_save[wid]=nil
			end
		else
			--oh no, its the old one...
			advtrains.trains=tbl
			--load ATC
			advtrains.fpath_atc=minetest.get_worldpath().."/advtrains_atc"
			local file, err = io.open(advtrains.fpath_atc, "r")
			if not file then
				local er=err or "Unknown Error"
				atprint("Failed loading advtrains atc save file "..er)
			else
				local tbl = minetest.deserialize(file:read("*a"))
				if type(tbl) == "table" then
					advtrains.atc.controllers=tbl.controllers
				end
				file:close()
			end
			--load wagon saves
			advtrains.fpath_ws=minetest.get_worldpath().."/advtrains_wagon_save"
			local file, err = io.open(advtrains.fpath_ws, "r")
			if not file then
				local er=err or "Unknown Error"
				atprint("Failed loading advtrains save file "..er)
			else
				local tbl = minetest.deserialize(file:read("*a"))
				if type(tbl) == "table" then
					advtrains.wagon_save=tbl
				end
				file:close()
			end
		end
	else
		minetest.log("error", " Failed to deserialize advtrains save data: Not a table!")
	end
end

advtrains.save_component = function (tbl, name)
	-- Saves each component of the advtrains file separately
	--
	-- required for now to shrink the advtrains db to overcome lua
	-- limitations.
	local datastr = minetest.serialize(tbl)
	if not datastr then
		minetest.log("error", " Failed to serialize advtrains save data!")
		return
	end
	local path = advtrains.fpath.."_"..name
	local success = minetest.safe_file_write(path, datastr)
	
	if not success then
		minetest.log("error", " Failed to write advtrains save data to file "..path)
	end
	
end

advtrains.avt_save = function(remove_players_from_wagons)
	--atprint("saving")
	
	if remove_players_from_wagons then
		for w_id, data in pairs(advtrains.wagons) do
			data.seatp={}
		end
		advtrains.player_to_train_mapping={}
	end
	
	local tmp_trains={}
	for id, train in pairs(advtrains.trains) do
		--first, deep_copy the train
		if #train.trainparts > 0 then
			local v=advtrains.save_keys(train, {
				"last_pos", "last_connid", "last_frac", "velocity", "tarvelocity",
				"trainparts", "recently_collided_with_env",
				"atc_brake_target", "atc_wait_finish", "atc_command", "atc_delay", "door_open",
				"text_outside", "text_inside", "line", "routingcode",
				"il_sections", "speed_restriction", "is_shunt", "points_split", "autocouple"
			})
			--then save it
			tmp_trains[id]=v
		else
			atwarn("Train",id,"had no wagons left because of some bug. It is being deleted. Wave it goodbye!")
			advtrains.remove_train(id)
		end
	end
	
	for id, wdata in pairs(advtrains.wagons) do
		local _,proto = advtrains.get_wagon_prototype(wdata)
		if proto.has_inventory then
			local inv=minetest.get_inventory({type="detached", name="advtrains_wgn_"..id})
			if inv then -- inventory is not initialized when wagon was never loaded
				-- TOOD: What happens with unloading rails when they don't find the inventory?
				wdata.ser_inv=advtrains.serialize_inventory(inv)
			end
		end
		-- TODO apply save-keys here too
		-- TODO temp
		wdata.dcpl_lock = nil
	end
	
	--versions:
	-- 1 - Initial new save format.
	-- 2 - version as of tss branch 11-2018+
	local il_save
	if advtrains.interlocking then
		il_save = advtrains.interlocking.db.save()
	else
		il_save = MDS_interlocking
	end
	local ln_save
	if advtrains.lines then
		ln_save = advtrains.lines.save()
	else
		ln_save = MDS_lines
	end

	local save_tbl={
		trains = tmp_trains,
		wagon_save = advtrains.wagons,
		ptmap = advtrains.player_to_train_mapping,
		atc = advtrains.atc.save_data(),
		ndb = advtrains.ndb.save_data(),
		lines = ln_save,
		version = 3,
	}
	for i,k in pairs(save_tbl) do
		advtrains.save_component(k,i)
	end
	
	for i,k in pairs(il_save) do
		advtrains.save_component(k,"interlocking_"..i)
	end
	
	if DUMP_DEBUG_SAVE then
		local file, err = io.open(advtrains.fpath.."_DUMP", "w")
		if err then
			return
		end
		file:write(dump(save_tbl))
		file:close()
	end
end

--## MAIN LOOP ##--
--Calls all subsequent main tasks of both advtrains and atlatc
local init_load=false
local save_interval=20
local save_timer=save_interval
advtrains.mainloop_runcnt=0


local t = 0
minetest.register_globalstep(function(dtime_mt)
	return advtrains.pcall(function()
		advtrains.mainloop_runcnt=advtrains.mainloop_runcnt+1
		--atprint("Running the main loop, runcnt",advtrains.mainloop_runcnt)
		--call load once. see advtrains.load() comment
		if not init_load then
			advtrains.load()
		end
		
		local dtime
		if GENERATE_ATRICIFIAL_LAG then
			dtime = 0.2
			if os.clock()<t then
				return
			end
			
			t = os.clock()+0.2
		else
			--limit dtime: if trains move too far in one step, automation may cause stuck and wrongly braking trains
			dtime=dtime_mt
			if dtime>0.2 then
				atprint("Limiting dtime to 0.2!")
				dtime=0.2
			end
		end
		
		advtrains.mainloop_trainlogic(dtime)
		if advtrains_itm_mainloop then
			advtrains_itm_mainloop(dtime)
		end
		if atlatc then
			atlatc.mainloop_stepcode(dtime)
			atlatc.interrupt.mainloop(dtime)
		end
		if advtrains.lines then
			advtrains.lines.step(dtime)
		end
		
		--trigger a save when necessary
		save_timer=save_timer-dtime
		if save_timer<=0 then
			local t=os.clock()
			--save
			advtrains.save()
			save_timer=save_interval
			atprintbm("saving", t)
		end
	end)
end)

--if something goes wrong in these functions, there is no help. no pcall here.

--## MAIN LOAD ROUTINE ##
-- Causes the loading of everything
-- first time called in main loop (after the init phase) because luaautomation has to initialize first.
function advtrains.load()
	advtrains.avt_load() --loading advtrains. includes ndb at advtrains.ndb.load_data()
	if atlatc then
		atlatc.load() --includes interrupts
	end
	if advtrains_itm_init then
		advtrains_itm_init()
	end
	init_load=true
	no_action=false
	atlog("[load_all]Loaded advtrains save files")
end

--## MAIN SAVE ROUTINE ##
-- Causes the saving of everything
function advtrains.save(remove_players_from_wagons)
	if not init_load then
		--wait... we haven't loaded yet?!
		atwarn("Instructed to save() but load() was never called!")
		return
	end
	advtrains.avt_save(remove_players_from_wagons) --saving advtrains. includes ndb at advtrains.ndb.save_data()
	if atlatc then
		atlatc.save()
	end
	atprint("[save_all]Saved advtrains save files")
	
	--TODO very simple yet hacky workaround for the "green signals" bug
	advtrains.invalidate_all_paths()
end
minetest.register_on_shutdown(advtrains.save)

-- This chat command provides a solution to the problem known on the LinuxWorks server
-- There are many players that joined a single time, got on a train and then left forever
-- These players still occupy seats in the trains.
minetest.register_chatcommand("at_empty_seats",
	{
        params = "", -- Short parameter description
        description = "Detach all players, especially the offline ones, from all trains. Use only when no one serious is on a train.", -- Full description
        privs = {train_operator=true, server=true}, -- Require the "privs" privilege to run
        func = function(name, param)
			return advtrains.pcall(function()
				atwarn("Data is being saved. While saving, advtrains will remove the players from trains. Save files will be reloaded afterwards!")
				advtrains.save(true)
				reload_saves()
			end)
        end,
})
-- This chat command solves another problem: Trains getting randomly stuck.
minetest.register_chatcommand("at_reroute",
	{
        params = "", 
        description = "Delete all train routes, force them to recalculate", 
        privs = {train_operator=true}, -- Only train operator is required, since this is relatively safe.
        func = function(name, param)
			return advtrains.pcall(function()
				advtrains.invalidate_all_paths()
				return true, "Successfully invalidated train routes"
			end)
        end,
})


local tot=(os.clock()-lot)*1000
minetest.log("action", "[advtrains] Loaded in "..tot.."ms")


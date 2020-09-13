-- stoprail.lua
-- adds "stop rail". Recognized by lzb. (part of behavior is implemented there)


local function to_int(n)
	--- Disallow floating-point numbers
	local k = tonumber(n)
	if k then
		return math.floor(k)
	end
end

local function updatemeta(pos)
	local meta = minetest.get_meta(pos)
	local pe = advtrains.encode_pos(pos)
	local stdata = advtrains.lines.stops[pe]
	if not stdata then
		meta:set_string("infotext", "Error")
	end
	
	meta:set_string("infotext", "Stn. "..stdata.stn.." T. "..stdata.track)
end

local door_dropdown = {L=1, R=2, C=3}
local door_dropdown_rev = {Right="R", Left="L", Closed="C"}

local function show_stoprailform(pos, player)
	local pe = advtrains.encode_pos(pos)
	local pname = player:get_player_name()
	if minetest.is_protected(pos, pname) then
		minetest.chat_send_player(pname, "Position is protected!")
		return
	end
	
	local stdata = advtrains.lines.stops[pe]
	if not stdata then
		advtrains.lines.stops[pe] = {
					stn="", track="", doors="R", wait=10, ars={default=true}, ddelay=1,speed="M"
				}
		stdata = advtrains.lines.stops[pe]
	end
	
	local stn = advtrains.lines.stations[stdata.stn]
	local stnname = stn and stn.name or ""
	if not stdata.ddelay then
		stdata.ddelay = 1
	end
	if not stdata.speed then
		stdata.speed = "M"
	end
	
	local form = "size[8,7]"
	form = form.."field[0.5,0.5;7,1;stn;"..attrans("Station Code")..";"..minetest.formspec_escape(stdata.stn).."]"
	form = form.."field[0.5,1.5;7,1;stnname;"..attrans("Station Name")..";"..minetest.formspec_escape(stnname).."]"
	form = form.."field[0.5,2.5;2,1;ddelay;"..attrans("Door Delay")..";"..minetest.formspec_escape(stdata.ddelay).."]"
	form = form.."field[3,2.5;3,1;speed;"..attrans("Departure Speed")..";"..minetest.formspec_escape(stdata.speed).."]"	
	form = form.."label[0.5,3;Door side:]"
	form = form.."dropdown[0.5,3;2;doors;Left,Right,Closed;"..door_dropdown[stdata.doors].."]"
	form = form.."dropdown[3,3;1.5;reverse;---,Reverse;"..(stdata.reverse and 2 or 1).."]"
	
	form = form.."field[5,3.5;2,1;track;"..attrans("Track")..";"..minetest.formspec_escape(stdata.track).."]"
	form = form.."field[5,4.5;2,1;wait;"..attrans("Stop Time")..";"..stdata.wait.."]"
	
	form = form.."textarea[0.5,4;4,2;ars;Trains stopping here (ARS rules);"..advtrains.interlocking.ars_to_text(stdata.ars).."]"
	
	form = form.."button[0.5,6;7,1;save;"..attrans("Save").."]"
	
	minetest.show_formspec(pname, "at_lines_stop_"..pe, form)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local pname = player:get_player_name()
	local pe = string.match(formname, "^at_lines_stop_(............)$")
	local pos = advtrains.decode_pos(pe)
	if pos then
		if minetest.is_protected(pos, pname) then
			minetest.chat_send_player(pname, "Position is protected!")
			return
		end
		
		local stdata = advtrains.lines.stops[pe]
		if fields.save then
			if fields.stn and stdata.stn ~= fields.stn then
				if fields.stn ~= "" then
					local stn = advtrains.lines.stations[fields.stn]
					if stn then
						if (stn.owner == pname or minetest.check_player_privs(pname, "train_admin")) then
							stdata.stn = fields.stn
						else
							minetest.chat_send_player(pname, "Station code '"..fields.stn.."' does already exist and is owned by "..stn.owner)
						end
					else
						advtrains.lines.stations[fields.stn] = {name = fields.stnname, owner = pname}
						stdata.stn = fields.stn
					end
				end
				updatemeta(pos)
				show_stoprailform(pos, player)
				return
			end
			local stn = advtrains.lines.stations[stdata.stn]
			if stn and fields.stnname and fields.stnname ~= stn.name then
				if (stn.owner == pname or minetest.check_player_privs(pname, "train_admin")) then
					stn.name = fields.stnname
				else
					minetest.chat_send_player(pname, "Not allowed to edit station name, owned by "..stn.owner)
				end
			end
			
			-- dropdowns
			if fields.doors then
				stdata.doors = door_dropdown_rev[fields.doors] or "C"
			end
			if fields.reverse then
				stdata.reverse = fields.reverse == "Reverse"
			end
			
			
			if fields.track then
				stdata.track = fields.track
			end
			if fields.wait then
				stdata.wait = to_int(fields.wait) or 10
			end
			
			if fields.ars then
				stdata.ars = advtrains.interlocking.text_to_ars(fields.ars)
			end

			if fields.ddelay then
				stdata.ddelay = to_int(fields.ddelay) or 1
			end
			if fields.speed then
				stdata.speed = to_int(fields.speed) or "M"
			end
			
			--TODO: signal
			updatemeta(pos)
			show_stoprailform(pos, player)
		end
	end			
	
end)


local adefunc = function(def, preset, suffix, rotation)
		return {
			after_place_node=function(pos)
				local pe = advtrains.encode_pos(pos)
				advtrains.lines.stops[pe] = {
					stn="", track="", doors="R", wait=10
				}
				updatemeta(pos)
			end,
			after_dig_node=function(pos)
				local pe = advtrains.encode_pos(pos)
				advtrains.lines.stops[pe] = nil
			end,
			on_rightclick = function(pos, node, player)
				show_stoprailform(pos, player)
			end,
			advtrains = {
				on_train_approach = function(pos,train_id, train, index)
					if train.path_cn[index] == 1 then
						local pe = advtrains.encode_pos(pos)
						local stdata = advtrains.lines.stops[pe]
						if stdata and stdata.stn then
						
							--TODO REMOVE AFTER SOME TIME (only migration)
							if not stdata.ars then
								stdata.ars = {default=true}
							end
							if stdata.ars and (stdata.ars.default or advtrains.interlocking.ars_check_rule_match(stdata.ars, train) ) then
								advtrains.lzb_add_checkpoint(train, index, 2, nil)
								local stn = advtrains.lines.stations[stdata.stn]
								local stnname = stn and stn.name or "Unknown Station"
								train.text_inside = "Next Stop:\n"..stnname
							end
						end
					end
				end,
				on_train_enter = function(pos, train_id, train, index)
					if train.path_cn[index] == 1 then
						local pe = advtrains.encode_pos(pos)
						local stdata = advtrains.lines.stops[pe]
						if not stdata then
							return
						end
						
						if stdata.ars and (stdata.ars.default or advtrains.interlocking.ars_check_rule_match(stdata.ars, train) ) then
							local stn = advtrains.lines.stations[stdata.stn]
							local stnname = stn and stn.name or "Unknown Station"
							
							-- Send ATC command and set text
							advtrains.atc.train_set_command(train, "B0 W O"..stdata.doors.." D"..stdata.wait.." OC "..(stdata.reverse and "R" or "").."D"..(stdata.ddelay or 1) .. "S" ..(stdata.speed or "M"), true)
							train.text_inside = stnname
							if tonumber(stdata.wait) then
								minetest.after(tonumber(stdata.wait), function() train.text_inside = "" end)
							end
						end
					end
				end
			},
		}
end

if minetest.get_modpath("advtrains_train_track") ~= nil then
	advtrains.register_tracks("default", {
		nodename_prefix="advtrains_line_automation:dtrack_stop",
		texture_prefix="advtrains_dtrack_stop",
		models_prefix="advtrains_dtrack",
		models_suffix=".b3d",
		shared_texture="advtrains_dtrack_shared_stop.png",
		description="Station/Stop Rail",
		formats={},
		get_additional_definiton = adefunc,
	}, advtrains.trackpresets.t_30deg_straightonly)
end
--atc.lua
--registers and controls the ATC system

local atc={}

local eval_conditional

-- ATC persistence table. advtrains.atc is created by init.lua when it loads the save file.
atc.controllers = {}
function atc.load_data(data)
	local temp = data and data.controllers or {}
	--transcode atc controller data to node hashes: table access times for numbers are far less than for strings
	for pts, data in pairs(temp) do
		if type(pts)=="number" then
			pts=minetest.pos_to_string(minetest.get_position_from_hash(pts))
		end
		atc.controllers[pts] = data
	end
end
function atc.save_data()
	return {controllers = atc.controllers}
end
--contents: {command="...", arrowconn=0-15 where arrow points}

--general
function atc.train_set_command(train, command, arrow)
	atc.train_reset_command(train, true)
	train.atc_delay = 0
	train.atc_arrow = arrow
	train.atc_command = command
end

function atc.send_command(pos, par_tid)
	local pts=minetest.pos_to_string(pos)
	if atc.controllers[pts] then
		--atprint("Called send_command at "..pts)
		local train_id = par_tid or advtrains.get_train_at_pos(pos)
		if train_id then
			if advtrains.trains[train_id] then
				--atprint("send_command inside if: "..sid(train_id))
				if atc.controllers[pts].arrowconn then
					atlog("ATC controller at",pts,": This controller had an arrowconn of", atc.controllers[pts].arrowconn, "set. Since this field is now deprecated, it was removed.")
					atc.controllers[pts].arrowconn = nil
				end
				
				local train = advtrains.trains[train_id]
				local index = advtrains.path_lookup(train, pos)
				
				local iconnid = 1
				if index then
					iconnid = train.path_cn[index]
				else
					atwarn("ATC rail at", pos, ": Rail not on train's path! Can't determine arrow direction. Assuming +!")
				end
				
				local command = atc.controllers[pts].command				
				command = eval_conditional(command, iconnid==1, train.velocity)
				if not command then command="" end
				command=string.match(command, "^%s*(.*)$")
				
				if command == "" then
					atprint("Sending ATC Command to", train_id, ": Not modifying, conditional evaluated empty.")
					return true
				end
				
				atc.train_set_command(train, command, iconnid==1)
				atprint("Sending ATC Command to", train_id, ":", command, "iconnid=",iconnid)
				return true
				
			else
				atwarn("ATC rail at", pos, ": Sending command failed: The train",train_id,"does not exist. This seems to be a bug.")
			end
		else
			atwarn("ATC rail at", pos, ": Sending command failed: There's no train at this position. This seems to be a bug.")
		end
	else
		atwarn("ATC rail at", pos, ": Sending command failed: Entry for controller not found.")
		atwarn("ATC rail at", pos, ": Please visit controller and click 'Save'")
	end
	return false
end

-- Resets any ATC commands the train is currently executing, including the target speed (tarvelocity) it is instructed to hold
-- if keep_tarvel is set, does not clear the tarvelocity
function atc.train_reset_command(train, keep_tarvel)
	train.atc_command=nil
	train.atc_delay=nil
	train.atc_brake_target=nil
	train.atc_wait_finish=nil
	train.atc_arrow=nil
	if not keep_tarvel then
		train.tarvelocity=nil
	end
end

--nodes
local idxtrans={static=1, mesecon=2, digiline=3}
local apn_func=function(pos)
	-- FIX for long-persisting ndb bug: there's no node in parameter 2 of this function!
	local meta=minetest.get_meta(pos)
	if meta then
		meta:set_string("infotext", attrans("ATC controller, unconfigured."))
		meta:set_string("formspec", atc.get_atc_controller_formspec(pos, meta))
	end
end

advtrains.atc_function = function(def, preset, suffix, rotation)
		return {
			after_place_node=apn_func,
			after_dig_node=function(pos)
				return advtrains.pcall(function()
					advtrains.invalidate_all_paths(pos)
					advtrains.ndb.clear(pos)
					local pts=minetest.pos_to_string(pos)
					atc.controllers[pts]=nil
				end)
			end,
			on_receive_fields = function(pos, formname, fields, player)
				return advtrains.pcall(function()
					if advtrains.is_protected(pos, player:get_player_name()) then
						minetest.record_protection_violation(pos, player:get_player_name())
						return
					end
					local meta=minetest.get_meta(pos)
					if meta then
						if not fields.save then 
							--maybe only the dropdown changed
							if fields.mode then
								meta:set_string("mode", idxtrans[fields.mode])
								if fields.mode=="digiline" then
									meta:set_string("infotext", attrans("ATC controller, mode @1\nChannel: @2", (fields.mode or "?"), meta:get_string("command")) )
								else
									meta:set_string("infotext", attrans("ATC controller, mode @1\nCommand: @2", (fields.mode or "?"), meta:get_string("command")) )
								end
								meta:set_string("formspec", atc.get_atc_controller_formspec(pos, meta))
							end
							return
						end
						meta:set_string("mode", idxtrans[fields.mode])
						meta:set_string("command", fields.command)
						meta:set_string("command_on", fields.command_on)
						meta:set_string("channel", fields.channel)
						if fields.mode=="digiline" then
							meta:set_string("infotext", attrans("ATC controller, mode @1\nChannel: @2", (fields.mode or "?"), meta:get_string("command")) )
						else
							meta:set_string("infotext", attrans("ATC controller, mode @1\nCommand: @2", (fields.mode or "?"), meta:get_string("command")) )
						end
						meta:set_string("formspec", atc.get_atc_controller_formspec(pos, meta))
						
						local pts=minetest.pos_to_string(pos)
						local _, conns=advtrains.get_rail_info_at(pos, advtrains.all_tracktypes)
						atc.controllers[pts]={command=fields.command}
						if #advtrains.occ.get_trains_at(pos) > 0 then
							atc.send_command(pos)
						end
					end
				end)
			end,
			advtrains = {
				on_train_enter = function(pos, train_id)
					atc.send_command(pos)
				end,
			},
		}
end

function atc.get_atc_controller_formspec(pos, meta)
	local mode=tonumber(meta:get_string("mode")) or 1
	local command=meta:get_string("command")
	local command_on=meta:get_string("command_on")
	local channel=meta:get_string("channel")
	local formspec="size[8,6]"
	--	"dropdown[0,0;3;mode;static,mesecon,digiline;"..mode.."]"
	if mode<3 then
		formspec=formspec.."field[0.5,1.5;7,1;command;"..attrans("Command")..";"..minetest.formspec_escape(command).."]"
		if tonumber(mode)==2 then
			formspec=formspec.."field[0.5,3;7,1;command_on;"..attrans("Command (on)")..";"..minetest.formspec_escape(command_on).."]"
		end
	else
		formspec=formspec.."field[0.5,1.5;7,1;channel;"..attrans("Digiline channel")..";"..minetest.formspec_escape(channel).."]"
	end
	return formspec.."button_exit[0.5,4.5;7,1;save;"..attrans("Save").."]"
end

--from trainlogic.lua train step
local matchptn={
	["SM"]=function(id, train)
		train.tarvelocity=train.max_speed
		return 2
	end,
	["S([0-9]+)"]=function(id, train, match)
		train.tarvelocity=tonumber(match)
		return #match+1
	end,
	["B([0-9]+)"]=function(id, train, match)
		if train.velocity>tonumber(match) then
			train.atc_brake_target=tonumber(match)
			if not train.tarvelocity or train.tarvelocity>train.atc_brake_target then
				train.tarvelocity=train.atc_brake_target
			end
		end
		return #match+1
	end,
	["BB"]=function(id, train)
		train.atc_brake_target = -1
		train.tarvelocity = 0
		return 2
	end,
	["W"]=function(id, train)
		train.atc_wait_finish=true
		return 1
	end,
	["D([0-9]+)"]=function(id, train, match)
		train.atc_delay=tonumber(match)
		return #match+1
	end,
	["R"]=function(id, train)
		if train.velocity<=0 then
			advtrains.invert_train(id)
			advtrains.train_ensure_init(id, train)
			-- no one minds if this failed... this shouldn't even be called without train being initialized...
		else
			atwarn(sid(id), attrans("ATC Reverse command warning: didn't reverse train, train moving!"))
		end
		return 1
	end,
	["O([LRC])"]=function(id, train, match)
		local tt={L=-1, R=1, C=0}
		local arr=train.atc_arrow and 1 or -1
		train.door_open = tt[match]*arr
		return 2
	end,
}

eval_conditional = function(command, arrow, speed)
	--conditional statement?
	local is_cond, cond_applies, compare
	local cond, rest=string.match(command, "^I([%+%-])(.+)$")
	if cond then
		is_cond=true
		if cond=="+" then
			cond_applies=arrow
		end
		if cond=="-" then
			cond_applies=not arrow
		end
	else 
		cond, compare, rest=string.match(command, "^I([<>]=?)([0-9]+)(.+)$")
		if cond and compare then
			is_cond=true
			if cond=="<" then
				cond_applies=speed<tonumber(compare)
			end
			if cond==">" then
				cond_applies=speed>tonumber(compare)
			end
			if cond=="<=" then
				cond_applies=speed<=tonumber(compare)
			end
			if cond==">=" then
				cond_applies=speed>=tonumber(compare)
			end
		end
	end	
	if is_cond then
		atprint("Evaluating if statement: "..command)
		atprint("Cond: "..(cond or "nil"))
		atprint("Applies: "..(cond_applies and "true" or "false"))
		atprint("Rest: "..rest)
		--find end of conditional statement
		local nest, pos, elsepos=0, 1
		while nest>=0 do
			if pos>#rest then
				atwarn(sid(id), attrans("ATC command syntax error: I statement not closed: @1",command))
				return ""
			end
			local char=string.sub(rest, pos, pos)
			if char=="I" then
				nest=nest+1
			end
			if char==";" then
				nest=nest-1
			end
			if nest==0 and char=="E" then
				elsepos=pos+0
			end
			pos=pos+1
		end
		if not elsepos then elsepos=pos-1 end
		if cond_applies then
			command=string.sub(rest, 1, elsepos-1)..string.sub(rest, pos)
		else
			command=string.sub(rest, elsepos+1, pos-2)..string.sub(rest, pos)
		end
		atprint("Result: "..command)
	end
	return command
end

function atc.execute_atc_command(id, train)
	--strip whitespaces
	local command=string.match(train.atc_command, "^%s*(.*)$")
	
	
	if string.match(command, "^%s*$") then
		train.atc_command=nil
		return
	end

	train.atc_command = eval_conditional(command, train.atc_arrow, train.velocity)
	
	if not train.atc_command then return end
	command=string.match(train.atc_command, "^%s*(.*)$")
	
	if string.match(command, "^%s*$") then
		train.atc_command=nil
		return
	end
	
	for pattern, func in pairs(matchptn) do
		local match=string.match(command, "^"..pattern)
		if match then
			local patlen=func(id, train, match)
			
			atprint("Executing: "..string.sub(command, 1, patlen))
			
			train.atc_command=string.sub(command, patlen+1)
			if train.atc_delay<=0 and not train.atc_wait_finish then
				--continue (recursive, cmds shouldn't get too long, and it's a end-recursion.)
				atc.execute_atc_command(id, train)
			end
			return
		end
	end
	atwarn(sid(id), attrans("ATC command parse error: Unknown command: @1", command))
	atc.train_reset_command(train, true)
end



--move table to desired place
advtrains.atc=atc

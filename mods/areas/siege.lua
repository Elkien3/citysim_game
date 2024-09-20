local storage = minetest.get_mod_storage()
local siegetbl = minetest.deserialize(storage:get_string("siegetbl")) or {}
local time_to_cap = tonumber(minetest.settings:get("siege_time_to_cap")) or 60

local function save_sieges()
	storage:set_string("siegetbl", minetest.serialize(siegetbl))
end

function areas.get_unixhour(time)
	time = time or os.time()
	time = math.floor(time/3600)
	return time
end

function areas.siege_get(id)
	return siegetbl[tonumber(id)]
end

function areas.siege_create(id, unixhour, newowner)
	id = id and tonumber(id)
	if not id or not unixhour then return end
	if not areas:player_exists(newowner) then return end
	siegetbl[id] = {unixhour = unixhour, newowner = newowner, attackers = {}, defenders = {}, progress = 0}
	save_sieges()
	minetest.chat_send_all("A Siege has been started on area "..id.." (Owned by "..(areas.areas[id].owner)..")")
	if email then
		local oldOwner = areas.areas[id].owner
		oldOwner = (jobs and (jobs.list[jobs.split(oldOwner, ":")[1]] or {}).ceo) or oldOwner
		email.send_mail("[SERVER]", oldOwner, "A Siege has been started on area "..id)
	end
end

function areas.siege_add_player(id, name, defending)
	id = id and tonumber(id)
	if not id or not name or not siegetbl[id] then return end
	areas.siege_remove_player(id, name)
	if defending then
		siegetbl[id].defenders[name] = true
		
	else
		siegetbl[id].attackers[name] = true
	end
	save_sieges()
	return true
end

function areas.siege_get_player(id, name)
	id = id and tonumber(id)
	if not id or not name or not siegetbl[id] then return end
	if siegetbl[id].attackers[name] == true then
		return "attacker"
	elseif siegetbl[id].defenders[name] == true then
		return "defender"
	else
		return
	end
end

function areas.siege_remove_player(id, name)
	id = id and tonumber(id)
	if not id or not name or not siegetbl[id] then return end
	if areas.siege_get_player(id, name) then
		siegetbl[id].attackers[name] = nil
		siegetbl[id].defenders[name] = nil
		save_sieges()
		return true
	end
end

function areas.siege_remove(id)
	id = id and tonumber(id)
	if not id or not siegetbl[id] then return end
	siegetbl[id] = nil
	save_sieges()
	minetest.chat_send_all("A Siege has been removed on area "..id.." (Owned by "..(areas.areas[id].owner)..")")
	if email then
		local oldOwner = areas.areas[id].owner
		oldOwner = (jobs and (jobs.list[jobs.split(oldOwner, ":")[1]] or {}).ceo) or oldOwner
		email.send_mail("[SERVER]", oldOwner, "The siege on area "..id.." has been removed.")
	end
end

function areas.get_siege_infotext(id, name)
	id = id and tonumber(id)
	if not id or not name then return end
	local tbl = siegetbl[id]
	local playerteam = areas.siege_get_player(id, name)
	
	local currentunixhour = areas.get_unixhour()
	if currentunixhour > tbl.unixhour then
		return ""
	end
	
	local str = ""
	
	if currentunixhour ~= tbl.unixhour then
		str = str.."Siege in "..tostring(tbl.unixhour-currentunixhour).." Hour/s "
	else
		str = str.."Siege progress "..tostring(math.floor((tbl.progress/time_to_cap)*100)).."% "
	end
	
	if not playerteam then
		str = str.."/area_attack or /area_defend."
	elseif playerteam == "defender" then
		str = str.."defending, /area_leave to stop."
	elseif playerteam == "attacker" then
		str = str.."attacking, /area_leave to stop."
	end
	
	return str
end


local function siege_tick()
	local save = false
	local currentunixhour = areas.get_unixhour()
	for id, tbl in pairs(siegetbl) do
		if tbl.unixhour < currentunixhour then
			areas.siege_remove(id)
			minetest.chat_send_all("Siege of area "..id.." has failed.")
		elseif tbl.unixhour == currentunixhour then
			if not tbl.annoucement then
				minetest.chat_send_all("Siege of area "..id.." has started!")
				siegetbl[id].annoucement = true
				save = true
			end
			local attackers = false
			local defenders = false
			for _, player in pairs(minetest.get_connected_players()) do
				for id2, area in pairs(areas:getAreasAtPos(player:get_pos())) do
					if id == id2 then
						local name = player:get_player_name()
						playerteam = areas.siege_get_player(id, name)
						if playerteam and minetest.check_player_privs(name, {interact = true}) then
							if playerteam == "defender" then
								defenders = true
							elseif playerteam == "attacker" then
								attackers = true
							end
						end
						break
					end
					if attackers and defenders then break end
				end
				if attackers and defenders then break end
			end
			if attackers and not defenders then
				siegetbl[id].progress = tbl.progress + 1
				if siegetbl[id].progress >= time_to_cap then
					if not areas:player_exists(tbl.newowner) then
						minetest.chat_send_all("Siege of area "..id.." has failed, no such player '"..tbl.newowner.."'")
					else
						if email then
							local oldOwner = areas.areas[id].owner
							oldOwner = (jobs and (jobs.list[jobs.split(oldOwner, ":")[1]] or {}).ceo) or oldOwner
							email.send_mail("[SERVER]", oldOwner, "A Siege on area "..id.." was successful, the new owner is '"..tbl.newowner.."'")
						end
						areas.areas[id].owner = tbl.newowner
						areas:save()
						minetest.chat_send_all("Siege of area "..id.." has been successful! Owner is now "..tbl.newowner)
					end
					areas.siege_remove(id)
				end
				save = true
			elseif defenders and not attackers then
				siegetbl[id].progress = math.max(tbl.progress - 1, 0)
				save = true
			end
		end
	end
	if save then
		save_sieges()
	end
	minetest.after(1, siege_tick)
end
siege_tick()

minetest.register_chatcommand("area_attack", {
    params = "",
    description = "Join the attack on an area.",
    func = function(name, param)
		local success = false
		local player = minetest.get_player_by_name(name)
		if not player then return false, "Must be online" end
		local pos = player:get_pos()
		for id, area in pairs(areas:getAreasAtPos(pos)) do
			if areas.siege_add_player(id, name, false) then success = true end
		end
		if success then
			return true, "You are now attacker."
		else
			return false, "Failed to become attacker."
		end
    end
})

minetest.register_chatcommand("area_defend", {
    params = "",
    description = "Join the defense on an area.",
    func = function(name, param)
		local success = false
		local player = minetest.get_player_by_name(name)
		if not player then return false, "Must be online" end
		local pos = player:get_pos()
		for id, area in pairs(areas:getAreasAtPos(pos)) do
			if areas.siege_add_player(id, name, true) then success = true end
		end
		if success then
			return true, "You are now defender."
		else
			return false, "Failed to become defender."
		end
    end
})

minetest.register_chatcommand("area_leave", {
    params = "",
    description = "leave the siege of an area.",
    func = function(name, param)
		local success = false
		local player = minetest.get_player_by_name(name)
		if not player then return false, "Must be online" end
		local pos = player:get_pos()
		for id, area in pairs(areas:getAreasAtPos(pos)) do
			if areas.siege_remove_player(id, name) then success = true end
		end
		if success then
			return true, "You have left the siege."
		else
			return false, "Failed to leave the siege."
		end
    end
})

minetest.register_chatcommand("area_siege", {
    params = "<id> <hoursfromnow> <newowner>",
	privs = areas.adminPrivs,
    description = "start a siege on an area",
    func = function(name, param)
		local params = param:split(" ")
		local id = params[1] and tonumber(params[1])
		local hoursfromnow = params[2] and tonumber(params[2])
		local newowner = params[3]
		if not id or not areas.areas[id] then return false, "Invalid ID" end
		if not hoursfromnow or hoursfromnow < 0 then return false, "Invalid hours from now" end
		if not newowner or not areas:player_exists(newowner) then return false, "Invalid newowner" end
		local currentunixhour = areas.get_unixhour()
		areas.siege_create(id, currentunixhour+math.floor(hoursfromnow), newowner)
		return true, "Created siege"
    end
})

minetest.register_chatcommand("area_end_siege", {
    params = "<id> <hoursfromnow> <newowner>",
	privs = areas.adminPrivs,
    description = "start a siege on an area",
    func = function(name, param)
		local id = tonumber(param)
		if not id then return false, "Invalid ID" end
		if not areas.siege_get(id) then return false, "Area is not under siege" end
		areas.siege_remove(id)
		return true, "Successfully ended siege"
    end
})

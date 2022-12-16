local mod_storage = minetest.get_mod_storage()
local list = minetest.deserialize(mod_storage:get_string("list")) or {}
minetest.register_on_prejoinplayer(function(name, ip)
	if (xban and xban.get_whitelist(name)) or minetest.check_player_privs(name, {ban=true}) then
		return true
	end
	for index, _ in pairs (list) do
		if index == "" or string.find(index, " ") or string.find(index, '%a') or string.len(index) < 3 then
			list[index] = nil
			mod_storage:set_string("list", minetest.serialize(list))
		elseif string.find(ip, index) then
			return "This VPN or general IP has been banned. If you weren't banned contact an admin."
		end
	end
end)
minetest.register_chatcommand("vpnban", {
	params = "<partial ip>",
	description = "Ban all ips that contain that ip.",
	privs = {ban = true},
	func = function( name , param)
		if not param or param == "" or string.find(param, " ") or string.find(param, '%a') or string.len(param) < 3 then
			return false, "Invalid input, must have no letters, spaces, and must be longer than 2 characters. FAILED."
		end
		if list[param] then
			return false, param.." is already banned. FAILED."
		end
		local text=""
		for index, _ in pairs (list) do
			if string.find(param, index) then
				if text == "" then
					text = " NOTE: "..param.." is already banned under "..index
				else
					text = text..", "..index
				end
			end
		end
		list[param] = name
		mod_storage:set_string("list", minetest.serialize(list))
		minetest.log("action", "[VPNBAN] "..param.." was banned by "..name)
		return true, param.." was banned by "..name..text
	end,
})
minetest.register_chatcommand("vpnunban", {
	params = "<partial ip>",
	description = "Unban all ips that contain that ip.",
	privs = {ban = true},
	func = function( name , param)
		local ip = param
		if not list[param] then
			for index, _ in pairs (list) do
				if string.find(param, index) then
					ip = index
				end
			end
		end
		if not list[ip] then
			return false, param.." was not found. FAILED."
		end
		list[ip] = nil
		mod_storage:set_string("list", minetest.serialize(list))
		minetest.log("action", "[VPNBAN] "..ip.." was unbanned by "..name)
		return true, ip.." was unbanned by "..name
	end,
})
minetest.register_chatcommand("vpnbanshow", {
	params = "<none/ip/name>",
	description = "View vpn bans.",
	privs = {ban = true},
	func = function( name , param)
		local text
		if not param or param == "" then
			local i = 0
			for index, _ in pairs (list) do
				i = i+1
				if not text then
					text = "List of VPN bans: "..index
				else
					text = text..", "..index
				end
			end
			if i == 0 then text = "No vpn bans on file." end
		else
			for index, name in pairs (list) do
				if param == name then
					if not text then
						text = "Ips banned by "..name..": "..index
					else
						text = text..", "..index
					end
				end
				if string.find(index, param) then
					text = index.." was banned by "..name
					break
				end
			end
		end
		if text then return true, text else return true, "Nothing found for '"..param.."'" end
	end,
})
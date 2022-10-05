--REFERRAL SYSTEM
--player is given a referral priv when joining for the first time, is automatically taken away after 2 hrs (or so) of gametime.
--by using /r 'playername' both they and the referring player recieves half the starting money amount. the priv is then removed and timer stopped
--if the player is sponsored/partnered, the player name is added to a persistent table,
--and a payable referral is created when the player recieves the "pvp" priv
--(or one of the other privs the player receives after 2hrs of play time)
--concern: people will abuse it and tell all new players (that they didn't refer) to do the command. tho if they help the player get started its not an issue.
--another concern is that people will use a vpn to create many accounts and refer them all. however this is already a bit of a concern with starting money.
--it can be against the rules, be sure to log all for enforcing this and also for potential issues with partners.
--maybe make a notice sent to admin /mail if one person refers more than 5 people in one 24hr period

local storage = minetest.get_mod_storage()
local starting_money = minetest.settings:get("money3.initial_amount")--todo find correct name
local refertbl = minetest.deserialize(storage:get_string("refertbl")) or {}
local partnertbl = minetest.deserialize(storage:get_string("partnertbl")) or {}

function split(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t={}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		table.insert(t, str)
	end
	return t
end

for i, partnername in pairs(split(minetest.settings:get("referral_partners") or "")) do
	if not partnertbl[partnername] then
		partnertbl[partnername] = {}
	end
end

local function cull_refertbl(name)
	local currenttime = os.time()
	if name then
		local i = 1
		while refertbl[name][i] do
			local refertime = refertbl[name][i]
			if not refertime then break end
			if currenttime-refertime > 86400 then
				table.remove(refertbl[name], i)
			else
				i = i + 1
			end
		end
	else
		for name, reftbl in pairs(refertbl) do
			local i = 1
			while refertbl[name][i] do
				local refertime = refertbl[name][i]
				if not refertime then break end
				if currenttime-refertime > 86400 then
					table.remove(refertbl[name], i)
				else
					i = i + 1
				end
			end
			if #refertbl[name] == 0 then
				refertbl[name] = nil
			end
		end
		storage:set_string("refertbl", minetest.serialize(refertbl))
	end
end
cull_refertbl()
--todo make the refer priv and add it to playercontrol
minetest.register_chatcommand("r", {
	params = "<name>",
	description = "Enter the name of the person who referred you.",
	privs = {refer = true},
	func = function(name, param)
		if not param or param == "" or (not minetest.player_exists(param) and not partnertbl[param]) then return false, "No such player/code" end
		money3.add(name, starting_money/2)
		if partnertbl[param] then
			partnertbl[param][name] = false--false until player gets the pvp priv after 2 hours of playing
			storage:set_string("partnertbl", minetest.serialize(partnertbl))
		else
			money3.add(param, starting_money/2)
		end
		
		--system to keep track of referrals. if one person refers more than 5 in a day, send a mail to admin
		if not refertbl[param] then
			refertbl[param] = {}
		else
			cull_refertbl(param)
		end
		table.insert(refertbl[param], os.time())
		if #refertbl[param] > 5 and email then
			local adminname = minetest.settings:get("name") or "sparky"
			email.send_mail("mod:referral", adminname, param.." has referred "..#refertbl[param].." players in the last 24 hour period")
		end
		storage:set_string("refertbl", minetest.serialize(refertbl))
		minetest.log("info", name.." recieved a referral from "..param.." ("..tostring(starting_money/2).." given)")
		local privs = minetest.get_player_privs(name)
		privs.refer = nil
		minetest.set_player_privs(name, privs)
		--todo stop playercontrol timer if applicable
		return true, "Referral complete!"
	end
})

function referral_complete(name)
	for partner, reftbl in pairs(partnertbl) do
		if reftbl[name] ~= nil then
			partnertbl[partner][name] = true--referral complete, partner should receive compensation
			storage:set_string("partnertbl", minetest.serialize(partnertbl))
		end
	end
end

minetest.register_chatcommand("dump_partner_refers", {
	params = "<clearall/clearcomplete/clearincomplete>",
	description = "makes a text file containing all partners and their complete/incomplete referrals. use parameters to clear when done.",
	privs = {server = true},
	func = function(name, param)
		if param ~= "" and param ~= "clearcomplete" and param ~= "clearall" and param ~= "clearincomplete" then
			return false, "allowed parameters: '', 'clearall', 'clearcomplete', 'clearincomplete'"
		end
		local filename = "referral_partners_list_"..string.gsub(os.date("%x"), "/", "-")..".txt"
		local path = minetest.get_worldpath().."/"..filename
		local file = io.open(path, "r")
		if file then
			file:close()
			return false, "file already exists"
		else
			file = io.open(path, "w+")
			if not file then return false, "no write access" end
		end
		
		local str = "Partner referrals: "
		for partnername, reftbl in pairs(partnertbl) do
			local completenum = 0
			local incompletenum = 0
			for refname, complete in pairs(reftbl) do
				if complete then
					completenum = completenum + 1
				else
					incompletenum = incompletenum + 1
				end
			end
			local totalnum = completenum + incompletenum
			str = str.."\n    "..partnername..": "..completenum.." complete, "..incompletenum.." incomplete, "..totalnum.." total."
		end
		
		file:write(str)
		file:close()
		
		file = io.open(path, "r")--double check that it worked
		if not file then
			return false, "file write failed."
		else
			file:close()
		end
		
		if param ~= "" then
			local clearednum = 0
			for partnername, reftbl in pairs(partnertbl) do
				for refname, complete in pairs(reftbl) do
					if complete and (param == "clearall" or param == "clearcomplete") then
						clearednum = clearednum + 1
						partnertbl[partnername][refname] = nil
					end
					if not complete and (param == "clearall" or param == "clearincomplete") then
						clearednum = clearednum + 1
						partnertbl[partnername][refname] = nil
					end
				end
			end
			storage:set_string("partnertbl", minetest.serialize(partnertbl))
			return true, "File saved, "..clearednum.." entries cleared."
		else
			return true, "File saved."
		end
	end
})
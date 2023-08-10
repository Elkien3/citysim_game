local S = minetest.get_translator("vote")
local storage = minetest.get_mod_storage()
local settings = minetest.deserialize(storage:get_string("settings")) or {}
for setting, val in pairs(settings) do
	if type(val) == "bool" then
		minetest.settings:set_bool(setting, val)
	else
		minetest.settings:set(setting, val)
	end
end
local function save_setting(setting, val)
	if type(val) == "bool" then
		minetest.settings:set_bool(setting, val)
	else
		minetest.settings:set(setting, val)
	end
	settings[setting] = val
	storage:set_string("settings", minetest.serialize(settings))
end
local votesneeded = tonumber(minetest.settings:get("vote_government_needed")) or 1
minetest.register_privilege("vote_government", {
	description = "Can vote on government matters."
})
local taxfree_protect = {}
if areas then
	minetest.register_chatcommand("vote_recursive_remove_areas", {
		params = "<name>",
		description = "Start a vote to recursivley remove areas under the given ID.",
		privs = {
			vote_government = true,
		},
		func = function(name, param)
			param = param:trim()
			if param == "" then
				return false, S("Invalid usage, see /help @1.", "recursive_remove_areas")
			end
			
			local id = tonumber(param)
			if not areas.areas[id] then
				return false, S("Area does not exist.")
			end

			return vote.new_vote(name, {
				description = "Recursively remove area " .. param .. " "..areas.areas[id].name..".",
				help = "/yes,  /no  or  /abstain",
				name = name,
				duration = 15,
				perc_needed = 0,

				can_vote = function(self, pname)
					return minetest.check_player_privs(pname,{vote_government = true})
				end,

				on_result = function(self, result, results)
					local yes = results.yes or {}
					if #yes >= votesneeded then
						areas:remove(id, true)
						areas:save()
						minetest.chat_send_all(S("Removed area @1 and it's sub areas. (@2/@3)", id, #yes, votesneeded))
					else
						minetest.chat_send_all(S("Vote to remove area @1 and it's sub areas failed. (@2/@3)", id, #yes, votesneeded))
					end
				end,

				on_vote = function(self, voter, value)
					minetest.chat_send_all(voter .. " voted " .. value .. " to '" ..
							self.description .. "'")
				end
			})
		end
	})

	minetest.register_chatcommand("vote_remove_area", {
		params = "<name>",
		description = "Start a vote to remove the area with the given ID.",
		privs = {
			vote_government = true,
		},
		func = function(name, param)
			param = param:trim()
			if param == "" then
				return false, S("Invalid usage, see /help @1.", "remove_area")
			end
			local id = tonumber(param)
			if not areas.areas[id] then
				return false, S("Area does not exist.")
			end

			return vote.new_vote(name, {
				description = "Remove area " .. param .. " "..areas.areas[id].name,
				help = "/yes,  /no  or  /abstain",
				name = name,
				duration = 15,
				perc_needed = 0,

				can_vote = function(self, pname)
					return minetest.check_player_privs(pname,{vote_government = true})
				end,

				on_result = function(self, result, results)
					local yes = results.yes or {}
					if #yes >= votesneeded then
						areas:remove(id)
						areas:save()
						minetest.chat_send_all(S("Removed area @1. (@2/@3)", id, #yes, votesneeded))
					else
						minetest.chat_send_all(S("Vote to remove area @1 failed. (@2/@3)", id, #yes, votesneeded))
					end
				end,

				on_vote = function(self, voter, value)
					minetest.chat_send_all(voter .. " voted " .. value .. " to '" ..
							self.description .. "'")
				end
			})
		end
	})

	minetest.register_chatcommand("vote_protect", {
		params = "<name>",
		description = "Start a vote protect the given area with admin privs.",
		privs = {
			vote_government = true,
		},
		func = function(name, param)
			param = param:trim()
			if param == "" then
				return false, S("Invalid usage, see /help @1.", "protect")
			end
			local pos1, pos2 = areas:getPos(name)
			if not (pos1 and pos2) then
				return false, S("You need to select an area first.")
			end
			
			return vote.new_vote(name, {
				description = "Protect area " ..param..
					" "..minetest.pos_to_string(pos1)..
					" "  ..minetest.pos_to_string(pos2),
				help = "/yes,  /no  or  /abstain",
				name = name,
				duration = 15,
				perc_needed = 0,

				can_vote = function(self, pname)
					return minetest.check_player_privs(pname,{vote_government = true})
				end,

				on_result = function(self, result, results)
					local yes = results.yes or {}
					if #yes >= votesneeded then
						taxfree_protect[name] = true
						local id = areas:add(name, param, pos1, pos2, nil)
						areas:save()
						minetest.chat_send_all(S("Area protected. ID: @1. (@2/@3)", id, #yes, votesneeded))
					else
						minetest.chat_send_all(S("Vote protect area '@1' failed. (@2/@3)", param, #yes, votesneeded))
					end
				end,

				on_vote = function(self, voter, value)
					minetest.chat_send_all(voter .. " voted " .. value .. " to '" ..
							self.description .. "'")
				end
			})
		end
	})

	minetest.register_chatcommand("vote_change_owner", {
		params = "<name>",
		description = "Start a vote to change the area's owner",
		privs = {
			vote_government = true,
		},
		func = function(name, param)
			local id, newOwner = param:match("^(%d+)%s(%S+)$")
			if not id then
				return false, S("Invalid usage, see"
						.." /help @1.", "change_owner")
			end

			if not areas:player_exists(newOwner) then
				return false, S("The player \"@1\" does not exist.", newOwner)
			end

			id = tonumber(id)
			if not areas.areas[id] then
				return false, S("Area does not exist.")
			end
			
			return vote.new_vote(name, {
				description = "Change the owner of area " ..id..
					" to "..newOwner,
				help = "/yes,  /no  or  /abstain",
				name = name,
				duration = 15,
				perc_needed = 0,

				can_vote = function(self, pname)
					return minetest.check_player_privs(pname,{vote_government = true})
				end,

				on_result = function(self, result, results)
					local yes = results.yes or {}
					if #yes >= votesneeded then
						areas.areas[id].owner = newOwner
						areas:save()
						minetest.chat_send_all(S("Area @1 owner changed to @2. (@3/@4)", id, newOwner, #yes, votesneeded))
					else
						minetest.chat_send_all(S("Failed to change area @1 owner to @2. (@3/@4)", id, newOwner, #yes, votesneeded))
					end
				end,

				on_vote = function(self, voter, value)
					minetest.chat_send_all(voter .. " voted " .. value .. " to '" ..
							self.description .. "'")
				end
			})
		end
	})
end

if money3 then
	minetest.register_chatcommand("vote_property_tax", {
		params = "<name>",
		description = "Start a vote to change property tax rate, in terms of how much mg is to be paid 1000 blocks (in 2d space), per month.",
		privs = {
			vote_government = true,
		},
		func = function(name, param)
			if not param or not tonumber(param) then
				return false, "Must enter a number."
			end
			
			return vote.new_vote(name, {
				description = "Change tax rate from "..tostring(minetest.settings:get("property_tax") or 0).." 1000 blocks/mo to " ..param.. " 1000m/mo",
				help = "/yes,  /no  or  /abstain",
				name = name,
				duration = 15,
				perc_needed = 0,

				can_vote = function(self, pname)
					return minetest.check_player_privs(pname,{vote_government = true})
				end,

				on_result = function(self, result, results)
					local yes = results.yes or {}
					local oldval = minetest.settings:get("property_tax") or 0
					if #yes >= votesneeded then
						save_setting("property_tax", tonumber(param))
						minetest.chat_send_all(S("The property tax rate has been changed from @1 1000 blocks/mo to @2 1000 blocks/mo. (@3/@4)", oldval, param, #yes, votesneeded))
					else
						minetest.chat_send_all(S("Failed to change property tax rate from @1 1000 blocks/mo to @2 1000 blocks/mo. (@3/@4)", oldval, param, #yes, votesneeded))
					end
				end,

				on_vote = function(self, voter, value)
					minetest.chat_send_all(voter .. " voted " .. value .. " to '" ..
							self.description .. "'")
				end
			})
		end
	})

	minetest.register_chatcommand("vote_income_amount", {
		params = "<name>",
		description = "Start a vote to change how much money is given to each player every hour",
		privs = {
			vote_government = true,
		},
		func = function(name, param)
			if not param or not tonumber(param) then
				return false, "Must enter a number."
			end
			--[[if tonumber(param) ~= math.floor(tonumber(param)) then
				return false, "Number must be an integer."
			end
			--]]
			return vote.new_vote(name, {
				description = "Change money gen rate from "..tostring(minetest.settings:get("money3.income_amount") or 0).."/hr to " ..param.. "/hr",
				help = "/yes,  /no  or  /abstain",
				name = name,
				duration = 15,
				perc_needed = 0,

				can_vote = function(self, pname)
					return minetest.check_player_privs(pname,{vote_government = true})
				end,

				on_result = function(self, result, results)
					local yes = results.yes or {}
					local oldval = minetest.settings:get("money3.income_amount") or 0
					if #yes >= votesneeded then
						save_setting("money3.income_amount", tonumber(param))
						minetest.chat_send_all(S("The money gen rate has been changed from @1/hr to @2/hr. (@3/@4)", oldval, param, #yes, votesneeded))
					else
						minetest.chat_send_all(S("Failed to change the money gen rate from @1/hr to @2/hr. (@3/@4)", oldval, param, #yes, votesneeded))
					end
				end,

				on_vote = function(self, voter, value)
					minetest.chat_send_all(voter .. " voted " .. value .. " to '" ..
							self.description .. "'")
				end
			})
		end
	})

	minetest.register_chatcommand("vote_initial_amount", {
		params = "<amount>",
		description = "Start a vote to change how much money a new player starts with. (integers only)",
		privs = {
			vote_government = true,
		},
		func = function(name, param)
			if not param or not tonumber(param) then
				return false, "Must enter a number."
			end
			if tonumber(param) ~= math.floor(tonumber(param)) then
				return false, "Number must be an integer."
			end
			return vote.new_vote(name, {
				description = "Change starting money from "..tostring(minetest.settings:get("money3.initial_amount") or 0).." to " ..param,
				help = "/yes,  /no  or  /abstain",
				name = name,
				duration = 15,
				perc_needed = 0,

				can_vote = function(self, pname)
					return minetest.check_player_privs(pname,{vote_government = true})
				end,

				on_result = function(self, result, results)
					local yes = results.yes or {}
					local oldval = minetest.settings:get("money3.initial_amount") or 0
					if #yes >= votesneeded then
						save_setting("money3.initial_amount", tonumber(param))
						minetest.chat_send_all(S("The starting money has been changed from @1 to @2. (@3/@4)", oldval, param, #yes, votesneeded))
					else
						minetest.chat_send_all(S("Failed to change the starting money from @1 to @2. (@3/@4)", oldval, param, #yes, votesneeded))
					end
				end,

				on_vote = function(self, voter, value)
					minetest.chat_send_all(voter .. " voted " .. value .. " to '" ..
							self.description .. "'")
				end
			})
		end
	})
	
	minetest.register_chatcommand("vote_get_balance", {
		params = "<name>",
		description = "Start a vote to see how much money a player has in their account.",
		privs = {
			vote_government = true,
		},
		func = function(name, param)
			if not param or not minetest.player_exists(param) or not money3.get(param) then
				return false, "Player does exist or does not have a money account."
			end
			return vote.new_vote(name, {
				description = "Get "..param.."'s money balance",
				help = "/yes,  /no  or  /abstain",
				name = name,
				duration = 15,
				perc_needed = 0,

				can_vote = function(self, pname)
					return minetest.check_player_privs(pname,{vote_government = true})
				end,

				on_result = function(self, result, results)
					local yes = results.yes or {}
					if #yes >= votesneeded then
						minetest.chat_send_all(S("@1's money balance: @2. (@3/@4)", param, money3.format(money3.get(param)), #yes, votesneeded))
					else
						minetest.chat_send_all(S("Failed to get @1's money balance (@2/@3)", param, #yes, votesneeded))
					end
				end,

				on_vote = function(self, voter, value)
					minetest.chat_send_all(voter .. " voted " .. value .. " to '" ..
							self.description .. "'")
				end
			})
		end
	})
end

if areas and money3 then
	taxes = {}
	taxes.tbl = minetest.deserialize(storage:get_string("taxes")) or {}
	local autopay = minetest.deserialize(storage:get_string("autopay")) or {}
	tax_account = storage:get_float("tax_account") or 0
	
	taxes.add = function(amount)
		tax_account = tax_account + amount
		storage:set_string("tax_account", tax_account)
	end
	taxes.remove = function(amount)
		tax_account = tax_account - amount
		storage:set_string("tax_account", tax_account)
	end
	local warning = {}
	local orig_add = areas.canPlayerAddArea
	function areas.canPlayerAddArea(areas, pos1, pos2, name)
		local tax_rate = tonumber(minetest.settings:get("property_tax") or 0)
		local val, errormsg = orig_add(areas, pos1, pos2, name)
		if minetest.get_player_privs(name).areas then
			return val, errormsg
		end
		if val and val == true then
			if warning[name] ~= nil and warning[name] == minetest.pos_to_string(pos1)..minetest.pos_to_string(pos2) then
				warning[name] = nil
				return val, errormsg
			else
				local temparealist = table.copy(areas.areas)
				table.insert(temparealist, {
					name = "temp",
					pos1 = pos1,
					pos2 = pos2,
					owner = name,
				})
				local dateinfo = os.date("*t", os.time())
				local perc = (30-dateinfo.day)/30
				local diff = areas:get_player_total_area(name, temparealist)-areas:get_player_total_area(name)
				local tax = math.ceil((diff/1000)*tax_rate)
				local tax_now = math.ceil((diff/1000)*tax_rate*perc)
				if tax > 0 then
					warning[name] = minetest.pos_to_string(pos1)..minetest.pos_to_string(pos2)
					minetest.after(60, function() if warning[name] and warning[name] == minetest.pos_to_string(pos1)..minetest.pos_to_string(pos2) then warning[name] = nil end end)
					return false, "WARNING: The area you are trying to protect will charge you a tax of $"..tonumber(tax_now)..", and also have a monthly tax of $"..tax..". repeat the command to proceed."
				else
					return val, errormsg
				end
			end
		else
			return val, errormsg
		end
	end
	areas:registerOnAdd(function(id, area)
		local tax_rate = tonumber(minetest.settings:get("property_tax") or 0)
		if tax_rate <= 0 then return end
		local name = area.owner
		if taxfree_protect[name] then
			taxfree_protect[name] = nil
			return
		end
		local temparealist = table.copy(areas.areas)
		temparealist[id] = nil
		local diff = areas:get_player_total_area(name)-areas:get_player_total_area(name, temparealist)
		if diff < 0 then return end
		local dateinfo = os.date("*t", os.time())
		local perc = (30-dateinfo.day)/30--I know, it won't be correct if there are more or less than 30 days in the current month, but whatever.
		if perc <= 0 then return end
		local tax = math.ceil((diff/1000)*tax_rate*perc)
		minetest.chat_send_player(name, "You have been charged a tax of $"..tax.." for protecting this area.")
		taxes.tbl[name] = math.ceil((taxes.tbl[name] or 0)) + tax
		if autopay[name] and not money3.dec(name, taxes.tbl[name]) then
			tax_account = tax_account + taxes.tbl[name]
			taxes.tbl[name] = nil
			storage:set_string("tax_account", tax_account)
		end
		storage:set_string("taxes", minetest.serialize(taxes.tbl))
	end)

	local function do_taxes()
		local dateinfo = os.date("*t", os.time())
		local tax_rate = tonumber(minetest.settings:get("property_tax") or 0)
		if storage:get_int("last_tax_month") ~= dateinfo.month then
			if tax_rate > 0 then
				local calcnames = {}
				for id, area in pairs(areas.areas) do
					local owner = (jobs and (jobs.list[jobs.split(area.owner, ":")[1]] or {}).ceo) or area.owner
					if not calcnames[owner] then
						taxes.tbl[owner] = math.ceil((taxes.tbl[owner] or 0) + (areas:get_player_total_area(owner)/1000)*tax_rate)
						if autopay[owner] and not money3.dec(owner, taxes.tbl[owner]) then
							tax_account = tax_account + taxes.tbl[owner]
							taxes.tbl[owner] = nil
						end
						calcnames[owner] = true
					end
				end
				storage:set_string("taxes", minetest.serialize(taxes.tbl))
				storage:set_string("tax_account", tax_account)
			end
			storage:set_int("last_tax_month", dateinfo.month)
		end
		local secondsToNext = os.time({year=dateinfo.year, month=dateinfo.month+1, day=1, hour=0, isdst=dateinfo.isdst})-os.time()
		minetest.after(secondsToNext, do_taxes)
	end
	do_taxes()
	
	minetest.register_chatcommand("taxes", {
		params = S("<nil/name>"),
		description = S("See the tax balance of you or another player."),
		func = function(name, param)
			if param == "" then
				param = name
			end
			if not taxes.tbl[param] then
				return false, S("That player does not have a tax balance to pay.")
			end
			
			return true, S("Player @1 has $@2 of taxes to pay.", param, taxes.tbl[param])
		end
	})
	
	minetest.register_chatcommand("taxes_autopay", {
		params = S("<nil/true/false/toggle>"),
		description = S("Enable or disable automatic payment of taxes."),
		func = function(name, param)
			local val
			if not autopay[name] then
				val = true
			end
			if param == "true" then
				val = true
			elseif param == "false" then
				val = nil
			elseif param ~= "" and param ~= "toggle" then
				return false, "Invalid input, valid inputs: '', 'true', 'false', 'toggle'"
			end
			autopay[name] = val
			storage:set_string("autopay", minetest.serialize(autopay))
			
			if val then
				return true, "Automatic tax payment is enabled."
			else
				return true, "Automatic tax payment is disabled."
			end
		end
	})
	
	minetest.register_chatcommand("taxes_pay", {
		params = S("<number or nil>"),
		description = S("Pay your tax balance."),
		func = function(name, param)
			local val = tonumber(param)
			if not taxes.tbl[name] then
				return false, "You have no tax balance to pay."
			end
			if not val or val > taxes.tbl[name] then val = taxes.tbl[name] end
			if money3.dec(name, val) then
				return false, "You do not have enough money in your account."
			end
			tax_account = tax_account + val
			taxes.tbl[name] = taxes.tbl[name]-val
			
			if taxes.tbl[name] == 0 then
				taxes.tbl[name] = nil
			end
			storage:set_string("tax_account", tax_account)
			storage:set_string("taxes", minetest.serialize(taxes.tbl))
			return true, S("Your payment of $@1 has been recieved, your balance is now $@2", val, (taxes.tbl[name] or 0))
		end
	})
	minetest.register_chatcommand("taxes_list", {
		params = S("<number or nil>"),
		description = S("List all players with tax balances. Add a number to check only balances at or above that number."),
		func = function(name, param)
			param = tonumber(param) or 1
			local str = "List of players with tax balances at or above $"..param..":"
			for name, balance in pairs(taxes.tbl) do
				if balance >= param then
					str = str.." "..name
				end
			end
			return true, str
		end
	})
	minetest.register_chatcommand("taxes_account", {
		params = S("<number or nil>"),
		description = S("Get the balance of the main tax account."),
		func = function(name, param)
			return true, "Tax Account balance: $"..tax_account
		end
	})
	
	minetest.register_chatcommand("vote_transfer_out", {
		params = "<amount> <account>",
		description = "Start a vote transfer money out of the Tax Account into another.",
		privs = {
			vote_government = true,
		},
		func = function(name, param)
			local params = param:split(" ")
			if not params or #params ~= 2 then
				return false, "Invalid input. do /vote_transfer_out <amount> <account>"
			end
			params[1] = tonumber(params[1])
			if not params[1] or (tonumber(params[1]) ~= math.floor(tonumber(params[1]))) or params[1] <= 0 then
				return false, "Amount must be a positive integer."
			end
			if params[1] > tax_account then
				return false, "There is not enough money in the tax account."
			end
			if not money3.user_exists(params[2]) then
				return false, "The account '"..params[2].."' does not exist."
			end
			return vote.new_vote(name, {
				description = "Transfer $"..params[1].." out of Tax Account into " ..params[2].."'s account",
				help = "/yes,  /no  or  /abstain",
				name = name,
				duration = 15,
				perc_needed = 0,

				can_vote = function(self, pname)
					return minetest.check_player_privs(pname,{vote_government = true})
				end,

				on_result = function(self, result, results)
					local yes = results.yes or {}
					if params[1] > tax_account then
						minetest.chat_send_all("There is not enough money in the tax account, vote cancelled.")
						return
					end
					if #yes >= votesneeded then
						tax_account = tax_account - params[1]
						storage:set_string("tax_account", tax_account)
						money3.add(params[2], params[1])
						minetest.chat_send_all(S("$@1 has been transfered out of the Tax Account into @2's account. (@3/@4)", params[1], params[2], #yes, votesneeded))
					else
						minetest.chat_send_all(S("Failed to transfer $@1 out of the Tax Account into @2's account. (@3/@4)", params[1], params[2], #yes, votesneeded))
					end
				end,

				on_vote = function(self, voter, value)
					minetest.chat_send_all(voter .. " voted " .. value .. " to '" ..
							self.description .. "'")
				end
			})
		end
	})
	minetest.register_chatcommand("vote_transfer_in", {
		params = "<amount> <account>",
		description = "Start a vote transfer money into the Tax Account from another.",
		privs = {
			vote_government = true,
		},
		func = function(name, param)
			local params = param:split(" ")
			if not params or #params ~= 2 then
				return false, "Invalid input. do /vote_transfer_in <amount> <account>"
			end
			params[1] = tonumber(params[1])
			if not params[1] or (tonumber(params[1]) ~= math.floor(tonumber(params[1]))) or params[1] <= 0 then
				return false, "Amount must be a positive integer."
			end
			if not money3.user_exists(params[2]) then
				return false, "The account '"..params[2].."' does not exist."
			end
			if money3.get(params[2]) < params[1] then
				return false, "The account '"..params[2].."' does not have enough money."
			end
			local owner = (jobs and (jobs.list[jobs.split(params[2], ":")[1]] or {}).ceo) or params[2]
			if not minetest.check_player_privs(owner, {vote_government=true}) then
				return false, "You can only take money out of Government accounts."
			end
			return vote.new_vote(name, {
				description = "Transfer $"..params[1].." out of " ..params[2].."'s account into the Tax Account",
				help = "/yes,  /no  or  /abstain",
				name = name,
				duration = 15,
				perc_needed = 0,

				can_vote = function(self, pname)
					return minetest.check_player_privs(pname,{vote_government = true})
				end,

				on_result = function(self, result, results)
					local yes = results.yes or {}
					if not money3.user_exists(params[2]) then
						minetest.chat_send_all("The account '"..params[2].."' does not exist. vote cancelled")
						return
					end
					if money3.get(params[2]) < params[1] then
						minetest.chat_send_all("The account '"..params[2].."' does not have enough money. vote cancelled")
						return
					end
					local owner = (jobs and (jobs.list[jobs.split(params[2], ":")[1]] or {}).ceo) or params[2]
					if not minetest.check_player_privs(owner, {vote_government=true}) then
						minetest.chat_send_all("You can only take money out of Government accounts. vote cancelled")
						return
					end
					if #yes >= votesneeded then
						money3.dec(params[2], params[1])
						tax_account = tax_account + params[1]
						storage:set_string("tax_account", tax_account)
						minetest.chat_send_all(S("$@1 has been transfered out @2's account into the Tax Account. (@3/@4)", params[1], params[2], #yes, votesneeded))
					else
						minetest.chat_send_all(S("Failed to transfer $@1 out of @2's account into the Tax Account. (@3/@4)", params[1], params[2], #yes, votesneeded))
					end
				end,

				on_vote = function(self, voter, value)
					minetest.chat_send_all(voter .. " voted " .. value .. " to '" ..
							self.description .. "'")
				end
			})
		end
	})
	minetest.register_chatcommand("vote_tax_balance", {
		params = "<name> <amount>",
		description = "Set the tax balance of a player",
		privs = {
			vote_government = true,
		},
		func = function(name, param)
			local params = param:split(" ")
			if not params or #params ~= 2 then
				return false, "Invalid input. do /vote_tax_balance <name> <amount>"
			end
			params[2] = tonumber(params[2])
			if not params[2] or (tonumber(params[2]) ~= math.floor(tonumber(params[2]))) or params[2] < 0 then
				return false, "Amount must be an non-negative integer."
			end
			if not minetest.player_exists(params[1]) then
				return false, "The player '"..params[1].."' does not exist."
			end
			local oldtax = taxes.tbl[params[1]] or 0
			return vote.new_vote(name, {
				description = "Change "..params[1].."'s tax balance from "..oldtax.." to "..params[2],
				help = "/yes,  /no  or  /abstain",
				name = name,
				duration = 15,
				perc_needed = 0,

				can_vote = function(self, pname)
					if pname == params[1] then return false end
					return minetest.check_player_privs(pname,{vote_government = true})
				end,

				on_result = function(self, result, results)
					local yes = results.yes or {}
					if #yes >= votesneeded then
						if params[2] == 0 then
							taxes.tbl[params[1]] = nil
						else
							taxes.tbl[params[1]] = params[2]
						end
						storage:set_string("taxes", minetest.serialize(taxes.tbl))
						minetest.chat_send_all(S("@1's tax balance was changed from @2 to @3 (@4/@5)", params[1], oldtax, params[2], #yes, votesneeded))
					else
						minetest.chat_send_all(S("Failed to change @1's tax balance from @2 to @3 (@4/@5)", params[1], oldtax, params[2], #yes, votesneeded))
					end
				end,

				on_vote = function(self, voter, value)
					minetest.chat_send_all(voter .. " voted " .. value .. " to '" ..
							self.description .. "'")
				end
			})
		end
	})
	if jobs then
		minetest.register_chatcommand("tax_exempt", {
			params = "",
			description = "See the list of all jobs that are tax exempt",
			func = function(name, param)
				local tax_exempt = minetest.deserialize(minetest.settings:get("tax_exemptions")) or {}
				local str = "Tax exempt jobs: "
				for jobname, val in pairs(tax_exempt) do
					if str == "Tax exempt jobs: " then
						str = str..jobname
					else
						str = str..", "..jobname
					end
				end
				return true, str
			end
		})
		minetest.register_chatcommand("vote_tax_exempt", {
			params = "<jobname>",
			description = "Make a job tax exempt if it isn't, or make it not tax exempt if it is.",
			privs = {
				vote_government = true,
			},
			func = function(name, param)
				if not jobs.list[param] then
					return false, "No such job as '"..param.."'"
				end
				local desc = "Make "..param.." job tax exempt"
				local success = "$@1 has been made tax exempt. (@2/@3)"
				local fail = "Failed to make $@1 tax exempt. (@2/@3)"
				local tax_exempt = minetest.deserialize(minetest.settings:get("tax_exemptions")) or {}
				if tax_exempt[param] then
					desc = "Make "..param.." job no longer tax exempt"
					success = "$@1 has been removed from tax exempt status. (@2/@3)"
					fail = "Failed to remove $@1 from tax exempt status. (@2/@3)"
				end
				return vote.new_vote(name, {
					description = desc,
					help = "/yes,  /no  or  /abstain",
					name = name,
					duration = 15,
					perc_needed = 0,

					can_vote = function(self, pname)
						return minetest.check_player_privs(pname,{vote_government = true})
					end,

					on_result = function(self, result, results)
						local yes = results.yes or {}
						if #yes >= votesneeded then
							if tax_exempt[param] then
								tax_exempt[param] = nil
							else
								tax_exempt[param] = true
							end
							save_setting("tax_exemptions", minetest.serialize(tax_exempt))
							minetest.chat_send_all(S(success, param, #yes, votesneeded))
						else
							minetest.chat_send_all(S(fail, param, #yes, votesneeded))
						end
					end,

					on_vote = function(self, voter, value)
						minetest.chat_send_all(voter .. " voted " .. value .. " to '" ..
								self.description .. "'")
					end
				})
			end
		})
	end
end

laws = minetest.deserialize(storage:get_string("laws")) or {}

local function get_law(name)
	if not name then return end
	for i, tbl in pairs(laws) do
		if tbl.name and string.lower(tbl.name) == string.lower(name) then return i, tbl end
	end
end

local function get_laws_form()
    local str = ""
    for i, law in pairs(laws) do
        if i ~= 1 then str = str.."," end
		if law.name and law.info then
			str = str .. minetest.formspec_escape(law.name..": "..law.info)
		end
    end
    local form = "size[13,7.5]textlist[0.5,0.5;12,6.5;textlist;"..str.."]"
    return form
end

minetest.register_chatcommand("vote_law_add", {
	params = "law name: law info",
	description = "Start a vote to add a law.",
	privs = {
		vote_government = true,
	},
	func = function(name, param)
		local params = param:split(": ")
		if not params or #params ~= 2 then
			return false, "Invalid input. do /vote_law_add law name: law info"
		end
		if get_law(params[1]) then
			return false, "Law already exists, use /vote_law_change to change it."
		end
		
		return vote.new_vote(name, {
			description = "Add law "..param,
			help = "/yes,  /no  or  /abstain",
			name = name,
			duration = 15,
			perc_needed = 0,

			can_vote = function(self, pname)
				return minetest.check_player_privs(pname,{vote_government = true})
			end,

			on_result = function(self, result, results)
				local yes = results.yes or {}
				if #yes >= votesneeded then
					table.insert(laws, {name = params[1], info = params[2]})
					storage:set_string("laws", minetest.serialize(laws))
					minetest.chat_send_all(S("'@1' has been made law. (@2/@3)", param, #yes, votesneeded))
				else
					minetest.chat_send_all(S("Failed to make '@1' law. (@2/@3)", param, #yes, votesneeded))
				end
			end,

			on_vote = function(self, voter, value)
				minetest.chat_send_all(voter .. " voted " .. value .. " to '" ..
						self.description .. "'")
			end
		})
	end
})

minetest.register_chatcommand("vote_law_remove", {
	params = "law name: law info",
	description = "Start a vote to remove a law.",
	privs = {
		vote_government = true,
	},
	func = function(name, param)
		if param == "" then
			return false, "Invalid input. do /vote_law_remove law name"
		end
		local lawid, lawtbl = get_law(param)
		if not lawid then
			return false, "That law does not exist."
		end
		
		return vote.new_vote(name, {
			description = "Remove law "..param,
			help = "/yes,  /no  or  /abstain",
			name = name,
			duration = 15,
			perc_needed = 0,

			can_vote = function(self, pname)
				return minetest.check_player_privs(pname,{vote_government = true})
			end,

			on_result = function(self, result, results)
				local yes = results.yes or {}
				if #yes >= votesneeded then
					table.remove(laws, lawid)
					storage:set_string("laws", minetest.serialize(laws))
					minetest.chat_send_all(S("'@1' has been removed. (@2/@3)", param, #yes, votesneeded))
				else
					minetest.chat_send_all(S("Failed to remove law '@1' (@2/@3)", param, #yes, votesneeded))
				end
			end,

			on_vote = function(self, voter, value)
				minetest.chat_send_all(voter .. " voted " .. value .. " to '" ..
						self.description .. "'")
			end
		})
	end
})

minetest.register_chatcommand("vote_law_change", {
	params = "law name: law info",
	description = "Start a vote to add a law.",
	privs = {
		vote_government = true,
	},
	func = function(name, param)
		local params = param:split(": ")
		if not params or #params ~= 2 then
			return false, "Invalid input. do /vote_law_change law name: law info"
		end
		local lawid, lawtbl = get_law(params[1])
		if not lawid then
			return false, "That law does not exist."
		end
		
		return vote.new_vote(name, {
			description = "Change law '"..params[1].."' to '"..params[2].."'",
			help = "/yes,  /no  or  /abstain",
			name = name,
			duration = 15,
			perc_needed = 0,

			can_vote = function(self, pname)
				return minetest.check_player_privs(pname,{vote_government = true})
			end,

			on_result = function(self, result, results)
				local yes = results.yes or {}
				if #yes >= votesneeded then
					laws[lawid] = {name = params[1], info = params[2]}
					storage:set_string("laws", minetest.serialize(laws))
					minetest.chat_send_all(S("'@1' has been updated to '@2'. (@3/@4)", params[1], params[2], #yes, votesneeded))
				else
					minetest.chat_send_all(S("Failed to updated '@1' to '@2'. (@3/@4)", params[1], params[2], #yes, votesneeded))
				end
			end,

			on_vote = function(self, voter, value)
				minetest.chat_send_all(voter .. " voted " .. value .. " to '" ..
						self.description .. "'")
			end
		})
	end
})

minetest.register_chatcommand("law_order", {
	params = "law name: number",
	description = "Set the order of a law.",
	privs = {
		vote_government = true,
	},
	func = function(name, param)
		local params = param:split(": ")
		if not params or #params ~= 2 then
			return false, "Invalid input. do /law_oeder law name: number"
		end
		local lawid, lawtbl = get_law(params[1])
		if not lawid then
			return false, "That law does not exist."
		end
		params[2] = tonumber(params[2])
		if not params[2] then
			return false, "Must enter a number."
		end
		if params[2] > #laws then
			return false, "Use /law_newline number to add spacing."
		end
		table.remove(laws, lawid)
		table.insert(laws, params[2], lawtbl)
		storage:set_string("laws", minetest.serialize(laws))
		return true, "Law order changed."
	end
})

minetest.register_chatcommand("law_newline", {
	params = "number",
	description = "Add a newline in the law list, or remove if one is already there.",
	privs = {
		vote_government = true,
	},
	func = function(name, param)
		param = tonumber(param)
		if not param then
			return false, "Must enter a number."
		end
		if param > #laws+1 then
			return false, "Cannot add newline past end of law table."
		end
		if not laws[param].name then
			table.remove(laws, param)
			return true, "Newline removed."
		else
			table.insert(laws, param, {})
			storage:set_string("laws", minetest.serialize(laws))
			return true, "Newline added"
		end
	end
})

minetest.register_chatcommand("laws", {
	params = "<empty>",
	description = "View laws",
	func = function(name, param)
		minetest.show_formspec(name, "laws", get_laws_form())
	end
})

local licenses = minetest.deserialize(storage:get_string("licenses")) or {}
local playerlicenses = minetest.deserialize(storage:get_string("playerlicenses")) or {}
local licenseperms = minetest.deserialize(storage:get_string("licenseperms")) or {}
local is_job_string
if jobs then
	is_job_string = jobs.is_job_string
end

function get_player_licenses(name)
	local tbl = {}
	if playerlicenses[name] then tbl = table.copy(playerlicenses[name]) end
	if jobs and jobs.players[name] then
		for jobstring, permtbl in pairs(playerlicenses) do
			if is_job_string(jobstring) and jobs.permissionstring(name, jobstring) then
				for i, licensename in pairs(permtbl) do
					table.insert(tbl, licensename.." ("..jobstring..")")
				end
			end
		end
	end
	return tbl
end

function player_has_license(name, license, checkjobs)
	if playerlicenses[name] then
		for i, license2 in pairs(playerlicenses[name]) do
			if license2 == license then
				return true
			end
		end
	end
	if jobs and (checkjobs == nil or checkjobs == true) and jobs.players[name] then
		for jobstring, permtbl in pairs(playerlicenses) do
			if is_job_string(jobstring) and jobs.permissionstring(name, jobstring) then
				return true
			end
		end
	end
	return false
end

local function has_licenseperms(name)
	if licenseperms[name] == true then return true end
	if jobs then
		for jobstring, permtbl in pairs(licenseperms) do
			if is_job_string(jobstring) and jobs.permissionstring(name, jobstring) then
				return true
			end
		end
	end
	return false
end

local function params_reduce(params)--used after a string split by space to result in only two strings
	if #params < 2 then return params end
	for i, param2 in pairs(params) do
		if i > 2 then
			params[2] = params[2].." "..param2
		end
	end
	return {params[1], params[2]}
end

minetest.register_chatcommand("vote_license_add", {
	params = "license name: license info",
	description = "Start a vote to add a license.",
	privs = {
		vote_government = true,
	},
	func = function(name, param)
		local params = param:split(": ")
		if not params or #params ~= 2 then
			return false, "Invalid input. do /vote_license_add license name: license info"
		end
		if licenses[params[1]] then
			return false, "license already exists, use /vote_license_remove to remove it."
		end
		
		return vote.new_vote(name, {
			description = "Add license "..param,
			help = "/yes,  /no  or  /abstain",
			name = name,
			duration = 15,
			perc_needed = 0,

			can_vote = function(self, pname)
				return minetest.check_player_privs(pname,{vote_government = true})
			end,

			on_result = function(self, result, results)
				local yes = results.yes or {}
				if #yes >= votesneeded then
					licenses[params[1]] = params[2]
					storage:set_string("licenses", minetest.serialize(licenses))
					minetest.chat_send_all(S("License '@1' has been made. (@2/@3)", params[1], #yes, votesneeded))
				else
					minetest.chat_send_all(S("Failed to make '@1' License. (@2/@3)", params[1], #yes, votesneeded))
				end
			end,

			on_vote = function(self, voter, value)
				minetest.chat_send_all(voter .. " voted " .. value .. " to '" ..
						self.description .. "'")
			end
		})
	end
})

minetest.register_chatcommand("vote_license_remove", {
	params = "<licensename>",
	description = "Start a vote to remove a license.",
	privs = {
		vote_government = true,
	},
	func = function(name, param)
		if param == "" then
			return false, "Invalid input. do /vote_license_remove license name"
		end
		if not licenses[param] then
			return false, "That license does not exist."
		end
		
		return vote.new_vote(name, {
			description = "Remove license "..param,
			help = "/yes,  /no  or  /abstain",
			name = name,
			duration = 15,
			perc_needed = 0,

			can_vote = function(self, pname)
				return minetest.check_player_privs(pname,{vote_government = true})
			end,

			on_result = function(self, result, results)
				local yes = results.yes or {}
				if #yes >= votesneeded then
					licenses[param] = nil
					for pname, licensetbl in pairs(playerlicenses) do
						for i, licensename in pairs(licensetbl) do
							if licensename == param then
								table.remove(playerlicenses[pname], i)
								goto next
							end
						end
						::next::
					end
					storage:set_string("licenses", minetest.serialize(licenses))
					storage:set_string("playerlicenses", minetest.serialize(playerlicenses))
					minetest.chat_send_all(S("'@1' license has been removed. (@2/@3)", param, #yes, votesneeded))
				else
					minetest.chat_send_all(S("Failed to remove license '@1' (@2/@3)", param, #yes, votesneeded))
				end
			end,

			on_vote = function(self, voter, value)
				minetest.chat_send_all(voter .. " voted " .. value .. " to '" ..
						self.description .. "'")
			end
		})
	end
})

minetest.register_chatcommand("vote_license_permission", {
	params = "playername/jobname",
	description = "Give or remove permission to player or job rank to give licenses. Give no input to see all with permission already.",
	privs = {
		vote_government = true,
	},
	func = function(name, param)
		if param == "" then
			local str = ""
			for name2, tbl in pairs(licenseperms) do
				if str ~= "" then
					str = str..", "
				end
				str = str..name2
			end
			str = "All entries for license permission: "..str
			return true, str
		end
		if not minetest.player_exists(param) and (not jobs or not is_job_string(param)) then
			return false, "Player or job not found."
		end
		local text = {"Grant", "granted", "grant"}
		if licenseperms[param] then
			text = {"Revoke", "revoked", "revoke"}
		end
		return vote.new_vote(name, {
			description = (text[1]).." license permissions to "..param,
			help = "/yes,  /no  or  /abstain",
			name = name,
			duration = 15,
			perc_needed = 0,

			can_vote = function(self, pname)
				return minetest.check_player_privs(pname,{vote_government = true})
			end,

			on_result = function(self, result, results)
				local yes = results.yes or {}
				if not minetest.player_exists(param) and (not jobs or not is_job_string(param)) then
					minetest.chat_send_all("Player or job not found.")
					return false
				end
				if #yes >= votesneeded then
					if licenseperms[param] then
						licenseperms[param] = nil
					else
						licenseperms[param] = true
					end
					storage:set_string("licenseperms", minetest.serialize(licenseperms))
					minetest.chat_send_all(S("'@1' has been @2 license permissions. (@3/@4)", param, text[2], #yes, votesneeded))
				else
					minetest.chat_send_all(S("Failed to @1 license permissions to '@2' (@3/@4)", text[3], param, #yes, votesneeded))
				end
			end,

			on_vote = function(self, voter, value)
				minetest.chat_send_all(voter .. " voted " .. value .. " to '" ..
						self.description .. "'")
			end
		})
	end
})

minetest.register_chatcommand("vote_license_grant", {
	params = "playername licensename",
	description = "Grant a license to a person/job",
	privs = {
		vote_government = true,
	},
	func = function(name, param)
		local params = param:split(" ")
		params = params_reduce(params)
		if not params or #params ~= 2 then
			return false, "Invalid input. do /license_grant <playername/jobname:rank> <licensename>"
		end
		if not minetest.player_exists(params[1]) and (not jobs or not is_job_string(params[1])) then
			minetest.chat_send_all("Player or job not found.")
			return false
		end
		if not licenses[params[2]] then
			return false, "That license does not exist."
		end
		if player_has_license(params[1], params[2], false) then
			return false, "Player or job already has license."
		end
		return vote.new_vote(name, {
			description = S("Grant @1 a @2 license", params[1], params[2]),
			help = "/yes,  /no  or  /abstain",
			name = name,
			duration = 15,
			perc_needed = 0,

			can_vote = function(self, pname)
				return minetest.check_player_privs(pname,{vote_government = true})
			end,

			on_result = function(self, result, results)
				local yes = results.yes or {}
				if not minetest.player_exists(params[1]) and (not jobs or not is_job_string(params[1])) then
					minetest.chat_send_all("Player or job not found.")
					return false
				end
				if not licenses[params[2]] then
					minetet.chat_send_all("That license does not exist.")
					return false
				end
				if player_has_license(params[1], params[2], false) then
					minetest.chat_send_all("Player or job already has license.")
					return false
				end
				if #yes >= votesneeded then
					if not playerlicenses[params[1]] then playerlicenses[params[1]] = {} end
					table.insert(playerlicenses[params[1]], params[2])
					storage:set_string("playerlicenses", minetest.serialize(playerlicenses))
					minetest.chat_send_all(S("'@1' has granted a @2 license. (@3/@4)", params[1], params[2], #yes, votesneeded))
				else
					minetest.chat_send_all(S("Failed to grant @1 a @2 license. (@3/@4)", params[1], params[2], #yes, votesneeded))
				end
			end,

			on_vote = function(self, voter, value)
				minetest.chat_send_all(voter .. " voted " .. value .. " to '" ..
						self.description .. "'")
			end
		})
	end
})
minetest.register_chatcommand("license_grant", {
	params = "<playername/jobname:rank> <licensename>",
	description = "Give a license to a player or job rank",
	func = function(name, param)
		if not has_licenseperms(name) then
			return false, "You do not have permissions to grant or revoke licenses"
		end
		local params = param:split(" ")
		params = params_reduce(params)
		if not params or #params ~= 2 then
			return false, "Invalid input. do /license_grant <playername/jobname:rank> <licensename>"
		end
		if not minetest.player_exists(params[1]) and (not jobs or not is_job_string(params[1])) then
			minetest.chat_send_all("Player or job not found.")
			return false
		end
		if not licenses[params[2]] then
			return false, "That license does not exist."
		end
		if player_has_license(params[1], params[2], false) then
			return false, "Player or job already has license."
		end
		if name == params[1] then
			return false, "Cannot grant yourself licenses"
		end
		if not playerlicenses[params[1]] then playerlicenses[params[1]] = {} end
		table.insert(playerlicenses[params[1]], params[2])
		storage:set_string("playerlicenses", minetest.serialize(playerlicenses))
		return true, "Granted "..params[2].." license to "..params[1]
	end
})

minetest.register_chatcommand("vote_license_revoke", {
	params = "playername licensename",
	description = "Revoke a license to a person/job",
	privs = {
		vote_government = true,
	},
	func = function(name, param)
		local params = param:split(" ")
		params = params_reduce(params)
		if not params or #params ~= 2 then
			return false, "Invalid input. do /vote_license_revoke <playername/jobname:rank> <licensename>"
		end
		if not minetest.player_exists(params[1]) and (not jobs or not is_job_string(params[1])) then
			minetest.chat_send_all("Player or job not found.")
			return false
		end
		if not licenses[params[2]] then
			return false, "That license does not exist."
		end
		if not player_has_license(params[1], params[2], false) then
			return false, "Player does not have that license."
		end
		return vote.new_vote(name, {
			description = S("Revoke @1 license from @2", params[2], params[1]),
			help = "/yes,  /no  or  /abstain",
			name = name,
			duration = 15,
			perc_needed = 0,

			can_vote = function(self, pname)
				return minetest.check_player_privs(pname,{vote_government = true})
			end,

			on_result = function(self, result, results)
				local yes = results.yes or {}
				if not minetest.player_exists(params[1]) and (not jobs or not is_job_string(params[1])) then
					minetest.chat_send_all("Player or job not found.")
					return false
				end
				if not licenses[params[2]] then
					minetest.chat_send_all("That license does not exist.")
					return false
				end
				if not player_has_license(params[1], params[2], false) then
					minetest.chat_send_all("Player does not have that license.")
					return false
				end
				if #yes >= votesneeded then
					for i, licensename in pairs(playerlicenses[params[1]]) do
						if licensename == params[2] then
							table.remove(playerlicenses[params[1]], i)
						end
					end
					if #playerlicenses[params[1]] == 0 then playerlicenses[params[1]] = nil end
					storage:set_string("playerlicenses", minetest.serialize(playerlicenses))
					minetest.chat_send_all(S("@1 license was revoked from @2. (@3/@4)", params[2], params[1], #yes, votesneeded))
				else
					minetest.chat_send_all(S("Failed to revoke @1 license from @2 (@3/@4)", params[2], params[1], #yes, votesneeded))
				end
			end,

			on_vote = function(self, voter, value)
				minetest.chat_send_all(voter .. " voted " .. value .. " to '" ..
						self.description .. "'")
			end
		})
	end
})
minetest.register_chatcommand("license_revoke", {
	params = "<playername/jobname:rank> <licensename>",
	description = "Revoke a license from a player or job rank",
	func = function(name, param)
		if not has_licenseperms(name) then
			return false, "You do not have permissions to grant or revoke licenses"
		end
		local params = param:split(" ")
		params = params_reduce(params)
		if not params or #params ~= 2 then
			return false, "Invalid input. do /license_revoke <playername/jobname:rank> <licensename>"
		end
		if not minetest.player_exists(params[1]) and (not jobs or not is_job_string(params[1])) then
			minetest.chat_send_all("Player or job not found.")
			return false
		end
		if not licenses[params[2]] then
			return false, "That license does not exist."
		end
		if not player_has_license(params[1], params[2], false) then
			return false, "Player does not have that license."
		end
		if name == params[1] then
			return false, "Cannot revoke your own licenses"
		end
		for i, licensename in pairs(playerlicenses[params[1]]) do
			if licensename == params[2] then
				table.remove(playerlicenses[params[1]], i)
			end
		end
		if #playerlicenses[params[1]] == 0 then playerlicenses[params[1]] = nil end
		storage:set_string("playerlicenses", minetest.serialize(playerlicenses))
		return true, "Revoked "..params[2].." license from "..params[1]
	end
})

minetest.register_chatcommand("licenses", {
	params = "<license>",
	description = "list all licenses or show specific license",
	func = function(name, param)
		local str = ""
		if param == "" then
			for licensename, licenseinfo in pairs(licenses) do
				if str ~= "" then
					str = str..", "
				end
				str = str..licensename
			end
		elseif licenses[param] then
			str = param..": "..licenses[param]
		else
			return false, "No such license"
		end
		return true, str
	end
})

minetest.register_chatcommand("playerlicenses", {
	params = "<license>",
	description = "list all players with all or a specific license.",
	func = function(name, param)
		local str = ""
		if param ~= "" and not licenses[param] then return false, "No such license" end
		if param == "" then
			for pname, licensetbl in pairs(playerlicenses) do
				for i, licensename in pairs(licensetbl) do
					if str ~= "" then
						str = str..", "
					end
					str = str..pname..": "..licensename
				end
				::next::
			end
			str = "All players with licenses: "..str
		else
			for pname, licensetbl in pairs(playerlicenses) do
				for i, licensename in pairs(licensetbl) do
					if param == "" or licensename == param then
						if str ~= "" then
							str = str..", "
						end
						str = str..pname
						goto next
					end
				end
				::next::
			end
			str = "All players with "..param.." license: "..str
		end
		return true, str
	end
})
local S = minetest.get_translator("vote")
local votesneeded = tonumber(minetest.settings:get("vote_government_needed")) or 1
minetest.register_privilege("vote_government", {
	description = "Can vote on government matters."
})

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
				duration = 20,
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
				duration = 20,
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
				duration = 20,
				perc_needed = 0,

				can_vote = function(self, pname)
					return minetest.check_player_privs(pname,{vote_government = true})
				end,

				on_result = function(self, result, results)
					local yes = results.yes or {}
					if #yes >= votesneeded then
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
				duration = 20,
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
		description = "Start a vote to change property tax rate, in terms of how much mg is to be paid per square kilometer, per month.",
		privs = {
			vote_government = true,
		},
		func = function(name, param)
			if not param or not tonumber(param) then
				return false, "Must enter a number."
			end
			
			return vote.new_vote(name, {
				description = "Change tax rate from "..tostring(minetest.settings:get("property_tax") or 0).." sq km/mo to " ..param.. " sq km/mo",
				help = "/yes,  /no  or  /abstain",
				name = name,
				duration = 20,
				perc_needed = 0,

				can_vote = function(self, pname)
					return minetest.check_player_privs(pname,{vote_government = true})
				end,

				on_result = function(self, result, results)
					local yes = results.yes or {}
					local oldval = minetest.settings:get("property_tax") or 0
					if #yes >= votesneeded then
						minetest.settings:set("property_tax", tonumber(param))
						minetest.chat_send_all(S("The property tax rate has been changed from @1 sq km/mo to @2 sq km/mo. (@3/@4)", oldval, param, #yes, votesneeded))
					else
						minetest.chat_send_all(S("Failed to change property tax rate from @1 sq km/mo to @2 sq km/mo. (@3/@4)", oldval, param, #yes, votesneeded))
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
				duration = 20,
				perc_needed = 0,

				can_vote = function(self, pname)
					return minetest.check_player_privs(pname,{vote_government = true})
				end,

				on_result = function(self, result, results)
					local yes = results.yes or {}
					local oldval = minetest.settings:get("money3.income_amount") or 0
					if #yes >= votesneeded then
						minetest.settings:set("money3.income_amount", tonumber(param))
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
		params = "<name>",
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
				duration = 20,
				perc_needed = 0,

				can_vote = function(self, pname)
					return minetest.check_player_privs(pname,{vote_government = true})
				end,

				on_result = function(self, result, results)
					local yes = results.yes or {}
					local oldval = minetest.settings:get("money3.initial_amount") or 0
					if #yes >= votesneeded then
						minetest.settings:set("money3.initial_amount", tonumber(param))
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
end

local storage = minetest.get_mod_storage()
if areas and money3 then
	taxes = minetest.deserialize(storage:get_string("taxes")) or {}
	local autopay = minetest.deserialize(storage:get_string("autopay")) or {}
	tax_account = storage:get_float("tax_account")
	local tax_rate = tonumber(minetest.settings:get("property_tax") or 0)
	
	areas:registerOnAdd(function(id, area)
		if tax_rate <= 0 then return end
		local name = area.owner
		local temparealist = table.copy(areas.areas)
		temparealist[id] = nil
		local diff = areas:get_player_total_area(name)-areas:get_player_total_area(name, temparealist)
		if diff < 0 then return end
		dateinfo = os.date("*t", os.time())
		local perc = (30-dateinfo.day)/30--I know, it won't be correct if there are more or less than 30 days in the current month, but whatever.
		if perc <= 0 then return end
		local tax = math.ceil((diff/1000)*tax_rate*perc)
		minetest.chat_send_player(name, "You have been charged a tax of $"..tax.." for protecting this area.")
		taxes[name] = math.ceil((taxes[name] or 0)) + tax
		if autopay[name] and not money3.dec(name, taxes[name]) then
			tax_account = tax_account + taxes[name]
			taxes[name] = nil
			storage:set_string("tax_account", tax_account)
		end
		storage:set_string("taxes", minetest.serialize(taxes))
	end)

	local function do_taxes()
		local dateinfo = os.date("*t", os.time())
		if storage:get_int("last_tax_month") ~= dateinfo.month then
			if tax_rate > 0 then
				local calcnames = {}
				for id, area in pairs(areas.areas) do
					local owner = (jobs and (jobs.list[jobs.split(area.owner, ":")[1]] or {}).ceo) or area.owner
					if not calcnames[owner] then
						taxes[owner] = math.ceil((taxes[owner] or 0) + (areas:get_player_total_area(owner)/1000)*tax_rate)
						if autopay[owner] and not money3.dec(owner, taxes[owner]) then
							tax_account = tax_account + taxes[owner]
							taxes[owner] = nil
						end
						calcnames[owner] = true
					end
				end
				storage:set_string("taxes", minetest.serialize(taxes))
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
			if not taxes[param] then
				return false, S("That player does have a tax balance to pay.")
			end
			
			return true, S("Player @1 has $@2 of taxes to pay.", param, taxes[param])
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
			if not taxes[name] then
				return false, "You have no tax balance to pay."
			end
			if not val or val > taxes[name] then val = taxes[name] end
			if money3.dec(name, val) then
				return false, "You do not have enough money in your account."
			end
			tax_account = tax_account + val
			taxes[name] = taxes[name]-val
			
			if taxes[name] == 0 then
				taxes[name] = nil
			end
			storage:set_string("tax_account", tax_account)
			storage:set_string("taxes", minetest.serialize(taxes))
			return true, S("Your payment of $@1 has been recieved, your balance is now $@2", val, (taxes[name] or 0))
		end
	})
	minetest.register_chatcommand("taxes_list", {
		params = S("<number or nil>"),
		description = S("List all players with tax balances. Add a number to check only balances at or above that number."),
		func = function(name, param)
			param = tonumber(param) or 1
			local str = "List of players with tax balances at or above $"..param..":"
			for name, balance in pairs(taxes) do
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
				duration = 20,
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
				duration = 20,
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
			duration = 20,
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
			duration = 20,
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
			duration = 20,
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
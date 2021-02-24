--
-- money3
--
-- Copyright © 2012 Bad_Command
-- Copyright © 2012 kotolegokot
-- Copyright © 2019 by luk3yx
--
-- This library is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.1 of the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU Lesser General Public
-- License along with this library; if not, write to the Free Software
-- Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
--

local storage = assert(...)
local worldpath = minetest.get_worldpath()

-- Raw get balance
local function raw_get_balance(name)
	local bal = tonumber(storage:get_string("balance-" .. name:lower()))
	if not bal or bal ~= bal then return nil end
	return bal
end

-- Migrate an old balance
local function migrate_old_balance(name, do_not_set)
	-- Make sure the name doesn't contain any insane characters
	if not name:find("^[A-Za-z0-9_%-]+$") then return end

	-- Try and get a handler to the balance file
	local path = worldpath .. "/money_" .. name .. ".txt"
	local file = io.open(path, "r")
	if not file then return end

	-- Read the credit and nuke the file.
	local credit = file:read("*n")
	file:close()
	os.remove(path)

	if not do_not_set and credit and credit == credit and credit >= 0 then
		return money3.set(name, (raw_get_balance(name) or 0) + credit)
	end
end

-- Combine the two above functions to provide seamless backwards compatibility
function money3.get(name)
	migrate_old_balance(name)
	return raw_get_balance(name)
end

-- Round a balance
function money3.round(balance)
	return math.floor(balance * 100) / 100
end

-- Set a balance
function money3.set(name, balance)
	migrate_old_balance(name, true)
	balance = money3.round(balance)
	storage:set_string("balance-" .. name:lower(), tostring(balance))
end

-- Check if a user exists
function money3.user_exists(name)
	local privs = minetest.get_player_privs(name)
	if not privs or not privs.money or not money3.get(name) then
		return false
	end

	return true
end
money3.has_credit = money3.user_exists

-- Add money
function money3.add(name, amount)
	if amount ~= amount or amount < 0 then
		return "The amount specified must be a positive non-NaN number."
	end

	local credit = money3.get(name)
	if not credit then
		return name .. " does not exist."
	end

	money3.set(name, credit + amount)
	return nil
end

function money3.dec(name, amount)
	if amount ~= amount or amount < 0 then
		return "The amount specified must be a positive non-NaN number."
	end

	local credit = money3.get(name)
	if not credit then
		return name .. " does not exist."
	elseif credit < amount then
		return name .. " does not have enough credit."
	end

	money3.set(name, credit - amount)
end

function money3.transfer(from, to, amount)
	if from == to then return end

	amount = money3.round(amount)

	if not money3.user_exists(from) then
		return from .. " does not have a credit account"
	elseif not money3.user_exists(to) then
		return to .. " does not have a credit account"
	end

	local err = money3.dec(from, amount)
	if err then return err end

	local err = money3.add(to, amount)
	if err then
		money3.add(from, amount)
		return err
	end

	minetest.log("action", "[money3] Credit transfer of " ..
		tostring(amount) .. " from " .. from .. " to " .. to)
end

-- Format currency
function money3.format(amount)
	return tostring(amount) .. (money3.currency_name or "cr")
end

-- Migrate balances and set the initial amount.
minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	if not money3.get(name) then
		money3.set(name, tostring(money3.initial_amount))
	end
end)

minetest.register_privilege("money",
	"Can use /money [pay <player> <amount>] command.")
minetest.register_privilege("money_admin", {
	description = "Full access to all /money commands.",
	give_to_singleplayer = false,
})

minetest.register_chatcommand("money", {
	privs = {money=true},
	params = "[<player> | pay/set/add/dec <player> <amount>]",
	description = "Operations with credit",
	func = function(name,  param)
		if param == "" then
			return true, "Your balance: " .. money3.format(money3.get(name))
		end

		local param1, reciever, amount = param:match("([^ ]+) ([^ ]+) (.+)")
		if not reciever and not amount then
			if not minetest.check_player_privs(name, {money_admin = true}) then
				return false, "Insufficient privileges!"
			elseif not money3.get(param) then
				return false, "Player named \"" ..
					param .. "\" does not exist or does not have an account."
			end
			return true, param .. "'s balance: " ..
				money3.format(money3.get(param))
		end

		if param1 ~= "pay" and param1 ~= "set" and param1 ~= "add" and
				param1 ~= "dec" or not reciever or not amount then
			return false, "Invalid parameters (see /help money)"
		elseif not money3.user_exists(reciever) then
			return false, "Player named \"" ..
				reciever .. "\" does not exist or does not have account."
		end

		amount = tonumber(amount)
		if not amount or amount ~= amount or amount < 0 then
			return false, "You must specify a valid non-negative number."
		end

		if param1 == "pay" then
			local err = money3.transfer(name, reciever, amount)
			if err then
				return false, err
			end
			local a = money3.format(amount)
			minetest.chat_send_player(reciever, "money3: " .. name ..
				" paid you " .. a)
			return true, "You paid " .. reciever .. " " .. a .. "."
		elseif not minetest.get_player_privs(name).money_admin then
			return false, "Insufficient privileges!"
		end

		local err = "Internal error!"
		if param1 == "add" then
			err = money3.add(reciever, amount)
		elseif param1 == "dec" then
			err = money3.dec(reciever, amount)
		elseif param1 == "set" then
			err = money3.set(reciever, amount)
		end

		return not err, err or "Done!"
	end,
})

-- A dummy money3.dignode() function. This is modified in convertval.lua.
function money3.dignode(pos, node, player) end

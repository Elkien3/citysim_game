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
local stat_file = minetest.get_worldpath() .. "/convert_stats"

minetest.register_chatcommand("convertval", {
	privs = {money = true},
	params = "",
	description = "Shows the current value of convertable items",
	func = function(name, param)
		minetest.chat_send_player(name, "Convertable item values:")
		for k, v in pairs(money3.stats) do
			minetest.chat_send_player(name, money3.convert_items[k].desc ..
				": "..money3.format(money3.stats[k].running_value) .. " each.")
		end
		return true, "Done!"
	end
})

function money3.dignode(pos, node, player)
	for k,v in pairs(money3.convert_items) do
		if ( node.name == money3.convert_items[k].dig_block ) then
			money3.stats[k].running_dug = money3.stats[k].running_dug + 1
		end
	end
end

function money3.calcConvertValues()
    core.log('warn',
        '[money3] Another mod tried to access money3.calcConvertValues.')
end

local function calcConvertValues()
	for k, stats in pairs(money3.stats) do
		stats.running_time = stats.running_time + 1
		stats.running_value = math.floor(
            money3.convert_items[k].amount
            + ((stats.running_time / 960)
            + (money3.stats[k].running_dug / 22)
            - (money3.stats[k].running_converted / 11))
        )

		if ( money3.stats[k].running_value < money3.convert_items[k].minval ) then
			money3.stats[k].running_val = money3.convert_items[k].minval
		end

		minetest.log("verbose", "Calculated " .. money3.convert_items[k].desc ..
            " value at "..tostring(money3.stats[k].running_value))
	end
	money3.save_stats()
    minetest.after(60, calcConvertValues)
end

function money3.save_stats()
	minetest.log("verbose", "Saving convert stats")
	local f = io.open(stat_file, "w")
	f:write(minetest.serialize(money3.stats))
	f:close()
end

local function load_old_stats()
    local f = io.open(stat_file, "r")
    if not f then return false end
        minetest.log("verbose", "[money3] Migrating legacy stats file.")
    local t = f:read("*all")
    f:close()
    os.remove(stat_file)

    if not t or t == "" then return false end
    storage:set_string("stats2", t)
    return minetest.deserialize(t)
end

function money3.load_stats()
    minetest.log("verbose", "[money3] Loading convert stats.")
	local t = storage:get_string("stats2")
    if not t or t == "" then return load_old_stats() end
    return minetest.deserialize(t)
end

money3.stats = money3.load_stats()

if not money3.stats then
	money3.stats = {}

	for key, val in pairs(money3.convert_items) do
		minetest.log("action", "[money3] Initial Convert Stats Setup for " ..
			money3.convert_items[key].desc)
		money3.stats[key] = {
			running_time = 0,
			running_dug = 0,
			running_converted = 0,
			running_value = money3.convert_items[key].amount
		}
	end
end

minetest.register_on_dignode(money3.dignode)

minetest.after(5, calcConvertValues)

local convert_options = {}
for k,v in pairs(money3.convert_items) do
	table.insert(convert_options, k)
end

minetest.register_chatcommand("convert", {
	privs = {money = true},
	params = "<" .. table.concat(convert_options, ", ") .. ">",
	description = "Converts certain ores to credits",
	func = function(name, param)
		-- check the parameters
		param = param:lower()
		if not money3.convert_items[param] then
			return false, "Invalid item!"
		end
		local item = money3.convert_items[param].item
		local amount = money3.stats[param].running_value
		local totalAmount = 0
		local totalItems = 0

		-- Look through their inventory for the item they chose.
		local player = minetest.get_player_by_name(name)
		local inventory = player:get_inventory()

		for i=1,inventory:get_size("main") do
			local inv_item = inventory:get_stack("main",i)
			if ( inv_item:get_name() == item ) then
				local add_amount = inv_item:get_count() * amount
				money3.add(name,add_amount)
				totalAmount = totalAmount + add_amount
				totalItems = totalItems + inv_item:get_count()
				inventory:set_stack("main",i,nil)
			end
		end

		money3.stats[param].running_converted =
			money3.stats[param].running_converted + totalItems
		return true, "You converted " .. tostring(totalItems) .. " " ..
			param .. " into "..tostring(totalAmount)..money3.currency_name
	end
})

convert_options = nil

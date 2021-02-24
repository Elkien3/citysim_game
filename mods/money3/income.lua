--
-- money3 income
-- Inspired by https://gitlab.com/VanessaE/currency/blob/master/income.lua
--
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

local income = {}

-- Earn income
function money3.earn_income(name)
	if type(name) ~= "string" then
		if not name or name.is_fake_player then return end
		name = name:get_player_name()
	end
	if income[name] then
		income[name] = nil
		money3.add(name, 10)

		-- Tell the player
		local msg = "[money3] You have earned " .. money3.format(10) ..
			". Your balance is now " .. money3.format(money3.get(name)) .. "."

		if minetest.colorize then msg = minetest.colorize("#CCCCCC", msg) end

		minetest.chat_send_player(name, msg)
		minetest.log("action", "[money3] Given " .. name .. " income.")
	end
end

-- The daemon
local time = 0
minetest.register_globalstep(function(dtime)
	time = time + dtime

	if time >= 720 then
		-- Reset everything
		time = 0
		for k, v in pairs(income) do income[k] = nil end

		-- Add money
		for _, player in ipairs(minetest.get_connected_players()) do
			income[player:get_player_name()] = true
		end
	end
end)

function money3.debug_step() time = 710 end

minetest.register_on_dignode(function(pos, oldnode, digger)
	money3.earn_income(digger)
end)

minetest.register_on_placenode(function(pos, newnode, placer)
	money3.earn_income(placer)
end)

-- Hijack the currency mod's income to disable it
if minetest.get_modpath("currency") and
		minetest.global_exists("players_income") then
	setmetatable(players_income, {
		__index = function(table, key) return 0 end,
		__newindex = function(table, key, value) end,
	})
end

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

money3 = {}
money3.version = 2.5

local modpath = assert(minetest.get_modpath("money3",
	"Please call this mod money3."))
dofile(modpath .. "/config.lua")

assert(not minetest.get_modpath("money2"), "money3 and money2 do not mix.")

local storage = minetest.get_mod_storage()
loadfile(modpath .. "/core.lua")(storage)

-- Only load convertval.lua if required.
if next(money3.convert_items) then
	loadfile(modpath .. "/convertval.lua")(storage)
end

-- Load income
if money3.enable_income then
	dofile(modpath .. "/income.lua")
end

-- Make sure the lurkcoin mod knows that money3 exists
if minetest.get_modpath("lurkcoin") then
	lurkcoin.change_bank({
		user_exists = money3.user_exists,
		getbal = money3.get,
		setbal = function(name, ...)
			if money3.user_exists(name) then
				money3.set(name, ...)
				return true
			end
			return false
		end,
		pay = function(from, to, amount)
			local err = money.transfer(from, to, amount)
			return not err, err
		end
	})
end

-- Backwards compatibility
rawset(_G, "money", money3)

-- I couldn't be bothered to update lockedsign.lua
if minetest.get_modpath("locked_sign") then
	dofile(modpath .. "/lockedsign.lua")
end

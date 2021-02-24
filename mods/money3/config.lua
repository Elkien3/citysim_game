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

local function setting(name, default)
	name = name
	local value
	if minetest.settings then
		value = minetest.settings:get("money3." .. name)
	else
		setting = minetest.setting_get("money3." .. name)
	end

	if value and type(default) == "number" then
		value = tonumber(value)
		if value ~= value then value = false end
	end

	if value and value ~= "" then
		money3[name] = value
	else
		money3[name] = default
	end
end

local function setting_bool(name, default)
	local value
	if minetest.settings then
		value = minetest.settings:get_bool("money3" .. name)
	else
		value = minetest.setting_getbool("money3" .. name)
	end

	if value == nil then
		money3[name] = default
	else
		money3[name] = value
	end
end

setting("initial_amount", 0)
setting("currency_name", "cr")

setting("convert_items", {
	gold = { item = "default:gold_ingot", dig_block="default:stone_with_gold", desc='Gold', amount=75, minval=25 },
	silver = { item = "moreores:silver_ingot", dig_block="moreores:mineral_silver", desc='Silver', amount = 27, minval=7}
})

setting_bool("enable_income", true)
if money3.enable_income and minetest.settings and
		minetest.settings:get_bool("creative_mode") then
	minetest.log("action", "[money3] Creative mode is enabled, force-disabling"
		.. " income.")
	money3.enable_income = false
end

-- Read the convert_items setting
if type(money3.convert_items) == "string" then
	local good, msg = pcall(minetest.deserialize, "return " ..
		money3.convert_items)
	if good and type(msg) == "table" then
		money3.convert_items = msg
	else
		money3.convert_items = {}
	end
end

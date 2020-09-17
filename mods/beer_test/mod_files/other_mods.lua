
--load configuration file from world folder
local MODPATH = minetest.get_modpath("beer_test")
local worldpath = minetest.get_worldpath()
local config = Settings(worldpath.."beer_test.conf")

local conf_table = config:to_table()

--look into readme.md how to change settings
local defaults = {
enable_default = "true",
enable_beesmod = "false",
}

--if not in conf file, create it.
for k, v in pairs(defaults) do
if conf_table[k] == nil then
config:set(k, v)
config:write();
end
end

-----------------
-- beer crafts --
-----------------

-- beer grains --

minetest.register_craft({
	output = "beer_test:mixed_beer_grain",
	type = "shapeless",
	recipe = {"beer_test:malt_tray_malt","beer_test:malt_tray_crystalised_malt","beer_test:malt_tray_black_malt","beer_test:hops_dried_2","beer_test:hops_dried_2","beer_test:hops_dried_2"},
})

--------------------
-- default crafts --
---------------------------------------
-- this dose not need any other mods --

if config:get("enable_default") == "true"  then
	minetest.log("info","Running in default mode")

	-- we use sugar instead of honey --

	minetest.register_craftitem("beer_test:sugar", {
		description = "Sugar ",
		inventory_image = "beer_test_sugar.png",
	})


	-- cooking to make sugar --
	-- yes i know this is like MineCraft but I cannot think of a better way :( --

	minetest.register_craft({
		type = "cooking",
		output = "beer_test:sugar",
		recipe = "default:papyrus",
	})

	-- craft for the mead --

	minetest.register_craft({
		output = "beer_test:mixed_mead_grain",
		type = "shapeless",
		recipe = {"default:apple","default:apple","default:apple","default:apple","beer_test:yeast","beer_test:sugar","beer_test:sugar","beer_test:sugar","beer_test:sugar"},
	})

end
---------------
-- bees mod -- 
------------------------------
-- This is for the bees mod --

if config:get("enable_beesmod") == "true"  then
minetest.log("info","Running in bees mod mode")

--[[
	-- craft for mead --
	minetest.register_craft({
		output = "beer_test:mixed_mead_grain","vessels:glass_bottle",
		type = "shapeless",
		recipe = {"default:apple","default:apple","default:apple","default:apple","beer_test:yeast","bees:bottle_honey","bees:bottle_honey","bees:bottle_honey","bees:bottle_honey"},
	})
]]--
end


-----------------
-- candles mod -- 
----------------------------
-- (broken do not enable) --
--[[
	minetest.register_craft({
		output = "beer_test:mixed_mead_grain",
		type = "shapeless",
		recipe = {"default:apple","default:apple","default:apple","default:apple","beer_test:yeast","candles:honey","candles:honey","candles:honey","candles:honey"},
	})
]] --


print("Beer_test:other_mods.lua                     [ok]")




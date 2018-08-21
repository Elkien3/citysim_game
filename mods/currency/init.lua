minetest.log("info", " Currency mod loading... ")
local modpath = minetest.get_modpath("currency")

dofile(modpath.."/craftitems.lua")
minetest.log("info", "[Currency] Craft_items Loaded!")
dofile(modpath.."/shop.lua")
minetest.log("info", "[Currency] Shop Loaded!")
--dofile(modpath.."/barter.lua")
--minetest.log("info", "[Currency]  Barter Loaded!")
dofile(modpath.."/safe.lua")
minetest.log("info", "[Currency] Safe Loaded!")
dofile(modpath.."/crafting.lua")
minetest.log("info", "[Currency] Crafting Loaded!")

if minetest.setting_getbool("creative_mode") then
	minetest.log("info", "[Currency] Creative mode in use, skipping basic income.")
else
	dofile(modpath.."/income.lua")
	minetest.log("info", "[Currency] Income Loaded!")
end

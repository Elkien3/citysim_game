---------------
--DEFINITIONS--
---------------
--[[
minetest.register_tool("knockout:bat", {
	description = "Knockout Bat | Knocks out players with less then 4 hearts",
	inventory_image = "knockout_bat.png",
})

minetest.register_craft({
	output = "knockout:bat",
	recipe = {
		{"", "group:wood", "group:wood"},
		{"", "default:steel_ingot", "group:wood"},
		{"group:wood", "", ""},
	}
})

--]]




--------------
--KNOCK OUT---
--------------
--knockout.register_tool("knockout:bat", 0.8, 8, 120)

-----------
--DEFAULT--
-----------

-- Fist
knockout.register_tool("", 0.6, 6, 80)

-- picks have no knockout chance
-- shovels have slight knockout chance with low knockout time
knockout.register_tool("default:shovel_wood", 0.1, 10, 20)
knockout.register_tool("default:shovel_stone", 0.05, 10, 20)
knockout.register_tool("default:shovel_steel", 0.07, 10, 20)
knockout.register_tool("default:shovel_bronze", 0.07, 10, 20)
knockout.register_tool("default:shovel_mese", 0.1, 10, 20)
knockout.register_tool("default:shovel_diamond", 0.1, 10, 20)
-- Low-level axes have a slight knockout chance with medium knockout time
knockout.register_tool("default:axe_wood", 0.3, 3, 100)
knockout.register_tool("default:axe_stone", 0.1, 4, 110)
-- Swords have a slight knockout chance with high knockout time, except for wooden sword = club
knockout.register_tool("default:sword_wood", 0.7, 6, 140)
knockout.register_tool("default:sword_stone", 0.3, 6, 150)
knockout.register_tool("default:sword_steel", 0.1, 7, 150)
knockout.register_tool("default:sword_bronze", 0.1, 7, 150)
knockout.register_tool("default:sword_mese", 0.05, 8, 160)
knockout.register_tool("default:sword_diamond", 0.05, 9, 160)
-- Hoes have no knockout chance

-----------------
--LOTT WEAPONS--
-----------------
if minetest.get_modpath("lottweapons") ~= nil then
	-- Battleaxes (Low knockout chance, high knockout time.)
	knockout.register_tool("lottweapons:wood_battleaxe", 0.2, 4, 140)
	knockout.register_tool("lottweapons:stone_battleaxe", 0.1, 6, 150)
	knockout.register_tool("lottweapons:copper_battleaxe", 0.05, 7, 150)
	knockout.register_tool("lottweapons:steel_battleaxe", 0.05, 7, 150)
	-- Warhammers (high knockout chance, medium knockout time for lower levels.)
	knockout.register_tool("lottweapons:wood_warhammer", 0.7, 7, 80)
	knockout.register_tool("lottweapons:stone_warhammer", 0.3, 4, 100)
	knockout.register_tool("lottweapons:copper_warhammer", 0.1, 4, 120)
	knockout.register_tool("lottweapons:steel_warhammer", 0.1, 5, 120)
	-- Spears have no knockout chance
	-- Daggers have no knockout chance
end

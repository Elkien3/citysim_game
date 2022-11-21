local orelist = table.copy(minetest.registered_ores)
minetest.clear_registered_ores()
local biomelist = {}

--DEFAULT
biomelist["default:stone_with_coal"] = {"rainforest", "rainforest_swamp", "rainforest_ocean", "rainforest_under",
	"coniferous_forest", "coniferous_forest_dunes", "coniferous_forest_ocean", "coniferous_forest_under"}
	
biomelist["default:stone_with_copper"] = {"deciduous_forest", "deciduous_forest_shore", "deciduous_forest_ocean", "deciduous_forest_under",
"savanna", "savanna_shore", "savanna_ocean", "savanna_under"}

biomelist["default:stone_with_tin"] = {"snowy_grassland", "snowy_grassland_ocean", "snowy_grassland_under",
	"grassland", "grassland_dunes", "grassland_ocean", "grassland_under"}

biomelist["default:stone_with_iron"] = {"coniferous_forest", "coniferous_forest_dunes", "coniferous_forest_ocean", "coniferous_forest_under",
	"taiga", "taiga_ocean", "taiga_under"}

biomelist["default:stone_with_gold"] = {"rainforest", "rainforest_swamp", "rainforest_ocean", "rainforest_under",
	"coniferous_forest", "coniferous_forest_dunes", "coniferous_forest_ocean", "coniferous_forest_under"}

biomelist["default:stone_with_mese"] = {"tundra_highland", "tundra", "tundra_beach", "tundra_ocean", "tundra_under",
	"icesheet", "icesheet_ocean", "icesheet_under"}

biomelist["default:stone_with_diamond"] = {"rainforest", "rainforest_swamp", "rainforest_ocean", "rainforest_under",
"savanna", "savanna_shore", "savanna_ocean", "savanna_under"}

biomelist["default:mese"] = {"tundra_highland", "tundra", "tundra_beach", "tundra_ocean", "tundra_under",
	"icesheet", "icesheet_ocean", "icesheet_under"}

--TECHNIC
biomelist["technic:mineral_uranium"] = {"taiga", "taiga_ocean", "taiga_under",
	"cold_desert", "cold_desert_ocean", "cold_desert_under"}

biomelist["technic:mineral_chromium"] = {"tundra_highland", "tundra", "tundra_beach", "tundra_ocean", "tundra_under",
	"desert", "desert_ocean", "desert_under"}

biomelist["technic:mineral_zinc"] = {"grassland", "grassland_dunes", "grassland_ocean", "grassland_under",
	"desert", "desert_ocean", "desert_under"}

biomelist["technic:mineral_lead"] = {"deciduous_forest", "deciduous_forest_shore", "deciduous_forest_ocean", "deciduous_forest_under",
	"sandstone_desert", "sandstone_desert_ocean", "sandstone_desert_under"}

--MOREORES
biomelist["moreores:mineral_silver"] = {"snowy_grassland", "snowy_grassland_ocean", "snowy_grassland_under",
	"cold_desert", "cold_desert_ocean", "cold_desert_under"}

biomelist["moreores:mineral_mithril"] = {"icesheet", "icesheet_ocean", "icesheet_under",
	"sandstone_desert", "sandstone_desert_ocean", "sandstone_desert_under"}
	
--OIL
biomelist["oil:oil_source"] = {"sandstone_desert", "sandstone_desert_ocean", "sandstone_desert_under",
	"savanna", "savanna_shore", "savanna_ocean", "savanna_under",
	"desert", "desert_ocean", "desert_under",
	"icesheet_ocean", "tundra_ocean", "taiga_ocean", "snowy_grassland_ocean", "grassland_ocean", "coniferous_forest_ocean", "deciduous_forest_ocean", "cold_desert_ocean", "rainforest_ocean"}

for name, def in pairs(orelist) do
	if biomelist[def.ore] then
		local scarcity = def.clust_scarcity
		local clust_num_ores = def.clust_num_ores
		--def.clust_scarcity = scarcity*4
		--def.clust_num_ores = clust_num_ores*.5
		--minetest.register_ore(def)
		def.clust_scarcity = scarcity*.5
		def.clust_num_ores = clust_num_ores*2
		def.biomes = biomelist[def.ore]
		minetest.register_ore(def)
	else
		minetest.register_ore(def)
	end
end

orelist = nil
biomelist = nil
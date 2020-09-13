local default_nodes = {
	{"stone", "stone"},
	{"cobble", "cobble",},
	{"mossycobble", "mossycobble"},
	{"brick", "brick"},
	{"sandstone", "sandstone" },
	{"steelblock", "steel_block"},
	{"goldblock", "gold_block"},
	{"copperblock", "copper_block"},
	{"bronzeblock", "bronze_block"},
	{"diamondblock", "diamond_block"},
	{"desert_stone", "desert_stone"},
	{"desert_cobble", "desert_cobble"},
	{"tree", "tree"},
	{"wood", "wood"},
	{"jungletree", "jungletree"},
	{"junglewood", "junglewood"},
	{"obsidian", "obsidian"},
	{"stonebrick", "stone_brick"},
	{"desert_stonebrick", "desert_stone_brick"},
	{"sandstonebrick", "sandstone_brick"},
	{"obsidianbrick", "obsidian_brick"},
	{"pine_tree", "pine_tree"},
	{"pine_wood", "pine_wood"},
}

for _, row in pairs(default_nodes) do
	local nodename = "default:" ..row[1]
	local ndef = minetest.registered_nodes[nodename]
	local texture = "default_" ..row[2].. ".png"
	letters.register_letters("default", row[1], nodename, ndef.description, texture) 
end


if minetest.get_modpath("darkage") then
	letters.register_letters("darkage", "marble", "darkage:marble", "Marble", "darkage_marble.png")
	letters.register_letters("darkage", "basalt", "darkage:basalt", "Basalt", "darkage_basalt.png")
	letters.register_letters("darkage", "serpentine", "darkage:serpentine", "Serpentine", "darkage_serpentine.png")
	letters.register_letters("darkage", "ors", "darkage:ors", "Old Red Sandstone", "darkage_ors.png")
	letters.register_letters("darkage", "schist", "darkage:schist", "Schist", "darkage_schist.png")
	letters.register_letters("darkage", "slate", "darkage:slate", "Slate", "darkage_slate.png")
	letters.register_letters("darkage", "gneiss", "darkage:gneiss", "Gneiss", "darkage_gneiss.png")
	letters.register_letters("darkage", "chalk", "darkage:chalk", "Chalk", "darkage_chalk.png")
	letters.register_letters("darkage", "ors_cobble", "darkage:ors_cobble", "Old Red Sandstone Cobble", "darkage_ors_brick.png")	
	letters.register_letters("darkage", "slate_cobble", "darkage:slate_cobble", "Slate Cobble", "darkage_slate_brick.png")
	letters.register_letters("darkage", "gneiss_cobble", "darkage:gneiss_cobble", "Gneiss Cobble", "darkage_gneiss_brick.png")
	letters.register_letters("darkage", "basalt_cobble", "darkage:basalt_cobble", "Basalt Cobble", "darkage_basalt_brick.png")
	letters.register_letters("darkage", "straw", "darkage:straw", "Straw", "darkage_straw.png")
	letters.register_letters("darkage", "straw_bale", "darkage:straw_bale", "Straw Bale", "darkage_straw_bale.png")
	letters.register_letters("darkage", "stone_brick", "darkage:stone_brick", "Stone Brick", "darkage_stone_brick.png")
	letters.register_letters("darkage", "marble_tile", "darkage:marble_tile", "Marble Tile", "darkage_marble_tile.png")
	letters.register_letters("darkage", "slate_tile", "darkage:slate_tile", "Slate Tile", "darkage_slate_tile.png")
end

if minetest.get_modpath("colouredstonebricks") then
	letters.register_letters("colouredstonebricks", "black", "colouredstonebricks:black", "Black", "colouredstonebricks_black.png")
	letters.register_letters("colouredstonebricks", "cyan", "colouredstonebricks:cyan", "Cyan", "colouredstonebricks_cyan.png")
	letters.register_letters("colouredstonebricks", "brown", "colouredstonebricks:brown", "Brown", "colouredstonebricks_brown.png")
	letters.register_letters("colouredstonebricks", "dark_blue", "colouredstonebricks:dark_blue", "Dark Blue", "colouredstonebricks_dark_blue.png")
	letters.register_letters("colouredstonebricks", "dark_green", "colouredstonebricks:dark_green", "Dark Green", "colouredstonebricks_dark_green.png")
	letters.register_letters("colouredstonebricks", "dark_grey", "colouredstonebricks:dark_grey", "Dark Gey", "colouredstonebricks_dark_grey.png")
	letters.register_letters("colouredstonebricks", "dark_pink", "colouredstonebricks:dark_pink", "Dark Pink", "colouredstonebricks_dark_pink.png")
	letters.register_letters("colouredstonebricks", "green", "colouredstonebricks:green", "Green", "colouredstonebricks_green.png")
	letters.register_letters("colouredstonebricks", "grey", "colouredstonebricks:grey", "Grey", "colouredstonebricks_grey.png")
	letters.register_letters("colouredstonebricks", "orange", "colouredstonebricks:orange", "Orange", "colouredstonebricks_orange.png")
	letters.register_letters("colouredstonebricks", "pink", "colouredstonebricks:pink", "Pink", "colouredstonebricks_pink.png")
	letters.register_letters("colouredstonebricks", "purple", "colouredstonebricks:purple", "Purple", "colouredstonebricks_purple.png")
	letters.register_letters("colouredstonebricks", "red", "colouredstonebricks:red", "Red", "colouredstonebricks_red.png")
	letters.register_letters("colouredstonebricks", "white", "colouredstonebricks:white", "White", "colouredstonebricks_white.png")
	letters.register_letters("colouredstonebricks", "yellow", "colouredstonebricks:yellow", "Yellow", "colouredstonebricks_yellow.png")
end

local orig_cactus_func = default.grow_cactus
default.grow_cactus = function(pos, node)
	local factor = 1/get_growth_multiplier(pos, "default:cactus")
	if math.random(4) <= factor then
		return orig_cactus_func(pos, node)
	else
		return
	end
end

local orig_papyrus_func = default.grow_papyrus
default.grow_papyrus = function(pos, node)
	local factor = 2/get_growth_multiplier(pos, "default:papyrus")
	if math.random(4) <= factor then
		return orig_papyrus_func(pos, node)
	else
		return
	end
end

local function get_growth_multiplier(pos, name)
	local id = minetest.get_biome_data(pos).biome
	local biome_name = minetest.get_biome_name(id)
	local multiplier = 1
	if name == "default:large_cactus_seedling" or name == "default:cactus" then
		if seasons_getseason and seasons_getseason() ~= "Summer" then
			multiplier = multiplier*.5
		end
		if string.find(biome_name, "savanna") or string.find(biome_name, "desert") or string.find(biome_name, "sandstone_desert") then
			multiplier = multiplier*.5
		end
		return multiplier
	end
	if ((name == "default:pine_sapling") and (string.find(biome_name, "coniferous_forest") or string.find(biome_name, "taiga")))
	or ((name == "default:sapling" or name == "default:aspen_sapling") and (string.find(biome_name, "deciduous_forest")))
	or ((name == "default:bush_sapling" ) and (string.find(biome_name, "deciduous_forest") or string.find(biome_name, "grassland") or string.find(biome_name, "snowy_grassland")))
	or ((name == "default:acacia_bush_sapling" or name == "default:acacia_sapling") and (string.find(biome_name, "savanna")))
	or ((name == "default:pine_bush_sapling") and (string.find(biome_name, "taiga") or string.find(biome_name, "snowy_grassland")))
	or ((name == "default:blueberry_bush_sapling" or name == "default:blueberry_bush_leaves_with_berries") and (string.find(biome_name, "grassland") or string.find(biome_name, "snowy_grassland")))
	or ((name == "default:junglesapling" or name == "default:emergent_jungle_sapling" or name == "default:papyrus") and (string.find(biome_name, "rainforest"))) then
		multiplier = multiplier * .5
	end
	if seasons_getseason and seasons_getseason() == "Winter" then
		multiplier = multiplier*2
	end
	return multiplier
end

local function overwrite_trees()
	local trees = {
		"default:bush_sapling",
		"default:blueberry_bush_sapling",
		"default:acacia_bush_sapling",
		"default:pine_bush_sapling",
		"default:sapling",
		"default:junglesapling",
		"default:emergent_jungle_sapling",
		"default:pine_sapling",
		"default:acacia_sapling",
		"default:aspen_sapling",
	}
	for id, name in pairs (trees) do
		minetest.override_item(name, {
			on_construct = function(pos)
				local growth_time = 6*60*60*get_growth_multiplier(pos, name)
				minetest.get_node_timer(pos):start(math.random(growth_time*.8, growth_time))
			end,
		})
	end
end
overwrite_trees()

minetest.override_item("default:blueberry_bush_leaves_with_berries", {
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		minetest.set_node(pos, {name = "default:blueberry_bush_leaves"})
		local growth_time = 12*60*60**get_growth_multiplier(pos, "default:blueberry_bush_leaves_with_berries")
		minetest.get_node_timer(pos):start(math.random(growth_time*.8, growth_time))
	end,
})

minetest.override_item("default:large_cactus_seedling", {
	on_construct = function(pos)
		local growth_time = 3800*get_growth_multiplier(pos, "default:large_cactus_seedling")
		minetest.get_node_timer(pos):start(math.random(growth_time*.8, growth_time))
	end,
})
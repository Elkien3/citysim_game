--mod adds bedrock boulders to impede mining >:) muahaha
if minetest.get_modpath("bedrock2") then
	--copied from gravel
	minetest.register_ore({
		ore_type        = "blob",
		ore             = "bedrock2:bedrock",
		wherein         = {"default:stone"},
		clust_scarcity  = 32 * 32 * 32,
		clust_size      = 6,
		y_max           = -512,
		y_min           = -31000,
		noise_threshold = 0.0,
		noise_params    = {
			offset = 0.5,
			scale = 0.2,
			spread = {x = 5, y = 5, z = 5},
			seed = 766,
			octaves = 1,
			persist = 0.0
		},
	})

	minetest.register_ore({
		ore_type        = "blob",
		ore             = "bedrock2:bedrock",
		wherein         = {"default:stone"},
		clust_scarcity  = 24 * 24 * 24,
		clust_size      = 8,
		y_max           = -1024,
		y_min           = -31000,
		noise_threshold = 0.0,
		noise_params    = {
			offset = 0.5,
			scale = 0.2,
			spread = {x = 5, y = 5, z = 5},
			seed = 766,
			octaves = 1,
			persist = 0.0
		},
	})

	minetest.register_ore({
		ore_type        = "blob",
		ore             = "bedrock2:bedrock",
		wherein         = {"default:stone"},
		clust_scarcity  = 20 * 20 * 20,
		clust_size      = 12,
		y_max           = -1536,
		y_min           = -31000,
		noise_threshold = 0.0,
		noise_params    = {
			offset = 0.5,
			scale = 0.2,
			spread = {x = 5, y = 5, z = 5},
			seed = 766,
			octaves = 1,
			persist = 0.0
		},
	})
end
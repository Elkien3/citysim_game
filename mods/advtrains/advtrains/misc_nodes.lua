--all nodes that do not fit in any other category

function advtrains.register_platform(modprefix, preset)
	local ndef=minetest.registered_nodes[preset]
	if not ndef then 
		minetest.log("warning", " register_platform couldn't find preset node "..preset)
		return
	end
	local btex=ndef.tiles
	if type(btex)=="table" then
		btex=btex[1]
	end
	local desc=ndef.description or ""
	local nodename=string.match(preset, ":(.+)$")
	minetest.register_node(modprefix .. ":platform_low_"..nodename, {
		description = attrans("@1 Platform (low)", desc),
		tiles = {btex.."^advtrains_platform.png", btex, btex, btex, btex, btex},
		groups = {cracky = 1, not_blocking_trains = 1, platform=1},
		sounds = default.node_sound_stone_defaults(),
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.1, -0.1, 0.5,  0  , 0.5},
				{-0.5, -0.5,  0  , 0.5, -0.1, 0.5}
			},
		},
		paramtype2="facedir",
		paramtype = "light",
		sunlight_propagates = true,
	})
	minetest.register_node(modprefix .. ":platform_high_"..nodename, {
		description = attrans("@1 Platform (high)", desc),
		tiles = {btex.."^advtrains_platform.png", btex, btex, btex, btex, btex},
		groups = {cracky = 1, not_blocking_trains = 1, platform=2},
		sounds = default.node_sound_stone_defaults(),
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5,  0.3, 0, 0.5,  0.5, 0.5},
				{-0.5, -0.5, 0.1  , 0.5,  0.3, 0.5}
			},
		},
		paramtype2="facedir",
		paramtype = "light",
		sunlight_propagates = true,
	})
	local diagonalbox = {
			type = "fixed",
			fixed = {
				{-0.5,  -0.5, 0.5, -0.25, 0.5, -0.8 },
				{-0.25, -0.5, 0.5 , 0,    0.5, -0.55},
				{0,     -0.5, 0.5 , 0.25, 0.5, -0.3 },
				{0.25 , -0.5, 0.5,  0.5,  0.5, -0.05}
			}
	}
	minetest.register_node(modprefix..":platform_45_"..nodename, {
		description = attrans("@1 Platform (45 degree)", desc),
		groups = {cracky = 1, not_blocking_trains = 1, platform=2},
		sounds = default.node_sound_stone_defaults(),
		drawtype = "mesh",
		mesh = "advtrains_platform_diag.b3d",
		selection_box = diagonalbox,
		collision_box = diagonalbox,
		tiles = {btex, btex.."^advtrains_platform_diag.png"},
		paramtype2 = "facedir",
		paramtype = "light",
		sunlight_propagates = true,
	})
	local diagonalbox_low = {
			type = "fixed",
			fixed = {
				{-0.5,  -0.5, 0.5, -0.25, 0, -0.8 },
				{-0.25, -0.5, 0.5 , 0,    0, -0.55},
				{0,     -0.5, 0.5 , 0.25, 0, -0.3 },
				{0.25 , -0.5, 0.5,  0.5,  0, -0.05}
			}
	}
	minetest.register_node(modprefix..":platform_45_low_"..nodename, {
		description = attrans("@1 Platform (low, 45 degree)", desc),
		groups = {cracky = 1, not_blocking_trains = 1, platform=2},
		sounds = default.node_sound_stone_defaults(),
		drawtype = "mesh",
		mesh = "advtrains_platform_diag_low.b3d",
		selection_box = diagonalbox_low,
		collision_box = diagonalbox_low,
		tiles = {btex, btex.."^advtrains_platform_diag.png"},
		paramtype2 = "facedir",
		paramtype = "light",
		sunlight_propagates = true,
	})
	minetest.register_craft({
		type="shapeless",
		output = modprefix .. ":platform_high_"..nodename.." 4",
		recipe = {
			"dye:yellow", preset, preset
		},
	})
	minetest.register_craft({
		type="shapeless",
		output = modprefix .. ":platform_low_"..nodename.." 4",
		recipe = {
			"dye:yellow", preset
		},
	})
	minetest.register_craft({
		type="shapeless",
		output = modprefix .. ":platform_45_"..nodename.." 2",
		recipe = {
			"dye:yellow", preset, preset, preset
		}
	})
end


advtrains.register_platform("advtrains", "default:stonebrick")
advtrains.register_platform("advtrains", "default:sandstonebrick")

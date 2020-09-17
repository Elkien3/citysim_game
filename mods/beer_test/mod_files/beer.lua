--------------------------
-- Items                --
--------------------------

--dont required, because its registered in farming

minetest.register_craftitem("beer_test:yeast", {
	description = "Yeast",
	inventory_image = "beer_test_yeast.png",
}) 

minetest.register_craftitem("beer_test:oat_grain", {
	description = "Oat Grain",
	inventory_image = "beer_test_oat_grain.png",
}) 

 --[[  -- keep this --
minetest.register_craftitem("beer_test:barley", {
	description = "Barley",
	inventory_image = "default_paper.png",
})
]]--

minetest.register_craftitem("beer_test:mixed_beer_grain", {
	description = "Mixed Beer Grain",
	inventory_image = "beer_test_mixed_malt.png",
})

minetest.register_craftitem("beer_test:mixed_ale_grain", {
	description = "Mixed Ale Grain",
	inventory_image = "beer_test_mixed_ale.png",
})

minetest.register_craftitem("beer_test:mixed_mead_grain", {
	description = "Mixed Apple Mead Grain",
	inventory_image = "beer_test_mixed_mead.png",
})

---------------------------------------------------------------
-- malt grain--
---------------------------------------------------------------
minetest.register_craftitem("beer_test:malt_grain_malt", {
	description = "Malt Grain",
	inventory_image = "beer_test_malt.png",
})

minetest.register_craftitem("beer_test:malt_grain_crystalised_malt", {
	description = "Crystalised Malt Grain",
	inventory_image = "beer_test_crystalised_malt.png",
})

minetest.register_craftitem("beer_test:malt_grain_black_malt", {
	description = "Black Malt Grain",
	inventory_image = "beer_test_black_malt.png",
})
--------------------------
-- Malt Tray            --
--------------------------

minetest.register_node("beer_test:tray", {
	description = "Malt Tray (Empty)",
	drawtype = "nodebox",
	tiles = {"default_wood.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky=3,oddly_breakable_by_hand=3},
	sounds = default.node_sound_wood_defaults(),
	
	on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			meta:set_string("infotext", "Malt Tray (Wheat)")
		end,
	node_box = {
			type = "fixed",
			fixed = {
            {-0.5, -0.5, 0.5, 0.5, 0, 0.44}, -- side back
			{-0.5, -0.5, -0.5, 0.5, -0.44, 0.5}, -- bottom
		    {-0.5, -0.5, -0.5, -0.44, 0, 0.5}, -- side l
            {0.44, -0.5, -0.5, 0.5, 0, 0.5},  -- side r
            {-0.5, -0.5, -0.44, 0.5, 0, -0.5}, -- frount


			},
		},
	selection_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
        },
})

minetest.register_node("beer_test:wheat_tray", {
	description = "Malt tray (wheat)",
	drawtype = "nodebox",
	tiles = {"default_wood.png^beer_test_wheat_tray.png", "default_wood.png", "default_wood.png",
	"default_wood.png", "default_wood.png", "default_wood.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky=3,oddly_breakable_by_hand=3},
	sounds = default.node_sound_wood_defaults(),
	
	on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			meta:set_string("infotext", "Malt Tray (Wheat)")
		end,
	node_box = {
			type = "fixed",
			fixed = {
            {-0.5, -0.5, 0.5, 0.5, 0, 0.44}, -- side back
			{-0.5, -0.5, -0.5, 0.5, -0.15, 0.5}, -- bottom
		    {-0.5, -0.5, -0.5, -0.44, 0, 0.5}, -- side l
            {0.44, -0.5, -0.5, 0.5, 0, 0.5},  -- side r
            {-0.5, -0.5, -0.44, 0.5, 0, -0.5}, -- frount


			},
		},
	selection_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
        },
})

minetest.register_node("beer_test:sprouting_tray", {
	description = "Malt tray (how did you get this?)",
	drawtype = "nodebox",
	tiles = {"default_wood.png^beer_test_wheat_tray_sprouting.png", "default_wood.png", "default_wood.png",
	"default_wood.png", "default_wood.png", "default_wood.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky=3,oddly_breakable_by_hand=3},
	drop = "beer_test:sprouting_tray_2",
	sounds = default.node_sound_wood_defaults(),
	
	on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			meta:set_string("infotext", "Malt Tray (Wheat sprouted)")
		end,
		node_box = {
			type = "fixed",
			fixed = {
            {-0.5, -0.5, 0.5, 0.5, 0, 0.44}, -- side back
			{-0.5, -0.5, -0.5, 0.5, -0.12, 0.5}, -- bottom
		    {-0.5, -0.5, -0.5, -0.44, 0, 0.5}, -- side l
            {0.44, -0.5, -0.5, 0.5, 0, 0.5},  -- side r
            {-0.5, -0.5, -0.44, 0.5, 0, -0.5}, -- frount


			},
		},
	selection_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
        },
})

minetest.register_node("beer_test:sprouting_tray_2", {
	description = "Malt tray (sprouting)",
	drawtype = "nodebox",
	tiles = {"default_wood.png^beer_test_wheat_tray_sprouting.png", "default_wood.png", "default_wood.png",
	"default_wood.png", "default_wood.png", "default_wood.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky=3,oddly_breakable_by_hand=3},
	sounds = default.node_sound_wood_defaults(),
	
	on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			meta:set_string("infotext", "Malt Tray (Wheat sprouted)")
		end,
		node_box = {
			type = "fixed",
			fixed = {
            {-0.5, -0.5, 0.5, 0.5, 0, 0.44}, -- side back
			{-0.5, -0.5, -0.5, 0.5, -0.12, 0.5}, -- bottom
		    {-0.5, -0.5, -0.5, -0.44, 0, 0.5}, -- side l
            {0.44, -0.5, -0.5, 0.5, 0, 0.5},  -- side r
            {-0.5, -0.5, -0.44, 0.5, 0, -0.5}, -- frount


			},
		},
	selection_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
        },
})

minetest.register_node("beer_test:malt_tray_malt", {
	description = "Malt tray (Malt)",
	drawtype = "nodebox",
	tiles = {"default_wood.png^beer_test_wheat_tray_dryed.png", "default_wood.png", "default_wood.png",
	"default_wood.png", "default_wood.png", "default_wood.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky=3,oddly_breakable_by_hand=3},
	sounds = default.node_sound_wood_defaults(),
	
	on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			meta:set_string("infotext", "Malt Tray (Malt)")
		end,
		node_box = {
			type = "fixed",
			fixed = {
            {-0.5, -0.5, 0.5, 0.5, 0, 0.44}, -- side back
			{-0.5, -0.5, -0.5, 0.5, -0.15, 0.5}, -- bottom
		    {-0.5, -0.5, -0.5, -0.44, 0, 0.5}, -- side l
            {0.44, -0.5, -0.5, 0.5, 0, 0.5},  -- side r
            {-0.5, -0.5, -0.44, 0.5, 0, -0.5}, -- frount


			},
		},
	selection_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
        },
})

minetest.register_node("beer_test:malt_tray_crystalised_malt", {
	description = "Malt tray (Crystalised Malt)",
	drawtype = "nodebox",
	tiles = {"default_wood.png^beer_test_wheat_tray_crystalised_malt.png", "default_wood.png", "default_wood.png",
	"default_wood.png", "default_wood.png", "default_wood.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky=3,oddly_breakable_by_hand=3},
	sounds = default.node_sound_wood_defaults(),
	
	on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			meta:set_string("infotext", "Malt Tray (Crystalised Malt)")
		end,
		node_box = {
			type = "fixed",
			fixed = {
            {-0.5, -0.5, 0.5, 0.5, 0, 0.44}, -- side back
			{-0.5, -0.5, -0.5, 0.5, -0.15, 0.5}, -- bottom
		    {-0.5, -0.5, -0.5, -0.44, 0, 0.5}, -- side l
            {0.44, -0.5, -0.5, 0.5, 0, 0.5},  -- side r
            {-0.5, -0.5, -0.44, 0.5, 0, -0.5}, -- frount


			},
		},
	selection_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
        },
})

minetest.register_node("beer_test:malt_tray_black_malt", {
	description = "Malt tray (Black Malt)",
	drawtype = "nodebox",
	tiles = {"default_wood.png^beer_test_wheat_tray_black_malt.png", "default_wood.png", "default_wood.png",
	"default_wood.png", "default_wood.png", "default_wood.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky=3,oddly_breakable_by_hand=3},
	sounds = default.node_sound_wood_defaults(),
	
	on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			meta:set_string("infotext", "Malt Tray (Black Malt)")
		end,
		node_box = {
			type = "fixed",
			fixed = {
            {-0.5, -0.5, 0.5, 0.5, 0, 0.44}, -- side back
			{-0.5, -0.5, -0.5, 0.5, -0.15, 0.5}, -- bottom
		    {-0.5, -0.5, -0.5, -0.44, 0, 0.5}, -- side l
            {0.44, -0.5, -0.5, 0.5, 0, 0.5},  -- side r
            {-0.5, -0.5, -0.44, 0.5, 0, -0.5}, -- frount


			},
		},
	selection_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
        },
})



--------------------------
-- wheat to malt stuff  --
--------------------------

minetest.register_abm({
	nodenames = {"beer_test:wheat_tray", "beer_test:sprouting_tray"},
	interval = 15,
	chance = 20,
	action = function(pos, node)
		pos.y = pos.y+1
		local nn = minetest.get_node(pos).name
		pos.y = pos.y-1
		if minetest.registered_nodes[nn] and minetest.registered_nodes[nn].walkable then
			minetest.set_node(pos, {name="beer_test:sprouting_tray"})
		end
		-- check if there is water nearby
		if minetest.find_node_near(pos, 5, {"group:water"}) then
			if node.name == "beer_test:wheat_tray" then
				minetest.set_node(pos, {name="beer_test:sprouting_tray"})
			end
		end
	end,
})

minetest.register_abm({
	nodenames = {"beer_test:sprouting_tray_2", "beer_test:malt_tray_malt"},
	interval = 15,
	chance = 20,
	action = function(pos, node)
		pos.y = pos.y+1
		local nn = minetest.get_node(pos).name
		pos.y = pos.y-1
		if minetest.registered_nodes[nn] and minetest.registered_nodes[nn].walkable then
			minetest.set_node(pos, {name="beer_test:malt_tray_malt"})
		end
		-- check if there is air nearby
		if minetest.find_node_near(pos, 5, {"air"}) then
			if node.name == "beer_test:sprouting_tray_2" then
				minetest.set_node(pos, {name="beer_test:malt_tray_malt"})
			end
		end
	end,
})

minetest.register_abm({
	nodenames = {"beer_test:malt_tray_malt", "beer_test:sprouting_tray"},
	interval = 15,
	chance = 30,
	action = function(pos, node)
		pos.y = pos.y+1
		local nn = minetest.get_node(pos).name
		pos.y = pos.y-1
		if minetest.registered_nodes[nn] and minetest.registered_nodes[nn].walkable then
			minetest.set_node(pos, {name="beer_test:malt_tray_malt"})
		end
		-- check if there is air nearby
		if minetest.find_node_near(pos, 5, {"group:water"}) then
			if node.name == "beer_test:malt_tray_malt" then
				minetest.set_node(pos, {name="beer_test:sprouting_tray"})
			end
		end
	end,
})




print("Beer_test: beer.lua                     [ok]")




--
-- Place seeds stuff
--
minetest.register_node("beer_test:growing_rope", {
	description = "Growing Suspension rope",
	drawtype = "nodebox",
	tiles = {"beer_test_rope.png", "beer_test_rope.png", "beer_test_rope_side.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = true,
	walkable = false,
	groups = {cracky=2},
	sounds = default.node_sound_wood_defaults(),
	node_box = {
			type = "fixed",
			fixed = {
				{-0.08, -0.08, -0.85, 0.08, 0.08, 0.85}, -- side f
				--{-0.1, -0.5, -0.1, 0.1, 0.7, 0.1}, -- floor

			},
		},
		selection_box = {
		type = "fixed",
		fixed = {
			{-0.15, -0.15, -0.85, 0.15, 0.15, 0.85}, -- side f
		},
	},
		on_punch = function(pos, node, puncher)
			local tool = puncher:get_wielded_item():get_name()
			if tool and tool == "beer_test:growing_rope_down" then
				node.name = "beer_test:growing_rope_1"
				minetest.env:set_node(pos, node)
				puncher:get_inventory():remove_item("main", ItemStack("beer_test:growing_rope_down"))
			end
		end
	})
	
	minetest.register_node("beer_test:growing_rope_down", {
	description = "Growing rope",
	drawtype = "nodebox",
	tiles = {"beer_test_rope.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = true,
	walkable = false,
	groups = {cracky=2},
	sounds = default.node_sound_wood_defaults(),
	node_box = {
			type = "fixed",
			fixed = {
				--{-0.1, -0.1, -0.9, 0.1, 0.1, 0.9}, -- side f
				{-0.06, -0.5, -0.06, 0.06, 0.5, 0.06}, -- floor

			},
		},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.1, -0.5, -0.1, 0.1, 0.5, 0.1}, -- side f
		},
	},
	
	})
	
minetest.register_node("beer_test:growing_rope_1", {
	description = "Growing rope",
	drawtype = "nodebox",
	tiles = {"beer_test_rope.png","beer_test_rope.png","beer_test_rope_side.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = true,
	walkable = false,
	groups = {cracky=2},
	sounds = default.node_sound_wood_defaults(),
	drop = {
		max_items = 2,
		items = {
			{ items = {'beer_test:growing_rope_down'} },
			{items = {'beer_test:growing_rope'} },
		}
	},
	node_box = {
			type = "fixed",
			fixed = {
				{-0.08, -0.08, -0.5, 0.08, 0.08, 0.5}, -- side f
				{-0.06, -0.5, -0.06, 0.06, 0.06, 0.06}, -- floor
				{-0.12, -0.12, -0.12, 0.12, 0.12, 0.12}, -- floor

			},
		},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.12, -0.5, -0.12, 0.12, 0.12, 0.12}, -- side f
		},
	},
	})

minetest.register_node("beer_test:hops_9", {
drawtype = "nodebox",
	tiles = {"beer_test_hops_8.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	drop = "beer_test:growing_rope_down",
	is_ground_content = true,
	walkable = false,
	buildable_to = true,
	groups = {cracky=2,not_in_creative_inventory=1},
	sounds = default.node_sound_wood_defaults(),
	node_box = {
			type = "fixed",
			fixed = {
				{-0.2, -0.5, -0.2, 0.2, 0.5, 0.2}, -- side f 
				{-0.3, -0.5, 0.2, 0.3, 0.5, 0.2}, -- side f 
				{-0.3, -0.5, -0.2, 0.3, 0.5, -0.2}, -- side f 
				{-0.2, -0.5, 0.3, -0.2, 0.5, -0.3}, -- side f 
				{0.2, -0.5, 0.3, 0.2, 0.5, -0.3}, -- side f 
				{-0.1, -0.5, -0.1, 0.1, 0.5, 0.1}, -- side f

			},
		},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.3, -0.5, -0.3, 0.3, 0.5, 0.3}, -- side f
		},
	},

})

minetest.register_node("beer_test:hops_9a", {
drawtype = "nodebox",
	tiles = {"beer_test_hops_9.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	drop = "beer_test:growing_rope_down",
	is_ground_content = true,
	walkable = false,
	buildable_to = true,
	groups = {cracky=2,not_in_creative_inventory=1},
	sounds = default.node_sound_wood_defaults(),
	node_box = {
			type = "fixed",
			fixed = {
				{-0.2, -0.5, -0.2, 0.2, 0.5, 0.2}, -- side f 
				{-0.3, -0.5, 0.2, 0.3, 0.5, 0.2}, -- side f 
				{-0.3, -0.5, -0.2, 0.3, 0.5, -0.2}, -- side f 
				{-0.2, -0.5, 0.3, -0.2, 0.5, -0.3}, -- side f 
				{0.2, -0.5, 0.3, 0.2, 0.5, -0.3}, -- side f 
				{-0.1, -0.5, -0.1, 0.1, 0.5, 0.1}, -- side f

			},
		},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.3, -0.5, -0.3, 0.3, 0.5, 0.3}, -- side f
		},
	},
	on_punch = function(pos, node, puncher)
			local tool = puncher:get_wielded_item():get_name()
			if tool and tool == "" then
				node.name = "beer_test:hops_9"
				minetest.env:set_node(pos, node)
				puncher:get_inventory():add_item("main", ItemStack("beer_test:hops"))
			end
		end
})

-- growing crops --

minetest.register_abm({
	nodenames = {"beer_test:hops_8", "beer_test:hops_9"},
	interval = 15,
	chance = 5,
	action = function(pos, node)
		pos.y = pos.y+1
		local nn = minetest.get_node(pos).name
		pos.y = pos.y-1
		if minetest.registered_nodes[nn] and minetest.registered_nodes[nn].walkable then
			minetest.set_node(pos, {name="beer_test:hops_8"})
		end
		-- check if there is air nearby
		if minetest.find_node_near(pos, 5, {"air"}) then
			if node.name == "beer_test:hops_8" then
				minetest.set_node(pos, {name="beer_test:hops_9"})
			end
		end
	end,
})

minetest.register_abm({
	nodenames = {"beer_test:hops_9", "beer_test:hops_9a"},
	interval = 30,
	chance = 50,
	action = function(pos, node)
		pos.y = pos.y+1
		local nn = minetest.get_node(pos).name
		pos.y = pos.y-1
		if minetest.registered_nodes[nn] and minetest.registered_nodes[nn].walkable then
			minetest.set_node(pos, {name="beer_test:hops_9"})
		end
		-- check if there is air nearby
		if minetest.find_node_near(pos, 5, {"air"}) then
			if node.name == "beer_test:hops_9" then
				minetest.set_node(pos, {name="beer_test:hops_9a"})
			end
		end
	end,
})

---------------
-- overrides --
---------------


print("Beer_test: plants-stuff.lua             [ok]")
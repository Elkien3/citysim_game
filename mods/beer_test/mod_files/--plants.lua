--
-- Place seeds stuff
--
local function place_seed(itemstack, placer, pointed_thing, plantname)
	local pt = pointed_thing
	-- check if pointing at a node
	if not pt then
		return
	end
	if pt.type ~= "node" then
		return
	end
	
	local under = minetest.get_node(pt.under)
	local above = minetest.get_node(pt.above)
	
	-- return if any of the nodes is not registered
	if not minetest.registered_nodes[under.name] then
		return
	end
	if not minetest.registered_nodes[above.name] then
		return
	end
	
	-- check if pointing at the top of the node
	if pt.above.y ~= pt.under.y+1 then
		return
	end
	
	-- check if you can replace the node above the pointed node
	if not minetest.registered_nodes[above.name].buildable_to then
		return
	end
	
	-- check if pointing at soil
	if minetest.get_item_group(under.name, "soil") <= 1 then
		return
	end
	
	-- add the node and remove 1 item from the itemstack
	minetest.add_node(pt.above, {name=plantname})
	if not minetest.setting_getbool("creative_mode") then
		itemstack:take_item()
	end
	return itemstack
end

-- plants hops --

minetest.register_craftitem("beer_test:seed_hops", {
	description = "hops Seed",
	inventory_image = "beer_test_hops_seed.png",
	
})

minetest.register_node("beer_test:hops", {
	description = "Hops",
	walkable = false,
	paramtype = "light",
	drawtype = "plantlike",
	tiles = {"beer_test_hops.png"},
	inventory_image = "beer_test_hops.png",
	groups = {snappy=3, flammable=2},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("beer_test:hops_dried_1", {
	description = "Dryed Hops",
	walkable = false,
	paramtype = "light",
	drawtype = "plantlike",
	tiles = {"beer_test_hops_dryed_1.png"},
	inventory_image = "beer_test_hops_dryed_1.png",
	groups = {snappy=3, flammable=2},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("beer_test:hops_dried_2", {
	description = "Dryed Hops",
	walkable = false,
	paramtype = "light",
	drawtype = "plantlike",
	tiles = {"beer_test_hops_dryed_2.png"},
	inventory_image = "beer_test_hops_dryed_2.png",
	groups = {snappy=3, flammable=2},
	sounds = default.node_sound_leaves_defaults(),
})

 
minetest.register_node("beer_test:hops_grow", {
	walkable = false,
	description = "Dryed Hops",
	paramtype = "light",
	drawtype = "plantlike",	
	drop = {
		max_items = 7,
		items = {
			{ items = {'beer_test:hops'} },
			{ items = {'beer_test:hops'}, rarity = 2},
			{ items = {'beer_test:hops'}, rarity = 5},
			{ items = {'beer_test:seed_hops'} },
			{ items = {'beer_test:seed_hops'}, rarity = 2 },
			{ items = {'beer_test:seed_hops'}, rarity = 5 },
			{items = {'beer_test:crop'} },
		}
	},
	tiles = {"beer_test_hops_8.png"},
	groups = {snappy=3, flammable=2},
	sounds = default.node_sound_leaves_defaults(),
	
	on_punch = function(pos, node, puncher)
		local tool = puncher:get_wielded_item():get_name()
		if tool and tool == "beer_test:crop" then
			node.name = "beer_test:hops_8"
			minetest.env:set_node(pos, node)
			puncher:get_inventory():remove_item("main", ItemStack("beer_test:crop"))
		end
	end
})


-- hops growing --

for i=1,8 do
	local drop = {
		items = {
			{items = {'beer_test:hops'},rarity=9-i},
			{items = {'beer_test:hops'},rarity=18-i*2},
			{items = {'beer_test:hops'},rarity=27-i*3},
			{items = {'beer_test:seed_hops'},rarity=9-i},
			{items = {'beer_test:seed_hops'},rarity=18-i*2},
			{items = {'beer_test:seed_hops'},rarity=27-i*3},
			{items = {'beer_test:crop'},rarity=1-i},
		}
	}
	minetest.register_node("beer_test:hops_"..i, {
		drawtype = "plantlike",
		tiles = {"beer_test_hops_"..i..".png^beer_test_crop.png"},
		paramtype = "light",
		walkable = false,
		is_ground_content = true,
		drop = drop,
		groups = {snappy=3,flammable=2,plant=1,hops=i,not_in_creative_inventory=1},
		sounds = default.node_sound_leaves_defaults(),
	})
end

minetest.register_abm({
	nodenames = {"group:hops"},
	neighbors = {"group:soil"},
	interval = 80,
	chance = 2,
	action = function(pos, node)
		-- return if already full grown
		if minetest.get_item_group(node.name, "hops") == 8 then
			return
		end
		
		-- check if on wet soil
		pos.y = pos.y-1
		local n = minetest.get_node(pos)
		if minetest.get_iteheat_traym_group(n.name, "soil") < 3 then
			return
		end
		pos.y = pos.y+1
		
		-- check light
		if not minetest.get_node_light(pos) then
			return
		end
		if minetest.get_node_light(pos) < 13 then
			return
		end
		
		-- grow
		local height = minetest.get_item_group(node.name, "hops") + 1
		minetest.set_node(pos, {name="beer_test:hops_"..height})
	end
})

 -- drying hops -- 
 
minetest.register_abm({
	nodenames = {"beer_test:hops", "beer_test:hops_dried_1"},
	interval = 15,
	chance = 30,
	action = function(pos, node)
		pos.y = pos.y+1
		local nn = minetest.get_node(pos).name
		pos.y = pos.y-1
		if minetest.registered_nodes[nn] and minetest.registered_nodes[nn].walkable then
			minetest.set_node(pos, {name="beer_test:hops_dried_2"})
		end
		-- check if there is water nearby
		if minetest.find_node_near(pos, 5, {"air"}) then
			-- if around air and no water dry out hops
			if node.name == "beer_test:hops" then
				minetest.set_node(pos, {name="beer_test:hops_dried_1"})
			end
		end
	end,
})

-- grow up up and away!--

minetest.register_abm({
	nodenames = {"beer_test:hops_9a"},
	neighbors = {"farming:soil_wet"},
	interval = 50,
	chance = 20,
	action = function(pos, node)
		pos.y = pos.y-1
		local name = minetest.get_node(pos).name
		if name == "farming:soil_wet" or name == "default:dirt_with_grass" or name == "farming:soil" or name == "default:dirt" then
			pos.y = pos.y+1
			local height = 0
			while minetest.get_node(pos).name == "beer_test:hops_9a" and height < 4 do
				height = height+1
				pos.y = pos.y+1
			end
			if height < 4 then
				if minetest.get_node(pos).name == "beer_test:growing_rope_down" then
					minetest.set_node(pos, {name="beer_test:hops_9"})
				end
			end
		end
	end,
})


-- crafts for hops --

minetest.register_craft({
	output = "beer_test:seed_hops",
	recipe = {
		{"beer_test:hops"},

	}
})

-- oats --

farming.register_plant("beer_test:oats", {
description = "Oat seed",
inventory_image = "beer_test_oats_seed.png",
steps = 8,
minlight = 13,
maxlight = LIGHT_MAX,
fertility = {"grassland"}
})




--old oats
--[[
minetest.register_craftitem("beer_test:seed_oats", {
	description = "oat Seed",
	inventory_image = "beer_test_oats_seed.png",
	
})

-- oats growing --

for i=1,8 do
	local drop = {
		items = {
			{items = {'beer_test:oats'},rarity=9-i},
			{items = {'beer_test:seed_oats'},rarity=9-i},
			{items = {'beer_test:seed_oats'},rarity=18-i*2},
			{items = {'beer_test:seed_oats'},rarity=18-i*2},
			{items = {'beer_test:seed_oats'},rarity=27-i*3},
			{items = {'beer_test:crop'},rarity=1-i},
		}
	}
	minetest.register_node("beer_test:oats_"..i, {
		drawtype = "plantlike",
		tiles = {"beer_test_oats_"..i..".png^beer_test_crop.png"},
		paramtype = "light",
		walkable = false,
		buildable_to = true,
		is_ground_content = true,
		drop = drop,
		selection_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5},
		},
		groups = {snappy=3,flammable=2,plant=1,oats=i,not_in_creative_inventory=1,attached_node=1},
		sounds = default.node_sound_leaves_defaults(),
	})
end

minetest.register_abm({
	nodenames = {"group:oats"},
	neighbors = {"group:soil"},
	interval = 80,
	chance = 20,
	action = function(pos, node)
		-- return if already full grown
		if minetest.get_item_group(node.name, "oats") == 8 then
			return
		end
		
		-- check if on wet soil
		pos.y = pos.y-1
		local n = minetest.get_node(pos)
		if minetest.get_item_group(n.name, "soil") < 3 then
			return
		end
		pos.y = pos.y+1
		
		-- check light
		if not minetest.get_node_light(pos) then
			return
		end
		if minetest.get_node_light(pos) < 13 then
			return
		end
		
		-- grow
		local height = minetest.get_item_group(node.name, "oats") + 1
		minetest.set_node(pos, {name="beer_test:oats_"..height})
	end
})
]]

-----------------
-- wild plants --
-----------------

-- wild oats --

minetest.register_node("beer_test:wild_oats", {
	description = "Wild Oats",
	paramtype = "light",
	walkable = false,
	drop = "beer_test:seed_oats",
	drawtype = "plantlike",
	paramtype2 = "facedir",
	tiles = {"beer_test_oats_8.png"},
	groups = {chopspy=3, oddly_breakable_by_hand=3, flammable=2, plant=1},
	sounds = default.node_sound_wood_defaults(),
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.35, 0.5}, -- side f
		},
	},
})

-- hops --

minetest.register_node("beer_test:wild_hops", {
drawtype = "nodebox",
description = "Wild hops",
	tiles = {"beer_test_hops_8.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	drop = "beer_test:seed_hops",
	is_ground_content = true,
	walkable = false,
	buildable_to = true,
	groups = {cracky=2},
	--light_source = LIGHT_MAX-1,
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




-- crop --

minetest.register_node("beer_test:crop", {
	description = "Crop",
	paramtype = "light",
	walkable = false,
	drawtype = "plantlike",
	paramtype2 = "facedir",
	tiles = {"beer_test_crop.png"},
	groups = {chopspy=3, oddly_breakable_by_hand=3, flammable=2, plant=1},
	sounds = default.node_sound_wood_defaults(),
	
	on_punch = function(pos, node, puncher)
		local tool = puncher:get_wielded_item():get_name()
		if tool and tool == "beer_test:seed_hops" then
			node.name = "beer_test:hops_1"
			minetest.env:set_node(pos, node)
			puncher:get_inventory():remove_item("main", ItemStack("beer_test:seed_hops"))
		end
			
		local tool = puncher:get_wielded_item():get_name()
		if tool and tool == "beer_test:seed_oats" then
			node.name = "beer_test:oats_1"
			minetest.env:set_node(pos, node)
			puncher:get_inventory():remove_item("main", ItemStack("beer_test:seed_oats"))
			
		end
	end		
})

-- 



 print("Beer_test: plants.lua                   [ok]")

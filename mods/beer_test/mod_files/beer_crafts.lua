
--------------------
-- general crafts --
-------------------- 

-- tankards crafts -- 
 
 minetest.register_craft({
	output = "beer_test:tankard",
	recipe = {
		{"default:wood","default:wood", "default:steel_ingot"},
		{"default:steel_ingot","", "default:steel_ingot"},
		{"default:steel_ingot","default:steel_ingot", "default:steel_ingot"},
	}
})

 minetest.register_craft({
	output = "beer_test:seed_oats",
	recipe = {
		{"beer_test:oats"},
	}
})

 minetest.register_craft({
	output = "beer_test:barrel 6",
	recipe = {
		{"default:wood","default:wood", "default:wood"},
		{"default:steel_ingot","default:steel_ingot", "default:steel_ingot"},
		{"default:wood","default:wood", "default:wood"},
	}
})

-- crafts wheat tray --


 minetest.register_craft({
	output = "beer_test:tray",
	recipe = {
		{"default:stick","", "default:stick"},
		{"default:wood","default:wood", "default:wood"},
	}
})


 minetest.register_craft({
	output = "beer_test:wheat_tray",
	recipe = {
		{"farming:wheat","farming:wheat", "farming:wheat"},
		{"farming:wheat","farming:wheat", "farming:wheat"},
		{"","beer_test:tray", ""},
	}
})

 minetest.register_craft({
	output = "beer_test:wheat_tray",
	recipe = {
		{"farming:wheat","farming:wheat", "farming:wheat"},
		{"farming:wheat","farming:wheat", "farming:wheat"},
		{"default:wood","default:wood", "default:wood"},
	}
})



-- malt grain crafts -- 

 minetest.register_craft({
	type = "shapeless",
	output = "beer_test:malt_grain_malt",
	recipe = {"beer_test:malt_tray_malt"},
	replacements = {
	{"beer_test:malt_tray_malt", "beer_test:tray"}
   }
})


 minetest.register_craft({
	type = "shapeless",
	output = "beer_test:malt_grain_crystalised_malt",
	recipe = {"beer_test:malt_tray_crystalised_malt"},
	replacements = {
		{"beer_test:malt_tray_crystalised_malt", "beer_test:tray"}
	}
})


 minetest.register_craft({
	type = "shapeless",
	output = "beer_test:malt_grain_black_malt",
	recipe = {"beer_test:malt_tray_black_malt"},
	replacements = {
		{"beer_test:malt_tray_black_malt", "beer_test:tray"}
	}
})

-- crafts for plant stuff --

 minetest.register_craft({
	output = "beer_test:growing_rope",
	recipe = {
		{"farming:cotton","farming:cotton", "farming:cotton"},
	}
})

 minetest.register_craft({
	output = "beer_test:growing_rope",
	recipe = {
		{"farming:cotton","farming:cotton", "farming:cotton"},
		{"default:stick","",""},
	}
})

-- crafts for plant stuff --

 minetest.register_craft({
	output = "beer_test:growing_rope_down",
	recipe = {
		{"farming:cotton"},
		{"farming:cotton"},
		{"farming:cotton"},
	}
})

 minetest.register_craft({
	output = "beer_test:growing_rope_down",
	recipe = {
		{"","farming:cotton"},
		{"","farming:cotton"},
		{"default:stick","farming:cotton"},
	}
})

-- craft for crops --

minetest.register_craft({
	output = "beer_test:crop 2",
	recipe = {
		{"default:stick","", "default:stick"},
		{"default:stick","", "default:stick"},
		{"default:stick","", "default:stick"},
	}
})

-----------------
-- beer crafts --
-----------------

-- beer grains --

minetest.register_craft({
	output = "beer_test:mixed_beer_grain",
	type = "shapeless",
	recipe = {"beer_test:malt_grain_malt","beer_test:malt_grain_crystalised_malt","beer_test:malt_grain_black_malt","beer_test:hops_dried_2","beer_test:hops_dried_2","beer_test:hops_dried_2"},
	replacements = {
		{"beer_test:malt_tray_malt", "beer_test:tray"},
	}
})


minetest.register_craft({
	output = "beer_test:mixed_ale_grain",
	type = "shapeless",
	recipe = {"beer_test:malt_tray_malt","beer_test:malt_tray_crystalised_malt","beer_test:malt_tray_black_malt","beer_test:yeast","beer_test:oats","beer_test:oats"},
})

-- temp crafts --

 minetest.register_craft({
	output = "beer_test:barrel_mixed_beer_grain",
	type = "shapeless",
	recipe = {"beer_test:mixed_beer_grain","beer_test:barrel"},
})

 minetest.register_craft({
	output = "beer_test:barrel_mixed_ale_grain",
	type = "shapeless",
	recipe = {"beer_test:mixed_ale_grain","beer_test:barrel"},
})



-------------
-- cooking --
-------------

minetest.register_craft({
	type = "cooking",
	output = "beer_test:yeast",
	recipe = "farming:wheat",
})

minetest.register_craft({
	type = "cooking",
	output = "beer_test:malt_tray_crystalised_malt",
	recipe = "beer_test:malt_tray_malt",
})

minetest.register_craft({
	type = "cooking",
	output = "beer_test:malt_tray_black_malt",
	recipe = "beer_test:malt_tray_crystalised_malt",
})

minetest.register_craft({
	type = "cooking",
	output = "beer_test:oat_grain",
	recipe = "beer_test:oats",
})

---------------
-- functions --
---------------

function default.node_sound_barrel_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name="default_wood_footstep", gain=0.5}
	table.dug = table.dug or
			{name="beertest_break_barrle", gain=1.0}
	default.node_sound_defaults(table)
	return table
end

function default.node_sound_tankard_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name="default_wood_footstep", gain=0.5}
	table.dug = table.dug or
			{name="beertest_break_tankard", gain=1.0}
	table.place = table.place or
			{name="beertest_place_tankard", gain=1.0}
	default.node_sound_defaults(table)
	return table
end

------------------
-- Spawn Things --
------------------


function default.make_hops(pos, size)
	for y=0,size-1 do
		local p = {x=pos.x, y=pos.y+y, z=pos.z}
		local nn = minetest.get_node(p).name
		if minetest.registered_nodes[nn] and
			minetest.registered_nodes[nn].buildable_to then
			minetest.set_node(p, {name="beer_test:wild_hops"})
		else
			return
		end
	end
end



minetest.register_on_generated(function(minp, maxp, seed)
if maxp.y >= 2 and minp.y <= 0 then
	-- Generate hops
	local perlin1 = minetest.get_perlin(354, 3, 0.7, 100)
	-- Assume X and Z lengths are equal
	local divlen = 8
	local divs = (maxp.x-minp.x)/divlen+1;
	for divx=0,divs-1 do
	for divz=0,divs-1 do
		local x0 = minp.x + math.floor((divx+0)*divlen)
		local z0 = minp.z + math.floor((divz+0)*divlen)
		local x1 = minp.x + math.floor((divx+1)*divlen)
		local z1 = minp.z + math.floor((divz+1)*divlen)
		-- Determine hops amount from perlin noise
		local hops_amount = math.floor(perlin1:get2d({x=x0, y=z0}) ^ 3 * 9)
		-- Find random positions for hops based on this random
		local pr = PseudoRandom(seed+1)
		for i=0,hops_amount do
			local x = pr:next(x0, x1)
			local z = pr:next(z0, z1)
				if minetest.get_node({x=x,y=1,z=z}).name == "default:dirt_with_grass" and
					minetest.find_node_near({x=x,y=1,z=z}, 1, "default:tree") then
					default.make_hops({x=x,y=2,z=z}, pr:next(2, 4))
				end
			end
		end
	end
	local perlin1 = minetest.get_perlin(329, 3, 0.6, 100)
	-- Assume X and Z lengths are equal
	local divlen = 16
	local divs = (maxp.x-minp.x)/divlen+1;
	for divx=0,divs-1 do
	for divz=0,divs-1 do
		local x0 = minp.x + math.floor((divx+0)*divlen)
		local z0 = minp.z + math.floor((divz+0)*divlen)
		local x1 = minp.x + math.floor((divx+1)*divlen)
		local z1 = minp.z + math.floor((divz+1)*divlen)
		-- Determine grass amount from perlin noise
		local grass_amount = math.floor(perlin1:get2d({x=x0, y=z0}) ^ 1 * 5)
		-- Find random positions for grass based on this random
		local pr = PseudoRandom(seed+1)
		for i=0,grass_amount do
			local x = pr:next(x0, x1)
			local z = pr:next(z0, z1)
		-- Find ground level (0...15)
			local ground_y = nil
			for y=30,0,-1 do
				if minetest.get_node({x=x,y=y,z=z}).name ~= "air" then
					ground_y = y
					break
				end
			end
			
			if ground_y then
				local p = {x=x,y=ground_y+1,z=z}
				local nn = minetest.get_node(p).name
				-- Check if the node can be replaced
				if minetest.registered_nodes[nn] and
					minetest.registered_nodes[nn].buildable_to then
					nn = minetest.get_node({x=x,y=ground_y,z=z}).name
					-- If dirt with grass, add oats
					if nn == "default:dirt_with_grass" then
						minetest.set_node(p,{name="beer_test:wild_oats"})
					end
				end
			end
		end
	end
	end
end
end)


	
print("Beer_test: beer_crafts.lua                     [ok]")




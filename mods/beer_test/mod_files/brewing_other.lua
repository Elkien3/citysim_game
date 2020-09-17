--- items ---

 --[[  -- keep this --
minetest.register_craftitem("beer_test:barrle_tap", {
	description = "Barrel Tap",
	inventory_image = "default_paper.png",
}) 
]] --
-----------------
-- beer barrle --
-----------------

minetest.register_node("beer_test:barrel", {
    description = "Barrel",
    drawtype = "nodebox",
    tiles = {"beer_test_barrel_top.png", "beer_test_barrel_top.png", "beer_test_barrel_side_2.png",
    "beer_test_barrel_side_2.png", "beer_test_barrel_side_2.png", "beer_test_barrel_side_2.png"},
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {cracky=2},
    sounds = default.node_sound_wood_defaults(),
	on_punch = function(pos, node, puncher)
		local tool = puncher:get_wielded_item():get_name()
		if tool and tool == "beer_test:mixed_beer_grain" then
			node.name = "beer_test:barrel_mixed_beer_grain"
			minetest.env:set_node(pos, node)
			puncher:get_inventory():remove_item("main", ItemStack("beer_test:mixed_beer_grain"))
		end
			
		local tool = puncher:get_wielded_item():get_name()
		if tool and tool == "beer_test:mixed_ale_grain" then
			node.name = "beer_test:barrel_mixed_ale_grain"
			minetest.env:set_node(pos, node)
			puncher:get_inventory():remove_item("main", ItemStack("beer_test:mixed_ale_grain"))
			
		end
		
		local tool = puncher:get_wielded_item():get_name()
		if tool and tool == "beer_test:mixed_mead_grain" then
			node.name = "beer_test:barrel_mixed_mead_grain"
			minetest.env:set_node(pos, node)
			puncher:get_inventory():remove_item("main", ItemStack("beer_test:mixed_mead_grain"))
			
		end
	end,
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_string("infotext", "Barrel")
    end,
    node_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, 0.5, 0.5, 0.5, 0.35}, -- side f
            {-0.5, -0.5, -0.5, 0.5, -0.35, 0.5}, -- bottom
            {-0.5, -0.5, -0.5, -0.35, 0.5, 0.5}, -- side l
            {0.35, -0.5, -0.5, 0.5, 0.5, 0.5},  -- side r
            {-0.5, -0.5, -0.35, 0.5, 0.5, -0.5}, -- frount
             
        },
    },
    selection_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
        },
    }, 
		
})

-- tankard --

minetest.register_node("beer_test:tankard", {
	description = "Tankard",
	stack_max = 16,
	wield_image = "beer_test_tankard.png",
	inventory_image = "beer_test_tankard.png",
	tiles = {"beer_test_tankard_top.png","beer_test_tankard_top.png","beer_test_tankard_side.png",
	"beer_test_tankard_side.png","beer_test_tankard_side.png","beer_test_tankard_side.png"},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky=3,dig_immediate=3},
	sounds = default.node_sound_tankard_defaults(),
	node_box = {
		type = "fixed",
		fixed = {
			{-0.18, -0.5, 0.125, 0.18, 0.18, 0.18},
			{0.125, -0.5, -0.18, 0.18, 0.18, 0.18},
			{-0.18, -0.5, -0.18, -0.125, 0.18, 0.18},
			{-0.18, -0.5, -0.18, 0.18, 0.18, -0.125},
			{-0.25, -0.5, -0.25, 0.25, -0.44, 0.25},
			{-0.315, -0.3, 0.04, -0.36 , 0.1, -0.05},
			{-0.15, -0.0, 0.04, -0.35 , 0.05, -0.05},
			{-0.15, -0.25, 0.04, -0.35 , -0.2, -0.05},
			-- side , top , side , side , bottom, side,
				
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			--{-0.25, -0.5, -0.25, 0.25, 0.25, 0.25},
			{-0.125, -0.5, -0.125, 0.125, 0.18, 0.125},
			{-0.18, -0.5, -0.18, 0.18, 0.18, 0.18},
			{-0.25, -0.5, -0.25, 0.25, -0.44, 0.25}, -- INNER ONE --
			--{-0.25, -0.5, -0.25, 0.25, -0.125, 0.25},
			{-0.315, -0.3, 0.04, -0.36 , 0.1, -0.05},
			{-0.15, -0.0, 0.04, -0.315 , 0.05, -0.05},
			{-0.15, -0.25, 0.04, -0.315 , -0.2, -0.05},
		},
	},
})

-- Rum Stuff --

minetest.register_node("beer_test:barrel_rum", {
   description = "Rum Barrel",
   tiles = {"beer_test_barrel_side_2.png", "beer_test_barrel_side_2.png", "beer_test_barrel_side.png",
   "beer_test_barrel_side.png", "beer_test_barrel_top.png", "beer_test_barrel_top.png"},
   paramtype = "light",
   paramtype2 = "facedir",
   drop = "beer_test:barrel",
   sounds = default.node_sound_barrel_defaults(),
   groups = {cracky=2},
   --sounds = default.node_sound_wood_defaults(),
   on_construct = function(pos)
         local meta = minetest.get_meta(pos)
         meta:set_string("infotext", "Rum (Brewed)")
      end,
    
   on_punch = function(pos, node, puncher)
      local tool = puncher:get_wielded_item():get_name()
      if tool and tool == "beer_test:tankard" then
         node.name = "beer_test:barrel_rum"
         minetest.env:set_node(pos, node)
         puncher:get_inventory():remove_item("main", ItemStack("beer_test:tankard"))
         puncher:get_inventory():add_item("main", ItemStack("beer_test:tankard_rum"))
      end
   end  
})

-- tankards rum --

minetest.register_node("beer_test:tankard_rum", {
	description = "Tankard with Rum",
	stack_max = 1,
	wield_image = "beer_test_tankard_beer.png",
	inventory_image = "beer_test_tankard_beer.png",
	tiles = {"beer_test_tankard_top_rum.png","beer_test_tankard_top.png","beer_test_tankard_side.png",
	"beer_test_tankard_side.png","beer_test_tankard_side.png","beer_test_tankard_side.png"},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky=3,dig_immediate=3},
	on_use = minetest.item_eat(1, "beer_test:tankard"),
	sounds = default.node_sound_tankard_defaults(),
	node_box = {
		type = "fixed",
		fixed = {
			{-0.18, -0.5, 0.125, 0.18, 0.18, 0.18},
			{0.125, -0.5, -0.18, 0.18, 0.18, 0.18},
			{-0.18, -0.5, -0.18, -0.125, 0.18, 0.18},
			{-0.18, -0.5, -0.18, 0.18, 0.18, -0.125},
			{-0.25, -0.5, -0.25, 0.25, -0.44, 0.25},
			{-0.315, -0.3, 0.04, -0.36 , 0.1, -0.05},
			{-0.15, -0.0, 0.04, -0.35 , 0.05, -0.05},
			{-0.15, -0.25, 0.04, -0.35 , -0.2, -0.05},
			{-0.18, -0.5, -0.18, 0.18, 0.1, 0.18},
			-- side , top , side , side , bottom, side,
				
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			--{-0.25, -0.5, -0.25, 0.25, 0.25, 0.25},
			{-0.125, -0.5, -0.125, 0.125, 0.18, 0.125},
			{-0.18, -0.5, -0.18, 0.18, 0.18, 0.18},
			{-0.25, -0.5, -0.25, 0.25, -0.44, 0.25}, -- INNER ONE --
			--{-0.25, -0.5, -0.25, 0.25, -0.125, 0.25},
			{-0.315, -0.3, 0.04, -0.36 , 0.1, -0.05},
			{-0.15, -0.0, 0.04, -0.315 , 0.05, -0.05},
			{-0.15, -0.25, 0.04, -0.315 , -0.2, -0.05},
		},
	},
})

-- moonsine --

minetest.register_node("beer_test:barrel_moonsine", {
   description = "Moonsine Barrel",
   tiles = {"beer_test_barrel_side_2.png", "beer_test_barrel_side_2.png", "beer_test_barrel_side.png",
   "beer_test_barrel_side.png", "beer_test_barrel_top.png", "beer_test_barrel_top.png"},
   paramtype = "light",
   paramtype2 = "facedir",
   drop = "beer_test:barrel",
   sounds = default.node_sound_barrel_defaults(),
   groups = {cracky=2},
   --sounds = default.node_sound_wood_defaults(),
   on_construct = function(pos)
         local meta = minetest.get_meta(pos)
         meta:set_string("infotext", "Moonsine (Brewed)")
      end,
    
   on_punch = function(pos, node, puncher)
      local tool = puncher:get_wielded_item():get_name()
      if tool and tool == "beer_test:tankard" then
         node.name = "beer_test:barrel_moonsine"
         minetest.env:set_node(pos, node)
         puncher:get_inventory():remove_item("main", ItemStack("beer_test:tankard"))
         puncher:get_inventory():add_item("main", ItemStack("beer_test:tankard_moonsine"))
      end
   end  
})

-- tankards rum --

minetest.register_node("beer_test:tankard_moonsine", {
	description = "Tankard with Moonsine",
	stack_max = 1,
	wield_image = "beer_test_tankard_beer.png",
	inventory_image = "beer_test_tankard_beer.png",
	tiles = {"beer_test_tankard_top_moonsine.png","beer_test_tankard_top.png","beer_test_tankard_side.png",
	"beer_test_tankard_side.png","beer_test_tankard_side.png","beer_test_tankard_side.png"},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky=3,dig_immediate=3},
	on_use = minetest.item_eat(1, "beer_test:tankard"),
	sounds = default.node_sound_tankard_defaults(),
	node_box = {
		type = "fixed",
		fixed = {
			{-0.18, -0.5, 0.125, 0.18, 0.18, 0.18},
			{0.125, -0.5, -0.18, 0.18, 0.18, 0.18},
			{-0.18, -0.5, -0.18, -0.125, 0.18, 0.18},
			{-0.18, -0.5, -0.18, 0.18, 0.18, -0.125},
			{-0.25, -0.5, -0.25, 0.25, -0.44, 0.25},
			{-0.315, -0.3, 0.04, -0.36 , 0.1, -0.05},
			{-0.15, -0.0, 0.04, -0.35 , 0.05, -0.05},
			{-0.15, -0.25, 0.04, -0.35 , -0.2, -0.05},
			{-0.18, -0.5, -0.18, 0.18, 0.1, 0.18},
			-- side , top , side , side , bottom, side,
				
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			--{-0.25, -0.5, -0.25, 0.25, 0.25, 0.25},
			{-0.125, -0.5, -0.125, 0.125, 0.18, 0.125},
			{-0.18, -0.5, -0.18, 0.18, 0.18, 0.18},
			{-0.25, -0.5, -0.25, 0.25, -0.44, 0.25}, -- INNER ONE --
			--{-0.25, -0.5, -0.25, 0.25, -0.125, 0.25},
			{-0.315, -0.3, 0.04, -0.36 , 0.1, -0.05},
			{-0.15, -0.0, 0.04, -0.315 , 0.05, -0.05},
			{-0.15, -0.25, 0.04, -0.315 , -0.2, -0.05},
		},
	},
})

-- mulled wine --

minetest.register_node("beer_test:barrel_mulledWine", {
   description = "Mulled Wine Barrel",
   tiles = {"beer_test_barrel_side_2.png", "beer_test_barrel_side_2.png", "beer_test_barrel_side.png",
   "beer_test_barrel_side.png", "beer_test_barrel_top.png", "beer_test_barrel_top.png"},
   paramtype = "light",
   paramtype2 = "facedir",
   drop = "beer_test:barrel",
   sounds = default.node_sound_barrel_defaults(),
   groups = {cracky=2},
   --sounds = default.node_sound_wood_defaults(),
   on_construct = function(pos)
         local meta = minetest.get_meta(pos)
         meta:set_string("infotext", "Mulled Wine (Brewed)")
      end,
    
   on_punch = function(pos, node, puncher)
      local tool = puncher:get_wielded_item():get_name()
      if tool and tool == "beer_test:tankard" then
         node.name = "beer_test:barrel_mulledWine"
         minetest.env:set_node(pos, node)
         puncher:get_inventory():remove_item("main", ItemStack("beer_test:tankard"))
         puncher:get_inventory():add_item("main", ItemStack("beer_test:tankard_mulledWine"))
      end
   end  
})

-- tankards rum --

minetest.register_node("beer_test:tankard_mulledWine", {
	description = "Tankard with Mulled Wine",
	stack_max = 1,
	wield_image = "beer_test_tankard_beer.png",
	inventory_image = "beer_test_tankard_beer.png",
	tiles = {"beer_test_tankard_top_mulledWine.png","beer_test_tankard_top.png","beer_test_tankard_side.png",
	"beer_test_tankard_side.png","beer_test_tankard_side.png","beer_test_tankard_side.png"},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky=3,dig_immediate=3},
	on_use = minetest.item_eat(1, "beer_test:tankard"),
	sounds = default.node_sound_tankard_defaults(),
	node_box = {
		type = "fixed",
		fixed = {
			{-0.18, -0.5, 0.125, 0.18, 0.18, 0.18},
			{0.125, -0.5, -0.18, 0.18, 0.18, 0.18},
			{-0.18, -0.5, -0.18, -0.125, 0.18, 0.18},
			{-0.18, -0.5, -0.18, 0.18, 0.18, -0.125},
			{-0.25, -0.5, -0.25, 0.25, -0.44, 0.25},
			{-0.315, -0.3, 0.04, -0.36 , 0.1, -0.05},
			{-0.15, -0.0, 0.04, -0.35 , 0.05, -0.05},
			{-0.15, -0.25, 0.04, -0.35 , -0.2, -0.05},
			{-0.18, -0.5, -0.18, 0.18, 0.1, 0.18},
			-- side , top , side , side , bottom, side,
				
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			--{-0.25, -0.5, -0.25, 0.25, 0.25, 0.25},
			{-0.125, -0.5, -0.125, 0.125, 0.18, 0.125},
			{-0.18, -0.5, -0.18, 0.18, 0.18, 0.18},
			{-0.25, -0.5, -0.25, 0.25, -0.44, 0.25}, -- INNER ONE --
			--{-0.25, -0.5, -0.25, 0.25, -0.125, 0.25},
			{-0.315, -0.3, 0.04, -0.36 , 0.1, -0.05},
			{-0.15, -0.0, 0.04, -0.315 , 0.05, -0.05},
			{-0.15, -0.25, 0.04, -0.315 , -0.2, -0.05},
		},
	},
})


print("Beer_test: brewing_other.lua            [ok]")

-- REGISTER MATERIALS AND PROPERTIES FOR NONCUBIC ELEMENTS:
-----------------------------------------------------------

local S = technic.getter

-- DIRT
-------
technic.cnc.register_all("default:dirt",
                {snappy=2,choppy=2,oddly_breakable_by_hand=3,not_in_creative_inventory=1},
                {"default_grass.png", "default_dirt.png", "default_grass.png"},
                S("Dirt"))
-- WOOD
-------
technic.cnc.register_all("default:wood",
                {snappy=2, choppy=2, oddly_breakable_by_hand=2, not_in_creative_inventory=1},
                {"default_wood.png"},
                S("Wooden"))
-- STONE
--------
technic.cnc.register_all("default:stone",
                {cracky=3, not_in_creative_inventory=1},
                {"default_stone.png"},
                S("Stone"))
-- STONE BRICK - added
---------------
technic.cnc.register_all("default:stonebrick",
                {cracky=3, not_in_creative_inventory=1},
                {"default_stone.png"},
                S("Stone Brick"))
-- COBBLE
---------
technic.cnc.register_all("default:cobble",
                {cracky=3, not_in_creative_inventory=1},
                {"default_cobble.png"},
                S("Cobble"))
-- DESERT STONE - added
--------
technic.cnc.register_all("default:desert_stone",
                {cracky=3, not_in_creative_inventory=1},
                {"default_desert_stone.png"},
                S("Desert Stone"))
-- DESERT STONE BRICK- added
--------
technic.cnc.register_all("default:desert_stonebrick",
                {cracky=3, not_in_creative_inventory=1},
                {"default_desert_stone_brick.png"},
                S("Desert Stone Brick"))

-- BRICK
--------
technic.cnc.register_all("default:brick",
                {cracky=3, not_in_creative_inventory=1},
                {"default_brick.png"},
                S("Brick"))

-- SANDSTONE
------------
technic.cnc.register_all("default:sandstone",
                {crumbly=2, cracky=3, not_in_creative_inventory=1},
                {"default_sandstone.png"},
                S("Sandstone"))

-- SANDSTONE BRICK - added
------------
technic.cnc.register_all("default:sandstonebrick",
                {cracky=3, not_in_creative_inventory=1},
                {"default_sandstone_brick.png"},
                S("Sandstone Brick"))

-- SILVER SANDSTONE - added
------------
technic.cnc.register_all("default:silver_sandstone",
                {crumbly=2, cracky=3, not_in_creative_inventory=1},
                {"default_silver_sandstone.png"},
                S("Silver Sandstone"))

-- SILVER SANDSTONE BRICK- added
------------
technic.cnc.register_all("default:silver_sandstone_brick",
                {cracky=3, not_in_creative_inventory=1},
                {"default_silver_sandstone_brick.png"},
                S("Silver Sandstone Brick"))
-- LEAVES
---------
technic.cnc.register_all("default:leaves",
                {snappy=2, choppy=2, oddly_breakable_by_hand=3, not_in_creative_inventory=1},
                {"default_leaves.png"},
                S("Leaves"))
-- TREE
-------
technic.cnc.register_all("default:tree",
                {snappy=1, choppy=2, oddly_breakable_by_hand=2, flammable=3, wood=1, not_in_creative_inventory=1},
                {"default_tree.png"},
                S("Tree"))

-- WROUGHT IRON
---------------
technic.cnc.register_all("default:steelblock",
                {cracky=1, level=2, not_in_creative_inventory=1},
                {"technic_wrought_iron_block.png"},
                S("Wrought Iron"))

-- Bronze
--------
technic.cnc.register_all("default:bronzeblock",
                {cracky=1, level=2, not_in_creative_inventory=1},
                {"default_bronze_block.png"},
                S("Bronze"))

-- Stainless Steel
--------
technic.cnc.register_all("technic:stainless_steel_block",
                {cracky=1, level=2, not_in_creative_inventory=1},
                {"technic_stainless_steel_block.png"},
                S("Stainless Steel"))

-- Marble
------------
technic.cnc.register_all("technic:marble",
                {cracky=3, not_in_creative_inventory=1},
                {"technic_marble.png"},
                S("Marble"))

-- Granite
------------
technic.cnc.register_all("technic:granite",
                {cracky=1, not_in_creative_inventory=1},
                {"technic_granite.png"},
                S("Granite"))


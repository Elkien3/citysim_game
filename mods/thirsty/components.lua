--[[

Default components for Thirsty.

These are nodes and items that "implement" the functionality
from functions.lua

See init.lua for license.

]]


--[[

Drinking containers (Tier 1)

Defines a simple wooden bowl which can be used on water to fill
your hydration.

Optionally also augments the nodes from vessels to enable drinking
on use.

]]

if minetest.get_modpath("vessels") and thirsty.config.register_vessels then
    -- add "drinking" to vessels
    --thirsty.augment_item_for_drinking('vessels:drinking_glass', 22)
    thirsty.augment_item_for_drinking('vessels:glass_bottle', 24)
    thirsty.augment_item_for_drinking('vessels:steel_bottle', 26)
end

--[[

Hydro containers (Tier 2)

Defines canteens (currently two types, with different capacities),
tools which store hydro. They use wear to show their content
level in their durability bar; they do not disappear when used up.

Wear corresponds to hydro level as follows:
- a wear of 0     shows no durability bar       -> empty (initial state)
- a wear of 1     shows a full durability bar   -> full
- a wear of 65535 shows an empty durability bar -> empty

]]

if minetest.get_modpath("default") and thirsty.config.register_canteens then

    minetest.register_tool('thirsty:steel_canteen', {
        description = 'Steel canteen',
        inventory_image = "thirsty_steel_canteen_16.png",
        liquids_pointable = true,
        stack_max = 1,
        on_use = thirsty.on_use(nil),
    })

    minetest.register_tool('thirsty:bronze_canteen', {
        description = 'Bronze canteen',
        inventory_image = "thirsty_bronze_canteen_16.png",
        liquids_pointable = true,
        stack_max = 1,
        on_use = thirsty.on_use(nil),
    })

    minetest.register_craft({
        output = "thirsty:steel_canteen",
        recipe = {
            { "group:wood", ""},
            { "default:steel_ingot", "default:steel_ingot"},
            { "default:steel_ingot", "default:steel_ingot"}
        }
    })
    minetest.register_craft({
        output = "thirsty:bronze_canteen",
        recipe = {
            { "group:wood", ""},
            { "default:bronze_ingot", "default:bronze_ingot"},
            { "default:bronze_ingot", "default:bronze_ingot"}
        }
    })

end

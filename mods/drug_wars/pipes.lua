-- wooden pipe

minetest.register_tool("drug_wars:wooden_pipe", {
    description = "Wooden Pipe",
    inventory_image = "drugwars_wooden_pipe.png",
    on_use = function(itemstack, user, pointed_thing)
        local inv = user:get_inventory()
        local stack = inv:get_stack("main", user:get_wield_index() + 1)

        if stack ~= nil and stack:get_name() ~= "" then
            local stackdef = minetest.registered_craftitems[stack:get_name()]
            if stackdef ~= nil and stackdef.on_smoke_woodenpipe ~= nil then
                stackdef.on_smoke_woodenpipe(user)
                inv:remove_item("main", stack:get_name() .. " 1")
            end
        end

        return nil 
    end,
    groups = {},
    sound = {breaks = "default_tool_breaks"},
})

minetest.register_craft({
    output = "drug_wars:wooden_pipe",
    recipe = {
        {"group:wood", "default:flint" , ""},
        {"default:steel_ingot", "group:wood", "group:wood"}
    }
})

minetest.register_tool("drug_wars:glass_pipe", {
    description = "Glass Pipe",
    inventory_image = "drugwars_glass_pipe.png",
    on_use = function(itemstack, user, pointed_thing)
        local inv = user:get_inventory()
        local stack = inv:get_stack("main", user:get_wield_index() + 1)

        if stack ~= nil and stack:get_name() ~= "" then
            local stackdef = minetest.registered_craftitems[stack:get_name()]
            if stackdef ~= nil and stackdef.on_smoke_glasspipe ~= nil then
                stackdef.on_smoke_glasspipe(user)
                inv:remove_item("main", stack:get_name() .. " 1")
            end
        end

        return nil 
    end,
    groups = {},
    sound = {breaks = "default_tool_breaks"},
})

minetest.register_craft({
    output = "drug_wars:glass_pipe",
    recipe = {
        {"default:glass", "default:flint" , ""},
        {"default:steel_ingot", "default:glass", "default:glass"}
    }
})
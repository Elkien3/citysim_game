minetest.original_register_chatcommand = minetest.register_chatcommand
minetest.original_override_chatcommand = minetest.override_chatcommand
minetest.original_unregister_chatcommand = minetest.unregister_chatcommand

function minetest_register_chatcommand_generator(override)
    return function(name, def, override)
        register_chatcommand(name, {
            description = def.description,
            privs = def.privs,
            params = def.params,
            custom_syntax = true,
            func = def.func,
            mod = def.mod_origin
        }, override)
    end
end

local minetest_register_chatcommand = minetest_register_chatcommand_generator()

for name, def in pairs(minetest.registered_chatcommands) do
    minetest_register_chatcommand(name, def)
end

minetest.register_chatcommand = function(name, def)
    minetest_register_chatcommand(name, def)
    minetest.original_register_chatcommand(name, def)
end

local minetest_override_chatcommand = minetest_register_chatcommand_generator(true)
minetest.override_chatcommand = function(name, def)
    minetest_override_chatcommand(name, def)
    minetest.original_override_chatcommand(name, def)
end

minetest.unregister_chatcommand = unregister_chatcommand
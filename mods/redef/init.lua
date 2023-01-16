local modpath = minetest.get_modpath('redef')
local path = modpath..DIR_DELIM..'redefinitions'..DIR_DELIM
local worldpath = minetest.get_worldpath()..DIR_DELIM

-- Get aconfiguration value or return a default
--
-- This function takes an unprefixed value, automatically prefixes it and
-- tries to get the value from the global configuration or the world-specific
-- configuration. If the option is not found in any of those the given default
-- value is returned.
--
-- @param value   The unprefixed option to get
-- @param default The default value in case the option is not found
-- @return mixed  The value
local g = function (value, default)
    local global_value = minetest.settings:get('redef_'..value) or default

    local world_config_path = worldpath..DIR_DELIM..'_redef.conf'
    local world_config = Settings(world_config_path)
    local world_value = world_config:get('redef_'..value)

    return world_value or global_value
end


minetest.register_on_mods_loaded(function()
    local redefinitions = {
        ['3D Ladders'] = minetest.is_yes(g('3d_ladders', true)),
        ['Aligned Textures'] = minetest.is_yes(g('aligned_textures', true)),
        ['Grass Box Height'] = false,--tonumber(g('grass_box_height', 2)) >= 1,
        ['Maximum Stack Size'] = false,--tonumber(g('stack_max', 100)) >= 1,
        ['Proper Rotation'] = false,--minetest.is_yes(g('proper_rotation', true)),
        ['Show Steps'] = false--minetest.is_yes(g('show_steps', true))
    }

    for name,use in pairs(redefinitions) do
        if use == true then
            dofile(path..name:lower():gsub(' ', '_')..'.lua')
            minetest.log('action', '[redef] Applied redefinition “'..name..'”')
        end
    end
end)

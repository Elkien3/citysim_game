local _stack_max = tonumber(minetest.settings:get('redef_stack_max') or 100)
local all_objects = {}

-- Get the things that have to be altered.
for w,what in pairs({'items', 'nodes', 'craftitems', 'tools'}) do
    for name,definition in pairs(minetest['registered_'..what]) do
        if definition.stack_max == 99 then
            table.insert(all_objects, name)
        end
    end
end

-- Set stack size to the given value.
for _,name in pairs(all_objects) do
    minetest.override_item(name, {
        stack_max = _stack_max
    })
end

-- Set Minetest default values in case mods or something within the engine
-- will use them after the above code ran.
minetest.craftitemdef_default.stack_max = _stack_max
minetest.nodedef_default.stack_max = _stack_max
minetest.noneitemdef_default.stack_max = _stack_max

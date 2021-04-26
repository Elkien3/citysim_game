--"waterworks:pipe"
if minetest.get_modpath("pipeworks") then
minetest.register_craft( {
    output = "waterworks:pipe 12",
    recipe = {
        { "default:steel_ingot", "", "default:steel_ingot" },
        { "default:steel_ingot", "", "default:steel_ingot" },
        { "default:steel_ingot", "", "default:steel_ingot" }
    },
})
else
minetest.register_craft( {
    output = "waterworks:pipe 12",
    recipe = {
        { "default:steel_ingot", "default:steel_ingot", "default:steel_ingot" },
        { "", "", "" },
        { "default:steel_ingot", "default:steel_ingot", "default:steel_ingot" }
    },
})
end

--"waterworks:valve_on"
minetest.register_craft( {
    output = "waterworks:valve_on",
    recipe = {
        { "default:steel_ingot", "", "default:steel_ingot" },
        { "", "waterworks:pipe", "" },
        { "default:steel_ingot", "", "default:steel_ingot" }
    },
})

--"waterworks:inlet"
minetest.register_craft( {
    output = "waterworks:inlet",
    recipe = {
        { "default:steel_ingot", "", "" },
        { "", "waterworks:pipe", "" },
        { "default:steel_ingot", "", "" }
    },
})
--"waterworks:pumped_inlet"
minetest.register_craft( {
    output = "waterworks:pumped_inlet",
    recipe = {
        { "default:steel_ingot", "", "" },
        { "default:mese_crystal_fragment", "waterworks:pipe", "" },
        { "default:steel_ingot", "", "" }
    },
})
minetest.register_craft( {
    output = "waterworks:pumped_inlet",
    recipe = {
        { "default:mese_crystal_fragment", "waterworks:inlet"},
    },
})

--"waterworks:outlet"
minetest.register_craft( {
    output = "waterworks:outlet",
    recipe = {
        { "", "", "default:steel_ingot" },
        { "", "waterworks:pipe", "" },
        { "", "", "default:steel_ingot" }
    },
})

--"waterworks:grate"
minetest.register_craft( {
    output = "waterworks:grate",
    recipe = {
        { "", "default:steel_ingot", "" },
        { "", "waterworks:pipe", "" },
        { "", "default:steel_ingot", "" }
    },
})

-- Allow the basic connectors to be cycled through
minetest.register_craft( {
    output = "waterworks:inlet",
	type = "shapeless",
    recipe = { "waterworks:outlet"},
})
minetest.register_craft( {
    output = "waterworks:outlet",
	type = "shapeless",
    recipe = {"waterworks:grate"},
})
minetest.register_craft( {
    output = "waterworks:grate",
	type = "shapeless",
    recipe = {"waterworks:inlet"},
})
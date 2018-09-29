-- © 2017 numberZero
-- License: GNU Lesser General Public License, version 2 (or any later version)

local function find_available_craftitem(...)
	local names = {...}
	for _, name in ipairs(names) do
		if minetest.registered_items[name] then
			return name
		end
	end
	-- make register_craft happy
	return "-- unavailable --"
end

local digiline_wire = "digilines:wire_std_00000000"
local connector = "digiline_routing:connector"

local steel = find_available_craftitem(
	"technic:carbon_steel_ingot",
	"default:steel_ingot"
)

local silver_wire = find_available_craftitem(
	"technic:fine_silver_wire",
	"moreores:silver_ingot",
	"default:gold_ingot"
)

local gold_dust = find_available_craftitem(
	"technic:gold_dust",
	"default:gold_ingot"
)

local silicon = find_available_craftitem(
	"mesecons_materials:silicon",
	"default:mese_crystal_fragment"
)

minetest.register_craftitem(connector, {
	description = "Digiline Bus Connector",
	inventory_image = "digiline_routing_connector.png",
})

minetest.register_craft({
	output = connector,
	recipe = {
		{"", steel, ""},
		{digiline_wire, silver_wire, gold_dust},
		{"", steel, ""},
	}
})

minetest.register_craft({
	output = "digiline_routing:diode 2",
	recipe = {
		{connector, silicon, connector},
	}
})

minetest.register_craft({
	output = "digiline_routing:filter 2",
	recipe = {
		{steel, silver_wire, steel},
		{connector, silicon, connector},
		{steel, silver_wire, steel},
}
})

minetest.register_craft({
	output = "digiline_routing:splitter 2",
	recipe = {
		{connector, ""},
		{silicon, connector},
		{connector, ""},
}
})

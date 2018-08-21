
local name = "rowboat"
local definition = ...

definition.description = "Rowboat"
definition.inventory_image = "rowboat_inventory.png"
definition.wield_image = "rowboat_wield.png"
definition.mesh = "rowboat.x"
definition.drop_on_destroy = "default:wood 4"
definition.recipe = {
	{"",			"",				""},
	{"group:wood",	"",				"group:wood"},
	{"group:wood",	"group:wood",	"group:wood"}
}

vehicle_mash.register_vehicle("vehicle_mash:"..name, definition)

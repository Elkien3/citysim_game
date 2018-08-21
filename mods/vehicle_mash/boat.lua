
local name = "boat"
local definition = ...

definition.description = "BoatA"
definition.inventory_image = "boat_inventory.png"
definition.wield_image = "boat_wield.png"
definition.mesh = "boats_boat.obj"
definition.drop_on_destroy = "default:wood 3"
definition.recipe = {
	{"",			"",				""},
	{"",			"",				"group:wood"},
	{"group:wood",	"group:wood",	"group:wood"}
}

vehicle_mash.register_vehicle("vehicle_mash:"..name, definition)

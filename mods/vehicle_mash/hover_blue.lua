
local name = "hover_blue"

local definition = ...

definition.description = "Blue hovercraft"
definition.inventory_image = "hovercraft_blue_inv.png"
definition.wield_image = "hovercraft_blue_inv.png"
definition.textures = {"hovercraft_blue.png"}

vehicle_mash.register_vehicle("vehicle_mash:"..name, definition)

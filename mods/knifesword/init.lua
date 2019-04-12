minetest.override_item("default:sword_wood", {
	description = "Wooden Knife",
	inventory_image = "default_tool_woodsword.png",
	range = 2,
})
minetest.override_item("default:sword_stone", {
	description = "Stone Knife",
	inventory_image = "default_tool_stonesword.png",
	range = 2,
})
minetest.override_item("default:sword_steel", {
	description = "Steel Knife",
	inventory_image = "default_tool_steelsword.png",
	range = 2,
})
minetest.override_item("default:sword_bronze", {
	description = "Bronze Knife",
	inventory_image = "default_tool_bronzesword.png",
	range = 2,
})
minetest.override_item("default:sword_mese", {
	description = "Mese Knife",
	inventory_image = "default_tool_mesesword.png",
	range = 2,
})
minetest.override_item("default:sword_diamond", {
	description = "Diamond Knife",
	inventory_image = "default_tool_diamondsword.png",
	range = 2,
})
if minetest.get_modpath("moreores") ~= nil then
	minetest.override_item("moreores:sword_mithril", {
		description = "Mithril Knife",
		inventory_image = "moreores_tool_mithrilsword.png",
		range = 2,
	})
	minetest.override_item("moreores:sword_silver", {
		description = "Silver Knife",
		inventory_image = "moreores_tool_silversword.png",
		range = 2,
	})
	minetest.override_item("moreores:pick_mithril", {
		tool_capabilities = {damage_groups = {fleshy = 6}}
	})
	minetest.override_item("moreores:shovel_mithril", {
		tool_capabilities = {damage_groups = {fleshy = 6}}
	})
	minetest.override_item("moreores:hoe_mithril", {
		tool_capabilities = {damage_groups = {fleshy = 6}}
	})
end
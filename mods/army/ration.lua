minetest.register_node("army:ration", {
	description = "Army Ration Pack",
	drawtype = "plantlike",
	tiles = {"army_ration.png"},
	inventory_image = "army_ration.png",
	wield_image = "army_ration.png",
	paramtype = "light",
	walkable = false,
	drop = "army:ration",
	groups = {oddly_breakable_by_hand=3},
	on_use = minetest.item_eat(6),
})

minetest.register_craft({
	output = 'army:ration 4',
	recipe = {
		{'default:apple'},
		{'default:steel_ingot'},
	}
})

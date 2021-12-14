minetest.register_craftitem("cooking:sugar", {
	description = "Sugar",
	inventory_image = "cooking_sugar.png",
})
cooking.register_craft({
	type = "press",
	recipe = "default:papyrus",
	output = "cooking:sugar"
})

if not foodspoil_register then foodspoil_register = function() end end

--breads
minetest.register_craftitem("cooking:bun", {
	description = "Uncooked Bun",
	inventory_image = "cooking_bun_uncooked.png",
})
minetest.register_craftitem("cooking:bun_cooked", {
	description = "Bun",
	on_use = minetest.item_eat(4),
	inventory_image = "cooking_bun.png",
})
minetest.register_craftitem("cooking:bread_sliced", {
	description = "Sliced Bread",
	on_use = minetest.item_eat(3),
	inventory_image = "cooking_bread_sliced.png",
})
minetest.register_craftitem("cooking:toast", {
	description = "Toast",
	on_use = minetest.item_eat(4),
	inventory_image = "cooking_toast.png",
})
minetest.register_craftitem("cooking:bread_with_jam", {
	description = "Bread with Jam",
	inventory_image = "cooking_bread_with_jam.png",
	on_use = minetest.item_eat(5),
})
minetest.register_craftitem("cooking:toast_with_jam", {
	description = "Toast with Jam",
	inventory_image = "cooking_toast_with_jam.png",
	on_use = minetest.item_eat(6),
})
minetest.register_craftitem("cooking:blueberry_jam", {
	description = "Blueberry Jam",
	inventory_image = "cooking_blueberry_jam.png",
})
minetest.clear_craft({output = "farming:bread"})
minetest.clear_craft({output = "farming:flour"})
cooking.register_craft({
	type = "mix",
	recipe = {"farming:wheat", "farming:wheat", "farming:wheat", "bucket:bucket_water", "cooking:sugar"},
	output = "farming:flour,bucket:bucket_empty"
})
cooking.register_craft({
	type = "oven",
	cooktime = 20,
	recipe = "farming:flour",
	output = "farming:bread"
})
cooking.register_craft({
	type = "stove",
	cooktime = 5,
	recipe = "cooking:bread_sliced",
	output = "cooking:toast"
})
cooking.register_craft({
	type = "cut",
	recipe = "farming:bread",
	output = "cooking:bread_sliced 6"
})
cooking.register_craft({
	type = "press",
	recipe = "default:blueberries",
	output = "cooking:blueberry_jam 4"
})
foodspoil_register("cooking:bread_sliced", 4)
cooking.register_craft({
	type = "stack",
	recipe = {"cooking:bread_sliced", "cooking:blueberry_jam"},
	output = "cooking:bread_with_jam"
})
foodspoil_register("cooking:bread_with_jam", 4)
cooking.register_craft({
	type = "stack",
	recipe = {"cooking:toast", "cooking:blueberry_jam"},
	output = "cooking:toast_with_jam"
})
cooking.register_craft({
	type = "cut",
	recipe = "farming:flour",
	output = "cooking:bun 4"
})
cooking.register_craft({
	type = "oven",
	cooktime = 10,
	recipe = "cooking:bun",
	output = "cooking:bun_cooked"
})

--apple pie
minetest.register_craftitem("cooking:chopped_apple", {
	description = "Chopped Apple",
	inventory_image = "cooking_chopped_apple.png",
})
minetest.register_craftitem("cooking:apple_pie_uncooked", {
	description = "Uncooked Apple Pie",
	inventory_image = "cooking_apple_pie_uncooked.png",
})
minetest.register_craftitem("cooking:apple_pie", {
	description = "Apple Pie",
	inventory_image = "cooking_apple_pie.png",
	on_use = minetest.item_eat(10),
})
minetest.register_craftitem("cooking:pie_crust", {
	description = "Pie Crust",
	inventory_image = "cooking_pie_crust.png",
})
cooking.register_craft({
	type = "roll",
	recipe = "cooking:bun",
	output = "cooking:pie_crust"
})
cooking.register_craft({
	type = "cut",
	recipe = "default:apple",
	output = "cooking:chopped_apple"
})
cooking.register_craft({
	type = "stack",
	recipe = {"cooking:pie_crust", "cooking:chopped_apple", "cooking:chopped_apple", "cooking:sugar", "cooking:pie_crust"},
	output = "cooking:apple_pie_uncooked"
})
cooking.register_craft({
	type = "oven",
	cooktime = 30,
	recipe = "cooking:apple_pie_uncooked",
	output = "cooking:apple_pie"
})

--mushroom soup
minetest.register_craftitem("cooking:mushroom_soup_uncooked", {
	description = "Uncooked Mushroom Soup",
	--stack_max = 1,
	inventory_image = "cooking_mushroom_soup_uncooked.png",
	param2 = 224,
	on_use = minetest.item_eat(4, "cooking:bowl")
})
foodspoil_register("cooking:mushroom_soup_uncooked", 4)
minetest.register_craftitem("cooking:mushroom_soup", {
	description = "Mushroom Soup",
	--stack_max = 1,
	inventory_image = "cooking_mushroom_soup.png",
	param2 = 222,
	on_use = minetest.item_eat(6, "cooking:bowl")
})
foodspoil_register("cooking:mushroom_soup", 4)
foodspoil_register("cooking:mushroom_soup_uncooked", 4)
cooking.register_craft({
	type = "soup",
	param2 = 6,
	recipe = {"flowers:mushroom_brown", "flowers:mushroom_brown", "flowers:mushroom_brown"},
	output = "cooking:mushroom_soup_uncooked"
})
cooking.register_craft({
	type = "stove",
	cooktime = 10,
	recipe = "cooking:mushroom_soup_uncooked",
	output = "cooking:mushroom_soup",
	burned = "cooking:burnt_soup"
})

--tools
minetest.register_craft({
	recipe = {
		{"group:wood", "", "group:wood"},
		{"", "group:wood", ""}
	},
	output = "cooking:bowl 4"
})
minetest.register_craft({
	recipe = {
		{"group:wood", "", "group:wood"},
		{"group:wood", "", "group:wood"},
		{"", "group:wood", ""}
	},
	output = "cooking:mixing_bowl 2"
})
minetest.register_craft({
	recipe = {
		{"default:steel_ingot", "", "default:steel_ingot"},
		{"default:steel_ingot", "", "default:steel_ingot"},
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"}
	},
	output = "cooking:pot_0 2"
})
minetest.register_craft({
	recipe = {
		{"default:glass", "group:sand", "default:glass"},
		{"", "default:glass", ""}
	},
	output = "cooking:plate 4"
})
minetest.register_craft({
	recipe = {
		{"default:stick", "group:wood", "default:stick"},
	},
	output = "cooking:rolling_pin"
})
minetest.register_craft({
	recipe = {
		{"default:stick", "group:wood", "default:stick"},
	},
	output = "cooking:rolling_pin"
})
minetest.register_craft({
	recipe = {
		{"", "group:wood"},
		{"default:stick", ""},
	},
	output = "cooking:spoon"
})
minetest.register_on_mods_loaded(function()
	local slablist = {}
	for name, def in pairs(minetest.registered_nodes) do
		if string.find(name, "slab") and string.find(name, "wood") then
			table.insert(slablist, name)
		end
	end
	for i, slabname in pairs(slablist) do
		minetest.register_craft({
			recipe = {
				{slabname},
			},
			output = "cooking:cutting_board"
		})
	end
end)
minetest.register_craft({
	recipe = {
		{"default:cobble", "default:cobble", "default:cobble"},
		{"default:cobble", "stairs:slab_cobble", "default:cobble"},
		{"default:cobble", "stairs:slab_cobble", "default:cobble"}
	},
	output = "cooking:oven"
})
minetest.register_craft({
	recipe = {
		{"default:cobble", "default:cobble", "default:cobble"},
		{"default:cobble", "stairs:slab_cobble", "default:cobble"},
		{"default:cobble", "default:cobble", "default:cobble"}
	},
	output = "cooking:stove"
})
minetest.register_craft({
	recipe = {
		{"", "", "default:steel_ingot"},
		{"default:steel_ingot", "default:sword_steel", "default:steel_ingot"},
	},
	output = "cooking:hand_press 2"
})
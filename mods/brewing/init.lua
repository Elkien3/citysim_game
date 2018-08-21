minetest.register_node("brewing:cauldron_full",{
    drawtype="nodebox",
	description= "Filled Cauldron",
    tiles = {"lottpotion_cauldron_top.png", "lottpotion_cauldron_side.png", "lottpotion_cauldron_side.png",
		"lottpotion_cauldron_side.png", "lottpotion_cauldron_side.png", "lottpotion_cauldron_side.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky=1},
	legacy_facedir_simple = true,
    node_box = {
        type = "fixed",
        fixed = {
			{-0.5, -0.5, -0.5, -0.375, 0.5, -0.375},
			{0.375, -0.5, -0.5, 0.5, 0.5, -0.375}, 
			{0.375, -0.5, 0.375, 0.5, 0.5, 0.5},
			{-0.5, -0.5, 0.375, -0.375, 0.5, 0.5},
			{-0.375, -0.375, -0.375, 0.375, -0.3125, 0.375},
			{-0.5, -0.375, -0.375, -0.375, 0.4375, 0.375},
			{0.375, -0.375, -0.375, 0.5, 0.4375, 0.375},
			{-0.375, -0.375, 0.375, 0.375, 0.4375, 0.5},
			{-0.375, -0.375, -0.5, 0.375, 0.4375, -0.375},
			{-0.375, 0.25, -0.375, 0.375, 0.3125, 0.375},
        }
    },
    on_punch = function(pos, node, player)
        local player_inv = player:get_inventory()
        local itemstack = player:get_wielded_item()
        if itemstack:get_name() == "vessels:drinking_glass" then
            minetest.set_node(pos, {name="brewing:cauldron_two_third_full"})
            if player_inv:room_for_item("main", 1) then
                itemstack:take_item(1)
                player_inv:add_item("main", "brewing:drinking_glass_water")
            end
            player:set_wielded_item(itemstack)
        elseif itemstack:get_name() == "bucket:bucket_empty" then
		    minetest.set_node(pos, {name="brewing:cauldron_empty"})
			itemstack:take_item()
            player_inv:add_item("main", "bucket:bucket_water")
        end
    end,
})

minetest.register_node("brewing:cauldron_two_third_full",{
    drawtype="nodebox",
    description= "Two Third Filled Cauldron",
    tiles = {"lottpotion_cauldron_top.png", "lottpotion_cauldron_side.png", "lottpotion_cauldron_side.png",
		"lottpotion_cauldron_side.png", "lottpotion_cauldron_side.png", "lottpotion_cauldron_side.png"},
	paramtype = "light",
	paramtype2 = "facedir",
    groups = {cracky=1, not_in_creative_inventory=1},
    node_box = {
        type = "fixed",
        fixed = {
			{-0.5, -0.5, -0.5, -0.375, 0.5, -0.375},
			{0.375, -0.5, -0.5, 0.5, 0.5, -0.375}, 
			{0.375, -0.5, 0.375, 0.5, 0.5, 0.5},
			{-0.5, -0.5, 0.375, -0.375, 0.5, 0.5},
			{-0.375, -0.375, -0.375, 0.375, -0.3125, 0.375},
			{-0.5, -0.375, -0.375, -0.375, 0.4375, 0.375},
			{0.375, -0.375, -0.375, 0.5, 0.4375, 0.375},
			{-0.375, -0.375, 0.375, 0.375, 0.4375, 0.5},
			{-0.375, -0.375, -0.5, 0.375, 0.4375, -0.375},
			{-0.375, 0.0625, -0.375, 0.375, 0.125, 0.375},
        }
    },
    on_punch = function(pos, node, player)
        local player_inv = player:get_inventory()
        local itemstack = player:get_wielded_item()
        if itemstack:get_name() == "vessels:drinking_glass" then
            minetest.set_node(pos, {name="brewing:cauldron_one_third_full"})
            if player_inv:room_for_item("main", 1) then
                itemstack:take_item(1)
                player_inv:add_item("main", "brewing:drinking_glass_water")
            end
            player:set_wielded_item(itemstack)
        end
    end,
})

minetest.register_node("brewing:cauldron_one_third_full",{
    drawtype="nodebox",
	description= "One Third Filled Cauldron",
    tiles = {"lottpotion_cauldron_top.png", "lottpotion_cauldron_side.png", "lottpotion_cauldron_side.png",
		"lottpotion_cauldron_side.png", "lottpotion_cauldron_side.png", "lottpotion_cauldron_side.png"},
	paramtype = "light",
	paramtype2 = "facedir",
    groups = {cracky=1, not_in_creative_inventory=1},
    node_box = {
        type = "fixed",
        fixed = {
			{-0.5, -0.5, -0.5, -0.375, 0.5, -0.375},
			{0.375, -0.5, -0.5, 0.5, 0.5, -0.375}, 
			{0.375, -0.5, 0.375, 0.5, 0.5, 0.5},
			{-0.5, -0.5, 0.375, -0.375, 0.5, 0.5},
			{-0.375, -0.375, -0.375, 0.375, -0.3125, 0.375},
			{-0.5, -0.375, -0.375, -0.375, 0.4375, 0.375},
			{0.375, -0.375, -0.375, 0.5, 0.4375, 0.375},
			{-0.375, -0.375, 0.375, 0.375, 0.4375, 0.5},
			{-0.375, -0.375, -0.5, 0.375, 0.4375, -0.375},
			{-0.375, -0.125, -0.375, 0.375, -0.0625, 0.375},
        }
    },
    on_punch = function(pos, node, player)
        local player_inv = player:get_inventory()
        local itemstack = player:get_wielded_item()
        if itemstack:get_name() == "vessels:drinking_glass" then
            minetest.set_node(pos, {name="brewing:cauldron_empty"})
            if player_inv:room_for_item("main", 1) then
                itemstack:take_item(1)
                player_inv:add_item("main", "brewing:drinking_glass_water")
            end
            player:set_wielded_item(itemstack)
        end
    end,
})

minetest.register_node("brewing:cauldron_empty",{
    drawtype="nodebox",
	description= "Empty Cauldron",
    tiles = {"lottpotion_cauldron_side.png"},
    paramtype = "light",
	paramtype2 = "facedir",
    groups = {cracky=1,level=2},
    node_box = {
        type = "fixed",
        fixed = {
			{-0.5, -0.5, -0.5, -0.375, 0.5, -0.375},
			{0.375, -0.5, -0.5, 0.5, 0.5, -0.375}, 
			{0.375, -0.5, 0.375, 0.5, 0.5, 0.5},
			{-0.5, -0.5, 0.375, -0.375, 0.5, 0.5},
			{-0.375, -0.375, -0.375, 0.375, -0.3125, 0.375},
			{-0.5, -0.375, -0.375, -0.375, 0.4375, 0.375},
			{0.375, -0.375, -0.375, 0.5, 0.4375, 0.375},
			{-0.375, -0.375, 0.375, 0.375, 0.4375, 0.5},
			{-0.375, -0.375, -0.5, 0.375, 0.4375, -0.375},
			{-0.375, -0.125, -0.375, 0.375, -0.25, 0.375},
        },
    },
    on_rightclick = function(pos, node, clicker, itemstack)
        if itemstack:get_name() == "bucket:bucket_water" then
		    minetest.set_node(pos, {name="brewing:cauldron_full"})
			return {name="bucket:bucket_empty"}
        end
    end
})

minetest.register_node("brewing:drinking_glass_water", {
	description = "Drinking Glass (Water)",
	drawtype = "plantlike",
	tiles = {"lottpotion_glass_water.png"},
	inventory_image = "lottpotion_glass_water.png",
	wield_image = "lottpotion_glass_water.png",
	paramtype = "light",
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-0.25, -0.5, -0.25, 0.25, 0.4, 0.25}
	},
	groups = {vessel=1,dig_immediate=3,attached_node=1},
	--sounds = default.node_sound_glass_defaults(),
})

local recipes = {
--MAKE YOUR OWN DRINK HERE!
--drink api: description, itemname, fill value, craft items.
	{"Wine", "wine", 4, {"default:apple", "cake:sugar", "brewing:cider"}},
    {"Beer", "beer", 2, {"farming:wheat", "farming:wheat", "cake:sugar" ,"brewing:drinking_glass_water"}},
    {"Cider", "cider", 2 , {"default:apple", "cake:sugar", "brewing:drinking_glass_water"}},
    {"Ale", "ale", 2, {"farming:seed_wheat", "farming:wheat", "cake:sugar", "brewing:drinking_glass_water"}},
	{"Root Beer", "rootbeer", 2, {"farming:seed_wheat", "default:sapling", "cake:sugar", "brewing:drinking_glass_water"}},
}
for _, data in pairs(recipes) do
	minetest.register_node("brewing:"..data[2], {
		description = data[1],
		drawtype = "plantlike",
		tiles = {"lottpotion_"..data[2]..".png^brewing_fizz.png"},
		inventory_image = "lottpotion_"..data[2]..".png^brewing_fizz.png",
		wield_image = "lottpotion_"..data[2]..".png^brewing_fizz.png",
		paramtype = "light",
		walkable = false,
		on_punch = function(pos, node, player)
			local player_inv = player:get_inventory()
			if not player_inv then return end
			if player_inv:room_for_item("main", 1) then
				minetest.remove_node(pos)
				player_inv:add_item("main", "brewing:"..data[2])
			end
			--player:set_wielded_item(itemstack)
		end,
		on_place = function(itemstack, placer, pointed_thing)
			local pt = pointed_thing
			local there = {x=pt.under.x, y=pt.under.y+1, z=pt.under.z}
			if minetest.env:get_node(there).name == "air" then
				minetest.add_node(there, {name="brewing:"..data[2]})
				itemstack:take_item()
				return itemstack
			end
		end,
		groups = {vessel=1,dig_immediate=4,attached_node=1},
		
		on_use = function(itemstack, player, pointed_thing)
			local player_inv = player:get_inventory()
			minetest.item_eat(data[3])
			player_inv:add_item("main", "vessels:drinking_glass")
		end,
		
		selection_box = {
			type = "fixed",
			fixed = {-0.25, -0.5, -0.25, 0.25, 0.4, 0.25}
		},
		groups = {vessel=1,dig_immediate=3,attached_node=1},
		--sounds = default.node_sound_glass_defaults(),
	})
	minetest.register_craftitem( "brewing:"..data[2].."_unbrewed", {
		description = "Unbrewed ".. data[1],
		inventory_image = "lottpotion_"..data[2]..".png",
		wield_image = "lottpotion_"..data[2]..".png",
	})
	minetest.register_craft({
		type = "shapeless",
		output = "brewing:"..data[2].."_unbrewed",
		recipe = data[4],
	})
	minetest.register_craft({
		output = "brewing:"..data[2],
		type = "cooking",
		cooktime = 7.9,
		recipe = "brewing:"..data[2].."_unbrewed"
	})
	if minetest.get_modpath("hud") ~= nil then
		overwritefood("brewing:"..data[2], data[3], "vessels:drinking_glass")
	end
end
minetest.register_craft({
	output = 'brewing:cauldron_empty',
	recipe = {
		{'default:steel_ingot', '', 'default:steel_ingot'},
		{'default:steel_ingot', '', 'default:steel_ingot'},
		{'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'},
	}
})
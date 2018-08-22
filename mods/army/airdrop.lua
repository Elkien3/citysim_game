minetest.register_node("army:airdrop",{
	description = "Airdrop Crate",
	tiles = {"army_crate.png"},
	paramtype = "light",
	groups = {choppy=2},
	drawtype = "normal",
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec",
				"size[8,6]"..
				"list[current_name;main;0,0;8,1;]"..
				"list[current_player;main;0,2;8,4;]")
		meta:set_string("infotext", "Airdrop Crate")
		local inv = meta:get_inventory()
		inv:set_size("main", 8*3)
       		local IStack = ItemStack( 'army:sandbag 20' )
		inv:add_item( 'main', IStack )
       		local IStack = ItemStack( 'army:chainlink 20' )
		inv:add_item( 'main', IStack )
       		local IStack = ItemStack( 'army:barbedwire 20' )
		inv:add_item( 'main', IStack )
       		local IStack = ItemStack( 'army:light 4' )
		inv:add_item( 'main', IStack )
       		local IStack = ItemStack( 'army:knife' )
		inv:add_item( 'main', IStack )
       		local IStack = ItemStack( 'army:ration 10' )
		inv:add_item( 'main', IStack )
       		local IStack = ItemStack( 'army:gun' )
		inv:add_item( 'main', IStack )
		    local IStack = ItemStack( 'army:bullet 20' )
		inv:add_item( 'main', IStack )
	end,
	can_dig = function(pos,player)
		local meta = minetest.get_meta(pos);
		local inv = meta:get_inventory()
		return inv:is_empty("main")
	end,
    on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" takes stuff from airdrop crate at "..minetest.pos_to_string(pos))
	end,
	drop = "",
})

minetest.register_craft({
	output = "army:airdrop",
	recipe = {
		{"dye:dark_green","default:mese_crystal","dye:dark_green"},
		{"default:mese_crystal","default:chest","default:mese_crystal"},
		{"dye:dark_green","default:mese_crystal","dye:dark_green"},
	}
})


-- the beer barrels -- 

minetest.register_node("beer_test:barrel_mixed_beer_grain", {
    description = "Barrel (With Mixed Beer Grain)",
    drawtype = "nodebox",
    tiles = {"beer_test_barrel_top.png^beer_test_barrel_mixed_beer_grain_top.png", "beer_test_barrel_top.png", "beer_test_barrel_side_2.png",
    "beer_test_barrel_side_2.png", "beer_test_barrel_side_2.png", "beer_test_barrel_side_2.png"},
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {choppy=2,oddly_breakable_by_hand=2},
    sounds = default.node_sound_wood_defaults(),
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_string("infotext", "Barrel (With Mixed Beer Grain)")
    end,
    node_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, 0.5, 0.5, 0.5, 0.35}, -- side f
            {-0.5, -0.5, -0.5, 0.5, -0.2, 0.5}, -- bottom
            {-0.5, -0.5, -0.5, -0.35, 0.5, 0.5}, -- side l
            {0.35, -0.5, -0.5, 0.5, 0.5, 0.5},  -- side r
            {-0.5, -0.5, -0.35, 0.5, 0.5, -0.5}, -- frount
			 {-0.5, -0.5, -0.5, 0.5, 0.1, 0.5},
             
        },
    },
    selection_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
        },
    },
    --i think using on rightclick is much better then onpunch, because all things in minetest are used/placed with righclick       
    on_rightclick = function(pos, node, player, itemstack, pointed_thing)
        if itemstack:get_name() == "default:wood" then --//check with tool/item is used on rightclick
        itemstack:take_item(1); --//and remove one if its the correct one
        player:set_wielded_item(itemstack);--//update inventory of the player
        node.name = "beer_test:barrel_beer_brewing";
        minetest.set_node(pos, node)--//replace the node
		local meta = minetest.get_meta(pos);
		meta:set_int("state",1);
		meta:set_string("infotext",beer.brewing[1].name .. "\n(brewing beer in progress... punch to interrupt)" )
        local timer = minetest.get_node_timer(pos);
        timer:start(1*60);--one minute
        end
    end,
    on_punch = function(pos, node, puncher)
        local tool = puncher:get_wielded_item():get_name()
        if tool and tool == "beer_test:mixed_beer_grain" then
            node.name = "beer_test:barrel_mixed_beer_grain"
            minetest.env:set_node(pos, node)
            puncher:get_inventory():remove_item("main", ItemStack("beer_test:mixed_beer_grain"))
        end
    end
})

beer = {};
beer.brewing={--//here are the brewing states it starts with the first one and continues to the last one with the time
{time=15*60,name="Watery Malt",item="beer_test:barrel_watery_malt",beer_tankard="beer_test:tankard_unbrewed_beer"},
{time=10*60,name="Fermetting Malt",item="beer_test:barrel_fermenting_malt",beer_tankard="beer_test:tankard_unbrewed_beer"},
{time=10*60,name="Light Beer",item="beer_test:barrel_light_beer",beer_tankard="beer_test:tankard_light_beer"},
{time=10*60,name="Normal Beer",item="beer_test:barrel_beer",beer_tankard="beer_test:tankard_beer"},
{time=1,name="Dark Beer",item="beer_test:barrel_dark_beer",beer_tankard="beer_test:tankard_dark_beer"}
}



beer.punched =function(pos, node, puncher)
      local tool = puncher:get_wielded_item():get_name()
	  local meta = minetest.get_meta(pos);
      if tool and tool == "beer_test:tankard" then
	  print(meta:get_int("full"))
		if meta:get_int("full") >=5 then
			local state = meta:get_int("state")
			if state == 0 then state = 1
			end
			local beer_tankardItem = beer.brewing[state].beer_tankard 
			puncher:set_wielded_item(ItemStack(beer_tankardItem)) 
			--puncher:set_wielded_item(ItemStack("beer_test:tankard_beer")) -- exactly replace the item wich was used. (old part) 
			newFull = meta:get_int("full")-5;
			meta:set_int("full",newFull);
			
			meta:set_string("infotext",beer.brewing[state].name .. "\n("..newFull.."% full)" )--//update the infotext
			if newFull <= 0 then
				node.name = "beer_test:barrel";
				minetest.swap_node(pos,node)
			end
		else
			minetest.chat_send_player(puncher:get_player_name(),"barrel is empty :-(\ngo brew a new one!")
		end
		
      end
   end  
   
beer.dug = function(pos, node, digger)
	local meta = minetest.get_meta(pos);
	local t = meta:to_table();
	if not(t and t.fields and t.fields.state) then
		minetest.set_node(pos, {name="air"});		
		return
	end
	local state = meta:get_int("state");
	local full = meta:get_int("full");
	local s = minetest.serialize(t);
	local wear = 65536 - (full*65536/100); --calculate the bar of the tool
	local item = ItemStack({name=beer.brewing[state].item, count=1, wear=wear, metadata=s})
	if digger and digger:is_player() then
		local inv = digger:get_inventory()
		inv:add_item("main", item);
		minetest.set_node(pos, {name="air"})
	end
end

beer.place = function(itemstack, placer, pointed_thing)
	if pointed_thing.above then
		pos = pointed_thing.above --needs to be improved
	else 
		pos = pointed_thing;
	end
	minetest.set_node(pos, {name="beer_test:barrel_beer_brewed"});
	local meta = minetest.get_meta(pos);
	meta:from_table(minetest.deserialize(itemstack:get_metadata()));
	itemstack:take_item();
	return itemstack
end

minetest.register_node("beer_test:barrel_beer_brewing", {
	description = "Beer Barrel",
	tiles = {"beer_test_barrel_top.png", "beer_test_barrel_top.png", "beer_test_barrel_side_2.png",
	"beer_test_barrel_side_2.png", "beer_test_barrel_side_2.png", "beer_test_barrel_side_2.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {choppy=2,oddly_breakable_by_hand=2,not_in_creative_inventory=1},
	sounds = default.node_sound_barrel_defaults(),
	on_timer = function(pos, elapsed)
		--minetest.chat_send_all("timer timed out")
		local meta = minetest.get_meta(pos)
		local state = meta:get_int("state") or 1; --fallback if state is unknown
		if state == 0 then
			state= 1
		end
		local nextState = state+1;
		if beer.brewing[nextState] then
			--minetest.chat_send_all("beeer reached next state")
			meta:set_int("state",nextState)--//save the new state
			local timer = minetest.get_node_timer(pos);--//then restart the timer
			timer:start(beer.brewing[nextState].time);
			meta:set_string("infotext",beer.brewing[nextState].name .. "\n(brewing beer in progress... punch to interrupt)" )--//and update the infotext
		else
			local node = minetest.get_node(pos);
			node.name = "beer_test:barrel_beer_brewed";
			minetest.swap_node(pos,node)
			meta:set_int("full",100);
			meta:set_string("infotext",beer.brewing[state].name .. "\n(100% full)" )
		end
	end,
	on_punch = function(pos, node, puncher, pointed_thing)
		minetest.chat_send_player(puncher:get_player_name(),"stopped brewing")
		local meta = minetest.get_meta(pos)
		local state = meta:get_int("state") or 1; --//fallback if state is unknown
		if not(state) then
			return
		end
		local timer = minetest.get_node_timer(pos);
		timer:stop();--//then stop the timer
		
		node.name = "beer_test:barrel_beer_brewed";
		minetest.swap_node(pos,node)
		meta:set_int("full",100);
		meta:set_string("infotext",beer.brewing[state].name .. "\n(100% full)" )--//and update the infotext
	end
})

minetest.register_node("beer_test:barrel_beer_brewed", {
	description = "Beer Barrel (You cheater!)",
	tiles = {"beer_test_barrel_side_2.png", "beer_test_barrel_side_2.png", "beer_test_barrel_side.png",
	"beer_test_barrel_side.png", "beer_test_barrel_top.png", "beer_test_barrel_top.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {choppy=2,oddly_breakable_by_hand=2,not_in_creative_inventory=1},
	drop = "", 
	sounds = default.node_sound_barrel_defaults(),
	on_punch = beer.punched,
	on_dig = beer.dug,
	on_place = beer.place
})


-- types of beers --
--Watery Malt

minetest.register_tool("beer_test:barrel_watery_malt", {
    description = "Beer Barrel (Watery Malt)",
    inventory_image = minetest.inventorycube("beer_test_barrel_side_2.png", "beer_test_barrel_side_2.png", "beer_test_barrel_side.png"),
	on_place = beer.place,
	on_drop = beer.place
})
minetest.register_tool("beer_test:barrel_fermenting_malt", {
    description = "Beer Barrel (Fermenting Malt)",
    inventory_image = minetest.inventorycube("beer_test_barrel_side_2.png", "beer_test_barrel_side_2.png", "beer_test_barrel_side.png"),
	on_place = beer.place,
	on_drop = beer.place
})
minetest.register_tool("beer_test:barrel_light_beer", {
    description = "Beer Barrel (Light Malt)",
    inventory_image = minetest.inventorycube("beer_test_barrel_side_2.png", "beer_test_barrel_side_2.png", "beer_test_barrel_side.png"),
	on_place = beer.place,
	on_drop = beer.place
})
minetest.register_tool("beer_test:barrel_beer", {
    description = "Beer Barrel (Beer)",
    inventory_image = minetest.inventorycube("beer_test_barrel_side_2.png", "beer_test_barrel_side_2.png", "beer_test_barrel_side.png"),
	on_place = beer.place,
	on_drop = beer.place
})
minetest.register_tool("beer_test:barrel_dark_beer", {
    description = "Beer Barrel (Dark Beer)",
    inventory_image = minetest.inventorycube("beer_test_barrel_side_2.png", "beer_test_barrel_side_2.png", "beer_test_barrel_side.png"),
	on_place = beer.place,
	on_drop = beer.place
})
--[[
minetest.register_node("beer_test:barrel_beer", {
   description = "Beer Barrel (Watery Malt)",
   tiles = {"beer_test_barrel_side_2.png", "beer_test_barrel_side_2.png", "beer_test_barrel_side.png",
   "beer_test_barrel_side.png", "beer_test_barrel_top.png", "beer_test_barrel_top.png"},
   paramtype = "light",
   paramtype2 = "facedir",
   groups = {cracky=2,not_in_creative_inventory=1},
   drop = "beer_test:barrel", -- this is for now --
   sounds = default.node_sound_barrel_defaults(),
   on_punch = beer.punched,
   on_dig = beer.dug,
   on_place = beer.place
})
--Fermeting Malt

minetest.register_node("beer_test:barrel_beer_1", {
   description = "Beer Barrel (Fermenting Malt)",
   tiles = {"beer_test_barrel_side_2.png", "beer_test_barrel_side_2.png", "beer_test_barrel_side.png",
   "beer_test_barrel_side.png", "beer_test_barrel_top.png", "beer_test_barrel_top.png"},
   paramtype = "light",
   paramtype2 = "facedir",
   groups = {cracky=2,not_in_creative_inventory=1},
   drop = "beer_test:barrel", -- this is for now --
   sounds = default.node_sound_barrel_defaults(),
   on_punch = beer.punched,
   on_dig = beer.dug,
   on_place = beer.place
})
--Light Beer
minetest.register_node("beer_test:barrel_beer_2", {
	description = "Beer Barrel (Light Beer)",
	tiles = {"beer_test_barrel_side_2.png", "beer_test_barrel_side_2.png", "beer_test_barrel_side.png",
	"beer_test_barrel_side.png", "beer_test_barrel_top.png", "beer_test_barrel_top.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky=2,not_in_creative_inventory=1},
	drop = "beer_test:barrel", -- this is for now --
	sounds = default.node_sound_barrel_defaults(),
	on_punch = beer.punched,
	on_dig = beer.dug,
	on_place = beer.place
})

--Normal beer
minetest.register_node("beer_test:barrel_beer_3", {
	description = "Beer Barrel (Normal Beer)",
	tiles = {"beer_test_barrel_side_2.png", "beer_test_barrel_side_2.png", "beer_test_barrel_side.png",
	"beer_test_barrel_side.png", "beer_test_barrel_top.png", "beer_test_barrel_top.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky=2,not_in_creative_inventory=1},
	drop = "",
	sounds = default.node_sound_barrel_defaults(),
	on_punch = beer.punched,
	on_dig = beer.dug,
	on_place = beer.place
})

--Dark beer
minetest.register_node("beer_test:barrel_beer_4", {
   description = "Beer Barrel (Dark Beer)",
   tiles = {"beer_test_barrel_side_2.png", "beer_test_barrel_side_2.png", "beer_test_barrel_side.png",
   "beer_test_barrel_side.png", "beer_test_barrel_top.png", "beer_test_barrel_top.png"},
   paramtype = "light",
   paramtype2 = "facedir",
   groups = {cracky=2,not_in_creative_inventory=1},
   drop = "beer_test:barrel", -- this is for now --
   sounds = default.node_sound_barrel_defaults(),
   on_punch = beer.punched,
   on_dig = beer.dug,
   on_place = beer.place
})

]]

-- tankards beer --
minetest.register_node("beer_test:tankard_unbrewed_beer", {
	description = "Tankard with Unbrewed Beer",
	stack_max = 1,
	wield_image = "beer_test_tankard_beer.png",
	inventory_image = "beer_test_tankard_beer.png",
	tiles = {"beer_test_tankard_top_unbrewed_beer.png","beer_test_tankard_top.png","beer_test_tankard_side.png",
	"beer_test_tankard_side.png","beer_test_tankard_side.png","beer_test_tankard_side.png"},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky=3,dig_immediate=3},
	on_use = minetest.item_eat(1, "beer_test:tankard"),
	sounds = default.node_sound_tankard_defaults(),
	node_box = {
		type = "fixed",
		fixed = {
			{-0.18, -0.5, 0.125, 0.18, 0.18, 0.18},
			{0.125, -0.5, -0.18, 0.18, 0.18, 0.18},
			{-0.18, -0.5, -0.18, -0.125, 0.18, 0.18},
			{-0.18, -0.5, -0.18, 0.18, 0.18, -0.125},
			{-0.25, -0.5, -0.25, 0.25, -0.44, 0.25},
			{-0.315, -0.3, 0.04, -0.36 , 0.1, -0.05},
			{-0.15, -0.0, 0.04, -0.35 , 0.05, -0.05},
			{-0.15, -0.25, 0.04, -0.35 , -0.2, -0.05},
			{-0.18, -0.5, -0.18, 0.18, 0.1, 0.18},
			-- side , top , side , side , bottom, side,
				
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			--{-0.25, -0.5, -0.25, 0.25, 0.25, 0.25},
			{-0.125, -0.5, -0.125, 0.125, 0.18, 0.125},
			{-0.18, -0.5, -0.18, 0.18, 0.18, 0.18},
			{-0.25, -0.5, -0.25, 0.25, -0.44, 0.25}, -- INNER ONE --
			--{-0.25, -0.5, -0.25, 0.25, -0.125, 0.25},
			{-0.315, -0.3, 0.04, -0.36 , 0.1, -0.05},
			{-0.15, -0.0, 0.04, -0.315 , 0.05, -0.05},
			{-0.15, -0.25, 0.04, -0.315 , -0.2, -0.05},
		},
	},
})


minetest.register_node("beer_test:tankard_light_beer", {
	description = "Tankard with Light Beer",
	stack_max = 1,
	wield_image = "beer_test_tankard_beer.png",
	inventory_image = "beer_test_tankard_beer.png",
	tiles = {"beer_test_tankard_top_beer.png","beer_test_tankard_top.png","beer_test_tankard_side_beer.png",
	"beer_test_tankard_side_beer.png","beer_test_tankard_side_beer.png","beer_test_tankard_side_beer.png"},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky=3,dig_immediate=3},
	on_use = minetest.item_eat(1, "beer_test:tankard"),
	sounds = default.node_sound_tankard_defaults(),
	node_box = {
		type = "fixed",
		fixed = {
			{-0.18, -0.5, 0.125, 0.18, 0.18, 0.18},
			{0.125, -0.5, -0.18, 0.18, 0.18, 0.18},
			{-0.18, -0.5, -0.18, -0.125, 0.18, 0.18},
			{-0.18, -0.5, -0.18, 0.18, 0.18, -0.125},
			{-0.25, -0.5, -0.25, 0.25, -0.44, 0.25},
			{-0.315, -0.3, 0.04, -0.36 , 0.1, -0.05},
			{-0.15, -0.0, 0.04, -0.35 , 0.05, -0.05},
			{-0.15, -0.25, 0.04, -0.35 , -0.2, -0.05},
			{-0.18, -0.5, -0.18, 0.18, 0.1, 0.18},
			-- side , top , side , side , bottom, side,
				
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			--{-0.25, -0.5, -0.25, 0.25, 0.25, 0.25},
			{-0.125, -0.5, -0.125, 0.125, 0.18, 0.125},
			{-0.18, -0.5, -0.18, 0.18, 0.18, 0.18},
			{-0.25, -0.5, -0.25, 0.25, -0.44, 0.25}, -- INNER ONE --
			--{-0.25, -0.5, -0.25, 0.25, -0.125, 0.25},
			{-0.315, -0.3, 0.04, -0.36 , 0.1, -0.05},
			{-0.15, -0.0, 0.04, -0.315 , 0.05, -0.05},
			{-0.15, -0.25, 0.04, -0.315 , -0.2, -0.05},
		},
	},
})

minetest.register_node("beer_test:tankard_beer", {
	description = "Tankard with Beer",
	stack_max = 1,
	wield_image = "beer_test_tankard_beer.png",
	inventory_image = "beer_test_tankard_beer.png",
	tiles = {"beer_test_tankard_top_beer.png","beer_test_tankard_top.png","beer_test_tankard_side_beer.png",
	"beer_test_tankard_side_beer.png","beer_test_tankard_side_beer.png","beer_test_tankard_side_beer.png"},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky=3,dig_immediate=3},
	on_use = minetest.item_eat(1, "beer_test:tankard"),
	sounds = default.node_sound_tankard_defaults(),
		node_box = {
		type = "fixed",
		fixed = {
			{-0.18, -0.5, 0.125, 0.18, 0.18, 0.18},
			{0.125, -0.5, -0.18, 0.18, 0.18, 0.18},
			{-0.18, -0.5, -0.18, -0.125, 0.18, 0.18},
			{-0.18, -0.5, -0.18, 0.18, 0.18, -0.125},
			{-0.25, -0.5, -0.25, 0.25, -0.44, 0.25},
			{-0.315, -0.3, 0.04, -0.36 , 0.1, -0.05},
			{-0.15, -0.0, 0.04, -0.35 , 0.05, -0.05},
			{-0.15, -0.25, 0.04, -0.35 , -0.2, -0.05},
			{-0.125, -0.5, -0.125, 0.125, 0.25, 0.125},
			{-0.135, -0.5, -0.135, 0.135, 0.25, 0.135},
			
			-- side , top , side , side , bottom, side,
				
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			--{-0.25, -0.5, -0.25, 0.25, 0.25, 0.25},
			{-0.125, -0.5, -0.125, 0.125, 0.18, 0.125},
			{-0.18, -0.5, -0.18, 0.18, 0.18, 0.18},
			{-0.25, -0.5, -0.25, 0.25, -0.44, 0.25}, -- INNER ONE --
			--{-0.25, -0.5, -0.25, 0.25, -0.125, 0.25},
			{-0.315, -0.3, 0.04, -0.36 , 0.1, -0.05},
			{-0.15, -0.0, 0.04, -0.315 , 0.05, -0.05},
			{-0.15, -0.25, 0.04, -0.315 , -0.2, -0.05},
		},
	},
})
minetest.register_node("beer_test:tankard_dark_beer", {
	description = "Tankard with Dark Beer",
	stack_max = 1,
	wield_image = "beer_test_tankard_beer.png",
	inventory_image = "beer_test_tankard_beer.png",
	tiles = {"beer_test_tankard_top_beer.png","beer_test_tankard_top.png","beer_test_tankard_side_beer.png",
	"beer_test_tankard_side_beer.png","beer_test_tankard_side_beer.png","beer_test_tankard_side_beer.png"},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky=3,dig_immediate=3},
	on_use = minetest.item_eat(1, "beer_test:tankard"),
	sounds = default.node_sound_tankard_defaults(),
		node_box = {
		type = "fixed",
		fixed = {
			{-0.18, -0.5, 0.125, 0.18, 0.18, 0.18},
			{0.125, -0.5, -0.18, 0.18, 0.18, 0.18},
			{-0.18, -0.5, -0.18, -0.125, 0.18, 0.18},
			{-0.18, -0.5, -0.18, 0.18, 0.18, -0.125},
			{-0.25, -0.5, -0.25, 0.25, -0.44, 0.25},
			{-0.315, -0.3, 0.04, -0.36 , 0.1, -0.05},
			{-0.15, -0.0, 0.04, -0.35 , 0.05, -0.05},
			{-0.15, -0.25, 0.04, -0.35 , -0.2, -0.05},
			{-0.125, -0.5, -0.125, 0.125, 0.25, 0.125},
			{-0.135, -0.5, -0.135, 0.135, 0.25, 0.135},
			
			-- side , top , side , side , bottom, side,
				
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			--{-0.25, -0.5, -0.25, 0.25, 0.25, 0.25},
			{-0.125, -0.5, -0.125, 0.125, 0.18, 0.125},
			{-0.18, -0.5, -0.18, 0.18, 0.18, 0.18},
			{-0.25, -0.5, -0.25, 0.25, -0.44, 0.25}, -- INNER ONE --
			--{-0.25, -0.5, -0.25, 0.25, -0.125, 0.25},
			{-0.315, -0.3, 0.04, -0.36 , 0.1, -0.05},
			{-0.15, -0.0, 0.04, -0.315 , 0.05, -0.05},
			{-0.15, -0.25, 0.04, -0.315 , -0.2, -0.05},
		},
	},
})



print("Beer_test: brewing_beer.lua             [ok]")
 

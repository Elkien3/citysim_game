-- mead Stuff --

-- the mead barrels -- 

minetest.register_node("beer_test:barrel_mixed_mead_grain", {
    description = "Barrel (With Mixed mead Grain)",
    drawtype = "nodebox",
    tiles = {"beer_test_barrel_top.png^beer_test_barrel_mixed_mead_grain_top.png", "beer_test_barrel_top.png", "beer_test_barrel_side_2.png",
    "beer_test_barrel_side_2.png", "beer_test_barrel_side_2.png", "beer_test_barrel_side_2.png"},
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {cracky=2},
    sounds = default.node_sound_wood_defaults(),
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_string("infotext", "Barrel (With Mixed mead Grain)")
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
		--puncher:get_inventory():add_item("main", ItemStack("bucket:bucket"))
        player:set_wielded_item(itemstack);--//update inventory of the player
        node.name = "beer_test:barrel_mead_brewing";
        minetest.set_node(pos, node)--//replace the node
		local meta = minetest.get_meta(pos);
		meta:set_int("state",1);
		meta:set_string("infotext",mead.brewing[1].name .. "\n(Brewing mead in progress... punch to interrupt)" )
        local timer = minetest.get_node_timer(pos);
        timer:start(1*60);--one minute
        end
    end,
    on_punch = function(pos, node, puncher)
        local tool = puncher:get_wielded_item():get_name()
        if tool and tool == "beer_test:mixed_mead_grain" then
            node.name = "beer_test:barrel_mixed_mead_grain"
            minetest.env:set_node(pos, node)
            puncher:get_inventory():remove_item("main", ItemStack("beer_test:mixed_mead_grain"))
        end
    end
})

mead = {};
mead.brewing={--//here are the brewing states it starts with the first one and continues to the last one with the time
{time=15*60,name="Watery Apple Mead",item="beer_test:barrel_watery_mead",mead_tankard="beer_test:tankard_unbrewed_mead"},
{time=10*60,name="Fermetting Apple Mead",item="beer_test:barrel_fermenting_mead",mead_tankard="beer_test:tankard_unbrewed_mead"},
{time=10*60,name="Light Apple Mead",item="beer_test:barrel_light_mead",mead_tankard="beer_test:tankard_light_mead"},
{time=10*60,name="Normal Apple Mead",item="beer_test:barrel_mead",mead_tankard="beer_test:tankard_mead"},
{time=1,name="Dark Apple Mead",item="beer_test:barrel_dark_mead",mead_tankard="beer_test:tankard_dark_mead"}
}


-- meh --
mead.punched =function(pos, node, puncher)
      local tool = puncher:get_wielded_item():get_name()
	  local meta = minetest.get_meta(pos);
      if tool and tool == "beer_test:tankard" then
	  print(meta:get_int("full"))
		if meta:get_int("full") >=5 then
			local state = meta:get_int("state") or 1;
			 local mead_tankardItem = mead.brewing[state].mead_tankard 
			 puncher:set_wielded_item(ItemStack(mead_tankardItem)) 
			 --puncher:set_wielded_item(ItemStack("beer_test:tankard_mead")) -- exactly replace the item wich was used. (old part) 
			 newFull = meta:get_int("full")-5;
			 meta:set_int("full",newFull);
			 
			 meta:set_string("infotext",mead.brewing[state].name .. "\n("..newFull.."% full)" )--//update the infotext
			 if newFull <= 0 then
				 node.name = "beer_test:barrel_mead";
				 minetest.swap_node(pos,node)
			end
		else
			minetest.chat_send_player(puncher:get_player_name(),"barrel is empty :-(\ngo brew a new one!")
		end
		
      end
   end  

mead.dug = function(pos, node, digger)
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
	local item = ItemStack({name=mead.brewing[state].item, count=1, wear=wear, metadata=s})
	if digger and digger:is_player() then
		local inv = digger:get_inventory()
		inv:add_item("main", item);
		minetest.set_node(pos, {name="air"})
	end
end

mead.place = function(itemstack, placer, pointed_thing)
	if pointed_thing.above then
		pos = pointed_thing.above --needs to be improved
	else 
		pos = pointed_thing;
	end
	minetest.set_node(pos, {name="beer_test:barrel_mead_brewed"});
	local meta = minetest.get_meta(pos);
	meta:from_table(minetest.deserialize(itemstack:get_metadata()));
	itemstack:take_item();
	return itemstack
end

   
minetest.register_node("beer_test:barrel_mead_brewing", {
	description = "mead Barrel",
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
		if mead.brewing[nextState] then
			--minetest.chat_send_all("beeer reached next state")
			meta:set_int("state",nextState)--//save the new state
			local timer = minetest.get_node_timer(pos);--//then restart the timer
			timer:start(mead.brewing[nextState].time);
			meta:set_string("infotext",mead.brewing[nextState].name .. "\n(Brewing mead in progress... punch to interrupt)" )--//and update the infotext
		else
			local node = minetest.get_node(pos);
			node.name = "beer_test:barrel_mead_brewed";
			minetest.swap_node(pos,node)
			meta:set_int("full",100);
			meta:set_string("infotext",mead.brewing[state].name .. "\n(100% full)" )
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
		
		node.name = "beer_test:barrel_mead_brewed";
		minetest.swap_node(pos,node)
		meta:set_int("full",100);
		meta:set_string("infotext",mead.brewing[state].name .. "\n(100% full)" )--//and update the infotext
	end
})

minetest.register_node("beer_test:barrel_mead_brewed", {
	description = "mead Barrel (You cheater!)",
	tiles = {"beer_test_barrel_side_2.png", "beer_test_barrel_side_2.png", "beer_test_barrel_side.png",
	"beer_test_barrel_side.png", "beer_test_barrel_top.png", "beer_test_barrel_top.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {choppy=2,oddly_breakable_by_hand=2,not_in_creative_inventory=1},
	drop = "", 
	sounds = default.node_sound_barrel_defaults(),
	on_punch = mead.punched,
	on_dig = mead.dug,
	on_place = mead.place
})


-- types of meads --
minetest.register_tool("beer_test:barrel_watery_mead", {
    description = "Mead Barrel (Watery Apple Mead)",
    inventory_image = minetest.inventorycube("beer_test_barrel_side_2.png", "beer_test_barrel_side_2.png", "beer_test_barrel_side.png"),
	on_place = mead.place,
	on_drop = mead.place
})
minetest.register_tool("beer_test:barrel_fermenting_mead", {
    description = "mead Barrel (Fermenting Apple Mead)",
    inventory_image = minetest.inventorycube("beer_test_barrel_side_2.png", "beer_test_barrel_side_2.png", "beer_test_barrel_side.png"),
	on_place = mead.place,
	on_drop = mead.place
})
minetest.register_tool("beer_test:barrel_light_mead", {
    description = "Mead Barrel (Light Apple Mead)",
    inventory_image = minetest.inventorycube("beer_test_barrel_side_2.png", "beer_test_barrel_side_2.png", "beer_test_barrel_side.png"),
	on_place = mead.place,
	on_drop = mead.place
})
minetest.register_tool("beer_test:barrel_mead", {
    description = "Mead Barrel (Apple Mead)",
    inventory_image = minetest.inventorycube("beer_test_barrel_side_2.png", "beer_test_barrel_side_2.png", "beer_test_barrel_side.png"),
	on_place = mead.place,
	on_drop = mead.place
})
minetest.register_tool("beer_test:barrel_dark_mead", {
    description = "Mead Barrel (Dark Apple Mead)",
    inventory_image = minetest.inventorycube("beer_test_barrel_side_2.png", "beer_test_barrel_side_2.png", "beer_test_barrel_side.png"),
	on_place = mead.place,
	on_drop = mead.place
})

-- tankards beer --

minetest.register_node("beer_test:tankard_unbrewed_mead", {
	description = "Tankard with Unbrewed mead",
	stack_max = 1,
	wield_image = "beer_test_tankard_beer.png",
	inventory_image = "beer_test_tankard_beer.png",
	tiles = {"beer_test_tankard_top_unbrewed_beer.png","beer_test_tankard_top.png","beer_test_tankard_side_beer.png",
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

minetest.register_node("beer_test:tankard_light_mead", {
	description = "Tankard with Light mead",
	stack_max = 1,
	wield_image = "beer_test_tankard_beer.png",
	inventory_image = "beer_test_tankard_beer.png",
	tiles = {"beer_test_tankard_top_light_mead.png","beer_test_tankard_top.png","beer_test_tankard_side_beer.png",
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
minetest.register_node("beer_test:tankard_mead", {
	description = "Tankard with mead",
	stack_max = 1,
	wield_image = "beer_test_tankard_beer.png",
	inventory_image = "beer_test_tankard_beer.png",
	tiles = {"beer_test_tankard_top_mead.png","beer_test_tankard_top.png","beer_test_tankard_side_beer.png",
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
minetest.register_node("beer_test:tankard_dark_mead", {
	description = "Tankard with Black mead",
	stack_max = 1,
	wield_image = "beer_test_tankard_beer.png",
	inventory_image = "beer_test_tankard_beer.png",
	tiles = {"beer_test_tankard_top_dark_mead.png","beer_test_tankard_top.png","beer_test_tankard_side_beer.png",
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





print("Beer_test: brewing_mead.lua              [ok]")

 

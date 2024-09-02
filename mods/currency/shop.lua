default.shop = {}
default.shop.current_shop = {}
default.shop.formspec = {
	customer = function(pos)
		local counter = minetest.get_meta(pos):get_string("counter")
		local list_name = "nodemeta:"..pos.x..','..pos.y..','..pos.z
		local formspec = "size[8,9.5]"..
		"label[0,0;Customer gives (pay here !)]"..
		"list["..list_name..";customer_gives;0,0.5;3,2;]"..
		"label[3,0;Transactions counter]"..
		"label[0,2.5;Customer gets]"..
		"list["..list_name..";customer_gets;0,3;3,2;]"..
		"label[5,0;Owner wants]"..
		"list["..list_name..";owner_wants;5,0.5;3,2;]"..
		"label[5,2.5;Owner gives]"..
		"list["..list_name..";owner_gives;5,3;3,2;]"..
		"list[current_player;main;0,5.5;8,4;]"..
		"button[3,2;2,1;exchange;Exchange]"
		if counter then formspec = formspec.."label[4,.25;"..tostring(counter).."]" end
		return formspec
	end,
	owner = function(pos)
		local counter = minetest.get_meta(pos):get_string("counter")
		local list_name = "nodemeta:"..pos.x..','..pos.y..','..pos.z
		local formspec = "size[8,9.5]"..
		"label[0,0;Customers gave:]"..
		"list["..list_name..";customers_gave;0,0.5;3,2;]"..
		"label[3,0;Transactions counter]"..
		"label[0,2.5;Your stock:]"..
		"list["..list_name..";stock;0,3;3,2;]"..
		"label[5,0;You want:]"..
		"list["..list_name..";owner_wants;5,0.5;3,2;]"..
		"label[5,2.5;In exchange, you give:]"..
		"list["..list_name..";owner_gives;5,3;3,2;]"..
		"list[current_player;main;0,5.5;8,4;]"..
		"button[3,1;2,1;tocustomer;Customer View]"
		if counter then formspec = formspec.."label[4,.25;"..tostring(counter).."]" end--.."button[3,.75;2,1;resetcounter;Reset Counter]" end
		return formspec
	end,
}

default.shop.check_privilege = function(listname,playername,meta)
	--[[if listname == "pl1" then
		if playername ~= meta:get_string("pl1") then
			return false
		elseif meta:get_int("pl1step") ~= 1 then
			return false
		end
	end
	if listname == "pl2" then
		if playername ~= meta:get_string("pl2") then
			return false
		elseif meta:get_int("pl2step") ~= 1 then
			return false
		end
	end]]
	return true
end


default.shop.give_inventory = function(inv,list,playername)
	player = minetest.get_player_by_name(playername)
	if player then
		for k,v in ipairs(inv:get_list(list)) do
			player:get_inventory():add_item("main",v)
			inv:remove_item(list,v)
		end
	end
end

default.shop.cancel = function(meta)
	--[[default.shop.give_inventory(meta:get_inventory(),"pl1",meta:get_string("pl1"))
	default.shop.give_inventory(meta:get_inventory(),"pl2",meta:get_string("pl2"))
	meta:set_string("pl1","")
	meta:set_string("pl2","")
	meta:set_int("pl1step",0)
	meta:set_int("pl2step",0)]]
end

default.shop.exchange = function(meta)
	--[[default.shop.give_inventory(meta:get_inventory(),"pl1",meta:get_string("pl2"))
	default.shop.give_inventory(meta:get_inventory(),"pl2",meta:get_string("pl1"))
	meta:set_string("pl1","")
	meta:set_string("pl2","")
	meta:set_int("pl1step",0)
	meta:set_int("pl2step",0)]]
end

minetest.register_node("currency:shop", {
	description = "Shop",
	paramtype2 = "facedir",
	tiles = {"shop_top.png",
	                "shop_top.png",
			"shop_side.png",
			"shop_side.png",
			"shop_back.png",
			"shop_front.png"},
	--inventory_image = "shop_front.png",
	groups = {choppy=2,oddly_breakable_by_hand=2,tubedevice=1,tubedevice_receiver=1},
	sounds = default.node_sound_wood_defaults(),
	after_place_node = function(pos, placer, itemstack)
		local owner = placer:get_player_name()
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", "Exchange shop (owned by "..owner..")")
		meta:set_string("owner",owner)
		meta:set_string("counter", 0)
		--[[meta:set_string("pl1","")
		meta:set_string("pl2","")]]
		local inv = meta:get_inventory()
		inv:set_size("customers_gave", 3*2)
		inv:set_size("stock", 3*2)
		inv:set_size("owner_wants", 3*2)
		inv:set_size("owner_gives", 3*2)
		inv:set_size("customer_gives", 3*2)
		inv:set_size("customer_gets", 3*2)
		if minetest.get_modpath("pipeworks") then pipeworks.after_place(pos) end
	end,
	after_dig_node = (pipeworks and pipeworks.after_dig),
	tube = {
		insert_object = function(pos, node, stack, direction)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			return inv:add_item("stock",stack)
		end,
		can_insert = function(pos,node,stack,direction)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			return inv:room_for_item("stock", stack)
		end,
		input_inventory = "customers_gave",
		connect_sides = {left = 1, right = 1, back = 1, front = 1, bottom = 1, top = 1}
	},
	on_rightclick = function(pos, node, clicker, itemstack)
		local inv = clicker:get_inventory()
		local nodeinv = minetest.get_inventory({type="node", pos=pos})

		--convert old shops with player inv gives and gets to node inv gives and gets
		if nodeinv:get_size("customer_gives") == 0 then
			nodeinv:set_size("customer_gives", 3*2)
		end
		if nodeinv:get_size("customer_gets") == 0 then
			nodeinv:set_size("customer_gets", 3*2)
		end
		if not inv:is_empty("customer_gives") and nodeinv:is_empty("customer_gives") then
			nodeinv:set_list("customer_gives", inv:get_list("customer_gives"))
			inv:set_list("customer_gives", {})
			inv:set_size("customer_gives", 0)
		end
		if not inv:is_empty("customer_gets") and nodeinv:is_empty("customer_gets") then
			nodeinv:set_list("customer_gets", inv:get_list("customer_gets"))
			inv:set_list("customer_gets", {})
			inv:set_size("customer_gets", 0)
		end
		default.shop.current_shop[clicker:get_player_name()] = pos
		local wield = clicker:get_wielded_item():get_name()
		local def = minetest.registered_tools[wield]
		if (default.can_interact_with_node(clicker, pos) and not clicker:get_player_control().aux1)
		or (def and def.tool_capabilities and def.tool_capabilities.groupcaps and def.tool_capabilities.groupcaps.locked) then--allow peeking with lockpicks
			minetest.show_formspec(clicker:get_player_name(),"currency:shop_formspec",default.shop.formspec.owner(pos))
		else
			minetest.show_formspec(clicker:get_player_name(),"currency:shop_formspec",default.shop.formspec.customer(pos))
		end
	end,
	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		if default.can_interact_with_node(player, pos) then return count end
		if (from_list == "customer_gives" or from_list == "customer_gets") and (to_list == "customer_gives" or to_list == "customer_gets") then return count end
		return 0
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		if (listname ~= "customer_gets" and listname ~= "customer_gives") and not default.can_interact_with_node(player, pos) then return 0 end
		return stack:get_count()
	end,
	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		if (listname ~= "customer_gets" and listname ~= "customer_gives") and not default.can_interact_with_node(player, pos) then return 0 end
		return stack:get_count()
	end,
	can_dig = function(pos, player)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		return inv:is_empty("stock") and inv:is_empty("customers_gave") and inv:is_empty("owner_wants") and inv:is_empty("owner_gives") and inv:is_empty("customer_gives") and inv:is_empty("customer_gets")
	end
})

minetest.register_on_player_receive_fields(function(sender, formname, fields)
	if formname == "currency:shop_formspec" and fields.tocustomer ~= nil and fields.tocustomer ~= "" then
		local name = sender:get_player_name()
		local pos = default.shop.current_shop[name]
		minetest.show_formspec(name,"currency:shop_formspec",default.shop.formspec.customer(pos))
	end
	if formname == "currency:shop_formspec" and fields.exchange ~= nil and fields.exchange ~= "" then
		local name = sender:get_player_name()
		local pos = default.shop.current_shop[name]
		local meta = minetest.get_meta(pos)
		if false and default.can_interact_with_node(sender, pos) then--disabled for now
			minetest.chat_send_player(name,"This is your own shop, you can't exchange to yourself !")
		else
			local minv = meta:get_inventory()
			local invlist_tostring = function(invlist)
				local out = {}
				for i, item in pairs(invlist) do
					out[i] = item:to_string()
				end
				return out
			end
			local wants = minv:get_list("owner_wants")
			local gives = minv:get_list("owner_gives")
			if wants == nil or gives == nil then return end -- do not crash the server
			-- Check if we can exchange
			local can_exchange = true
			local owners_fault = false
			local meta_mismatch = false
			for i, item in pairs(wants) do
				if not minv:contains_item("customer_gives",item) then
					can_exchange = false
				end
			end
			for i, item in pairs(gives) do
				if not minv:contains_item("stock",item, true) then
					can_exchange = false
					owners_fault = true
					if minv:contains_item("stock",item) then
						meta_mismatch = true
					end
				end
			end
			if can_exchange then
				for i, item in pairs(wants) do
					local cust_gave_item = minv:remove_item("customer_gives",item)
					minv:add_item("customers_gave",cust_gave_item)
				end
				for i, item in pairs(gives) do
					local stock_item = minv:remove_item("stock",item)
					minv:add_item("customer_gets",stock_item)
				end
				minetest.chat_send_player(name,"Exchanged!")
				local counter = meta:get_string("counter")
				if counter == nil or counter == "" then counter = 0 end
				counter = counter + 1
				meta:set_string("counter", counter)
			else
				if owners_fault then
					if meta_mismatch then
						minetest.chat_send_player(name,"Exchange can not be done, contact the shop owner. (meta mismatch)")
					else
						minetest.chat_send_player(name,"Exchange can not be done, contact the shop owner.")
					end
				else
					minetest.chat_send_player(name,"Exchange can not be done, check if you put all items !")
				end
			end
		end
	end
	if formname == "currency:shop_formspec" and fields.resetcounter and fields.resetcounter ~= nil then
		local name = sender:get_player_name()
		local pos = default.shop.current_shop[name]
		local meta = minetest.get_meta(pos)
		if default.can_interact_with_node(sender, pos) then
			meta:set_string("counter", 0)
			minetest.show_formspec(name,"currency:shop_formspec",default.shop.formspec.owner(pos))
		end
	end
end)

minetest.register_craft({
	output = 'currency:shop',
	recipe = {
		{'default:sign_wall'},
		{'default:chest_locked'},
	}
})

local get_money = money3.get
local set_money = money3.set
--Admin shop.
minetest.register_node("money3:admin_shop", {
	description = "Admin Shop",
	tiles = {"admin_shop.png"},
	groups = {snappy=2,choppy=2,oddly_breakable_by_hand=2},
	sounds = default.node_sound_wood_defaults(),
	paramtype2 = "facedir",
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", "Untuned Admin Shop")
		meta:set_string("formspec", "size[6,3.75]"..default.gui_bg..default.gui_bg_img..
			"label[-0.025,-0.2;Trade Type]"..
			"dropdown[-0.025,0.25;2.5,1;action;Sell,Buy,Buy and Sell;]"..
			"field[2.7,0.48;3.55,1;amount;Trade lot quantity (1-99);]"..
			"field[0.256,1.65;5.2,1;nodename;Node name to trade (eg. default:mese);]"..
			"item_image[5,1.25;1,1;default:diamond]" ..
			"field[0.256,2.75;3,1;costbuy;Buying price (per lot);]"..
			"field[3.25,2.75;3,1;costsell;Selling price (per lot);]"..
			"button_exit[2,3.25;2,1;button;Proceed]")
		meta:set_string("form", "yes")
	end,
	can_dig = function(pos,player)
		return minetest.get_player_privs(player:get_player_name())["money_admin"]
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		local meta = minetest.get_meta(pos)
		if meta:get_string("form") == "yes" then
			--if minetest.registered_items[fields.nodename] and tonumber(fields.amount) and tonumber(fields.amount) >= 1 and tonumber(fields.amount) <= 99 and (meta:get_string("owner") == sender:get_player_name() or minetest.get_player_privs(sender:get_player_name())["money_admin"]) then
			if tonumber(fields.amount) and tonumber(fields.amount) >= 1 and tonumber(fields.amount) <= 99 and (meta:get_string("owner") == sender:get_player_name() or minetest.get_player_privs(sender:get_player_name())["money_admin"]) then
				if fields.action == "Sell" then
					if not tonumber(fields.costbuy) then
						return
					end
					if not (tonumber(fields.costbuy) >= 0) then
						return
					end
				end
				if fields.action == "Buy" then
					if not tonumber(fields.costsell) then
						return
					end
					if not (tonumber(fields.costsell) >= 0) then
						return
					end
				end
				if fields.action == "Buy and Sell" then
					if not tonumber(fields.costbuy) then
						return
					end
					if not (tonumber(fields.costbuy) >= 0) then
						return
					end
					if not tonumber(fields.costsell) then
						return
					end
					if not (tonumber(fields.costsell) >= 0) then
						return
					end
				end
				local s, ss
				if fields.action == "Sell" then
					s = " sell "
					ss = "button[1,0.5;2,1;buttonsell;Sell("..fields.costbuy..")]"
				elseif fields.action == "Buy" then
					s = " buy "
					ss = "button[1,0.5;2,1;buttonbuy;Buy("..fields.costsell..")]"
				else
					s = " buy and sell "
					ss = "button[1,0.5;2,1;buttonbuy;Buy("..fields.costsell..")]" .. "button[5,0.5;2,1;buttonsell;Sell("..fields.costbuy..")]"
				end
				local meta = minetest.get_meta(pos)
				meta:set_string("formspec", "size[8,5.5;]"..default.gui_bg..default.gui_bg_img..
					"label[0.256,0;You can"..s..fields.amount.." "..fields.nodename.."]"..
					ss..
					"list[current_player;main;0,1.5;8,4;]")
				meta:set_string("nodename", fields.nodename)
				meta:set_string("amount", fields.amount)
				meta:set_string("costbuy", fields.costsell)
				meta:set_string("costsell", fields.costbuy)
				meta:set_string("infotext", "Admin Shop")
				meta:set_string("form", "no")
			end
		elseif fields["buttonbuy"] then
			local sender_name = sender:get_player_name()
			local sender_inv = sender:get_inventory()
			local is_car = car_list and car_list[meta:get_string("nodename")]
			if not is_car and not sender_inv:room_for_item("main", meta:get_string("nodename") .. " " .. meta:get_string("amount")) then
				minetest.chat_send_player(sender_name, "In your inventory is not enough space.")
			return true
			elseif get_money(sender_name) - tonumber(meta:get_string("costbuy")) < 0 then
				minetest.chat_send_player(sender_name, "You do not have enough money.")
			return true
			end
			set_money(sender_name, get_money(sender_name) - meta:get_string("costbuy"))
			if not is_car then
				sender_inv:add_item("main", meta:get_string("nodename") .. " " .. meta:get_string("amount"))
			else
				local car_near = false
				for id, obj in pairs(minetest.get_objects_inside_radius(pos, 4)) do
					if not obj:is_player() and car_list[obj:get_entity_name()] then
						car_near = true
						break
					end
				end
				if not car_near then
					local ent = minetest.add_entity({x=pos.x,y=pos.y+.5,z=pos.z}, meta:get_string("nodename"), sender_name)
					ent:setyaw(minetest.dir_to_yaw(minetest.facedir_to_dir(minetest.get_node(pos).param2)) - math.pi)
				else
					minetest.chat_send_player(sender_name, "You cannot spawn a vehicle with any other vehicles nearby.")
					return true
				end
			end
			minetest.chat_send_player(sender_name, "You bought " .. meta:get_string("amount") .. " " .. meta:get_string("nodename") .. " at a price of " .. money3.format(tonumber(meta:get_string("costbuy"))) .. ".")
		elseif fields["buttonsell"] then
			local sender_name = sender:get_player_name()
			local sender_inv = sender:get_inventory()
			if not sender_inv:contains_item("main", meta:get_string("nodename") .. " " .. meta:get_string("amount")) then
				minetest.chat_send_player(sender_name, "You don't have enough product.")
				return true
			end
			set_money(sender_name, get_money(sender_name) + meta:get_string("costsell"))
			if warfare and meta:get_string("nodename") == "warfare:resource" then
				local team = warfare.check_player(sender_name)
				if team and warfare[team] then
					for name, val in pairs(warfare[team].players) do
						if name ~= sender_name and get_money(name) then
							set_money(name, get_money(name) + math.floor(meta:get_string("costsell")/SHARED_AMOUNT+.5))
						end
					end
				end
			end
			sender_inv:remove_item("main", meta:get_string("nodename") .. " " .. meta:get_string("amount"))
			minetest.chat_send_player(sender_name, "You sold " .. meta:get_string("amount") .. " " .. meta:get_string("nodename") .. " at a price of "  .. money3.format(tonumber(meta:get_string("costsell"))) .. ".")
		end
	end,
})

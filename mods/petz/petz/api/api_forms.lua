local modpath, S = ...

petz.create_form = function(player_name, context)
    local pet = petz.pet[player_name]
    local form_size = {w = 4, h = 3}
    local buttonexit_pos = {x = 1, y = 6}
    local hungrystuff_pos = {x= 0, y = 0}
    local form_title = ""
    local tamagochi_form_stuff = ''
    local affinity_stuff = ''
    local form_orders = ''
    local more_form_orders = ''
    local tab_form = ''
    local final_form = ''
    if not context then
		context = {}
		context.tab_id = 1
    end
    local pet_icon = "petz_spawnegg_"..pet.type..".png"
	if context.tab_id == 1 and not(context.buy) then
		local pet_image_icon = "image[0.375,0.375;1,1;"..pet_icon.."]"
		if pet.affinity == nil then
			pet.affinity = 0
		end
		if petz.settings.tamagochi_mode == true then
			form_size.w= form_size.w + 1
			if pet.has_affinity == true then
				form_title = S("Orders")
				hungrystuff_pos = {x= 3, y = 2}
				affinity_stuff =
					"image_button[3.5,3.5;1,1;petz_affinity_heart.png;btn_affinity;]"..
					"label[4.5,4;".. tostring(pet.affinity).."%]"
			else
				form_size.w= form_size.w
				form_size.h= form_size.h + 1
				form_title = S("Status")
				hungrystuff_pos = {x= 1, y = 3}
			end
			tamagochi_form_stuff =
				pet_image_icon ..
				"label[1.375,3;".. form_title .."]"..
				"image_button[".. (hungrystuff_pos.x+0.5) ..",".. (hungrystuff_pos.y +0.5)..";1,1;petz_pet_bowl_inv.png;btn_bowl;]"..
				affinity_stuff
			local hungry_label = ""
			local health_label = S("Health").." = "..tostring(pet.hp)
			if pet.fed == false then
				hungry_label = S("Hungry")
			else
				hungry_label = S("Satiated")
			end
			hungry_label = hungry_label.."\n"..health_label
			tamagochi_form_stuff = tamagochi_form_stuff .. "label[".. hungrystuff_pos.x +1.5 ..",".. (hungrystuff_pos.y+0.75) ..";"..hungry_label.."]"
		else
			if pet.has_saddlebag == true and pet.saddlebag == true then
				form_size.w= form_size.w + 1
			end
			tamagochi_form_stuff = pet_image_icon
			if pet.has_affinity == true then
				tamagochi_form_stuff = tamagochi_form_stuff .. "label[1,2;".. S("Orders") .."]"
			end
		end
		if pet.is_pet == true and pet.tamed == true then
			if not(pet.tag) then
				pet.tag = ""
			end
			if pet.dreamcatcher == true then
				tamagochi_form_stuff = tamagochi_form_stuff..
				"image_button_exit[4,0.375;1,1;petz_dreamcatcher.png;btn_dreamcatcher;]"
			end
			tamagochi_form_stuff = tamagochi_form_stuff..
				"field[0.375,2;3,0.5;ipt_name;"..S("Name")..":"..";"..pet.tag.."]"..
				"checkbox[3.5,1.75;btn_muted;"..S("Muted")..";"..petz.vartostring(pet.muted).."]"--..
				--"checkbox[3.5,2.25;btn_show_tag;"..S("Show tag")..";"..petz.vartostring(pet.show_tag).."]"
		end
		if pet.breed == true then --Show the Gender
			local gender = ''
			if pet.is_male == true then
				gender = S("Male")
			else
				gender = S("Female")
			end
			tamagochi_form_stuff = tamagochi_form_stuff..
				"label[3,0.875;"..gender.."]"
			local pregnant_icon_x
			local pregnant_icon_y
			local pregnant_text_x
			local pregnant_text_y
			local infertile_text_x
			local infertile_text_y
			if pet.is_mountable == true or pet.give_orders == true then
				pregnant_icon_x = 3
				pregnant_icon_y = 5
				pregnant_text_x = 4
				pregnant_text_y = 5
				infertile_text_x = 3
				infertile_text_y = 5
			else
				pregnant_icon_x = 3
				pregnant_icon_y = 2
				pregnant_text_x = 4
				pregnant_text_y = 2
				infertile_text_x = 3
				infertile_text_y = 3
			end
			if pet.is_male == false and pet.is_pregnant == true then
				local pregnant_remain_time = petz.round(petz.settings.pregnancy_time - pet.pregnant_time)
				tamagochi_form_stuff = tamagochi_form_stuff..
					"image["..(pregnant_icon_x+0.375)..","..(pregnant_icon_y+0.5)..";1,1;petz_"..pet.type.."_pregnant_icon.png]"..
					"label["..(pregnant_text_x+0.375)..","..(pregnant_text_y+1)..";"..S("Pregnant").." ("..tostring(pregnant_remain_time).."s)]"
			elseif pet.is_male == false and pet.pregnant_count and pet.pregnant_count <= 0 then
				tamagochi_form_stuff = tamagochi_form_stuff..
					"label["..(pregnant_icon_x+0.5)..","..(infertile_text_y+1)..";"..S("Infertile").."]"
			end
			if pet.is_baby == true then
				local growth_remain_time = petz.round(petz.settings.growth_time - pet.growth_time)
				tamagochi_form_stuff = tamagochi_form_stuff..
					"label["..(pregnant_text_x-0.5)..","..(pregnant_text_y+1)..";"..S("To adult").." ("..tostring(growth_remain_time).."s)]"
			end
		end
		if pet.type == "pony" then
			local horseshoes = pet.horseshoes or 0
			more_form_orders = more_form_orders..
				"image_button_exit[5,0.375;1,1;petz_horseshoe.png;btn_horseshoes;"..tostring(horseshoes).."]"
		end
		if pet.can_perch then
			form_size.h = form_size.h + 1
			buttonexit_pos.y = buttonexit_pos.y + 1
			more_form_orders = more_form_orders..
			"button_exit[0.375,6.5;1,1;btn_alight;"..S("Alight").."]"	..
			"button_exit[1.375,6.5;1,1;btn_fly;"..S("Fly").."]"..
			"button_exit[2.375,6.5;2,1;btn_perch_shoulder;"..S("Perch on shoulder").."]"
		elseif pet.is_mountable == true then
			more_form_orders = more_form_orders..
				"image[3.5,4.5;1,1;petz_"..pet.type.."_velocity_icon.png]"..
				"label[4.5,5;".. tostring(pet.max_speed_forward).."/"..tostring(pet.max_speed_reverse)..'/'..tostring(pet.accel).."]"
			if pet.has_saddlebag == true and pet.saddlebag == true then
				more_form_orders = more_form_orders..
					"image_button[5,0.375;1,1;petz_saddlebag.png;btn_saddlebag;]"
			end
		end
		if pet.give_orders == true then
			form_size.h= form_size.h + 4
			form_size.w= form_size.w + 1
			form_orders =
				"button_exit[0.375,3.5;3,1;btn_followme;"..S("Follow me").."]"..
				"button_exit[0.375,4.5;3,1;btn_standhere;"..S("Stand here").."]"..
				"button_exit[0.375,5.5;3,1;btn_ownthing;"..S("Do your own thing").."]"..
				more_form_orders
		else
			if petz.settings.tamagochi_mode == true then
				buttonexit_pos.y = buttonexit_pos.y - 2
				form_size.h= form_size.h + 1
			else
				buttonexit_pos.y = buttonexit_pos.y - 4
				form_size.w= form_size.w + 1
			end
		end
		if pet.is_wild == true then
			form_orders =	form_orders .. "button_exit[3.375,5.5;2,1;btn_guard;"..S("Guard").."]"
		end
		tab_form = tamagochi_form_stuff.. form_orders
	elseif context.tab_id == 1 and context.buy then
		form_size.w = form_size.w + 1
		form_size.h = form_size.h + 2
		buttonexit_pos.x = buttonexit_pos.x + 1
		buttonexit_pos.y = buttonexit_pos.y - 2
		local item_description = petz.settings.selling_exchange_items_list[pet.exchange_item_index].description or ""
		local item_amount = pet.exchange_item_amount or 1
		local item_inventory_image = petz.settings.selling_exchange_items_list[pet.exchange_item_index].inventory_image or ""
		tab_form = tab_form ..
			"label[0.375,1.85;"..S("Cost")..": ]"..
			"label[2,1.85;"..item_description.."]"..
			"image[2.5,0.375;1,1;"..item_inventory_image.."]"..
			"label[0.375,2.5;"..S("Amount")..":]"..
			"label[2,2.5;"..tostring(item_amount).."]"..
			"style_type[button_exit;bgcolor=#333600;textcolor=white]"..
			"button_exit[2,3.25;2,1;btn_buy;"..S("Buy").."]"
	elseif context.tab_id == 2 and not(context.buy) then
		form_size.w = form_size.w + 1
		form_size.h = form_size.h + 2
		buttonexit_pos.y = buttonexit_pos.y - 2
		if pet.owner then
			tab_form = "image_button[0.375,0.375;1,1;"..pet_icon.."^petz_abandon_icon.png;btn_abandon;]"
			if pet.herd then
				tab_form = tab_form .. "checkbox[0.375,1.75;btn_herding;"..S("Herding")..";"..petz.vartostring(pet.herding).."]"
			end
			if petz.check_lifetime(pet) then
				tab_form = tab_form .. "image[2,0.375;1,1;petz_lifetime.png]" .. "label[3,0.75;"..S("Lifetime").."]".."label[3,1;"..tostring(pet.lifetime).."]"
			end
		end
	elseif context.tab_id == 3 and petz.settings.selling and not(context.buy) then
		form_size.w = form_size.w + 1
		form_size.h = form_size.h + 2
		buttonexit_pos.y = buttonexit_pos.y - 2
		local exchange_items = ''
		local dropdown_index = 1
		for i = 1, #petz.settings.selling_exchange_items_list do
			local description = petz.settings.selling_exchange_items_list[i].description
			if description then
				if i > 1 then
					exchange_items = exchange_items .. ","
				end
				exchange_items = exchange_items .. description
				if i == pet.exchange_item_index then
					dropdown_index = i
				end
			end
		end
		tab_form = tab_form ..
		"checkbox[0.375,0.5;chk_for_sale;"..S("For Sale")..";"..petz.vartostring(pet.for_sale).."]"..
		"label[0.375,1.0;"..S("Item").."]"..
		"textlist[0.375,1.25;3,3;txtlst_exchange_items;"..exchange_items..";"..tostring(dropdown_index).."]"..
		"label[4,1;"..S("Amount").."]"..
		"field[4,1.25;1,0.45;fld_exchange_item_amount;;"..tostring(pet.exchange_item_amount).."]"
		--"scrollbaroptions[min=1;max=99;arrows=show;smallstep=1;largestep=1]"..
		--"scrollbar[4,1.0;0.45,0.45;vertical;scrbar_exchange_item_amount;10]"
	end
	--Tab Header
	local tab_main = S("Main")
	local tab_other = S("Other")
	local tab_shop = S("Shop")
	local tab_header
	if context.buy then
		tab_header = tab_shop
	else
		tab_header =tab_main..","..tab_other
		if not(minetest.is_singleplayer()) then
			tab_header = tab_header..","..tab_shop
		end
	end
	--minetest.chat_send_player("singleplayer", tab_header)
	final_form =
		"size["..(form_size.w+0.875)..","..(form_size.h+1)..";]"..
		"real_coordinates[true]"..
		"tabheader[0,0;tabheader;"..tab_header..";"..tostring(context.tab_id)..";true;false]"..
		tab_form..
		"style_type[button_exit;bgcolor=#006699;textcolor=white]"..
		"button_exit["..(buttonexit_pos.x+0.5)..","..(buttonexit_pos.y+0.75)..";1,1;btn_close;"..S("Close").."]"
	return final_form
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if (formname ~= "petz:form_orders") then
		return false
	end
	local player_name = player:get_player_name()
	-- Was a tab selected?
	if fields.tabheader then
		local tab_id = tonumber(fields.tabheader)
		if tab_id > 0 then
			local context = {}
			context.tab_id = tab_id
			minetest.show_formspec(player_name, "petz:form_orders", petz.create_form(player_name, context))
		end
		return
	end
    local pet = petz.pet[player_name]
	if pet and pet.object then
		if fields.btn_followme then
			petz.follow(pet, player)
		elseif fields.btn_standhere then
			petz.standhere(pet)
		elseif fields.btn_guard then
			petz.guard(pet)
		elseif fields.btn_ownthing then
			mobkit.clear_queue_low(pet)
			petz.ownthing(pet)
		elseif fields.btn_alight then
			petz.alight(pet)
		elseif fields.btn_fly then
			mobkit.clear_queue_low(pet)
			mobkit.clear_queue_high(pet)
			pet.status = nil
			mobkit.hq_fly(pet, 0)
			minetest.after(2.5, function(pet)
				if mobkit.is_alive(pet) then
					mobkit.clear_queue_low(pet)
					pet.object:set_acceleration({ x = 0, y = 0, z = 0 })
					pet.object:set_velocity({ x = 0, y = 0, z = 0 })
				end
			end, pet)
		elseif fields.btn_perch_shoulder then
			petz.standhere(pet)
			mobkit.animate(pet, "stand")
			local shoulder_pos
			if pet.type == "parrot" then
				shoulder_pos = {x= 0.5, y= -6.25, z=0}
			else
				shoulder_pos = {x= 0.5, y= -6.0, z=0}
			end
			pet.object:set_attach(player, "Arm_Left", shoulder_pos, {x=0, y=0, z=180})
			pet.object:set_properties({physical = false,})
			minetest.after(120.0, function(pet)
				if mobkit.is_alive(pet) then
					pet.object:set_detach()
					pet.object:set_properties({physical = true,})
				end
			end, pet)
		elseif fields.btn_muted then
			pet.muted= mobkit.remember(pet, "muted", minetest.is_yes(fields.btn_muted))
		elseif fields.btn_show_tag then
			pet.show_tag = mobkit.remember(pet, "show_tag", minetest.is_yes(fields.btn_show_tag))
		elseif fields.btn_dreamcatcher then
			petz.drop_dreamcatcher(pet)
		elseif fields.btn_saddlebag then
			--Load the inventory from the petz
			local inv = minetest.get_inventory({ type="detached", name="saddlebag_inventory" })
			inv:set_list("saddlebag", {})
			if pet.saddlebag_inventory then
				for key, value in pairs(pet.saddlebag_inventory) do
					inv:set_stack("saddlebag", key, value)
				end
			end
			--Show the inventory:
			local formspec = "size[8,8;]"..
							"image[3,0;1,1;petz_saddlebag.png]"..
							"label[4,0;"..S("Saddlebag").."]"..
							"list[detached:saddlebag_inventory;saddlebag;0,1;8,2;]"..
							"list[current_player;main;0,4;8,4;]"
			minetest.show_formspec(player_name, "petz:saddlebag_inventory", formspec)
		elseif fields.btn_bowl then
			minetest.show_formspec(player_name, "petz:food_form", petz.create_food_form(pet))
		elseif fields.btn_affinity then
			minetest.show_formspec(player_name, "petz:affinity_form", petz.create_affinity_form(pet))
		elseif fields.btn_horseshoes then
			petz.horseshoes_reset(pet)
		elseif fields.btn_abandon then
			minetest.show_formspec(player_name, "petz:abandon_form", petz.get_abandon_confirmation())
		elseif fields.btn_herding then
			pet.herding = mobkit.remember(pet, "herding", minetest.is_yes(fields.btn_herding))
		elseif fields.chk_for_sale then
			pet.for_sale = mobkit.remember(pet, "for_sale", minetest.is_yes(fields.chk_for_sale))
		elseif fields.fld_exchange_item_amount or fields.txtlst_exchange_items then
			local event = minetest.explode_textlist_event(fields.txtlst_exchange_items)
			if event.type == "CHG" then
				--minetest.chat_send_all(event.index)
				pet.exchange_item_index = mobkit.remember(pet, "exchange_item_index", event.index)
			end
			pet.exchange_item_amount = mobkit.remember(pet, "exchange_item_amount", mokapi.delimit_number( tonumber(fields.fld_exchange_item_amount), {min=1, max=99}) or 1)
		elseif fields.btn_buy then
			petz.buy(pet, player)
		end
		if fields.ipt_name then
			pet.tag = minetest.formspec_escape(string.sub(fields.ipt_name, 1 , 12))
			mobkit.remember(pet, "tag", pet.tag)
			if not(pet.tag == "") then
				petz.insert_tamed_by_owner(pet)
			else
				petz.remove_tamed_by_owner(pet, true)
			end
		end
		petz.update_nametag(pet)
		return true
	else
		return false
	end
end)

--On receive fields
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "petz:saddlebag_inventory" then
		return false
	end
	--Save the saddlebag content
	local player_name = player:get_player_name()
	local ent = petz.pet[player_name]
	if ent and ent.object then
		local inv = minetest.get_inventory({ type="detached", name="saddlebag_inventory" })
		local itemstacks_table = {}
		local inv_size = inv:get_size("saddlebag")
		if inv_size > 0 then
			for i = 1, inv_size do
				itemstacks_table[i] = inv:get_stack("saddlebag", i):to_table()
			end
			ent.saddlebag_inventory = itemstacks_table
			mobkit.remember(ent, "saddlebag_inventory", itemstacks_table)
		end
	end
	return true
end)

--Saddlebag detached inventory

local function allow_put(pos, listname, index, stack, player)
	return stack:get_count()
end

petz.create_detached_saddlebag_inventory = function(name)
	local saddlebag_inventory = minetest.create_detached_inventory(name, {
		allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
			local stack = inv:get_stack(from_list, from_index)
			return allow_put(inv, from_list, from_index, stack, player)
			end,
		allow_put = function(inv, listname, index, stack, player)
			return stack:get_count()
		end,
		allow_take = function(inv, listname, index, stack, player)
			return stack:get_count()
		end,
	})
	-- Size and width of saddlebag inventory
	saddlebag_inventory:set_size("saddlebag", 16)
	saddlebag_inventory:set_width("saddlebag", 8)
end

petz.create_detached_saddlebag_inventory("saddlebag_inventory")

petz.create_food_form = function(self)
	local items = string.split(petz.settings[self.type.."_follow"], ',')
	local items_desc = ""
	for i = 1, #items do --loop  thru all items
		local item = petz.str_remove_spaces(items[i]) --remove spaces
		if string.sub(item, 1, 5) == "group" then
			items_desc = items_desc .. string.sub(item, 7)
		else
			items_desc = items_desc .. (minetest.registered_items[item].description or "unknown")
		end
		if i < #items then
			items_desc = items_desc .. ", "
		end
	end
	local formspec = ""
	local form_size = {w= 3, h= 3}
	local button_exit = {x= 1, y= 2}
	if self.breed == true then
		form_size.h = form_size.h + 1
		button_exit.y = button_exit.y + 1
	end
	formspec =
		"size["..form_size.w..","..form_size.h.."]"..
		"image[0,0;1,1;petz_spawnegg_"..self.type..".png]"..
		"label[1,0;"..S("Food").."]"..
		"label[0,1;"..S("It likes")..": ".. items_desc .."]"..
		"button_exit["..button_exit.x..","..button_exit.y..";1,1;btn_exit;"..S("Close").."]"
	if self.breed == true then
		local breed_item = minetest.registered_items[petz.settings[self.type.."_breed"]]
		local breed_item_desc
		if not(breed_item) then
			if self.is_mountable then
				breed_item_desc = minetest.registered_items["petz:glass_syringe"].description
			else
				breed_item_desc = "unknown"
			end
		else
			breed_item_desc = breed_item.description
		end
		formspec = formspec .. "label[0,2;"..S("It breeds with")..": ".. breed_item_desc .."]"
	end
    return formspec
end

petz.create_affinity_form = function(self)
	local formspec = ""
	local form_size = {w= 3, h= 4}
	local button_exit = {x= 1, y= 3}
	local feed_status, feed_status_color
	if self.fed == true then
		feed_status = S("Fed")
		feed_status_color = petz.colors["green"]
	else
		feed_status = S("Hungry")..": " .. tostring(petz.calculate_affinity_change(-petz.settings.tamagochi_feed_hunger_rate))
		feed_status_color = petz.colors["red"]
	end
	local brushing_status, brushing_status_color
	if self.brushed then
		brushing_status = S("Brushed")
		brushing_status_color = petz.colors["green"]
	else
		brushing_status = S("Not brushed")..": " .. tostring(petz.calculate_affinity_change(-petz.settings.tamagochi_brush_rate))
		brushing_status_color = petz.colors["red"]
	end
	formspec =
		"size["..form_size.w..","..form_size.h.."]"..
		"image[0,0;1,1;petz_affinity_heart.png]"..
		"label[1,0;"..S("Affinity").."]"..
		"label[0,1;".. minetest.colorize(feed_status_color, feed_status).."]"..
		"label[0,2;".. minetest.colorize(brushing_status_color, brushing_status).."]"..
		"button_exit["..button_exit.x..","..button_exit.y..";1,2;btn_exit;"..S("Close").."]"
    return formspec
end

--On receive fields
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "petz:food_form" and formname ~= "petz:affinity_form" then
		return false
	end
	local player_name = player:get_player_name()
	local pet = petz.pet[player_name]
	if pet and (mobkit.is_alive(pet)) then
		minetest.show_formspec(player_name, "petz:form_orders", petz.create_form(player_name, context))
	end
	return true
end)

function petz.get_abandon_confirmation()
    local text = S("Do you want to ABANDON your pet?!")
    local formspec = {
        "size[6,2.476]",
        "real_coordinates[true]",
        "label[0.375,0.5;", minetest.formspec_escape(text), "]",
        "style_type[button_exit;bgcolor=#006699;textcolor=white]",
        "button_exit[1.2,1.3;1,0.8;btn_yes;"..S("Yes").."]"..
        "button_exit[3.2,1.3;1.5,0.8;btn_cancel;"..S("Cancel").."]"
    }
    return table.concat(formspec, "")
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "petz:abandon_form" then
		return false
	end
	local player_name = player:get_player_name()
	if fields.btn_yes then
		local pet = petz.pet[player_name]
		if pet and (mobkit.is_alive(pet)) then
			local msg = S("You've abandoned your").." "..pet.type
			petz.abandon_pet(pet, msg)
		end
	else
		local context = {}
		context.tab_id = 2
		minetest.show_formspec(player_name, "petz:form_orders", petz.create_form(player_name, context))
	end
	return true
end)

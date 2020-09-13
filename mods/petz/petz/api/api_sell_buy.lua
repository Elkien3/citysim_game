local S = ...

petz.buy = function(self, buyer)
	local buyer_name= buyer:get_player_name()
	local inv_buyer= buyer:get_inventory()
	local seller_name = self.owner
	if not seller_name then
		return
	end
	local seller = minetest.get_player_by_name(seller_name)
	local item_index = self.exchange_item_index
	local item_amount = self.exchange_item_amount
	local item_name = petz.settings.selling_exchange_items_list[item_index].name
	--minetest.chat_send_all(item_name)
	local item_description = petz.settings.selling_exchange_items_list[item_index].description
	local item_stack = ItemStack({name = item_name, count = item_amount})
	if not seller then
		minetest.chat_send_player(buyer_name, S("The seller is not online."))
		return
	elseif not(inv_buyer:contains_item("main", item_stack)) then
		minetest.chat_send_player(buyer_name, S("You have not").." "..item_description.." ("..tostring(item_amount)..")")
		return
	end
	-- Do buy
	inv_buyer:remove_item("main", item_stack)
	local inv_seller = seller:get_inventory()
	if inv_seller:room_for_item("main", item_stack) then
		inv_seller:add_item("main", item_stack)
	else
		local seller_pos = seller:get_pos()
		minetest.item_drop(item_stack, seller, seller_pos)
	end
	petz.abandon_pet(self, S("You have sold your").." "..self.type.." "..S("to").." "..buyer_name..".")
	mokapi.set_owner(self, buyer_name)
	minetest.chat_send_player(buyer_name, S("Congratulations, you've bought a").." "..self.type)
end

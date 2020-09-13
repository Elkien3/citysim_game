
petz.bottled = function(self, clicker)
	--capture the petz with the 'bottled' property in the bottle
	local new_stack = ItemStack(self.bottled) 	-- add special mob egg with all mob information
	local stack_meta = new_stack:get_meta()
	local itemstack_meta = petz.capture(self, clicker, false)
	stack_meta:set_int("petz:texture_no", itemstack_meta:get_int("texture_no"))
	--minetest.chat_send_all("texture= "..itemstack_meta:get_int("texture_no"))
	local inv = clicker:get_inventory()
	if inv:room_for_item("main", new_stack) then
		inv:add_item("main", new_stack)
	else
		minetest.add_item(clicker:get_pos(), new_stack)
	end
end

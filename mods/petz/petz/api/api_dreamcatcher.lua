local modpath, S = ...

--
-- Dreamcatcher (protector for Petz)
--

-- Dreamcatcher
--[[
minetest.register_craftitem("petz:dreamcatcher", {
	description = S("Pet Dreamcatcher"),
	inventory_image = "petz_dreamcatcher.png",
	groups = {},
	on_use = function (itemstack, user, pointed_thing)
		local user_name = user:get_player_name()
		local user_pos = user:get_pos()
		minetest.show_formspec(user_name, "petz:form_dreamcatcher", petz.create_form_list_by_owner_dreamcatcher(user_name, user_pos))
	end,
})

minetest.register_craft({
	type = "shaped",
	output = "petz:dreamcatcher",
	recipe = {
		{"", "group:wood", ""},
		{"farming:string", "farming:string", "farming:string"},
		{"petz:ducky_feather", "petz:ducky_feather", "petz:ducky_feather"},
	}
})
--]]
petz.put_dreamcatcher = function(self, clicker, wielded_item, wielded_item_name)
	if self.dreamcatcher == true then
		minetest.chat_send_player(clicker:get_player_name(), S("This pet already has a Dreamcatcher."))
		return
	end
	wielded_item:take_item() --quit one from player's inventory
	clicker:set_wielded_item(wielded_item)
	self.dreamcatcher = true
	mobkit.remember(self, "dreamcatcher", self.dreamcatcher)
	mokapi.make_sound("object", self.object, "petz_magical_chime", petz.settings.max_hear_distance)
	petz.do_particles_effect(self.object, self.object:get_pos(), "dreamcatcher")
end

petz.drop_dreamcatcher = function(self)
	if self.dreamcatcher == true then --drop the dreamcatcher
		minetest.add_item(self.object:get_pos(), "petz:dreamcatcher")
		mokapi.make_sound("object", self.object, "petz_pop_sound", petz.settings.max_hear_distance)
		self.dreamcatcher = false
		mobkit.remember(self, "dreamcatcher", self.dreamcatcher)
	end
end

petz.dreamcatcher_save_metadata = function(self)
	if self.tag == "" or not(self.owner) then
		return
	end
	local item_list_table = petz.tamed_by_owner[self.owner]
	if not(item_list_table) then
		return
	end
	for i = 1, #item_list_table do
		if item_list_table[i].pet == self then
			item_list_table[i]["metadata"].tag = self.tag
			item_list_table[i]["metadata"].type = self.type
			item_list_table[i]["metadata"].dreamcatcher = self.dreamcatcher
			item_list_table[i]["metadata"].last_pos = self.object:get_pos()
			break
		end
	end
end

petz.create_form_list_by_owner_dreamcatcher = function(user_name, user_pos)
	--Get the values of the list
	local item_list_table = petz.tamed_by_owner[user_name]
	if item_list_table then
		if #item_list_table <= 0 then
			minetest.chat_send_player(user_name, "You have no pets with a name and a dreamcatcher to list.")
			return ''
		end
		local item_list = ""
		local text_color
		for key, pet_table in ipairs(item_list_table) do
			local pet = pet_table.pet
			local pet_type
			local pet_pos
			local pet_tag
			local list_pet = false
			if mobkit.is_alive(pet) and pet.dreamcatcher then -- check if alive and has a dreamcatcher
				pet_tag = pet.tag
				pet_type =  pet.type
				pet_pos =  pet.object:get_pos()
				text_color = petz.colors["green"]
				list_pet = true
			elseif pet_table.metadata.dreamcatcher == true then
				pet_tag = pet_table.metadata.tag
				pet_type = pet_table.metadata.type
				pet_pos = pet_table.metadata.last_pos
				text_color = petz.colors["red"]
				list_pet = true
			end
			if list_pet and pet_pos then
				local pet_type =  pet.type:gsub("^%l", string.upper)
				local distance, pet_pos_x, pet_pos_y, pet_pos_z
				distance = tostring(petz.round(vector.distance(user_pos, pet_pos)))
				pet_pos_x = tostring(math.floor(pet_pos.x+0.5))
				pet_pos_y = tostring(math.floor(pet_pos.y+0.5))
				pet_pos_z = tostring(math.floor(pet_pos.z+0.5))
				item_list = item_list .. pet_tag.." | " .. S(pet_type) .. " | ".. "Pos = (".. pet_pos_x .. "/"
				.. pet_pos_y .. "/".. pet_pos_z ..") | Dist= "..distance..","
			end
		end
		local form_list_by_owner =
			"size[6,8;]"..
			--"style_type[textlist;textcolor="..text_color.."]"..
			"image[2,0;1,1;petz_dreamcatcher.png]"..
			"textlist[0,1;5,6;petz_list;"..item_list..";selected idx]"..
			"button_exit[2,7;1,1;btn_exit;"..S("Close").."]"
		return form_list_by_owner
	else
		return ''
	end
end

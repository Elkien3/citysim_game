local modpath, S = ...

--
-- Mount Engine
--

petz.mount = function(self, clicker, wielded_item, wielded_item_name)
	if clicker:is_player() then
		local player_pressed_keys = clicker:get_player_control()
		if player_pressed_keys["sneak"] == true then
			return true
		end
	end
	if self.tamed and self.owner == clicker:get_player_name() then
		if self.driver and clicker == self.driver then -- detatch player already riding horse
			petz.detach(clicker, {x = 1, y = 0, z = 1})
			mobkit.clear_queue_low(self)
			return false
		elseif (self.saddle or self.saddlebag) and wielded_item_name == petz.settings.shears then
			if self.saddle then
				minetest.add_item(self.object:get_pos(), "petz:saddle")
				mokapi.make_sound("object", self.object, "petz_pop_sound", petz.settings.max_hear_distance)
				self.saddle = false
				mobkit.remember(self, "saddle", self.saddle)
			end
			if self.saddlebag then
				minetest.add_item(self.object:get_pos(), "petz:saddlebag")
				mokapi.make_sound("object", self.object, "petz_pop_sound", petz.settings.max_hear_distance)
				self.saddlebag = false
				mobkit.remember(self, "saddlebag", self.saddlebag)
			end
			petz.set_properties(self, {textures = {"petz_"..self.type.."_"..self.skin_colors[self.texture_no]..".png"}})
			return false
		elseif (not(self.driver) and not(self.is_baby)) and ((wielded_item_name == "petz:saddle") or (wielded_item_name == "petz:saddlebag")) then -- Put on saddle if tamed
			local put_saddle = false
			if wielded_item_name == "petz:saddle" and not(self.saddle) then
				put_saddle = true
			elseif wielded_item_name == "petz:saddlebag" and not(self.saddlebag) and not(self.type == "pony") then
				put_saddle = true
			end
			if put_saddle == true then
				petz.put_saddle(self, clicker, wielded_item, wielded_item_name)
				return false
			end
		elseif not(self.driver) and self.saddle then -- Mount petz
			petz.set_properties(self, {stepheight = 1.1})
			petz.attach(self, clicker)
			return false
		else
			return true
		end
	else
		return true
	end
end

petz.put_saddle = function(self, clicker, wielded_item, wielded_item_name)
	local saddle_type
	local another_saddle = ""
	if wielded_item_name == "petz:saddle" then
		saddle_type = "saddle"
		self.saddle = true
		mobkit.remember(self, "saddle", self.saddle)
		if self.saddlebag == true then
			another_saddle = "^petz_"..self.type.."_saddlebag.png"
		end
	else
		saddle_type = "saddlebag"
		self.saddlebag = true
		mobkit.remember(self, "saddlebag", self.saddlebag)
		if self.saddle == true then
			another_saddle = "^petz_"..self.type.."_saddle.png"
		end
	end
	local texture = "petz_"..self.type.."_"..self.skin_colors[self.texture_no]..".png" .. "^petz_"..self.type.."_"..saddle_type..".png"..another_saddle
	petz.set_properties(self, {textures = {texture}})
	if not minetest.settings:get_bool("creative_mode") then
		wielded_item:take_item()
		clicker:set_wielded_item(wielded_item)
	end
	mokapi.make_sound("object", self.object, "petz_put_sound", petz.settings.max_hear_distance)
end

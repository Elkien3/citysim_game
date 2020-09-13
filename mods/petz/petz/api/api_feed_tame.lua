local modpath, S, creative_mode = ...

petz.insert_tamed_by_owner = function(self)
	if not self.owner then
		return
	end
	if (petz.tamed_by_owner[self.owner] == nil) then
		petz.tamed_by_owner[self.owner] = {}
	end
	local insert = true
	for i = 1, #petz.tamed_by_owner[self.owner] do
		if petz.tamed_by_owner[self.owner][i].pet == self then
			insert = false
			break
		end
	end
	if insert == true then --if not yet
		table.insert(petz.tamed_by_owner[self.owner], {["pet"] = self, metadata = {["tag"] = self.tag, ["type"] = self.type, ["last_pos"] = nil}})
	end
end

petz.remove_tamed_by_owner = function(self, force)
	if self.tag ~= "" or force then
		if petz.tamed_by_owner[self.owner] then
			local temp_table = {}
			for key, pet_table in ipairs(petz.tamed_by_owner[self.owner]) do
				if pet_table.pet ~= self then
					table.insert(temp_table, pet_table)
					--minetest.chat_send_player("singleplayer", self.tag)
				end
			end
			petz.tamed_by_owner[self.owner] = temp_table
		end
	end
end

petz.count_tamed_by_owner = function(owner_name)
	local count
	if petz.tamed_by_owner[owner_name] then
		count = #petz.tamed_by_owner[owner_name]
	else
		count = 0
	end
	return count
end

petz.do_feed = function(self)
	petz.set_affinity(self, petz.settings.tamagochi_feed_hunger_rate)
	self.fed = mobkit.remember(self, "fed", true)
end

petz.after_tame = function(self)
	petz.insert_tamed_by_owner(self)
	if petz.settings.tamagochi_mode == true then
		self.init_tamagochi_timer = true
	end
end

--
--Tame with a whip mechanic
--

-- Whip/lashing behaviour

petz.do_lashing = function(self)
    if self.lashed == false then
        self.lashed = mobkit.remember(self, "lashed", true)
    end
    mokapi.make_sound("object", self.object, "petz_"..self.type.."_moaning", petz.settings.max_hear_distance)
end

petz.tame_whip= function(self, hitter)
		local wielded_item_name= hitter:get_wielded_item():get_name()
		if (wielded_item_name == "petz:whip") then
			if self.tamed == false then
				--The mob can be tamed lashed with a whip
				self.lashing_count = self.lashing_count + 1
				if self.lashing_count >= petz.settings.lashing_tame_count then
					self.lashing_count = mobkit.remember(self, "lashing_count", 0)	 --reset to 0
					mokapi.set_owner(self, hitter:get_player_name())
					petz.after_tame(self)
					minetest.chat_send_player(self.owner, S("The").." "..S(petz.first_to_upper(self.type)).." "..S("has been tamed."))
					mobkit.clear_queue_high(self) -- do not attack
				end
			else
				if (petz.settings.tamagochi_mode == true) and (self.owner == hitter:get_player_name()) then
					petz.do_lashing(self)
				end
			end
			mokapi.make_sound("object", hitter, "petz_whip", petz.settings.max_hear_distance)
		end
end

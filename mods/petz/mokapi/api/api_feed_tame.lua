function mokapi.feed(self, clicker, feed_rate, msg_full_health, sound_type)
	local fed = false
	local wielded_item = clicker:get_wielded_item()
	local wielded_item_name = wielded_item:get_name()
	if mokapi.item_in_itemlist(wielded_item_name, self.follow) then -- Can eat/tame with item in hand
		fed = true
		local creative_mode = minetest.settings:get_bool("creative_mode")
		if creative_mode == false then -- if not in creative, take item
			wielded_item:take_item()
			clicker:set_wielded_item(wielded_item)
		end
		--Feed-->
		mokapi.set_health(self, feed_rate or mokapi.consts.DEFAULT_FEED_RATE)
		if self.hp >= self.max_hp then
			self.hp = self.max_hp
			if msg_full_health then
				minetest.chat_send_player(clicker:get_player_name(), msg_full_health)
			end
		end
		self.food_count = mobkit.remember(self, "food_count", self.food_count + 1) --increase the food count
		if sound_type then
			mobkit.make_sound(self, sound_type)
		end
	end
	return fed
end

function mokapi.tame(self, feed_count, owner_name, msg_tamed, limit)
	local tamed = false
	if self.food_count >= (feed_count or mokapi.consts.DEFAULT_FEED_COUNT) then
		self.food_count = mobkit.remember(self, "food_count", 0) --reset
		if self.tamed == false then --if not tamed
			local limit_reached = false
			if limit and (limit.max >= 0) then
				--minetest.chat_send_player(owner_name, "limit.max="..tostring(limit.max)..", limit.count="..tostring(limit.count))
				if (limit.count +1) > limit.max then
					minetest.chat_send_player(owner_name, limit.msg)
					limit_reached = true
				end
			end
			if not limit_reached then
				tamed = true
				mokapi.set_owner(self, owner_name)
				if msg_tamed then
					minetest.chat_send_player(owner_name, msg_tamed)
				end
				mobkit.clear_queue_high(self) -- clear behaviour (i.e. it was running away)
			end
		end
	end
	return tamed
end

function mokapi.set_owner(self, owner_name)
	self.tamed = mobkit.remember(self, "tamed", true)
	self.owner = mobkit.remember(self, "owner", owner_name)
end

function mokapi.remove_owner(self)
	self.tamed = mobkit.remember(self, "tamed", false)
	self.owner = mobkit.remember(self, "owner", nil)
end

--Calculate heal/hurt hunger

function mokapi.set_health(self, rate)
	if rate > 1.0 then
		rate = 1.0
	end
	local hp_amount = math.abs(self.max_hp * rate)
	if rate >= 0 then
		mobkit.heal(self, hp_amount)
	else
		mobkit.hurt(self, hp_amount)
	end
end

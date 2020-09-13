local modpath, S = ...

--
-- FOLLOW BEHAVIOURS
-- 2 types: for terrestrial and for flying/aquatic mobs.

--
-- Follow behaviours for terrestrial mobs (2 functions; start & stop)
--

function petz.bh_start_follow(self, pos, player, prty)
	if player then
		local wielded_item_name = player:get_wielded_item():get_name()
		local tpos = player:get_pos()
		if mokapi.item_in_itemlist(wielded_item_name, self.follow) and vector.distance(pos, tpos) <= self.view_range then
			self.status = mobkit.remember(self, "status", "follow")
			if (self.can_fly) or (self.can_swin and self.isinliquid) then
				mobkit.hq_followliquidair(self, prty, player)
			else
				mobkit.hq_follow(self, prty, player)
			end
			return true
		else
			return false
		end
	end
end

function petz.bh_stop_follow(self, player)
	if player then
		local wielded_item_name = player:get_wielded_item():get_name()
		if wielded_item_name ~= self.follow then
			petz.ownthing(self)
			return true
		else
			return false
		end
	else
		petz.ownthing(self)
	end
end

--
-- Follow Fly/Water Behaviours (2 functions: HQ & LQ)
--

function mobkit.hq_followliquidair(self, prty, player)
	local func=function(self)
		local pos = mobkit.get_stand_pos(self)
		local tpos = player:get_pos()
		if self.can_swin then
			if not(petz.isinliquid(self)) then
				--check if water below, dolphins
				local node_name = mobkit.node_name_in(self, "below")
				if minetest.get_item_group(node_name, "water") == 0  then
					petz.ownthing(self)
					return true
				end
			end
		end
		if pos and tpos then
			local distance = vector.distance(pos, tpos)
			if distance < 3 then
				return
			elseif (distance < self.view_range) then
				if mobkit.is_queue_empty_low(self) then
					mobkit.lq_followliquidair(self, player)
				end
			elseif distance >= self.view_range then
				petz.ownthing(self)
				return true
			end
		else
			return true
		end
	end
	mobkit.queue_high(self, func, prty)
end

function mobkit.lq_followliquidair(self, target)
	local func = function(self)
		mobkit.flyto(self, target)
		return true
	end
	mobkit.queue_low(self,func)
end

function mobkit.flyto(self, target)
	local pos = self.object:get_pos()
	local tpos = target:get_pos()
	local tgtbox = target:get_properties().collisionbox
	local height = math.abs(tgtbox[3]) + math.abs(tgtbox[6])
	--minetest.chat_send_player("singleplayer", tostring(tpos.y))
	--minetest.chat_send_player("singleplayer", tostring(height))
	tpos.y = tpos.y + 2 * (height)
	local dir = vector.direction(pos, tpos)
	local velocity = {
		x= self.max_speed* dir.x,
		y= self.max_speed* dir.y,
		z= self.max_speed* dir.z,
	}
	local new_yaw = minetest.dir_to_yaw(dir)
	self.object:set_yaw(new_yaw)
	self.object:set_velocity(velocity)
end

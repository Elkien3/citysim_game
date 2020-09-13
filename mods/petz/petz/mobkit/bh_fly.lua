local modpath, S = ...

--
-- WANDER FLY BEHAVIOUR (2 functions: HQ & LQ)
--

function mobkit.hq_wanderfly(self, prty)
	local func=function(self)
		if mobkit.is_queue_empty_low(self) then
			mobkit.lq_dumbfly(self, 0.6)
		end
	end
	mobkit.queue_high(self,func,prty)
end

--3 fly status: ascend, descend and stand right.
--Each 3 seconds:
--1) Search if 'max_height' defined for each mob is reached, if yes: descend or stand.
--2) Check if over water, if yes: ascend.
--3) Check if node in front, if yes: random rotation backwards. This does mobs not stuck.
--4) Random rotation, to avoid mob go too much further.
--5) In each status a chance to change of status, important: more preference for 'ascend'
--than descend, cos this does the mobs stand on air, and climb mountains and trees.

function mobkit.lq_turn2yaw(self, yaw)
	local func = function(self)
		if mobkit.turn2yaw(self, yaw) then
			return true
		end
	end
	mobkit.queue_low(self,func)
end

function mobkit.lq_dumbfly(self, speed_factor)
	local timer = petz.settings.fly_check_time
	local fly_status = "ascend"
	speed_factor = speed_factor or 1
	local func = function(self)
		timer = timer - self.dtime
		if timer < 0 then
			--minetest.chat_send_player("singleplayer", tostring(timer))
			local velocity
			mobkit.animate(self, 'fly')
			local random_num = math.random(1, 5)
			local yaw = self.object:get_yaw()
			local rotation = self.object:get_rotation()
			if random_num <= 1 or mobkit.node_name_in(self, "front") ~= "air" then
				if yaw then
					--minetest.chat_send_player("singleplayer", "test")
					local rotation_integer = math.random(0, 4)
					local rotation_decimals = math.random()
					local new_yaw = yaw + rotation_integer + rotation_decimals
					mobkit.lq_turn2yaw(self, new_yaw)
					return true --finish this que to start the turn
				end
			end
			local y_impulse = 1
			if mobkit.check_front_obstacle(self) and mobkit.node_name_in(self, "top") == "air" then
				fly_status = "ascend"
				y_impulse = 3
			end
			local height_from_ground = mobkit.check_height(self) --returns 'false' if the mob flies higher that max_height, otherwise returns the height from the ground
			--minetest.chat_send_player("singleplayer", tostring(height_from_ground))
			if not(height_from_ground) or mobkit.node_name_in(self, "top") ~= "air" then --check if max height, then stand or descend, or a node above the petz
				random_num = math.random(1, 100)
				if random_num < 70 then
					fly_status = "descend"
				else
					fly_status = "stand"
				end
			else --check if water below, or near the ground, if yes ascend
				local node_name = mobkit.node_name_in(self, "below")
				if minetest.get_item_group(node_name, "water") >= 1  then
					fly_status = "ascend"
				end
				if height_from_ground and (height_from_ground < 1) then
					fly_status = "ascend"
				end
			end
			--minetest.chat_send_player("singleplayer", status)
			--local node_name_in_front = mobkit.node_name_in(self, "front")
			if fly_status == "stand" then -- stand
				velocity = {
					x= self.max_speed* speed_factor,
					y= 0.0,
					z= self.max_speed* speed_factor,
				}
				self.object:set_rotation({x= -0.0, y = rotation.y, z= rotation.z})
				random_num = math.random(1, 100)
				if random_num < 20 and not(height_from_ground) then
					fly_status = "descend"
				elseif random_num < 40 then
					fly_status = "ascend"
				end
				--minetest.chat_send_player("singleplayer", "stand")
			elseif fly_status == "descend" then -- descend
				velocity = {
					x = self.max_speed* speed_factor,
					y = -speed_factor,
					z = self.max_speed* speed_factor,
				}
				self.object:set_rotation({x= 0.16, y = rotation.y, z= rotation.z})
				random_num = math.random(1, 100)
				if random_num < 20 then
					fly_status = "stand"
				elseif random_num < 40 then
					fly_status = "ascend"
				end
				--minetest.chat_send_player("singleplayer", "descend")
			else --ascend
				fly_status = "ascend"
				velocity ={
					x = self.max_speed * speed_factor,
					y = speed_factor * (y_impulse or 1),
					z = self.max_speed * speed_factor,
				}
				self.object:set_rotation({x= -0.16, y = rotation.y, z= rotation.z})
				--minetest.chat_send_player("singleplayer", tostring(velocity.x))
				--minetest.chat_send_player("singleplayer", "ascend")
			end
			timer = petz.settings.fly_check_time
			petz.set_velocity(self, velocity)
			self.fly_velocity = velocity --save the velocity to set in each step, not only each x seconds
			return true
		else
			if self.fly_velocity then
				petz.set_velocity(self, self.fly_velocity)
			else
				petz.set_velocity(self, {x = 0.0, y = 0.0, z = 0.0})
			end
		end
	end
	mobkit.queue_low(self,func)
end

--
-- 'Take Off' Behaviour ( 2 funtions)
--

function mobkit.hq_fly(self, prty)
	local func=function(self)
		mobkit.animate(self, "fly")
		mobkit.lq_fly(self)
		mobkit.clear_queue_high(self)
	end
	mobkit.queue_high(self, func, prty)
end

function mobkit.lq_fly(self)
	local func=function(self)
		self.object:set_acceleration({ x = 0, y = 1, z = 0 })
	end
	mobkit.queue_low(self,func)
end

-- Function to recover flying mobs from water

function mobkit.hq_liquid_recovery_flying(self, prty)
	local func=function(self)
		self.object:set_acceleration({ x = 0.0, y = 0.125, z = 0.0 })
		self.object:set_velocity({ x = 1.0, y = 1.0, z = 1.0 })
		if not(petz.isinliquid(self)) then
			self.object:set_acceleration({ x = 0.0, y = 0.0, z = 0.0 })
			return true
		end
	end
	mobkit.queue_high(self, func, prty)
end

--
-- Alight Behaviour ( 2 funtions: HQ & LQ)
--

function mobkit.hq_alight(self, prty)
	local func = function(self)
		local node_name = mobkit.node_name_in(self, "below")
		if node_name == "air" then
			mobkit.lq_alight(self)
		elseif minetest.get_item_group(node_name, "water") >= 1  then
			mobkit.hq_wanderfly(self, 0)
			return true
		else
			--minetest.chat_send_player("singleplayer", "on ground")
			mobkit.animate(self, "stand")
			mobkit.lq_idle(self, 2400)
			self.status = "stand"
			return true
		end
	end
	mobkit.queue_high(self, func, prty)
end

function mobkit.lq_alight(self)
	local func=function(self)
		--minetest.chat_send_player("singleplayer", "alight")
		self.object:set_acceleration({ x = 0, y = -1, z = 0 })
		return true
	end
	mobkit.queue_low(self, func)
end

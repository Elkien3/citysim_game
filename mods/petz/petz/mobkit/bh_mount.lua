local modpath, S = ...

---
--- DRIVER MOUNT
---

--
-- Helper functions
--

petz.fallback_node = minetest.registered_aliases["mapgen_dirt"] or "default:dirt"

local node_ok = function(pos, fallback)
	fallback = fallback or petz.fallback_node
	local node = minetest.get_node_or_nil(pos)
	if node and minetest.registered_nodes[node.name] then
		return node
	end
	return {name = fallback}
end

local function node_is(pos)
	local node = node_ok(pos)
	if node.name == "air" then
		return "air"
	end
	if minetest.get_item_group(node.name, "lava") ~= 0 then
		return "lava"
	end
	if minetest.get_item_group(node.name, "liquid") ~= 0 then
		return "liquid"
	end
	if minetest.registered_nodes[node.name].walkable == true then
		return "walkable"
	end
	return "other"
end

local function get_sign(i)
	i = i or 0
	if i == 0 then
		return 0
	else
		return i / math.abs(i)
	end
end

local function get_velocity(v, yaw, y)
	local x = -math.sin(yaw) * v
	local z =  math.cos(yaw) * v
	return {x = x, y = y, z = z}
end

local function get_v(v)
	return math.sqrt(v.x * v.x + v.z * v.z)
end

function mobkit.hq_mountdriver(self, prty)
	local func=function(self)
		if not(self.driver) then
			return true
		else
			if mobkit.is_queue_empty_low(self) then
				mobkit.lq_mountdriver(self)
			end
		end
	end
	mobkit.queue_high(self,func,prty)
end

function mobkit.lq_mountdriver(self)
	local auto_drive = false
	local func = function(self)
		if not(self.driver) then return true end
		local rot_steer, rot_view = math.pi/2, 0
		if self.player_rotation.y == 90 then
			rot_steer, rot_view = 0, math.pi/2
		end
		local acce_y = 0
		local velo
		if velo == nil then
			velo= {
				x= self.max_speed_forward/3,
				y= 0,
				z= self.max_speed_forward/3,
			}
		end
		local velocity = get_v(velo)
		--minetest.chat_send_player("singleplayer", tostring(velocity))
		-- process controls
		local ctrl = self.driver:get_player_control()
		if ctrl.up and ctrl.aux1 then
			auto_drive = true
		elseif auto_drive and ctrl.sneak then
			auto_drive = false
		end
		if (ctrl.up or auto_drive) and self.isonground then -- move forwards
			velocity = velocity + (self.accel/2)
			if ctrl.jump then
				velo.y = velo.y + (self.jump_height)*4
				acce_y = acce_y *1.5
			end
		elseif ctrl.down and self.isonground then -- move backwards
			if self.max_speed_reverse == 0 and velocity == 0 then
				return
			end
			velocity = velocity - (self.accel/4)
			if velocity > 0 then
				velocity = - velocity
			end
		elseif ctrl.jump and self.isonground then -- jump
			velo.y = velo.y + (self.jump_height)*4
			acce_y = acce_y *1.5
		else --stand
			velocity = 0
			mobkit.animate(self, "stand")
			return
		end
		--Gallop
		if ctrl.up and ctrl.sneak and not(self.gallop_exhausted) then
			if self.gallop == false then
				self.gallop = true
				mokapi.make_sound("object", self.object, "petz_horse_whinny", petz.settings.max_hear_distance)
				mokapi.make_sound("object", self.object, "petz_horse_gallop", petz.settings.max_hear_distance)
			end
			velocity = velocity + self.accel
		end
		--minetest.chat_send_player("singleplayer", tostring(velocity))
		-- fix mob rotation
		local horz = self.driver:get_look_horizontal() or 0
		self.object:set_yaw(horz - self.rotate)
		-- enforce speed limit forward and reverse
		local max_spd = self.max_speed_reverse

		if get_sign(velocity) >= 0 then
			max_spd = self.max_speed_forward
		end
		if math.abs(velocity) > max_spd then
			velocity = velocity - get_sign(velocity)
		end
		-- Set position, velocity and acceleration
		local new_velo = get_velocity(velocity, self.object:get_yaw() - rot_view, velo.y)
		local new_acce = {x = 0, y = mobkit.gravity, z = 0}
		self.object:set_velocity(new_velo)
		if not(self.gallop) then
			mobkit.animate(self, "walk")	-- set animation
		else
			mobkit.animate(self, "run")
		end
		new_acce.y = new_acce.y + acce_y
		--minetest.chat_send_player("singleplayer", tostring(new_acce.y))
		self.object:set_acceleration(new_acce)
		return
	end
	mobkit.queue_low(self, func)
end

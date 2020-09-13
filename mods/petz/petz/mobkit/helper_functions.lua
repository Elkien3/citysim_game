local modpath, S = ...

--
-- Helpers Functions
--

petz.lookback = function(self, pos2)
	local pos1 = self.object:get_pos()
	local vec = {x = pos1.x - pos2.x, y = pos1.y - pos2.y, z = pos1.z - pos2.z}
	local yaw = math.atan(vec.z / vec.x) - math.pi / 2
	if pos1.x >= pos2.x then
		yaw = yaw + math.pi
	end
   self.object:set_yaw(yaw + math.pi)
end

petz.lookat = function(self, pos2)
	local pos1 = self.object:get_pos()
	local vec = {x = pos1.x - pos2.x, y = pos1.y - pos2.y, z = pos1.z - pos2.z}
	local yaw = math.atan(vec.z / vec.x) - math.pi / 2
	if pos1.x >= pos2.x then
		yaw = yaw + math.pi
	end
   self.object:set_yaw(yaw + math.pi)
end

function petz.bh_check_pack(self)
	if mobkit.get_closest_entity(self, "petz:"..self.type) then
		return true
	else
		return false
	end
end

function petz.get_player_back_pos(player, pos)
	local yaw = player:get_look_horizontal()
	if yaw then
		local dir_x = -math.sin(yaw)
		local dir_z = math.cos(yaw)
		local back_pos = {
			x = pos.x - dir_x,
			y = pos.y,
			z = pos.z - dir_z,
		}
		local node = minetest.get_node_or_nil(back_pos)
		if node and minetest.registered_nodes[node.name] then
			return node.name, back_pos
		else
			return nil, nil
		end
	else
		return nil, nil
	end
end


function mobkit.check_height(self)
	local yaw = self.object:get_yaw()
	local dir_x = -math.sin(yaw) * (self.collisionbox[4] + 0.5)
	local dir_z = math.cos(yaw) * (self.collisionbox[4] + 0.5)
	local pos = self.object:get_pos()
	local ypos = pos.y - self.collisionbox[2] -- just floor level
	local pos1 = {x = pos.x + dir_x, y = ypos, z = pos.z + dir_z}
	local pos2 = {x = pos.x + dir_x, y = ypos - self.max_height, z = pos.z + dir_z}
	local blocking_node, blocking_node_pos = minetest.line_of_sight(pos1, pos2, 1)
	if not(blocking_node) then
		local height = ypos - blocking_node_pos.y
		return height
	end
	return false
end

function mobkit.check_front_obstacle(self)
	local yaw = self.object:get_yaw()
	local dir_x = -math.sin(yaw) * (self.collisionbox[4] + 0.5)
	local dir_z = math.cos(yaw) * (self.collisionbox[4] + 0.5)
	local pos = self.object:get_pos()
	local nodes_front = 5
	if minetest.line_of_sight(
		{x = pos.x + dir_x, y = pos.y, z = pos.z + dir_z}, {x = pos.x + dir_x + nodes_front, y = pos.y, z = pos.z + dir_z + nodes_front}, 1) then
		return false
	end
	return true
end

function mobkit.check_is_on_surface(self)
	local pos = self.object:get_pos()
	if pos.y > 0 then
		return true
	else
		return false
	end
end

function petz.is_standing(self)
	local velocity = self.object:get_velocity()
	local speed = vector.length(velocity)
	if speed == 0 then
		return true
	else
		return false
	end
end

function petz.is_jumping(self)
	if self.isonground == true then
		return false
	else
		return true
	end
end


function mobkit.check_ground_suffocation(self)
	local spos = mobkit.get_stand_pos(self)
	spos.y = spos.y + 0.01
	if self.type and mobkit.is_alive(self) and not(self.is_baby) then
		local stand_pos = spos
		stand_pos.y = spos.y + 0.5
		local stand_node_pos = mobkit.get_node_pos(stand_pos)
		local stand_node = mobkit.nodeatpos(stand_node_pos)
		if stand_node and stand_node.walkable and stand_node.drawtype == "normal" then
			local new_y = stand_pos.y + self.jump_height
			if new_y <= 30927 then
				self.object:set_pos({
					x = stand_pos.x,
					y = new_y,
					z = stand_pos.z
				})
			end
		end
	end
end

function petz.set_velocity(self, velocity)
	local yaw = self.object:get_yaw() or 0
	self.object:set_velocity({
		x = (math.sin(yaw) * -velocity.x),
		y = velocity.y or 0,
		z = (math.cos(yaw) * velocity.z),
	})
end

function mobkit.node_name_in(self, where)
	local pos = self.object:get_pos()
	local yaw = self.object:get_yaw()
	if yaw then
		local dir_x = -math.sin(yaw)
		local dir_z = math.cos(yaw)
		local pos2
		if where == "front" then
			pos2 = {
				x = pos.x + dir_x,
				y = pos.y,
				z = pos.z + dir_z,
			}
		elseif where == "top" then
			pos2= {
				x = pos.x,
				y = pos.y + 0.5,
				z = pos.z,
			}
		elseif where == "below" then
			pos2 = mobkit.get_stand_pos(self)
			pos2.y = pos2.y - 0.1
		elseif where == "back" then
			pos2 = {
				x = pos.x - dir_x,
				y = pos.y,
				z = pos.z - dir_z,
			}
		elseif where == "self" then
			pos2= {
				x = pos.x,
				y = pos.y - 0.75,
				z = pos.z,
			}
		elseif where == "front_top" then
			pos2= {
				x = pos.x + dir_x,
				y = pos.y + 1,
				z = pos.z + dir_z,
			}
		end
		local node = minetest.get_node_or_nil(pos2)
		if node and minetest.registered_nodes[node.name] then
			return node.name, pos2
		else
			return nil
		end
	else
		return nil
	end
end

petz.pos_front = function(self, pos)
	local yaw = self.object:get_yaw()
	local dir_x = -math.sin(yaw) * (self.collisionbox[4] + 0.5)
	local dir_z = math.cos(yaw) * (self.collisionbox[4] + 0.5)
	local pos_front = {	-- what is in front of mob?
		x = pos.x + dir_x,
		y = pos.y - 0.75,
		z = pos.z + dir_z
	}
	return pos_front
end

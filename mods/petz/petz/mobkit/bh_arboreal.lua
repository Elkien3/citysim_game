local modpath, S = ...

--
-- ARBOREAL BRAIN
--

function petz.check_tree(self)
	local node_front_name = mobkit.node_name_in(self, "front")
	--minetest.chat_send_player("singleplayer", node_front_name)
	local node_top_name= mobkit.node_name_in(self, "top")
	--minetest.chat_send_player("singleplayer", node_top_name)
	if node_front_name and minetest.registered_nodes[node_front_name]
		and petz.is_tree_like(node_front_name)
		and node_top_name and minetest.registered_nodes[node_top_name]
		and node_top_name == "air" then
			return true
	else
		return false
	end
end

function petz.is_tree_like(node)
	if minetest.registered_nodes[node].groups.wood
			or minetest.registered_nodes[node].groups.leaves
				or minetest.registered_nodes[node].groups.tree then
					return true
	else
		return false
	end
end

function petz.bh_climb(self, pos, prty)
	if petz.check_tree(self) then
		mobkit.hq_climb(self, prty)
		mobkit.animate(self, 'climb')
		return true
	else --search for a tree
		if mobkit.timer(self, 10) then
			local view_range = self.view_range
			local nearby_wood = minetest.find_nodes_in_area(
				{x = pos.x - view_range, y = pos.y - view_range, z = pos.z - view_range},
				{x = pos.x + view_range, y = pos.y + view_range, z = pos.z + view_range},
				{"group:wood"})
			if #nearby_wood >= 1 then
				local tpos = nearby_wood[1] --the first match
				mobkit.hq_goto(self, prty, tpos)
				return true
			end
		end
	end
	return false
end

function mobkit.hq_climb(self, prty)
	local func=function(self)
		if not petz.check_tree(self) then
			self.status = nil
			mobkit.clear_queue_high(self)
			mobkit.clear_queue_low(self)
			return true
		end
		if mobkit.is_queue_empty_low(self) then
			self.status = "climb"
			mobkit.lq_climb(self)
		end
	end
	mobkit.queue_high(self,func,prty)
end

function mobkit.lq_climb(self)
	local func = function(self)
		local pos = self.object:get_pos()
		pos.y = pos.y + 1
		local node_top = minetest.get_node_or_nil(pos)
		if not(node_top) then
			return true
		end
		local node_top_name= node_top.name
		local node_front_top_name, front_top_pos = mobkit.node_name_in(self, "front_top")
		--minetest.chat_send_all(node_top_name)
		if node_top_name and minetest.registered_nodes[node_top_name]
			and (petz.is_tree_like(node_top_name)) then
				local climb = false
				local climb_pos
				for i =1, 8 do
					pos.y = pos.y + 1.1
					local node = minetest.get_node_or_nil(pos)
					if not node then
						climb = false
						break
					end
					if node.name == "air" then
						climb = true
						pos.y = pos.y + 0.5
						climb_pos = pos
						break
					elseif not(petz.is_tree_like(node.name)) then
						climb = false
						break
					end
				end
				if climb then
					self.object:set_pos(climb_pos)
					self.status = nil
				end
				mobkit.clear_queue_high(self)
				mobkit.clear_queue_low(self)
		elseif node_front_top_name == "air" then
			self.object:set_pos(front_top_pos)
		end
		self.object:set_velocity({x = 0, y = 1.0, z = 0 })
		return true
	end
	mobkit.queue_low(self, func)
end

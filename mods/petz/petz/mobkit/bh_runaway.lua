local modpath, S = ...

--
-- Runaway from predator behaviour
--

function petz.bh_runaway_from_predator(self, pos)
	local predator_list = petz.settings[self.type.."_predators"]
	if predator_list then
		predator_list = petz.str_remove_spaces(predator_list)
		local predators = string.split(predator_list, ',')
		for i = 1, #predators do --loop  thru all preys
			--minetest.chat_send_player("singleplayer", "spawn node="..spawn_nodes[i])
			--minetest.chat_send_player("singleplayer", "node name="..node.name)
			local predator = mobkit.get_closest_entity(self, predators[i])	-- look for predator
			if predator then
				local predator_pos = predator:get_pos()
				if predator and vector.distance(pos, predator_pos) <= self.view_range then
					mobkit.hq_runfrom(self, 18, predator)
					return true
				else
					return false
				end
			end
		end
	end
end

petz.bh_afraid= function(self, pos)
	petz.lookback(self, pos)
	local x = self.object:get_velocity().x
	local z = self.object:get_velocity().z
	self.object:set_velocity({x= x, y= 0, z= z})
	--self.object:set_acceleration({x= hvel.x, y= 0, z= hvel.z})
end

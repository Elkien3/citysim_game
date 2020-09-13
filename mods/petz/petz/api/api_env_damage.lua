local modpath, S = ...

--
-- Enviromental Damage
--

function petz.env_damage(self, pos, prty)
	local stand_pos= mobkit.get_stand_pos(self)
	local stand_node_pos = mobkit.get_node_pos(stand_pos)
	local stand_node = mobkit.nodeatpos(stand_node_pos)
	if stand_node and stand_node.groups.igniter then --if lava or fire
		mobkit.hurt(self, petz.settings.igniter_damage)
		local air_pos = minetest.find_node_near(stand_pos, self.view_range, "air", false)
		if air_pos then
			mobkit.hq_goto(self, prty, air_pos)
		end
	end
	if self.noxious_nodes then
		for i = 1, #self.noxious_nodes do
			local noxious_node = self.noxious_nodes[i]
			local node_pos
			if noxious_node.where then
				if noxious_node.where == "stand" then
					node_pos = stand_pos
				elseif noxious_node.where == "entity" then
					node_pos = pos
				else
					node_pos = pos
				end
			else
				node_pos = pos
			end
			local node = minetest.get_node_or_nil(node_pos)
			if node and node.name == noxious_node.name then
				mobkit.hurt(self, noxious_node.damage or 1)
			end
		end
	end
end

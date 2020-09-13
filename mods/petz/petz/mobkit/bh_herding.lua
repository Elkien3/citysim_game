local modpath, S = ...

--
-- Herding Behaviour
--

function petz.bh_herding(self, pos, player)
	if not(self.tamed) or not(self.herd) or not(self.herding) then
		return false
	end
	local join_herd = false
	local tpos
	local ent_obj = mobkit.get_closest_entity(self, "petz:"..self.type) -- look for a herd to join with
	if ent_obj then
		local ent = ent_obj:get_luaentity()
		if ent and ent.herding then
			tpos = ent_obj:get_pos()
			local distance = vector.distance(pos, tpos)
			if distance > petz.settings.herding_members_distance then
				join_herd = true
			end
		end
	end
	if not join_herd and player then -- search for a shepherd
		local player_name = player:get_player_name()
		if self.owner == player_name  then
			local wielded_item = player:get_wielded_item()
			local wielded_item_name = wielded_item:get_name()
			if wielded_item_name == "petz:shepherd_crook" then
				tpos = player:get_pos()
				if vector.distance(pos, tpos) > petz.settings.herding_shepherd_distance then -- if player close
					join_herd = true
				end
			end
		end
	end
	if join_herd and tpos then
		mobkit.hq_goto(self, 4.5, tpos)
		return true
	else
		return false
	end
end

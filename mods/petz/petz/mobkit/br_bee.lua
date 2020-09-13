local modpath, S = ...

--
-- BEE BRAIN
--

function petz.bee_brain(self)

	local pos = self.object:get_pos() --pos of the petz

	mobkit.vitals(self)

	self.object:set_acceleration({x=0, y=0, z=0})

	local behive_exists = petz.behive_exists(self)
	local meta, honey_count, bee_count
	if behive_exists then
		meta, honey_count, bee_count = petz.get_behive_stats(self.behive)
	end

	if (self.hp <= 0) or (not(self.queen) and not(petz.behive_exists(self))) then
		if behive_exists then --decrease the total bee count
			petz.decrease_total_bee_count(self.behive)
			petz.set_infotext_behive(meta, honey_count, bee_count)
		end
		petz.on_die(self) -- Die Behaviour
		return
	elseif (petz.is_night() and not(self.queen)) then --all the bees sleep in their beehive
		if behive_exists then
			bee_count = bee_count + 1
			meta:set_int("bee_count", bee_count)
			if self.pollen == true and (honey_count < petz.settings.max_honey_behive) then
				honey_count = honey_count + 1
				meta:set_int("honey_count", honey_count)
			end
			petz.set_infotext_behive(meta, honey_count, bee_count)
			mokapi.remove_mob(self)
			return
		end
	end

	mobkit.check_ground_suffocation(self, pos)

	if mobkit.timer(self, 1) then

		local prty = mobkit.get_queue_priority(self)

		if prty < 40 and self.isinliquid then
			mobkit.hq_liquid_recovery(self, 40)
			return
		end

		local player = mobkit.get_nearby_player(self)

		if prty < 30 then
			petz.env_damage(self, pos, 30) --enviromental damage: lava, fire...
		end

		--search for flowers
		if prty < 20 and behive_exists then
			if not(self.queen) and not(self.pollen) and (honey_count < petz.settings.max_honey_behive) then
				local view_range = self.view_range
				local nearby_flowers = minetest.find_nodes_in_area(
					{x = pos.x - view_range, y = pos.y - view_range, z = pos.z - view_range},
					{x = pos.x + view_range, y = pos.y + view_range, z = pos.z + view_range},
					{"group:flower"})
				if #nearby_flowers >= 1 then
					local tpos = 	nearby_flowers[1] --the first match
					mobkit.hq_gotopollen(self, 20, tpos)
					return
				end
			end
		end

		--search for the bee behive when pollen
		if prty < 18 and behive_exists then
			if not(self.queen) and self.pollen == true and (honey_count < petz.settings.max_honey_behive) then
				if vector.distance(pos, self.behive) <= self.view_range then
					mobkit.hq_gotobehive(self, 18, pos)
					return
				end
			end
		end

		--stay close behive
		if prty < 15 and behive_exists then
			if not(self.queen) then
			--minetest.chat_send_player("singleplayer", "testx")
				if math.abs(pos.x - self.behive.x) > self.view_range and math.abs(pos.z - self.behive.z) > self.view_range then
					mobkit.hq_approach_behive(self, pos, 15)
					return
				end
			end
		end

		if prty < 13 and self.queen == true then --if queen try to create a colony (beehive)
			if petz.bh_create_beehive(self, pos) then
				return
			end
		end

		if prty < 10 then
			if player then
				if petz.bh_attack_player(self, pos, 10, player) == true then
					return
				end
			end
		end

		-- Default Random Sound
		mokapi.make_misc_sound(self, petz.settings.misc_sound_chance, petz.settings.max_hear_distance)

		--Roam default
		if mobkit.is_queue_empty_high(self) and not(self.status) then
			mobkit.hq_wanderfly(self, 0)
		end

	end
end

local modpath, S = ...

--
-- AQUATIC BRAIN
--

function petz.aquatic_brain(self)

	local pos = self.object:get_pos()

	mobkit.vitals(self)

	-- Die Behaviour

	if self.hp <= 0 then
		petz.on_die(self)
		return
	elseif not(petz.is_night()) and self.die_at_daylight == true then --it dies when sun rises up
		if minetest.get_node_light(pos, minetest.get_timeofday()) >= self.max_daylight_level then
			petz.on_die(self)
			return
		end
	end

	if not(self.is_mammal) and not(petz.isinliquid(self)) then --if not mammal, air suffocation
		mobkit.hurt(self, petz.settings.air_damage)
	end

	mobkit.check_ground_suffocation(self, pos)

	if mobkit.timer(self, 1) then

		local prty = mobkit.get_queue_priority(self)
		local player = mobkit.get_nearby_player(self)

		--Follow Behaviour
		if prty < 16 then
			if petz.bh_start_follow(self, pos, player, 16) == true then
				return
			end
		end

		if prty == 16 then
			if petz.bh_stop_follow(self, player) == true then
				return
			end
		end

		if prty < 10 then
			if player and (self.attack_player == true) then
				if petz.bh_attack_player(self, pos, 10, player) == true then
					return
				end
			end
		end

		if prty < 8 then
			if (self.can_jump) and not(self.status== "jump") and (mobkit.is_in_deep(self)) then
				local random_number = math.random(1, 25)
				if random_number == 1 then
					--minetest.chat_send_player("singleplayer", "jump")
					mobkit.clear_queue_high(self)
					mobkit.hq_aqua_jump(self, 8)
				end
			end
		end

		-- Default Random Sound
		mokapi.make_misc_sound(self, petz.settings.misc_sound_chance, petz.settings.max_hear_distance)

		--Roam default
		if mobkit.is_queue_empty_high(self) and not(self.status) and not(self.status== "jump") then
			mobkit.hq_aqua_roam(self, 0, self.max_speed)
		end
	end
end

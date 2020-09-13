local modpath, S = ...

--
-- SEMIAQUATIC BRAIN
--

function petz.semiaquatic_brain(self)

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

	if not(petz.isinliquid(self)) then
		mobkit.check_ground_suffocation(self, pos)
	end

	if mobkit.timer(self, 1) then

		local prty = mobkit.get_queue_priority(self)
		local player = mobkit.get_nearby_player(self)

		--if prty < 100 then
			--if petz.isinliquid(self) then
				--mobkit.hq_liquid_recovery(self, 100)
			--end
		--end

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
			if player then
				if (self.tamed == false) or (self.tamed == true and self.status == "guard" and player:get_player_name() ~= self.owner) then
					local player_pos = player:get_pos()
					if vector.distance(pos, player_pos) <= self.view_range then	-- if player close
						if self.warn_attack == true then --attack player
							mobkit.clear_queue_high(self)							-- abandon whatever they've been doing
							if petz.isinliquid(self) then
								mobkit.hq_aqua_attack(self, 10, player, 6)				-- get revenge
							else
								petz.hq_hunt(self, 10, player)
							end
						end
					end
				end
			end
		end

		if prty < 6 then
			petz.bh_replace(self)
		end

		-- Default Random Sound
		mokapi.make_misc_sound(self, petz.settings.misc_sound_chance, petz.settings.max_hear_distance)

		if self.petz_type == "beaver" then --beaver's dam
			petz.create_dam(self, pos)
		end

		--Roam default
		if mobkit.is_queue_empty_high(self) and not(self.status) then
			if petz.isinliquid(self) then
				mobkit.hq_aqua_roam(self, 0, self.max_speed)
			else
				mobkit.hq_roam(self, 0)
			end
		end
	end
end

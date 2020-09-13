local modpath, S = ...

--
-- 1. HERBIBORE/FLYING MOBS BRAIN
--

function petz.herbivore_brain(self)

	local pos = self.object:get_pos()

	local die = false

	mobkit.vitals(self)

	if self.hp <= 0 then
		die = true
	elseif not(petz.is_night()) and self.die_at_daylight == true then --it dies when sun rises up
		if pos then
			local node_light = minetest.get_node_light(pos, minetest.get_timeofday())
			if node_light and self.max_daylight_level then
				if node_light >= self.max_daylight_level then
					die = true
				end
			end
		end
	end

	if die == true then
		petz.on_die(self)
		return
	end

	if self.can_fly or self.status == "climb" then
		self.object:set_acceleration({x=0, y=0, z=0})
	end

	mobkit.check_ground_suffocation(self, pos)

	if mobkit.timer(self, 1) then

		local prty = mobkit.get_queue_priority(self)

		if prty < 30 then
			petz.env_damage(self, pos, 30) --enviromental damage: lava, fire...
		end

		if prty < 25 then
			if self.driver then
				mobkit.hq_mountdriver(self, 25)
				return
			end
		end

		if prty < 20 then
			if self.isinliquid then
				if not self.can_fly then
					mobkit.hq_liquid_recovery(self, 20)
				else
					mobkit.hq_liquid_recovery_flying(self, 20)
				end
				return
			end
		end

		local player = mobkit.get_nearby_player(self)

		--if player then petz.move_head(self, player:get_pos()) end

		--Runaway from predator
		if prty < 18  then
			if petz.bh_runaway_from_predator(self, pos) == true then
				return
			end
		end

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

		--Runaway from Player
		if prty < 14 then
			if not(self.can_fly) and self.tamed == false then --if no tamed
				if player then
					local player_pos = player:get_pos()
					local wielded_item_name = player:get_wielded_item():get_name()
					if self.is_pet == false and self.follow ~= wielded_item_name and vector.distance(pos, player_pos) <= self.view_range then
						mobkit.hq_runfrom(self, 14, player)
						return
					end
				end
			end
		end

		--if prty < 7 and self.type == "moth" and mobkit.is_queue_empty_high(self) then --search for a squareball
			--local pos_torch_near = minetest.find_node_near(pos, self.view_range, "default:torch")
			--if pos_torch_near then
				--mobkit.hq_approach_torch(self, 7, pos_torch_near)
				--return
			--end
		--end

		--Replace nodes by others
		if prty < 7 then
			petz.poop(self, pos)
		end

		--Replace nodes by others
		if prty < 6 then
			petz.bh_replace(self)
		end

		if prty < 5 then
			petz.bh_breed(self, pos)
		end

		--Herding
		if prty < 4.5 and petz.settings.herding then
			if mobkit.timer(self, petz.settings.herding_timing) then
				if petz.bh_herding(self, pos, player) then
					return
				end
			end
		end
		--search for a petz:pet_bowl or a bale
		if prty < 4 and self.tamed == true then
			local view_range = self.view_range
			local nearby_nodes = minetest.find_nodes_in_area(
				{x = pos.x - view_range, y = pos.y - 1, z = pos.z - view_range},
				{x = pos.x + view_range, y = pos.y + 1, z = pos.z + view_range},
				{"group:feeder"})
			if #nearby_nodes >= 1 then
				local tpos = nearby_nodes[1] --the first match
				local distance = vector.distance(pos, tpos)
				if distance > 3.0 then
					mobkit.hq_goto(self, 4, tpos)
				elseif distance <= 3.0 then
					if (petz.settings.tamagochi_mode == true) and not(self.fed) then
						petz.do_feed(self)
						if self.eat_hay then
							local node = minetest.get_node_or_nil(tpos)
							if node and node.name == "bale:bale" then
								minetest.remove_node(tpos)
								mokapi.make_sound("pos", tpos, "petz_replace", 5 or mokapi.consts.DEFAULT_MAX_HEAR_DISTANCE)
							end
						end
					end
				end
			end
		end

		--if prty < 5 and self.type == "puppy" and self.tamed == true and self.square_ball_attached == false then --search for a squareball
			--local object_list = minetest.get_objects_inside_radius(self.object:get_pos(), 10)
			--for i = 1,#object_list do
				--local obj = object_list[i]
				--local ent = obj:get_luaentity()
				--if ent and ent.name == "__builtin:item" then
					--minetest.chat_send_player("singleplayer", ent.itemstring)
						--local spos = self.object:get_pos()
						--local tpos = obj:get_pos()
						--if vector.distance(spos, tpos) > 2 then
							--if tpos then
								--mobkit.hq_goto(self, 5, tpos)
							--end
						--else
							--local meta = ent:get_meta()
							--local shooter_name = meta:get_string("shooter_name")
							--petz.attach_squareball(ent, self, self.object, nil)
						--end
					--end
				--end
			--end
		--end

		-- Default Random Sound
		mokapi.make_misc_sound(self, petz.settings.misc_sound_chance, petz.settings.max_hear_distance)

		if prty < 3 then
			if self.is_arboreal == true then
				if petz.bh_climb(self, pos, 3) then
					return
				end
			end
		end

		if prty < 2 then	--Sleep Behaviour
			petz.bh_sleep(self, 2)
		end

		--Look_at Behaviour
		if prty < 1 and player then
			if petz.bh_look_at(self, player:get_pos(), 1) then
				return
			end
		end

		--Roam default
		if mobkit.is_queue_empty_high(self) and not(self.status) then
			if not(self.can_fly) then
				mobkit.hq_roam(self, 0)
			else
				mobkit.hq_wanderfly(self, 0)
			end
		end

	end
end

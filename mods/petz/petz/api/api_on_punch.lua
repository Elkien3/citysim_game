local modpath, S = ...

petz.puncher_is_player = function(puncher)
	if type(puncher) == 'userdata' and puncher:is_player() then
		return true
	else
		return false
	end
end

petz.calculate_damage = function(self, time_from_last_punch, tool_capabilities)
	local tool_damage = tool_capabilities.damage_groups.fleshy or 1
	--minetest.chat_send_all(tostring("damage= "..tool_damage))
	local time_bonus = (1 / time_from_last_punch)
	if time_bonus > 1 then -- the second punch in less than 1 second
		time_bonus= petz.round(time_bonus^0.33) --cubic root
	else
		time_bonus = 0
	end
	--minetest.chat_send_all(tostring(time_bonus))
	local health_bonus = petz.round((self.max_hp / self.hp)^0.33)
	--minetest.chat_send_all(tostring(health_bonus))
	local luck_bonus = math.random(-1, 1)
	--minetest.chat_send_all(tostring(luck_bonus))
	local damage = tool_damage + time_bonus + health_bonus + luck_bonus
	--minetest.chat_send_all(tostring(damage))
	return damage
end

petz.kick_back= function(self, dir)
	local hvel = vector.multiply(vector.normalize({x=dir.x, y=0, z=dir.z}), 4)
	self.object:set_velocity({x=hvel.x, y=2, z=hvel.z})
end

petz.punch_tamagochi = function (self, puncher)
	if self.affinity == nil then
		return
    end
    if petz.settings.tamagochi_mode == true then
        if self.owner == puncher:get_player_name() then
            petz.set_affinity(self, -petz.settings.tamagochi_punch_rate)
        end
    end
end

--
--on_punch event for all the Mobs
--

function petz.on_punch(self, puncher, time_from_last_punch, tool_capabilities, dir)
	local pos = self.object:get_pos() --pos of the petz
	if not mobkit.is_alive(self) then --is petz alive
		return
	end
	--Do not punch when you are mounted on it!!!-->
	if self.is_mountable and puncher == self.driver then
		return
	end
	--Check Dreamcatcher Protection
	local puncher_is_player = petz.puncher_is_player(puncher)
	if puncher_is_player then --player
		if self.dreamcatcher and self.owner ~= puncher:get_player_name() then --The dreamcatcher protects the petz
			return
		end
	else --no player
		if self.dreamcatcher then
			return
		end
	end
	--Colorize Punch Effect-->
	if petz.settings.colorize_punch then
		local punch_texture = self.textures[self.texture_no].."^[colorize:"..petz.settings.punch_color..":125"
		self.object:set_properties(self, {textures = {punch_texture}})
		minetest.after(0.1, function()
			if self then
				self.object:set_properties(self, {textures = { self.textures[self.texture_no]}})
			end
		end)
	end
	--Do Hurt-->
	local damage = petz.calculate_damage(self, time_from_last_punch, tool_capabilities)
	mobkit.hurt(self, damage)
	--Tamagochi Mode?-->
	petz.punch_tamagochi(self, puncher) --decrease affinity when in Tamagochi mode
	--Check if killed by player and save it-->
	self.was_killed_by_player = petz.was_killed_by_player(self, puncher)
	--Update Nametag-->
	petz.update_nametag(self)
	--Kickback-->
	petz.kick_back(self, dir)
	--Sound-->
	mokapi.make_sound("object", self.object, "petz_default_punch", petz.settings.max_hear_distance)
	--Blood-->
	petz.blood(self)
	--Unmount?-->
	if self.is_mountable and self.hp <= 0 and self.driver then --important for mountable petz!
		petz.force_detach(self.driver)
	end
	--Lashing?-->
	if self.is_wild == true then
		petz.tame_whip(self, puncher)
	end
	--Warn Attack?-->
	if self.is_wild and not(self.tamed) and not(self.attack_player) then --if you hit it, will attack player
		self.warn_attack = true
		mobkit.clear_queue_high(self)
	end
	--Monster Specific-->
	if self.type == "mr_pumpkin" then --teleport to player's back
		if math.random(1, 3) == 1 then
			--petz.lookat(self, puncher:get_pos())
			if (self.hp <= self.max_hp / 2) then
				petz.bh_teleport(self, pos, puncher, puncher:get_pos())
			else
				mokapi.make_sound("object", self.object, "petz_fireball", petz.settings.max_hear_distance)
				petz.spawn_throw_object(self.object, 20, "petz:ent_jack_o_lantern_grenade")
			end
		end
	elseif self.type == "tarantula" then
		if math.random(1, 5) == 1 then
			--petz.lookat(self, puncher:get_pos())
			petz.spawn_throw_object(self.object, 20, "petz:ent_cobweb")
		end
	end
end

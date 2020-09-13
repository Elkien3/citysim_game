--
--Sound System
--

function mokapi.make_misc_sound(self, chance, max_hear_distance)
	if self.muted == true then
		return
	end
	local random_number = math.random(1, chance)
	if random_number == 1 then
		if self.sounds and self.sounds['misc'] then
			local misc_sound
			if (type(self.sounds['misc']) == "table") then
				misc_sound = self.sounds['misc'][math.random(1, #self.sounds['misc'])]
			else
				misc_sound = self.sounds['misc']
			end
			mokapi.make_sound("object", self.object, misc_sound, max_hear_distance or mokapi.consts.DEFAULT_MAX_HEAR_DISTANCE)
		end
	end
end

function mokapi.make_sound(dest_type, dest, soundfile, max_hear_distance)
	if dest_type == "object" then
		minetest.sound_play(soundfile, {object = dest, gain = 0.5, max_hear_distance = max_hear_distance or mokapi.consts.DEFAULT_MAX_HEAR_DISTANCE,})
	 elseif dest_type == "player" then
		local player_name = dest:get_player_name()
		--minetest.chat_send_player("singleplayer", player_name..tostring(max_hear_distance))
		minetest.sound_play(soundfile, {to_player = player_name, gain = 0.5, max_hear_distance = max_hear_distance or mokapi.consts.DEFAULT_MAX_HEAR_DISTANCE,})
	 elseif dest_type == "pos" then
		minetest.sound_play(soundfile, {pos = dest, gain = 0.5, max_hear_distance = max_hear_distance or mokapi.consts.DEFAULT_MAX_HEAR_DISTANCE,})
	end
end

local modpath, S = ...

petz.calculate_sleep_times = function(self)
	if not petz.settings.sleeping then
		return
	end
	if (self.sleep_at_night or self.sleep_at_day) then
		local sleep_time
		local sleep_start_time
		local sleep_end_time
		local sleep_end_time_limit
		if self.sleep_at_night then
			local night_start = 19500
			local night_duration = 9000
			sleep_time = night_duration * (self.sleep_ratio or 1)
			sleep_end_time_limit = 23999 + 4500
			sleep_start_time = math.random(night_start, sleep_end_time_limit - sleep_time)
			sleep_end_time = sleep_start_time + sleep_time
			if sleep_start_time > 23999 then
				sleep_start_time = sleep_end_time_limit - sleep_start_time
			end
			if sleep_end_time > 23999 then
				sleep_end_time = sleep_end_time - 23999
			end
		else
			local day_start = 4500
			local day_duration = 15000
			sleep_time = day_duration * (self.sleep_ratio or 1)
			sleep_end_time_limit = 19500
			sleep_start_time = math.random(day_start, sleep_end_time_limit - sleep_time)
			sleep_end_time = sleep_start_time + sleep_time
		end
		self.sleep_start_time = mobkit.remember(self, "sleep_start_time", sleep_start_time)
		self.sleep_end_time = mobkit.remember(self, "sleep_end_time", sleep_end_time)
		--minetest.chat_send_player("singleplayer", "sleep_time="..tostring(sleep_time).."/sleep_start_time="..tostring(sleep_start_time).."/sleep_end_time="..tostring(sleep_end_time))
	end
end

petz.bh_sleep = function(self, prty)
	if(not petz.settings.sleeping) or petz.isinliquid(self) then
		return
	end
	--minetest.chat_send_player("singleplayer", "ana")
	if (self.sleep_at_night and petz.is_night()) or (self.sleep_at_day and not(petz.is_night())) then
		--minetest.chat_send_player("singleplayer", "lucas")
		local timeofday = minetest.get_timeofday() * 24000
		--minetest.chat_send_player("singleplayer", tostring(timeofday))
		local sleep_start_time = self.sleep_start_time
		local sleep_end_time = self.sleep_end_time
		if self.sleep_at_night then
			if timeofday > 19500 then
				sleep_end_time = 23999
			elseif timeofday < 4500 then
				sleep_start_time = 0
			end
		end
		--minetest.chat_send_player("singleplayer", "time of day="..tostring(timeofday).."/sleep_start_time="..tostring(self.sleep_start_time).."/sleep_end_time="..tostring(self.sleep_end_time))
		if (self.status ~= "sleep") and (timeofday > sleep_start_time and timeofday < sleep_end_time) then
			--minetest.chat_send_player("singleplayer", "prueba")
			petz.sleep(self, prty, false)
		end
	end
end

petz.sleep = function(self, prty, force)
	self.status = mobkit.remember(self, "status", "sleep")
	mobkit.animate(self, 'sleep')
	local texture = self.textures[self.texture_no]
	self.object:set_properties(self, {textures = {texture.."^petz_"..self.type.."_sleep.png"}}) --sleeping eyes
	mobkit.hq_sleep(self, prty, force)
end

function mobkit.hq_sleep(self, prty, force)
	local timer = 2
	local func=function(self)
		timer = timer - self.dtime
		if timer <  0 then
			if not(force) then
				local timeofday = minetest.get_timeofday() * 24000
				local sleep_start_time = self.sleep_start_time
				local sleep_end_time = self.sleep_end_time
				if self.sleep_at_night then
					if timeofday > 19500 then
						sleep_end_time = 23999
					elseif timeofday < 4500 then
						sleep_start_time = 0
					end
				end
				if (self.status == "sleep") and timer < 0 --check if status did not change
					and (self.sleep_at_night and not(petz.is_night())) or (self.sleep_at_day and petz.is_night())
					or (timeofday < sleep_start_time) or (timeofday > sleep_end_time) then
						mobkit.clear_queue_high(self) --awake
						local texture = self.textures[self.texture_no]
						self.object:set_properties(self, {textures = {texture}}) --quit sleeping eyes
						self.status = mobkit.remember(self, "status", nil)
						return true
				else
					petz.do_particles_effect(self.object, self.object:get_pos(), "sleep")
				end
			else
				petz.do_particles_effect(self.object, self.object:get_pos(), "sleep")
			end
			timer = 2
		end
	end
	mobkit.queue_high(self,func,prty)
end
